variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "test-terraform-multiservice"
}

variable "region" {
  description = "Name of the Region to deploy into"
  type        = string
  default     = "us-south"
}

variable "location" {
  description = "The region in which the network zone is scoped"
  type        = string
  default     = "dal" # dal metro is the equivalent location for the us-south region
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
  type        = list(string)
  default     = ["cloud-object-storage", "server-protect"]
  description = "(List) Service reference for the zone creation"
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
