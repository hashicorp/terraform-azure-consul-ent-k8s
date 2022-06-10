/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

terraform {
  cloud {
    organization = "hc-tfc-dev"

    workspaces {
      tags = [
        "integrationtest",
      ]
    }
  }
}

provider "azurerm" {
  features {}
}

module "consul" {
  source = "../../"

  azure_key_vault_id   = var.key_vault_id
  azure_key_vault_name = var.key_vault_name
  consul_license       = var.consul_license
  cluster_name         = var.cluster_name
  primary_datacenter   = true
  resource_group_name  = var.resource_group_name
}
