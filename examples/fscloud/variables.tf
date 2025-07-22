variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all vpc_zone_list, zone_service_ref_list and cbr_rule_description created by this submodule"
}

variable "region" {
  description = "Name of the region to deploy into"
  type        = string
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

variable "enable_appconfig_aggregator_flows" {
  description = "Map of bools to enable/disable AppConfig flows per service."
  type        = map(bool)
  default = {
    cloud-object-storage = true
    is                   = true
    secrets-manager      = true
    container-registry   = true
    codeengine           = true
    messagehub           = true
    toolchain            = true
    cloudantnosqldb      = true
    schematics           = true
    sysdig-monitor       = true
    compliance           = true
    hs-crypto            = true
    appid                = true
    apprapp              = true
    event-notifications  = true
    logs                 = true
  }
}
