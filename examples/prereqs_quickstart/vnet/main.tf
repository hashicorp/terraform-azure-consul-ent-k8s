resource "azurerm_resource_group" "aks" {
  location = var.location
  name     = "${var.resource_name_prefix}-aks"
  tags     = var.common_tags
}

resource "azurerm_virtual_network" "aks" {
  location            = azurerm_resource_group.aks.location
  name                = "${var.resource_name_prefix}-aks"
  resource_group_name = azurerm_resource_group.aks.name
  tags                = var.common_tags

  address_space = [
    var.address_space,
  ]
}

resource "azurerm_subnet" "aks_1" {
  name                 = "${var.resource_name_prefix}-aks-1"
  resource_group_name  = azurerm_resource_group.aks.name
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
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = [
    var.aks_address_prefix_2,
  ]

  service_endpoints = [
    "Microsoft.KeyVault",
  ]
}
