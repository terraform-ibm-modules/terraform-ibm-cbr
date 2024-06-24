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

variable "zone_service_ref_list" {
  type = map(object({
    serviceRef_location = optional(list(string), [])
  }))
  description = "Provide a valid service reference with the location where the context-based restriction zones are created. If no value is specified for `serviceRef_location`, the zones are not scoped to any location."
  default = {
    "cloud-object-storage" = {
      serviceRef_location = ["syd", "au"]
    },
    "server-protect" = {
      serviceRef_location = ["au"]
    },
    "directlink"          = {}, # directlink does not support restriction per location, hence no value is specified for serviceRef_location.
    "event-notifications" = {}
  }
}


variable "endpoints" {
  type        = list(string)
  description = "List specific endpoint types for target services, valid values for endpoints are 'public', 'private' or 'direct'"
  default     = ["private"]
  validation {
    condition = alltrue([
      for endpoint in var.endpoints : can(regex("^(public|private|direct)$", endpoint))
    ])
    error_message = "Valid values for endpoints are 'public', 'private' or 'direct'"
  }
}
