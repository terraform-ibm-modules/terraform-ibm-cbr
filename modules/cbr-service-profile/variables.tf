##############################################################################
# Rule Related Input Variables
##############################################################################

variable "prefix" {
  type        = string
  description = "Prefix to append to all vpc_zone_list, service_ref_zone_list and cbr_rule_description created by this submodule"
  default     = "serviceprofile"
}

variable "zone_vpc_crn_list" {
  type        = list(string)
  default     = []
  description = "(List) VPC CRN for the zones"
}

variable "zone_service_ref_list" {
  type = map(object({
    serviceRef_location = optional(list(string), [])
  }))
  description = "Provide a valid service reference with the location where the context-based restriction zones are created. If no value is specified for `serviceRef_location`, the zones are not scoped to any location."
  # Validation to restrict the target service name to be the list of supported targets only.
  validation {
    condition = alltrue([
      for service_ref, service_ref_location in var.zone_service_ref_list :
      contains(["cloud-object-storage", "codeengine", "containers-kubernetes",
        "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql",
        "databases-for-redis", "directlink",
        "iam-groups", "is", "messagehub",
        "messages-for-rabbitmq", "schematics", "secrets-manager", "server-protect", "user-management",
        "apprapp", "compliance", "event-notifications", "logdna", "logdnaat",
      "cloudantnosqldb", "globalcatalog-collection", "sysdig-monitor", "sysdig-secure", "toolchain"], service_ref)
    ])
    error_message = "Provide a valid target service name that is supported by context-based restrictions."
  }
}

variable "target_service_details" {
  type = list(object({
    target_service_name = string
    target_rg           = optional(string)
    enforcement_mode    = string
    tags                = optional(list(string))
  }))
  description = "(String) Details of the target service for which the rule has to be created"
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
      "schematics", "apprapp", "event-notifications", "compliance", "logdna", "logdnaat"], service_detail.target_service_name)
    ])
    error_message = "Provide a valid target service name that is supported by context-based restrictions"
  }
}

variable "endpoints" {
  type        = list(string)
  description = "List specific endpoint types for target services, valid values for endpoints are 'public', 'private' or 'direct'"
  default     = ["private"]
  validation {
    condition = alltrue([
      for endpoint in var.endpoints : can(regex("^(public|private|direct)$", endpoint))
    ])
    error_message = "Valid values for endpoints are 'public', 'private' or 'direct'"
  }
}
