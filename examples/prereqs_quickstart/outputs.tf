output "aks_1_name" {
  value = module.aks_1.aks_name
}

output "aks_2_name" {
  value = module.aks_2.aks_name
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "resource_group_name" {
  value = module.vnet.resource_group.name
}

