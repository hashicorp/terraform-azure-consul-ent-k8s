/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

terraform {
  cloud {
    organization = "hc-tfc-dev"

    workspaces {
      tags = [
        "integrationtest",
      ]
    }
  }

  required_providers {
    testingtoolsk8s = {
      source  = "app.terraform.io/hc-tfc-dev/testingtoolsk8s"
      version = "~> 0.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

provider "testingtoolsk8s" {
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
  token                  = data.azurerm_kubernetes_cluster.cluster.kube_config.0.password
}

resource "testingtoolsk8s_exec" "consul_wan_members" {
  namespace = "consul"
  pod       = "consul-server-4"

  command = [
    "consul",
    "members",
    "-wan",
  ]
}

output "consul_wan_members" {
  value = testingtoolsk8s_exec.consul_wan_members.stdout
}

data "azurerm_kubernetes_cluster_node_pool" "cluster" {
  name                    = var.node_pool_name
  kubernetes_cluster_name = var.cluster_name
  resource_group_name     = var.resource_group_name
}

output "node_pool_availability_zones" {
  value = join(",", sort(data.azurerm_kubernetes_cluster_node_pool.cluster.zones))
}
