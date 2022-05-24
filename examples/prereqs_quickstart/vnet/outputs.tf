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
