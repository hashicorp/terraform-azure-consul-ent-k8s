/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "aks_1_name" {
  value = module.aks_1.aks_name
}

output "aks_2_name" {
  value = module.aks_2.aks_name
}

output "aks_1_nodepool_name" {
  value = module.aks_1.nodepool_name
}

output "aks_2_nodepool_name" {
  value = module.aks_2.nodepool_name
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "resource_group_name" {
  value = var.resource_group == null ? azurerm_resource_group.aks[0].name : var.resource_group.name
}

