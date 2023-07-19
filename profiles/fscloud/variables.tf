variable "resource_group_id" {
  type        = string
  description = "The resource group ID where the instance will be created."
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all vpc_zone_list, service_ref_zone_list and cbr_rule_description created by this submodule"
}

variable "existing_access_tags" {
  type        = list(string)
  description = "Optional list of existing access tags to be added https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create, Provide the access tags with key:value format in a list"
}

variable "zone_vpc_crn_list" {
  type        = list(string)
  description = "(List) VPC CRN for the zones"
}

variable "enforcement_mode" {
  type        = string
  default     = "enabled"
  description = "The rule enforcement mode on a rule upon creation. Allowable values are: enabled, disabled, report."
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
