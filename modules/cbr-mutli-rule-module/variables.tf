##############################################################################
# Rule Related Input Variables
##############################################################################
variable "cbr_rule_list" {
  type = list(object({
    description      = string
    account_id       = string
    resource         = optional(string)
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
  description = "List of CBR rules to be created"
  # Validation happens in the rule module
}

variable "resource" {
  type        = string
  description = "Resource to be used in the rule, applied to all rules in list and overrides rule specific resource if provided"
  default     = ""
}

variable "service_instance" {
  type        = string
  description = "Service Instance to be used in the rule, applied to all rules in list and overrides rule specific serviceInstance if provided"
  default     = ""
}
