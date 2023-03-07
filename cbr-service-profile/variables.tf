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
    target_service_name = string
    enforcement_mode    = string
    tags = optional(list(object({
      name  = string
      value = string
    })))
  }))
  description = "(String) Details of the target service for which the rule has to be created"
  default     = []
  #Validation to restrict the target service name to be the list of supported targets only.
  validation {
    condition = alltrue([
      for service_detail in var.target_service_details :
      contains(["iam-groups", "iam-access-management", "iam-identity",
        "user-management", "cloud-object-storage", "codeengine",
        "container-registry", "databases-for-cassandra",
        "databases-for-enterprisedb", "databases-for-elasticsearch",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql", "databases-for-redis",
        "directlink", "dns-svcs", "messagehub", "kms", "containers-kubernetes",
        "messages-for-rabbitmq", "secrets-manager", "transit", "is",
      "schematics"], service_detail.target_service_name)
    ])
    error_message = "Provide a valid target service name that is supported by context-based restrictions"
  }
}
