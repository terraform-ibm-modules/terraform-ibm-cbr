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
  description = "Set rule for COS to KMS, default is true"
  default     = true
}

variable "allow_block_storage_to_kms" {
  type        = bool
  description = "Set rule for block storage to KMS, default is true"
  default     = true
}

variable "allow_roks_to_kms" {
  type        = bool
  description = "Set rule for ROKS to KMS, default is true"
  default     = true
}

variable "allow_icd_to_kms" {
  type        = bool
  description = "Set rule for ICD to KMS, default is true"
  default     = true
}

variable "allow_event_streams_to_kms" {
  type        = bool
  description = "Set rule for Event Streams (Messagehub) to KMS, default is true"
  default     = true
}

variable "allow_vpcs_to_container_registry" {
  type        = bool
  description = "Set rule for VPCs to container registry, default is true"
  default     = true
}

variable "allow_vpcs_to_cos" {
  type        = bool
  description = "Set rule for VPCs to COS, default is true"
  default     = true
}

variable "allow_at_to_cos" {
  type        = bool
  description = "Set rule for Activity Tracker to COS, default is true"
  default     = true
}

variable "allow_iks_to_is" {
  type        = bool
  description = "Set rule for IKS to IS (VPC Infrastructure Services), default is true"
  default     = true
}

variable "allow_is_to_cos" {
  type        = bool
  description = "Set rule for IS (VPC Infrastructure Services) to COS, default is true"
  default     = true
}

variable "zone_service_ref_list" {
  type = object({
    cloud-object-storage        = optional(string)
    codeengine                  = optional(string)
    containers-kubernetes       = optional(string)
    databases-for-cassandra     = optional(string)
    databases-for-elasticsearch = optional(string)
    databases-for-enterprisedb  = optional(string)
    databases-for-etcd          = optional(string)
    databases-for-mongodb       = optional(string)
    databases-for-mysql         = optional(string)
    databases-for-postgresql    = optional(string)
    databases-for-redis         = optional(string)
    directlink                  = optional(string)
    iam-groups                  = optional(string)
    is                          = optional(string)
    messagehub                  = optional(string)
    messages-for-rabbitmq       = optional(string)
    schematics                  = optional(string)
    secrets-manager             = optional(string)
    server-protect              = optional(string)
    user-management             = optional(string)
    apprapp                     = optional(string)
    compliance                  = optional(string)
    event-notifications         = optional(string)
    logdna                      = optional(string)
    logdnaat                    = optional(string)
  })
  default = {
    cloud-object-storage        = null
    codeengine                  = null
    containers-kubernetes       = null
    databases-for-cassandra     = null
    databases-for-elasticsearch = null
    databases-for-enterprisedb  = null
    databases-for-etcd          = null
    databases-for-mongodb       = null
    databases-for-mysql         = null
    databases-for-postgresql    = null
    databases-for-redis         = null
    directlink                  = null
    iam-groups                  = null
    is                          = null
    messagehub                  = null
    messages-for-rabbitmq       = null
    schematics                  = null
    secrets-manager             = null
    server-protect              = null
    user-management             = null
    apprapp                     = null
    compliance                  = null
    event-notifications         = null
    logdna                      = null
    logdnaat                    = null
  }
  validation {
    condition = alltrue([
      for service_ref, service_ref_name in var.zone_service_ref_list : contains([
        "cloud-object-storage", "codeengine", "containers-kubernetes",
        "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql",
        "databases-for-redis", "directlink",
        "iam-groups", "is", "messagehub",
        "messages-for-rabbitmq", "schematics", "secrets-manager", "server-protect", "user-management",
        "apprapp", "compliance", "event-notifications", "logdna", "logdnaat"],
      service_ref)
    ])
    error_message = "Provide a valid service reference for zone creation"
  }
  description = "(Optional) Customized name of the zone for the service reference. If not provided, default zone name with the prefix will be created."
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
          "containers-kubernetes-cluster", "containers-kubernetes-management",
          "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb",
          "databases-for-etcd", "databases-for-mongodb",
          "databases-for-mysql", "databases-for-postgresql",
          "databases-for-redis", "directlink",
          "iam-groups", "is", "messagehub",
          "messages-for-rabbitmq", "schematics", "secrets-manager", "server-protect", "user-management",
          "apprapp", "compliance", "event-notifications", "logdna", "logdnaat"],
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
variable "target_service_details" {
  type = map(object({
    description      = optional(string)
    target_rg        = optional(string)
    instance_id      = optional(string)
    enforcement_mode = string
    tags             = optional(list(string))
  }))
  description = "Details of the target service for which a rule is created. The key is the service name."
  validation {
    condition = alltrue([
      for target_service_name, _ in var.target_service_details :
      contains(["iam-groups", "iam-access-management", "iam-identity",
        "user-management", "cloud-object-storage", "codeengine",
        "container-registry", "databases-for-cassandra",
        "databases-for-enterprisedb", "databases-for-elasticsearch",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql", "databases-for-redis",
        "directlink", "dns-svcs", "messagehub", "kms", "containers-kubernetes", "containers-kubernetes-cluster", "containers-kubernetes-management",
        "messages-for-rabbitmq", "secrets-manager", "transit", "is",
      "schematics", "apprapp", "event-notifications", "compliance", "hs-crypto"], target_service_name)
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

variable "existing_serviceref_zone" {
  type = map(object(
    {
      zone_id = string
  }))
  validation {
    condition     = var.existing_serviceref_zone == null || (alltrue([for zone in var.existing_serviceref_zone : can(regex("^[0-9a-fA-F]{32}$", zone.zone_id))]))
    error_message = "Value should be a valid zone id with 32 alphanumeric characters"
  }
  validation {
    condition = alltrue([
      for key, _ in var.existing_serviceref_zone :
      contains(["cloud-object-storage", "codeengine", "containers-kubernetes",
        "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql",
        "databases-for-redis", "directlink",
        "iam-groups", "is", "messagehub",
        "messages-for-rabbitmq", "schematics", "secrets-manager", "server-protect", "user-management",
      "apprapp", "compliance", "event-notifications", "logdna", "logdnaat"], key)
    ])
    error_message = "Provide a valid service reference"
  }
  description = "Provide a valid service reference and existing zone id"
  default     = {}
}

variable "existing_cbr_zone_vpcs" {
  type = object(
    {
      zone_id = string
  })
  validation {
    condition     = var.existing_cbr_zone_vpcs == null || (can(regex("^[0-9a-fA-F]{32}$", var.existing_cbr_zone_vpcs.zone_id)))
    error_message = "Value should be a valid zone id with 32 alphanumeric characters"
  }
  description = "Provide a existing zone id for VPC"
  default     = null
}

variable "skip_specific_services_for_zone_creation" {
  type = list(string)
  validation {
    condition = alltrue([
      for service_ref in var.skip_specific_services_for_zone_creation :
      contains(["cloud-object-storage", "codeengine", "containers-kubernetes",
        "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb",
        "databases-for-etcd", "databases-for-mongodb",
        "databases-for-mysql", "databases-for-postgresql",
        "databases-for-redis", "directlink",
        "iam-groups", "is", "messagehub",
        "messages-for-rabbitmq", "schematics", "secrets-manager", "server-protect", "user-management",
        "apprapp", "compliance", "event-notifications", "logdna", "logdnaat"],
      service_ref)
    ])
    error_message = "Provide a valid service reference for zone creation"
  }
  description = "Provide a list of service references for which zone creation is not required"
  default     = []
}

variable "location" {
  type        = string
  description = "The region in which the network zone is scoped"
  default     = null
}

variable "kms_service_targeted_by_prewired_rules" {
  type        = list(string)
  description = "IBM Cloud offers two distinct Key Management Services (KMS): Key Protect and Hyper Protect Crypto Services (HPCS). This variable determines the specific KMS service to which the pre-configured rules will be applied. Use the value 'key-protect' to specify the Key Protect service, and 'hs-crypto' for the Hyper Protect Crypto Services (HPCS)."
  default     = ["hs-crypto"]
  validation {
    condition = alltrue([
      for key_protect_val in var.kms_service_targeted_by_prewired_rules : can(regex("^(key-protect|hs-crypto)$", key_protect_val))
    ])
    error_message = "Valid values for kms are 'key-protect' for Key Protect and 'hs-crypto' for HPCS"
  }
}
