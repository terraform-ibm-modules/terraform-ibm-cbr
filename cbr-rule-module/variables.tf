##############################################################################
# Rule Related Input Variables
##############################################################################

variable "rule_description" {
  type        = string
  description = "(Optional, String) The description of the rule"
  default     = null
  validation {
    condition = anytrue([
      var.rule_description == null,
      alltrue([
        can(length(var.rule_description) >= 0),
        can(length(var.rule_description) <= 300),
        can(regex("^[\\x20-\\xFE]+$", var.rule_description))
      ])
    ])
    error_message = "Value should be a valid rule description with 1-300 characters"
  }

}

variable "rule_contexts" {
  type = list(object({
    attributes = optional(list(object({
      name  = string
      value = string
    })))
  }))
  description = "(List) The contexts the rule applies to"
  validation {
    condition = anytrue(
      flatten(
        [for rule_context in var.rule_contexts :
          [for attribute in rule_context.attributes : alltrue([
            length(attribute.name) >= 2,
            length(attribute.name) <= 128,
            can(regex("^[a-zA-Z0-9]+$", attribute.name))
          ])]
        ]
      )
    )
    error_message = "Value should be a valid rule context name"
  }
}

variable "enforcement_mode" {
  type        = string
  description = "(String) The rule enforcement mode"
  default     = "report" # As part of the best practices, mode should be in report only mode for 30 days before the rules is enabled.
  validation {
    condition = anytrue([
      var.enforcement_mode == "enabled",
      var.enforcement_mode == "disabled",
      var.enforcement_mode == "report"
    ])
    error_message = "Valid values for enforcement mode can be 'enabled', 'disabled' and 'report'"
  }
}

variable "resources" {
  type = list(object({
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
  description = "(List) The resources this rule apply to"

}

variable "operations" {
  type = list(object({
    api_types = list(object({
      api_type_id = string
    }))
  }))
  description = "(Optional, List) The operations this rule applies to"
  default     = []
  validation {
    condition     = var.operations != null
    error_message = "operations cannot be null, an empty list is valid"
  }
}
