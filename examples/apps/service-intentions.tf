resource "kubernetes_manifest" "serviceintentions_consul_dashboard" {
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceIntentions"
    "metadata" = {
      "name"      = "dashboard"
      "namespace" = var.kubernetes_namespace
    }
    "spec" = {
      "destination" = {
        "name" = "counting"
      }
      "sources" = [
        {
          "name" = "dashboard"
          "permissions" = [
            {
              "action" = "allow"
              "http" = {
                "methods" = [
                  "GET",
                ]
                "pathPrefix" = "/"
              }
            },
          ]
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "serviceintentions_consul_counting" {
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceIntentions"
    "metadata" = {
      "name"      = "counting"
      "namespace" = var.kubernetes_namespace
    }
    "spec" = {
      "destination" = {
        "name" = "dashboard"
      }
      "sources" = [
        {
          "name" = "counting"
          "permissions" = [
            {
              "action" = "allow"
              "http" = {
                "methods" = [
                  "GET",
                ]
                "pathPrefix" = "/"
              }
            },
          ]
        },
      ]
    }
  }
}
