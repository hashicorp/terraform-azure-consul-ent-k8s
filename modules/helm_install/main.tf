/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

resource "helm_release" "consul_primary" {
  count            = var.primary_datacenter ? 1 : 0
  chart            = var.chart_name
  create_namespace = var.create_namespace
  name             = var.release_name
  namespace        = var.kubernetes_namespace
  repository       = var.chart_repository
  timeout          = 900
  version          = var.consul_helm_chart_version

  values = [
    templatefile("${path.module}/templates/values-dc1.yaml", {
      consul_version  = var.consul_version
      server_replicas = var.server_replicas
      }
    )
  ]
}

resource "helm_release" "consul_secondary" {
  count            = var.primary_datacenter ? 0 : 1
  chart            = var.chart_name
  create_namespace = var.create_namespace
  name             = var.release_name
  namespace        = var.kubernetes_namespace
  repository       = var.chart_repository
  timeout          = 900
  version          = var.consul_helm_chart_version

  values = [
    templatefile("${path.module}/templates/values-dc2.yaml", {
      consul_version  = var.consul_version
      server_replicas = var.server_replicas
      }
    )
  ]
  depends_on = [kubernetes_secret.federation_secret[0]]
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_secret" "federation" {
  count        = var.primary_datacenter ? 1 : 0
  name         = var.azure_key_vault_secret_name
  key_vault_id = var.azure_key_vault_id
  value        = jsonencode(data.kubernetes_secret.federation_secret[0].data)
}

resource "kubernetes_secret" "consul_license" {
  metadata {
    name      = "consul-ent-license"
    namespace = var.kubernetes_namespace
  }

  data = {
    "key" = var.consul_license
  }
}

data "kubernetes_secret" "federation_secret" {
  count = var.primary_datacenter ? 1 : 0
  metadata {
    name      = "consul-federation"
    namespace = var.kubernetes_namespace
  }

  depends_on = [helm_release.consul_primary[0]]
}

data "azurerm_key_vault" "federation" {
  count               = var.primary_datacenter ? 0 : 1
  name                = var.azure_key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "federation" {
  count        = var.primary_datacenter ? 0 : 1
  name         = var.azure_key_vault_secret_name
  key_vault_id = data.azurerm_key_vault.federation[0].id
}

resource "kubernetes_secret" "federation_secret" {
  count = var.primary_datacenter ? 0 : 1
  metadata {
    name      = "consul-federation"
    namespace = var.kubernetes_namespace
  }

  data = jsondecode(data.azurerm_key_vault_secret.federation[0].value)
  depends_on = [
    data.azurerm_key_vault_secret.federation[0]
  ]
}

resource "kubectl_manifest" "proxy_defaults" {
  count     = var.primary_datacenter ? 1 : 0
  yaml_body = <<YAML
apiVersion: consul.hashicorp.com/v1alpha1
kind: ProxyDefaults
metadata:
  name: global
  namespace: "${var.kubernetes_namespace}"
spec:
  meshGateway:
    mode: 'local'
YAML

  depends_on = [helm_release.consul_primary[0]]
}
