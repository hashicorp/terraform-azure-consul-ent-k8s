output "aks_principal_id" {
  value = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.cluster.name
}

