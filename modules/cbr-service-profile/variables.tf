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
  validation {
    condition = (
      length(var.zone_vpc_crn_list) > 0 || length(var.zone_service_ref_list) > 0
    )
    error_message = "Error: Provide at least one of zone_vpc_crn_list or zone_service_ref_list."
  }

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

  validation {
    condition = alltrue([
      for item in ["directlink", "globalcatalog-collection", "iam-groups", "platform_service", "user-management"] :
      contains(keys(var.zone_service_ref_list), item) ?
      try(length(var.zone_service_ref_list[item].serviceRef_location), 0) == 0 :
      true
    ])
    error_message = "Error: The services 'directlink', 'globalcatalog-collection', 'iam-groups', 'platform_service' and 'user-management' must not specify a serviceRef_location."
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
      contains(["apprapp", "atracker", "cloud-object-storage", "codeengine", "container-registry", "containers-kubernetes", "context-based-restrictions", "databases-for-elasticsearch", "databases-for-enterprisedb", "databases-for-etcd", "databases-for-mongodb", "databases-for-mysql", "databases-for-postgresql", "databases-for-redis", "directlink", "dns-svcs", "event-notifications", "ghost-tags", "globalcatalog-collection", "hs-crypto", "IAM", "iam-access-management", "iam-groups", "iam-identity", "is", "kms", "logs", "messagehub", "messages-for-rabbitmq", "mqcloud", "schematics", "secrets-manager", "sysdig-monitor", "sysdig-secure", "transit", "user-management"], service_detail.target_service_name)
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
