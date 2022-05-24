/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

data "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
  token                  = data.azurerm_kubernetes_cluster.cluster.kube_config.0.password
}

resource "kubernetes_namespace" "consul" {
  metadata {
    name = var.kubernetes_namespace
  }
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
    token                  = data.azurerm_kubernetes_cluster.cluster.kube_config.0.password
  }
}

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
  token                  = data.azurerm_kubernetes_cluster.cluster.kube_config.0.password
  load_config_file       = false
}

module "helm_install" {
  source = "./modules/helm_install"

  azure_key_vault_id          = var.azure_key_vault_id
  azure_key_vault_name        = var.azure_key_vault_name
  azure_key_vault_secret_name = var.azure_key_vault_secret_name
  chart_name                  = var.chart_name
  chart_repository            = var.chart_repository
  consul_helm_chart_version   = var.consul_helm_chart_version
  consul_license              = var.consul_license
  consul_namespace            = var.consul_namespace
  consul_version              = var.consul_version
  create_namespace            = var.create_namespace
  kubernetes_namespace        = var.kubernetes_namespace
  primary_datacenter          = var.primary_datacenter
  release_name                = var.release_name
  resource_group_name         = var.resource_group_name
  server_replicas             = var.server_replicas

  depends_on = [
    kubernetes_namespace.consul
  ]
}
