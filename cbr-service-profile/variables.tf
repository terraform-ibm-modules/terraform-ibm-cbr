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

variable "target_service_details" {
  type = list(object({
    attributes = list(object({
      name     = string
      value    = string
      operator = optional(string)
    }))
    tags = optional(list(object({
      name  = string
      value = string
    })))
    operations = list(object({
      api_types = list(object({
        api_type_id = string
      }))
    }))

  }))
  description = "(String) Details of the target service for which the rule has to be created"
  default     = []
}
