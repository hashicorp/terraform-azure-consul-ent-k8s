/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "resource_group" {
  value = {
    id       = azurerm_resource_group.aks.id
    location = azurerm_resource_group.aks.location
    name     = azurerm_resource_group.aks.name
  }
}

output "aks_subnet_id_1" {
  value = azurerm_subnet.aks_1.id
}

output "aks_subnet_id_2" {
  value = azurerm_subnet.aks_2.id
}

output "vnet_id" {
  value = azurerm_virtual_network.aks.id
}
