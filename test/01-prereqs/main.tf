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

module "quickstart" {
  source = "../../examples/prereqs_quickstart"

  resource_group       = var.resource_group
  resource_name_prefix = var.resource_name_prefix
  aks_1_cluster_name   = "${var.resource_name_prefix}-consul-primary"
  aks_2_cluster_name   = "${var.resource_name_prefix}-consul-secondary"
}
output "resource_group_name" {
  value = module.quickstart.resource_group_name
}
output "primary_cluster_name" {
  value = module.quickstart.aks_1_name
}
output "primary_cluster_nodepool_name" {
  value = module.quickstart.aks_1_nodepool_name
}
output "secondary_cluster_name" {
  value = module.quickstart.aks_2_name
}
output "secondary_cluster_nodepool_name" {
  value = module.quickstart.aks_2_nodepool_name
}
output "key_vault_id" {
  value = module.quickstart.key_vault_id
}
output "key_vault_name" {
  value = module.quickstart.key_vault_name
}
