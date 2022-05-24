/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "aks_1_principal_id" {
  description = "AKS principal ID"
  type        = string
}

variable "aks_2_principal_id" {
  description = "AKS principal ID"
  type        = string
}

variable "vnet_id" {
  description = "Azure vnet ID"
  type        = string
}

