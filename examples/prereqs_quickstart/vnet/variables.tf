variable "address_space" {
  description = "Virtual Network address space"
  type        = string
}

variable "aks_address_prefix_1" {
  description = "VM Virtual Network subnet address prefix"
  type        = string
}

variable "aks_address_prefix_2" {
  description = "VM Virtual Network subnet address prefix"
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

variable "resource_name_prefix" {
  description = "Prefix for resource names (e.g. \"prod\")"
  type        = string
}

