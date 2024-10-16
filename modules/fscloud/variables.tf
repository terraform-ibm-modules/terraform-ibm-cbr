variable "prefix" {
  type        = string
  description = "Prefix to append to all vpc_zone_list, service_ref_zone_list and cbr_rule_description created by this submodule"
}

variable "zone_vpc_crn_list" {
  type        = list(string)
  description = "(List) VPC CRN for the zones"
  default     = []
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

variable "allow_vpcs_to_iam_groups" {
  type        = bool
  description = "Set rule for VPCs to IAM groups, default is true"
  default     = true
}

variable "allow_vpcs_to_iam_access_management" {
  type        = bool
  description = "Set rule for VPCs to IAM access management, default is true"
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

variable "allow_scc_to_cos" {
  type        = bool
  description = "Set rule for SCC (Security and Compliance Center) to COS, default is true"
  default     = true
}

variable "zone_service_ref_list" {
  type = object({
    cloud-object-storage = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    codeengine = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    containers-kubernetes = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    databases-for-cassandra = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    databases-for-elasticsearch = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    databases-for-enterprisedb = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    databases-for-etcd = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    databases-for-mongodb = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    databases-for-mysql = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    databases-for-postgresql = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    databases-for-redis = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    directlink = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    iam-groups = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    is = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    messagehub = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    messages-for-rabbitmq = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    schematics = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    secrets-manager = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    server-protect = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    user-management = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    apprapp = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    compliance = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    event-notifications = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    logdna = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    logdnaat = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    cloudantnosqldb = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    globalcatalog-collection = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    sysdig-monitor = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    sysdig-secure = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

    toolchain = optional(object({
      zone_name           = optional(string)
      serviceRef_location = optional(list(string))
    }))

  })

  description = "(Optional) Provide a valid service reference with the customized name of the zone and location where the context-based restriction zones are created. If no value is specified for `serviceRef_location`, the zones are not scoped to any location and if no value is specified for `zone_name` default zone name with the prefix will be created."

  default = {}
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
    condition = alltrue([
      for service_target in keys(var.custom_rule_contexts_by_service) : contains(["IAM", "apprapp", "cloud-object-storage", "codeengine", "compliance", "container-registry", "containers-kubernetes", "containers-kubernetes-cluster", "containers-kubernetes-management", "context-based-restrictions", "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb", "databases-for-etcd", "databases-for-mongodb", "databases-for-mysql", "databases-for-postgresql", "databases-for-redis", "directlink", "dns-svcs", "event-notifications", "globalcatalog-collection", "hs-crypto", "iam-access-management", "iam-groups", "iam-identity", "is", "kms", "logdna", "logdnaat", "messagehub", "messages-for-rabbitmq", "mqcloud", "schematics", "secrets-manager", "sysdig-monitor", "sysdig-secure", "transit", "user-management"], service_target)
    ])
    error_message = "Provide a valid target service name that is supported by context-based restrictions"
  }

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
          "apprapp", "compliance", "event-notifications", "logdna", "logdnaat",
          "cloudantnosqldb", "globalcatalog-collection", "sysdig-monitor", "sysdig-secure", "toolchain"],
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
    region           = optional(string)
    geography        = optional(string)
    global_deny      = optional(bool, true)
  }))
  description = "Details of the target service for which a rule is created. The key is the service name."

  validation {
    condition = alltrue([
      for target_service_name, _ in var.target_service_details :
      contains(["IAM", "apprapp", "cloud-object-storage", "codeengine", "compliance", "container-registry", "containers-kubernetes", "containers-kubernetes-cluster", "containers-kubernetes-management", "context-based-restrictions", "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb", "databases-for-etcd", "databases-for-mongodb", "databases-for-mysql", "databases-for-postgresql", "databases-for-redis", "directlink", "dns-svcs", "event-notifications", "globalcatalog-collection", "hs-crypto", "iam-access-management", "iam-groups", "iam-identity", "is", "kms", "logdna", "logdnaat", "messagehub", "messages-for-rabbitmq", "mqcloud", "schematics", "secrets-manager", "sysdig-monitor", "sysdig-secure", "transit", "user-management"], target_service_name)
    ])
    error_message = "Provide a valid target service name that is supported by context-based restrictions"
  }
  validation {
    condition = alltrue([
      for target_service_name, attributes in var.target_service_details : (
        target_service_name != "container-registry" || (
          contains(["container-registry"], target_service_name) &&
          !(attributes.region != null && attributes.geography != null)
        )
      )
    ])
    error_message = "Both `region` and `geography` cannot be set simultaneously for the container registry service."
  }
  validation {
    condition = alltrue([
      for target_service_name, attributes in var.target_service_details :
      contains(["cloud-object-storage", "codeengine", "container-registry", "containers-kubernetes", "containers-kubernetes-cluster", "containers-kubernetes-management", "databases-for-cassandra", "databases-for-elasticsearch", "databases-for-enterprisedb", "databases-for-etcd", "databases-for-mongodb", "databases-for-mysql", "databases-for-postgresql", "databases-for-redis", "event-notifications", "hs-crypto", "iam-identity", "is", "logdna", "logdnaat", "messagehub", "messages-for-rabbitmq", "mqcloud", "secrets-manager", "sysdig-monitor", "sysdig-secure"], target_service_name) if attributes.region != null
    ])
    error_message = "Provide a valid target service name that supports region attribute."
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
        "apprapp", "compliance", "event-notifications", "logdna", "logdnaat",
      "cloudantnosqldb", "globalcatalog-collection", "sysdig-monitor", "sysdig-secure", "toolchain"], key)
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
        "apprapp", "compliance", "event-notifications", "logdna", "logdnaat",
      "cloudantnosqldb", "globalcatalog-collection", "sysdig-monitor", "sysdig-secure", "toolchain"], service_ref)
    ])
    error_message = "Provide a valid service reference for zone creation"
  }
  description = "Provide a list of service references for which zone creation is not required"
  default     = []
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
