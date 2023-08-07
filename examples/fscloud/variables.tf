variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all vpc_zone_list, service_ref_zone_list and cbr_rule_description created by this submodule"
  default     = "fs"
}

variable "region" {
  description = "Name of the region to deploy into"
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "allow_cos_to_kms" {
  type        = bool
  description = "Set rule for COS to KMS, deafult is true"
  default     = true
}

variable "allow_block_storage_to_kms" {
  type        = bool
  description = "Set rule for block storage to KMS, deafult is true"
  default     = true
}

variable "allow_roks_to_kms" {
  type        = bool
  description = "Set rule for ROKS to KMS, deafult is true"
  default     = true
}

variable "allow_vpcs_to_container_registry" {
  type        = bool
  description = "Set rule for VPCs to container registry, deafult is true"
  default     = true
}

variable "allow_vpcs_to_cos" {
  type        = bool
  description = "Set rule for VPCs to COS, deafult is true"
  default     = true
}
