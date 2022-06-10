/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "aks_principal_id" {
  value = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.cluster.name
}

output "nodepool_name" {
  value = azurerm_kubernetes_cluster_node_pool.cluster.name
}
