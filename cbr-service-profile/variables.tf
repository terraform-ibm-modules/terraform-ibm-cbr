##############################################################################
# Rule Related Input Variables
##############################################################################

variable "rule_description" {
  type        = string
  description = "(Optional, String) The description of the rule"
  default     = null
}

variable "rule_contexts" {
  type = list(object({
    attributes = optional(list(object({
      name  = string
      value = string
    })))
  }))
  description = "(List) The contexts the rule applies to"
}

variable "enforcement_mode" {
  type        = string
  description = "(String) The rule enforcement mode"
  default     = "report" # As part of the best practices, mode should be in report only mode for 30 days before the rules is enabled.
}

variable "operations" {
  type = list(object({
    api_types = list(object({
      api_type_id = string
    }))
  }))
  description = "(Optional, List) The operations this rule applies to"
  default     = []
}

variable "target_service_details" {
    type = list(object({
      account_id  = string
      target_service_name = string
      operations = list(object({
      api_types = list(object({
        api_type_id = string
        }))
      }))
      tags = optional(list(object({
        name = string
        value = string
      })))
    }))
  description = "(String) The rule enforcement mode"
  default     = []
}


