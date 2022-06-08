/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

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
  description = "(Optional) The location/region to create the resource group (if one is not provided)"
  type        = string
}

variable "resource_group" {
  default     = null
  description = "(Optional) Azure resource group in which resources will be deployed; omit to create one"

  type = object({
    location = string
    name     = string
  })
}

variable "resource_name_prefix" {
  description = "Prefix for resource names (e.g. \"prod\")"
  type        = string

  # azurerm_key_vault name must not exceed 24 characters and has this as a prefix
  validation {
    condition     = length(var.resource_name_prefix) < 12 && (replace(var.resource_name_prefix, " ", "") == var.resource_name_prefix)
    error_message = "The resource_name_prefix value must be fewer than 12 characters and may not contain spaces."
  }
}
