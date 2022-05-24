# Role assignment to be able to manage the virtual network
resource "azurerm_role_assignment" "aks_vnet_contributor_aks1" {
  scope                            = var.vnet_id
  role_definition_name             = "Network Contributor"
  principal_id                     = var.aks_1_principal_id
  skip_service_principal_aad_check = true
}

# Role assignment to be able to manage the virtual network
resource "azurerm_role_assignment" "aks_vnet_contributor_aks2" {
  scope                            = var.vnet_id
  role_definition_name             = "Network Contributor"
  principal_id                     = var.aks_2_principal_id
  skip_service_principal_aad_check = true
}

