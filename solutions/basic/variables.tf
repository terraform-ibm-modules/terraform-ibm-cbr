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

# variable "cabin_service_id_access_group" {
#   description = "The name of the service id access group for the cabin.  Format: <cabin-name>_service_id where <cabin-name> is from the cabin config 'cabin_data.name'"
#   type        = string
#   default     = null
# }

##############################################################################
# Zone Related Input Variable
##############################################################################

variable "cbr_zones" {
  description = <<EOT
  Map of CBR zones to be created. Key is a unique zone identifier.
  These zones are referenced by `zone_keys` inside `cbr_rules` to explicitly control which zones apply to which rules.
  Note: The keys used here must match the values listed under `zone_keys` in the `cbr_rules` input. This design allows flexible, reusable zones that can be bound to one or more rules.

  Example:
  cbr_zones = {
    "vpc_zone" = {
      name        = "VPC Zone"
      account_id  = "12345"
      description = "Allow access from VPC"
      addresses = [
        { type = "vpc",
        value = "...."
        }
      ]
    },
    "zone_2" = {
      name        = "Zone 2"
      account_id  = "12345"
      description = "Allow access from Zone 2"
      addresses = [
        { type = "ipAddress",
        value = "...."
        },
        { type = "subnet",
        value = "...."
        }

      ]
    }
  }
  EOT
  type = map(object({
    # By default account id is populated using data block where the CBR is created, else it can be passed if required
    account_id = optional(string, null)
    name       = string
    # By default, the description is null
    zone_description = optional(string, null)
    # By default, the addresses is empty list
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
    # By default, the excluded_addresses is empty list
    excluded_addresses = optional(list(object({
      type  = optional(string)
      value = optional(string)
    })), [])
    # To update an existing CBR zone using `existing_zone_id`. By default, it is false
    use_existing_cbr_zone = optional(bool, false)
    # By default, it is null
    existing_zone_id = optional(string, null)
  }))
  default = {}
  # Validation happens in the rule module
}

##############################################################################
# Rule Related Input Variable
##############################################################################

# variable "cbr_rules" {
#   description = <<EOT
#   Map of CBR rules to be created. Each rule includes mapping to zone keys.
#   Example:
#   cbr_rules = {
#     "limit_cos_1" = {
#       name             = "Restrict COS Access"
#       description      = "Allow request to COS only from vpc_zone and ip_zone"
#       enforcement_mode = "enabled"
#       zone_keys        = ["vpc_zone", "zone_2"]
#       resources = [
#         {
#           service_name         = "cloud-object-storage"
#           resource_instance_id = "cos-instance-id-1"
#         }
#       ]
#     },
#     "limit_cos_1" = {
#       name             = "Restrict COS Access"
#       description      = "Allow request to COS from vpc_zone only"
#       enforcement_mode = "enabled"
#       zone_keys        = ["vpc_zone"]
#       resources = [
#         {
#           service_name         = "cloud-object-storage"
#           resource_instance_id = "cos-instance-id-2"
#         }
#       ]
#     }
#   }
#   EOT
#   type = map(object({
#     # By default, rule_description is null if not passed
#     rule_description = optional(string)
#     # By default, rule_contexts is empty list if not passed
#     rule_contexts = optional(list(object({
#       attributes = list(object({
#         name  = string
#         value = string
#       }))
#       # check if attributes has to be made optional because it is already optional in variable definiton
#     })))
#     # Valid values for enforcement mode can be 'enabled', 'disabled' and 'report'
#     enforcement_mode = string
#     resources = list(object({
#       attributes = optional(list(object({
#         name     = string
#         value    = string
#         operator = optional(string)
#       })))
#       tags = optional(list(object({
#         name     = string
#         value    = string
#         operator = optional(string)
#       })))
#     }))
#     # By default it will protect all of the service and platform APIs the target service supports,
#     # For more information: check the default value of operations variable in modules/cbr-rule-module/variables.tf
#     operations = optional(list(object({
#       api_types = list(object({
#         api_type_id = string
#       }))
#     })))
#     # references keys from var.cbr_zones.
#     zone_keys = list(string)
#   }))
#   default = {}
#   # Validation happens in the rule module
# }
