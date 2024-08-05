variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  description = "Name of the region to deploy into"
  type        = string
  default     = "us-south"
}

variable "provision_cbr" {
  type        = bool
  description = "Whether to enable the creation of context-based restriction rules and zones in the module. Default is false."
  default     = true
}

variable "cbr_prefix" {
  type        = string
  description = "String to use as the prefix for all context-based restriction resources, default is `account-infra-base` if `provision_cbr` is set to true."
  default     = "slz"
}

variable "cbr_allow_cos_to_kms" {
  type        = bool
  description = "Whether to enable the rule that allows Object Storage to access the key management service. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_block_storage_to_kms" {
  type        = bool
  description = "Whether to enable the rule that allows Block Storage for VPC to access the key management service. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_roks_to_kms" {
  type        = bool
  description = "Whether to enable the rule that allows Red Hat OpenShift to access the key management service. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_icd_to_kms" {
  type        = bool
  description = "Whether to enable the rule that allows IBM cloud databases to access the key management service. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_event_streams_to_kms" {
  type        = bool
  description = "Whether to enable the rule that allows Event Streams to access the key management service. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_vpcs_to_container_registry" {
  type        = bool
  description = "Whether to enable the rule that allows Virtual Private Clouds to access Container Registry. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_vpcs_to_cos" {
  type        = bool
  description = "Whether to enable the rule that allows Virtual Private Clouds to access Object Storage. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_at_to_cos" {
  type        = bool
  description = "Whether to enable the rule that allows Activity Tracker to access Object Storage. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_iks_to_is" {
  type        = bool
  description = "Whether to enable the rule that allows the Kubernetes Service to access VPC Infrastructure Services. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_allow_is_to_cos" {
  type        = bool
  description = "Whether to enable the rule that allows VPC Infrastructure Services to access Object Storage. Default is true if `provision_cbr` is set to true."
  default     = true
}

variable "cbr_kms_service_targeted_by_prewired_rules" {
  type        = list(string)
  description = "IBM Cloud offers two distinct Key Management Services (KMS): Key Protect and Hyper Protect Crypto Services (HPCS). This variable determines the specific KMS service to which the pre-configured rules are applied. Use the value 'key-protect' to specify the Key Protect service, and 'hs-crypto' for the Hyper Protect Crypto Services (HPCS). Default is `[\"hs-crypto\"]` if `provision_cbr` is set to true."
  default     = ["hs-crypto"]
}


