/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

data "azurerm_client_config" "current" {}

resource "random_id" "key_vault_suffix" {
  byte_length = 4
}

resource "azurerm_key_vault" "federation" {
  enable_rbac_authorization  = true
  location                   = var.resource_group.location
  name                       = "${var.resource_name_prefix}-aks-${random_id.key_vault_suffix.hex}"
  resource_group_name        = var.resource_group.name
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  tags                       = var.common_tags
  tenant_id                  = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_role_assignment" "terraform_client" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.federation.id
}

