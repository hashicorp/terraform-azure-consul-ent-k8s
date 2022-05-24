variable "aks_subnet_id" {
  description = "Subnet ID AKS nodes will go into"
  type        = string
}

variable "cluster_name" {
  description = "Name of AKS cluster"
  type        = string
}

variable "common_tags" {
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "location" {
  description = "The location/region where the virtual network is created"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}
