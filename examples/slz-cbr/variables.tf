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
