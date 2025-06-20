##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  default     = null
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-0205-cos. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

##############################################################################
# Cabin IAM Access Group Name
##############################################################################

variable "cabin_service_id_access_group" {
  description = "The name of the service id access group for the cabin.  Format: <cabin-name>_service_id where <cabin-name> is from the cabin config 'cabin_data.name'"
  type        = string
  default     = null
}

##############################################################################
# Zone Related Input Variable
##############################################################################

variable "cbr_zones" {
  description = "Map of CBR zones to be created. Key is a unique zone identifier. These zones are referenced by `zone_keys` inside `cbr_rules` to explicitly control which zones apply to which rules. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/solutions/basic/DA-complex-input-variables.md)"
  type = map(object({
    account_id       = optional(string, null)
    name             = string
    zone_description = optional(string, null)
    addresses = optional(list(object({
      type  = optional(string)
      value = optional(string)
      ref = optional(object({
        account_id       = optional(string)
        location         = optional(string)
        service_instance = optional(string)
        service_name     = optional(string)
        service_type     = optional(string)
      }))
    })), [])
    excluded_addresses = optional(list(object({
      type  = optional(string)
      value = optional(string)
    })), [])
    use_existing_cbr_zone = optional(bool, false)
    existing_zone_id      = optional(string, null)
  }))
  default = {}
  # Validation happens in the rule module
}

##############################################################################
# Rule Related Input Variable
##############################################################################

variable "cbr_rules" {
  description = "Map of CBR rules to be created. Each rule includes mapping to zone keys. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/solutions/basic/DA-complex-input-variables.md)"
  type = map(object({
    rule_description = optional(string, null)
    rule_contexts = optional(list(object({
      attributes = optional(list(object({
        name  = string
        value = string
      })))
    })), [])
    enforcement_mode = optional(string, "report")
    resources = list(object({
      attributes = optional(list(object({
        name     = string
        value    = string
        operator = optional(string)
      })))
      tags = optional(list(object({
        name     = string
        value    = string
        operator = optional(string)
      })))
    }))
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
      })), [
      {
        api_types = [
          {
            api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
          }
        ]
      }
    ])
    zone_keys = list(string)
  }))
  default = {}
  # Validation happens in the rule module
}
