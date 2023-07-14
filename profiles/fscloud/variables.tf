variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
}

variable "region" {
  description = "Name of the Region to deploy into"
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

variable "existing_access_tags" {
  type        = list(string)
  description = "Optional list of existing access tags to be added https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create"
  # Provide the access tags with key:value format in a list
  default = ["env:dev"]
}

variable "zone_service_ref_list" {
  type        = list(string)
  default     = ["cloud-object-storage", "is"]
  description = "(List) Service reference for the zone creation"
}

variable "zone_vpc_crn_list" {
  type        = list(string)
  default     = []
  description = "(List) VPC CRN for the zones"
}

variable "enforcement_mode"{
  type = string
  default = "report"
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

variable "allow_at_to_cos" {
  type        = bool
  description = "Set rule for Activity Tracker to COS, deafult is true"
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
