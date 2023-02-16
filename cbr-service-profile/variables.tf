##############################################################################
# Rule Related Input Variables
##############################################################################
variable "rule_contexts" {
  type = list(object({
    attributes = optional(list(object({
      name  = string
      value = string
    })))
  }))
  description = "(List) The contexts the rule applies to"
}

variable "target_service_details" {
  type = list(object({
    attributes = list(object({
      name     = string
      value    = string
      operator = optional(string)
    }))
    rule_description = string
    enforcement_mode = string
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
