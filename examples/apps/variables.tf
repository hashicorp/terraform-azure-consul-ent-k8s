variable "cluster_name" {
  type        = string
  description = "Name of AKS cluster"
}


variable "kubernetes_namespace" {
  type        = string
  default     = "consul"
  description = "The namespace to install Consul/k8s components in"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

