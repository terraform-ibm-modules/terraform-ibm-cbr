variable "prefix" {
  type        = string
  description = "Prefix to append to all vpc_zone_list, service_ref_zone_list and cbr_rule_description created by this submodule"
}

variable "zone_vpc_crn_list" {
  type        = list(string)
  description = "(List) VPC CRN for the zones"
}

variable "allow_cos_to_kms" {
  type        = bool
  description = "Set rule for COS to KMS, deafult is true"
  default     = true
}

variable "allow_block_storage_to_kms" {
  type        = bool
  description = "Set rule for block storage to KMS, deafult is true"
  default     = true
}

variable "allow_roks_to_kms" {
  type        = bool
  description = "Set rule for ROKS to KMS, deafult is true"
  default     = true
}

variable "allow_vpcs_to_container_registry" {
  type        = bool
  description = "Set rule for VPCs to container registry, deafult is true"
  default     = true
}

variable "allow_vpcs_to_cos" {
  type        = bool
  description = "Set rule for VPCs to COS, deafult is true"
  default     = true
}

variable "zone_service_ref_list" {
  type = list(string)
  validation {
    condition = alltrue([
      for service_ref in var.zone_service_ref_list :
      contains(["cloud-object-storage", "codeengine", "containers-kubernetes",
        "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql",
        "databases-for-redis", "directlink",
        "iam-groups", "is", "messagehub",
        "messages-for-rabbitmq", "schematics", "secrets-manager", "server-protect", "user-management",
        "apprapp", "compliance", "event-notifications"],
      service_ref)
    ])
    error_message = "Provide a valid service reference for zone creation"
  }
  default = ["cloud-object-storage", "codeengine", "containers-kubernetes",
    "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb",
    "databases-for-etcd", "databases-for-mongodb",
    "databases-for-mysql", "databases-for-postgresql",
    "databases-for-redis", "directlink",
    "iam-groups", "is", "messagehub",
    "messages-for-rabbitmq", "schematics", "secrets-manager", "server-protect", "user-management",
  "apprapp", "compliance", "event-notifications"]
  description = "(List) Service reference for the zone creation"
}

variable "custom_rule_contexts_by_service" {
  # servicename -> [cbr rule context]
  # append to rule context created by profile
  type = map(list(object(
    {
      endpointType = string # "private, public or direct"

      # Service-name (module lookup for existing network zone) and/or CBR zone id
      service_ref_names    = optional(list(string), [])
      add_managed_vpc_zone = optional(bool, false)
      zone_ids             = optional(list(string), [])
  })))
  validation {
    condition = alltrue(flatten([
      for key, val in var.custom_rule_contexts_by_service :
      [for rule in val : [
        for ref in rule.service_ref_names : contains(["cloud-object-storage", "codeengine", "containers-kubernetes",
          "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb",
          "databases-for-etcd", "databases-for-mongodb",
          "databases-for-mysql", "databases-for-postgresql",
          "databases-for-redis", "directlink",
          "iam-groups", "is", "messagehub",
          "messages-for-rabbitmq", "schematics", "secrets-manager", "server-protect", "user-management",
          "apprapp", "compliance", "event-notifications"],
      ref)]]

    ]))
    error_message = "Provide a valid service reference for zone creation"
  }
  validation {

    condition = alltrue(flatten([
      for key, val in var.custom_rule_contexts_by_service :
      [for rule in val : [
      for zone_id in rule.zone_ids : can(regex("^[0-9a-fA-F]{32}$", zone_id))]]
    ]))
    error_message = "Value should be a valid zone id with 32 alphanumeric characters"
  }
  description = "Any additional context to add to the CBR rules created by this module. The context are added to the CBR rule targetting the service passed as a key. The module looks up the zone id when service_ref_names or add_managed_vpc_zone are passed in."
  default     = {}
}

# variable "target_service_details" {
#   type = list(object({
#     target_service_name = string
#     target_rg           = optional(string)
#     enforcement_mode    = string
#     tags                = optional(list(string))
#   }))
#   description = "(String) Details of the target service for which the rule has to be created"
#   #Validation to restrict the target service name to be the list of supported targets only.
#   validation {
#     condition = alltrue([
#       for service_detail in var.target_service_details :
#       contains(["iam-groups", "iam-access-management", "iam-identity",
#         "user-management", "cloud-object-storage", "codeengine",
#         "container-registry", "databases-for-cassandra",
#         "databases-for-enterprisedb", "databases-for-elasticsearch",
#         "databases-for-etcd", "databases-for-mongodb",
#         "databases-for-mysql", "databases-for-postgresql", "databases-for-redis",
#         "directlink", "dns-svcs", "messagehub", "kms", "containers-kubernetes",
#         "messages-for-rabbitmq", "secrets-manager", "transit", "is",
#       "schematics", "apprapp", "event-notifications", "compliance"], service_detail.target_service_name)
#     ])
#     error_message = "Provide a valid target service name that is supported by context-based restrictions"
#   }
#   default = [
#     { "target_service_name" : "iam-groups", "enforcement_mode" : "report" },
#     { "target_service_name" : "iam-access-management", "enforcement_mode" : "report" },
#     { "target_service_name" : "iam-identity", "enforcement_mode" : "report" },
#     { "target_service_name" : "user-management", "enforcement_mode" : "report" },
#     { "target_service_name" : "cloud-object-storage", "enforcement_mode" : "report" },
#     { "target_service_name" : "codeengine", "enforcement_mode" : "report" },
#     { "target_service_name" : "container-registry", "enforcement_mode" : "report" },
#     { "target_service_name" : "databases-for-cassandra", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "databases-for-enterprisedb", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "databases-for-elasticsearch", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "databases-for-etcd", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "databases-for-mongodb", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "databases-for-mysql", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "databases-for-postgresql", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "databases-for-redis", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "directlink", "enforcement_mode" : "report" },
#     { "target_service_name" : "dns-svcs", "enforcement_mode" : "report" },
#     { "target_service_name" : "messagehub", "enforcement_mode" : "report" },
#     { "target_service_name" : "kms", "enforcement_mode" : "report" },
#     { "target_service_name" : "containers-kubernetes", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "messages-for-rabbitmq", "enforcement_mode" : "disabled" },
#     { "target_service_name" : "secrets-manager", "enforcement_mode" : "report" },
#     { "target_service_name" : "transit", "enforcement_mode" : "report" },
#     { "target_service_name" : "is", "enforcement_mode" : "report" },
#     { "target_service_name" : "schematics", "enforcement_mode" : "report" },
#     { "target_service_name" : "apprapp", "enforcement_mode" : "report" },
#     { "target_service_name" : "event-notifications", "enforcement_mode" : "report" },
#     { "target_service_name" : "compliance", "enforcement_mode" : "report" }
#   ]
# }

variable "target_service_details" {
  type = map(object({
    target_rg        = optional(string)
    enforcement_mode = string
    tags             = optional(list(string))
  }))
  description = "Details of the target service for which a rule is created. The key is the service name."
  #Validation to restrict the target service name to be the list of supported targets only.
  validation {
    condition = alltrue([
      for target_service_name, _ in var.target_service_details :
      contains(["iam-groups", "iam-access-management", "iam-identity",
        "user-management", "cloud-object-storage", "codeengine",
        "container-registry", "databases-for-cassandra",
        "databases-for-enterprisedb", "databases-for-elasticsearch",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql", "databases-for-redis",
        "directlink", "dns-svcs", "messagehub", "kms", "containers-kubernetes",
        "messages-for-rabbitmq", "secrets-manager", "transit", "is",
      "schematics", "apprapp", "event-notifications", "compliance"], target_service_name)
    ])
    error_message = "Provide a valid target service name that is supported by context-based restrictions"
  }
  validation {
    condition = alltrue([
      for target_service_name, details in var.target_service_details :
      contains(["enabled", "disabled", "report"], details.enforcement_mode)
    ])
    error_message = "Valid values for enforcement mode can be 'enabled', 'disabled' and 'report'"
  }

  default = {}
}


## TODO validation for all below variables to be added

# variable "zone_allowed_ip_list" {
#   type        = list(string)
#   description = "(List) Allowed IP addresses for the zones"
#   default     = []
# }

# variable "zone_allowed_ip_range_list" {
#   type        = list(string)
#   description = "(List) Allowed IP range for the zones"
#   default     = []
# }

# variable "zone_allowed_subnet_list" {
#   type        = list(string)
#   description = "(List) Allowed subnet list for the zones"
#   default     = []
# }
# variable "zone_exluded_ip_list" {
#   type        = list(string)
#   description = "(List) Excluded IP address for the zones"
#   default     = []
# }

# variable "zone_excluded_ip_range_list" {
#   type        = list(string)
#   description = "(List) Excluded IP range for the zones"
#   default     = []
# }

# variable "zone_excluded_subnet_list" {
#   type        = list(string)
#   description = "(List) Excluded subnet list for the zones"
#   default     = []
# }


variable "ip_addresses" {
  type = object({
    ipAddress = optional(list(string))
    ipRange   = optional(list(string))
    subnet    = optional(list(string))
  })
  description = "List of all addresses."
  default     = null
}

variable "ip_excluded_addresses" {
  type = object({
    ipAddress = optional(list(string))
    ipRange   = optional(list(string))
    subnet    = optional(list(string))
  })
  description = "List of all excluded addresses."
  default     = null
}