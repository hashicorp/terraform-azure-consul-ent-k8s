/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

resource "azurerm_virtual_network" "aks" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-aks"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags

  address_space = [
    var.address_space,
  ]
}

resource "azurerm_subnet" "aks_1" {
  name                 = "${var.resource_name_prefix}-aks-1"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = [
    var.aks_address_prefix_1,
  ]

  service_endpoints = [
    "Microsoft.KeyVault",
  ]
}

resource "azurerm_subnet" "aks_2" {
  name                 = "${var.resource_name_prefix}-aks-2"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = [
    var.aks_address_prefix_2,
  ]

  service_endpoints = [
    "Microsoft.KeyVault",
  ]
}
