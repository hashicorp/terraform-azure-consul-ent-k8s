/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "vnet" {
  source = "./vnet/"

  address_space        = var.address_space
  aks_address_prefix_1 = var.aks_address_prefix_1
  aks_address_prefix_2 = var.aks_address_prefix_2
  common_tags          = var.common_tags
  location             = var.location
  resource_name_prefix = var.resource_name_prefix
}

module "key_vault" {
  source = "./key_vault/"

  common_tags          = var.common_tags
  location             = module.vnet.resource_group.location
  resource_group_name  = module.vnet.resource_group.name
  resource_name_prefix = var.resource_name_prefix

  depends_on = [
    # vnet module creates a resource group that key_vault depends on
    module.vnet,
  ]
}

module "aks_1" {
  source = "./aks/"

  aks_subnet_id       = module.vnet.aks_subnet_id_1
  cluster_name        = var.aks_1_cluster_name
  location            = module.vnet.resource_group.location
  resource_group_name = module.vnet.resource_group.name
  common_tags         = var.common_tags

  depends_on = [
    # vnet module creates a resources that aks depends on
    module.vnet,
  ]
}

module "aks_2" {
  source = "./aks/"

  aks_subnet_id       = module.vnet.aks_subnet_id_2
  cluster_name        = var.aks_2_cluster_name
  location            = module.vnet.resource_group.location
  resource_group_name = module.vnet.resource_group.name
  common_tags         = var.common_tags

  depends_on = [
    # vnet module creates a resources that aks depends on
    module.vnet,
  ]
}

module "role_assignments" {
  source = "./role_assignments/"

  aks_1_principal_id = module.aks_1.aks_principal_id
  aks_2_principal_id = module.aks_2.aks_principal_id
  vnet_id            = module.vnet.vnet_id

  depends_on = [
    module.vnet,
    module.aks_1,
    module.aks_2,
  ]
}
