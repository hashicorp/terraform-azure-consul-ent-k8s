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

resource "azurerm_resource_group" "aks" {
  count = var.resource_group == null ? 1 : 0

  location = var.location
  name     = "${var.resource_name_prefix}-aks"
  tags     = var.common_tags
}

locals {
  resource_group = var.resource_group == null ? { location = azurerm_resource_group.aks[0].location, name = azurerm_resource_group.aks[0].name } : var.resource_group
}

module "vnet" {
  source = "./vnet/"

  address_space        = var.address_space
  aks_address_prefix_1 = var.aks_address_prefix_1
  aks_address_prefix_2 = var.aks_address_prefix_2
  common_tags          = var.common_tags
  resource_group       = local.resource_group
  resource_name_prefix = var.resource_name_prefix
}

module "key_vault" {
  source = "./key_vault/"

  common_tags          = var.common_tags
  resource_group       = local.resource_group
  resource_name_prefix = var.resource_name_prefix
}

module "aks_1" {
  source = "./aks/"

  aks_subnet_id  = module.vnet.aks_subnet_id_1
  cluster_name   = var.aks_1_cluster_name
  common_tags    = var.common_tags
  resource_group = local.resource_group

  depends_on = [
    # vnet module creates additional network resources that aks depends on
    module.vnet,
  ]
}

module "aks_2" {
  source = "./aks/"

  aks_subnet_id  = module.vnet.aks_subnet_id_2
  cluster_name   = var.aks_2_cluster_name
  common_tags    = var.common_tags
  resource_group = local.resource_group

  depends_on = [
    # vnet module creates additional network resources that aks depends on
    module.vnet,
  ]
}

module "role_assignments" {
  source = "./role_assignments/"

  aks_1_principal_id = module.aks_1.aks_principal_id
  aks_2_principal_id = module.aks_2.aks_principal_id
  vnet_id            = module.vnet.vnet_id
}
