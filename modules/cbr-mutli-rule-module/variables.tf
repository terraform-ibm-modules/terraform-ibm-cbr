##############################################################################
# Rule Related Input Variables
##############################################################################
variable "rule_list" {
  description = "List of CBR Rules to be created"
  type = list(object({
    service_instance = optional(string)
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  # Validation happens in the rule module
}

variable "rule_descriptions" {
  description = "List of CBR Rule Descriptions to be created"
  type        = list(string)
  default     = []
}

variable "rule_resources" {
  description = "List of CBR Rule Resources to be created"
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
  default = []
}
