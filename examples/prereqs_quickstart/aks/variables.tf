/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

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

variable "resource_group" {
  description = "Azure resource group in which resources will be deployed"

  type = object({
    location = string
    name     = string
  })
}
