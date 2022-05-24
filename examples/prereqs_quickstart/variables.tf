variable "address_space" {
  default     = "172.16.0.0/12"
  description = "Virtual Network address space"
  type        = string
}

variable "aks_address_prefix_1" {
  default     = "172.16.1.0/24"
  description = "VM Virtual Network subnet address prefix"
  type        = string
}

variable "aks_address_prefix_2" {
  default     = "172.16.2.0/24"
  description = "VM Virtual Network subnet address prefix"
  type        = string
}

variable "aks_1_cluster_name" {
  description = "Name of first AKS cluster"
  type        = string
}

variable "aks_2_cluster_name" {
  description = "Name of second AKS cluster"
  type        = string
}

variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "location" {
  default     = "East US"
  description = "The location/region where the virtual network is created"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for resource names (e.g. \"prod\")"
  type        = string
}
