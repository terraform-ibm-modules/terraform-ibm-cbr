##############################################################################
# Rule Related Input Variables
##############################################################################
variable "cbr_rule_list" {
  description = "List of CBR Rules to be created"
  type = list(object({
    description = string
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
    service_instance = optional(string)
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    tags = optional(list(object({
      name  = string
      value = string
    })), [])
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  # Validation happens in the rule module
}
