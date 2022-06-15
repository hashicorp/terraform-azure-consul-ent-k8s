// Copyright © 2014-2022 HashiCorp, Inc.
//
// This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
//

package test

import (
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var tfcOrg string = "hc-tfc-dev"
var repoName string = "terraform-azure-consul-ent-k8s"

func TestClusterDeployment(t *testing.T) {
	var deployEnv string

	cwdPath, err := os.Getwd()
	if err != nil {
		logger.Log(t, "Unable to get current working directory")
		t.FailNow()
	}

	// TFC API token will be needed to update workspaces
	tfcToken := getTfeToken(t)
	if tfcToken == "" {
		t.FailNow()
	}

	var consulLicense string
	licenseLocation := filepath.Join(cwdPath, "consul.hclic")
	if os.Getenv("TEST_CONSUL_ENT_LICENSE") != "" {
		consulLicense = strings.TrimSuffix(os.Getenv("TEST_CONSUL_ENT_LICENSE"), "\n")
	} else {
		if _, err := os.Stat(licenseLocation); errors.Is(err, os.ErrNotExist) {
			logger.Log(t, "Consul license needs to be in place, or in the TEST_CONSUL_ENT_LICENSE environment variable")
			t.FailNow()
		} else {
			consulLicenseBytes, err := ioutil.ReadFile(licenseLocation)
			if err != nil {
				logger.Log(t, "Error reading Consul license")
				t.FailNow()
			}
			consulLicense = strings.TrimSuffix(string(consulLicenseBytes), "\n")
		}
	}

	if os.Getenv("DEPLOY_ENV") != "" {
		deployEnv = os.Getenv("DEPLOY_ENV")
	} else {
		if runtime.GOOS == "windows" {
			deployEnv = "test" + os.Getenv("USERNAME")
		} else {
			deployEnv = "test" + os.Getenv("USER")
		}
	}
	if len(deployEnv) > 11 {
		logger.Log(t, fmt.Sprintf("The chosen or autoconfigured resource name prefix (%s) exceeds 11 characters. Choose a new one by setting it as an environment variable -- e.g. export DEPLOY_ENV='%s'", deployEnv, deployEnv[0:11]))
		t.FailNow()
	}

	// Cleanup any characters that will cause problems in resource & workspace names
	deployEnv = strings.Replace(deployEnv, ".", "", -1)
	baseWorkspaceName := repoName + "-" + deployEnv

	// Run prereqs module, and setup its destruction during CI
	// (non-CI destruction is conditionally configured after tests below)
	prereqsModulePath := filepath.Join(cwdPath, "01-prereqs")
	prereqsTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{TerraformDir: prereqsModulePath, Lock: true})
	prereqsWorkspaceName := baseWorkspaceName + "-" + filepath.Base(prereqsModulePath)
	removeAutoTfvars(t, prereqsModulePath)
	prereqsTfVars := fmt.Sprintf("resource_name_prefix = \"%s\"\n", deployEnv)
	if os.Getenv("TEST_RESOURCE_GROUP_LOCATION") != "" && os.Getenv("TEST_RESOURCE_GROUP_NAME") != "" {
		prereqsTfVars = prereqsTfVars + fmt.Sprintf("resource_group = {location = \"%s\", name = \"%s\"}\n", os.Getenv("TEST_RESOURCE_GROUP_LOCATION"), os.Getenv("TEST_RESOURCE_GROUP_NAME"))
	}
	ioutil.WriteFile(filepath.Join(prereqsModulePath, deployEnv+".auto.tfvars"), []byte(prereqsTfVars), 0644)
	if os.Getenv("GITHUB_ACTIONS") != "" {
		defer tfDestroyAndDeleteWorkspaceWithRetries(t, prereqsTerraformOptions, tfcOrg, tfcToken, prereqsWorkspaceName, 3)
	}
	createTfcWorkspace(t, tfcOrg, tfcToken, prereqsWorkspaceName)
	os.Setenv("TF_WORKSPACE", prereqsWorkspaceName)
	terraform.Init(t, prereqsTerraformOptions)
	if os.Getenv("GITHUB_ACTIONS") == "" {
		writeWorkspaceNameToTfDir(prereqsModulePath, prereqsWorkspaceName)
	}
	terraform.ApplyAndIdempotent(t, prereqsTerraformOptions)
	// Gather prereqs outputs
	resourceGroupName := terraform.Output(t, prereqsTerraformOptions, "resource_group_name")
	primaryClusterName := terraform.Output(t, prereqsTerraformOptions, "primary_cluster_name")
	secondaryClusterName := terraform.Output(t, prereqsTerraformOptions, "secondary_cluster_name")
	keyVaultId := terraform.Output(t, prereqsTerraformOptions, "key_vault_id")
	keyVaultName := terraform.Output(t, prereqsTerraformOptions, "key_vault_name")
	primaryClusterNodePoolName := terraform.Output(t, prereqsTerraformOptions, "primary_cluster_nodepool_name")

	// Run primary module, and setup its destruction during CI
	// (non-CI destruction is conditionally configured after tests below)
	primaryModulePath := filepath.Join(cwdPath, "02-primary")
	primaryTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{TerraformDir: primaryModulePath, Lock: true})
	primaryWorkspaceName := baseWorkspaceName + "-" + filepath.Base(primaryModulePath)
	removeAutoTfvars(t, primaryModulePath)
	primaryTfVars := fmt.Sprintf("consul_license       = \"%s\"\ncluster_name         = \"%s\"\nkey_vault_id = \"%s\"\nkey_vault_name      = \"%s\"\nresource_group_name = \"%s\"\n", consulLicense, primaryClusterName, keyVaultId, keyVaultName, resourceGroupName)
	ioutil.WriteFile(filepath.Join(primaryModulePath, deployEnv+".auto.tfvars"), []byte(primaryTfVars), 0644)
	if os.Getenv("GITHUB_ACTIONS") != "" {
		defer tfDestroyAndDeleteWorkspace(t, primaryTerraformOptions, tfcOrg, tfcToken, primaryWorkspaceName)
	}
	createTfcWorkspace(t, tfcOrg, tfcToken, primaryWorkspaceName)
	os.Setenv("TF_WORKSPACE", primaryWorkspaceName)
	terraform.Init(t, primaryTerraformOptions)
	if os.Getenv("GITHUB_ACTIONS") == "" {
		writeWorkspaceNameToTfDir(primaryModulePath, primaryWorkspaceName)
	}
	terraform.ApplyAndIdempotent(t, primaryTerraformOptions)

	// Run secondary module, and setup its destruction during CI
	// (non-CI destruction is conditionally configured after tests below)
	secondaryModulePath := filepath.Join(cwdPath, "03-secondary")
	secondaryTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{TerraformDir: secondaryModulePath, Lock: true})
	secondaryWorkspaceName := baseWorkspaceName + "-" + filepath.Base(secondaryModulePath)
	removeAutoTfvars(t, secondaryModulePath)
	secondaryTfVars := fmt.Sprintf("consul_license     = \"%s\"\ncluster_name       = \"%s\"\nkey_vault_id               = \"%s\"\nkey_vault_name      = \"%s\"\nresource_group_name = \"%s\"\n", consulLicense, secondaryClusterName, keyVaultId, keyVaultName, resourceGroupName)
	ioutil.WriteFile(filepath.Join(secondaryModulePath, deployEnv+".auto.tfvars"), []byte(secondaryTfVars), 0644)
	if os.Getenv("GITHUB_ACTIONS") != "" {
		defer tfDestroyAndDeleteWorkspace(t, secondaryTerraformOptions, tfcOrg, tfcToken, secondaryWorkspaceName)
	}
	createTfcWorkspace(t, tfcOrg, tfcToken, secondaryWorkspaceName)
	os.Setenv("TF_WORKSPACE", secondaryWorkspaceName)
	terraform.Init(t, secondaryTerraformOptions)
	if os.Getenv("GITHUB_ACTIONS") == "" {
		writeWorkspaceNameToTfDir(secondaryModulePath, secondaryWorkspaceName)
	}
	terraform.ApplyAndIdempotent(t, secondaryTerraformOptions)

	// Run app primary module, and setup its destruction during CI
	// (non-CI destruction is conditionally configured after tests below)
	appPrimaryModulePath := filepath.Join(cwdPath, "04-app-primary")
	appPrimaryTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{TerraformDir: appPrimaryModulePath, Lock: true})
	appPrimaryWorkspaceName := baseWorkspaceName + "-" + filepath.Base(appPrimaryModulePath)
	removeAutoTfvars(t, appPrimaryModulePath)
	appPrimaryTfVars := fmt.Sprintf("cluster_name        = \"%s\"\nresource_group_name = \"%s\"\n", primaryClusterName, resourceGroupName)
	ioutil.WriteFile(filepath.Join(appPrimaryModulePath, deployEnv+".auto.tfvars"), []byte(appPrimaryTfVars), 0644)
	if os.Getenv("GITHUB_ACTIONS") != "" {
		defer tfDestroyAndDeleteWorkspace(t, appPrimaryTerraformOptions, tfcOrg, tfcToken, appPrimaryWorkspaceName)
	}
	createTfcWorkspace(t, tfcOrg, tfcToken, appPrimaryWorkspaceName)
	os.Setenv("TF_WORKSPACE", appPrimaryWorkspaceName)
	terraform.Init(t, appPrimaryTerraformOptions)
	if os.Getenv("GITHUB_ACTIONS") == "" {
		writeWorkspaceNameToTfDir(appPrimaryModulePath, appPrimaryWorkspaceName)
	}
	terraform.ApplyAndIdempotent(t, appPrimaryTerraformOptions)

	// Run app secondary module, and setup its destruction during CI
	// (non-CI destruction is conditionally configured after tests below)
	appSecondaryModulePath := filepath.Join(cwdPath, "05-app-secondary")
	appSecondaryTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{TerraformDir: appSecondaryModulePath, Lock: true})
	appSecondaryWorkspaceName := baseWorkspaceName + "-" + filepath.Base(appSecondaryModulePath)
	removeAutoTfvars(t, appSecondaryModulePath)
	appSecondaryTfVars := fmt.Sprintf("cluster_name        = \"%s\"\nresource_group_name = \"%s\"\n", secondaryClusterName, resourceGroupName)
	ioutil.WriteFile(filepath.Join(appSecondaryModulePath, deployEnv+".auto.tfvars"), []byte(appSecondaryTfVars), 0644)
	if os.Getenv("GITHUB_ACTIONS") != "" {
		defer tfDestroyAndDeleteWorkspace(t, appSecondaryTerraformOptions, tfcOrg, tfcToken, appSecondaryWorkspaceName)
	}
	createTfcWorkspace(t, tfcOrg, tfcToken, appSecondaryWorkspaceName)
	os.Setenv("TF_WORKSPACE", appSecondaryWorkspaceName)
	terraform.Init(t, appSecondaryTerraformOptions)
	if os.Getenv("GITHUB_ACTIONS") == "" {
		writeWorkspaceNameToTfDir(appSecondaryModulePath, appSecondaryWorkspaceName)
	}
	terraform.ApplyAndIdempotent(t, appSecondaryTerraformOptions)

	// Run validation module, and setup its destruction during CI
	// (non-CI destruction is conditionally configured after tests below)
	validationModulePath := filepath.Join(cwdPath, "06-validation")
	validationTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{TerraformDir: validationModulePath, Lock: true})
	validationWorkspaceName := baseWorkspaceName + "-" + filepath.Base(validationModulePath)
	removeAutoTfvars(t, validationModulePath)
	validationTfVars := fmt.Sprintf("cluster_name        = \"%s\"\nnode_pool_name      = \"%s\"\nresource_group_name = \"%s\"\n", primaryClusterName, primaryClusterNodePoolName, resourceGroupName)
	ioutil.WriteFile(filepath.Join(validationModulePath, deployEnv+".auto.tfvars"), []byte(validationTfVars), 0644)
	if os.Getenv("GITHUB_ACTIONS") != "" {
		defer tfDestroyAndDeleteWorkspace(t, validationTerraformOptions, tfcOrg, tfcToken, validationWorkspaceName)
	}
	createTfcWorkspace(t, tfcOrg, tfcToken, validationWorkspaceName)
	os.Setenv("TF_WORKSPACE", validationWorkspaceName)
	terraform.Init(t, validationTerraformOptions)
	if os.Getenv("GITHUB_ACTIONS") == "" {
		writeWorkspaceNameToTfDir(validationModulePath, validationWorkspaceName)
	}
	terraform.Apply(t, validationTerraformOptions)
	// Gather validation outputs
	consulWanMembers := terraform.Output(t, validationTerraformOptions, "consul_wan_members")
	nodePoolAvailabilityZones := terraform.Output(t, validationTerraformOptions, "node_pool_availability_zones")

	// Perform validation comparisons and collect pass/fail results
	_ = os.Unsetenv("TF_WORKSPACE")
	var testResults []bool

	// Check for the 10 servers
	for _, serverNum := range []string{"0", "1", "2", "3", "4"} {
		for _, dcNum := range []string{"1", "2"} {
			testResults = append(testResults, assert.Contains(t, consulWanMembers, fmt.Sprintf("consul-server-%s.dc%s", serverNum, dcNum)))
		}
	}

	// Ensure Consul node pool is split across availability zones
	testResults = append(testResults, assert.Equal(t, "1,2,3", nodePoolAvailabilityZones))

	// Comparisons complete; conditionally exit
	if os.Getenv("GITHUB_ACTIONS") == "" {
		if anyFalse(testResults) {
			logger.Log(t, "")
			logger.Log(t, "One or more tests failed; skipping terraform destroy")
			logger.Log(t, "You should either:")
			logger.Log(t, "1) Fix the Terraform code and re-run the tests until they pass and automatically invoke terraform destroy, or")
			logger.Log(t, "2) Run terraform destroy \"manually\", i.e. via ./destroy.sh")
			logger.Log(t, "")
		} else {
			if os.Getenv("TEST_DONT_DESTROY_UPON_SUCCESS") == "" {
				logger.Log(t, "")
				logger.Log(t, "All tests passed succesfully; proceeding to destroy root modules in reverse order")
				logger.Log(t, "")
				// Attempt to destroy each Terraform module in reverse
				os.Setenv("TF_WORKSPACE", validationWorkspaceName)
				terraform.Destroy(t, validationTerraformOptions)
				os.Setenv("TF_WORKSPACE", appSecondaryWorkspaceName)
				terraform.Destroy(t, appSecondaryTerraformOptions)
				os.Setenv("TF_WORKSPACE", appPrimaryWorkspaceName)
				terraform.Destroy(t, appPrimaryTerraformOptions)
				os.Setenv("TF_WORKSPACE", secondaryWorkspaceName)
				terraform.Destroy(t, secondaryTerraformOptions)
				os.Setenv("TF_WORKSPACE", primaryWorkspaceName)
				terraform.Destroy(t, primaryTerraformOptions)
				os.Setenv("TF_WORKSPACE", prereqsWorkspaceName)
				// AKS cluster can often fail to delete on first attempt with a
				// "please manually dissociate route table and/or network security group from subnet ... then try to delete managed cluster"
				// error, so destroy is attempted 3 times here before raising an error
				tfDestroyWithRetries(t, prereqsTerraformOptions, 3)
			} else {
				logger.Log(t, "")
				logger.Log(t, "Tests were successful, but skipping terraform destroy because TEST_DONT_DESTROY_UPON_SUCCESS environment variable is set")
				logger.Log(t, "")
			}
		}
	}
}
