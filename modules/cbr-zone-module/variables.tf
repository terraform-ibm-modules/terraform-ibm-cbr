##############################################################################
# Input Variables
##############################################################################

variable "account_id" {
  type        = string
  description = "(Optional, String) The id of the account owning this zone"
  default     = null
  validation {
    condition = anytrue([
      var.account_id == null,
      alltrue([
        can(length(var.account_id) >= 1),
        can(length(var.account_id) <= 128),
        can(regex("^[0-9A-Za-z \\-]+$", var.account_id))
      ])
    ])
    error_message = "Value should be a valid account id with 1-128 characters"
  }
}

variable "name" {
  type        = string
  description = "(Optional, String) The name of the zone"
  default     = null
  validation {
    condition = anytrue([
      var.name == null,
      alltrue([
        can(length(var.name) >= 1),
        can(length(var.name) <= 128),
        can(regex("^[0-9A-Za-z \\-_]+$", var.name))
      ])
    ])
    error_message = "Value should be a valid account id with 1-128 characters"
  }
}

variable "zone_description" {
  type        = string
  description = "(Optional, String) The description of the zone"
  default     = null
  validation {
    condition = anytrue([
      var.zone_description == null,
      alltrue([
        can(length(var.zone_description) >= 0),
        can(length(var.zone_description) <= 300),
        can(regex("^[\\x20-\\xFE]+$", var.zone_description))
      ])
    ])
    error_message = "Value should be a valid zone description with 1-300 characters"
  }
}

variable "addresses" {
  type = list(object({
    type  = optional(string)
    value = optional(string)
    ref = optional(object({
      account_id       = string
      location         = optional(string)
      service_instance = optional(string)
      service_name     = optional(string)
      service_type     = optional(string)
    }))
  }))
  description = "(List) The list of addresses in the zone"
  default     = []
  validation {
    condition = alltrue([
      for address in var.addresses : contains(["ipAddress", "ipRange", "subnet", "vpc", "serviceRef"], address.type)
    ])
    error_message = "Valid values for address types are 'ipAddress', 'ipRange', 'subnet', 'vpc', and 'serviceRef'"
  }
  validation {
    condition = alltrue(
      flatten(
        [for address in var.addresses :
          (address.ref != null ?
            (
              alltrue(
                [for ref in address.ref : alltrue([
                  length(address.ref.account_id) >= 1,
                  length(address.ref.account_id) <= 128,
                  can(regex("^[a-zA-Z0-9-]+$", address.ref.account_id))
                ])]
              )
            ) : true
          )
        ]
      )
    )
    error_message = "Value should be a valid account id"
  }

  validation {
    condition = alltrue(
      flatten(
        [for address in var.addresses :
          (address.ref != null ?
            (
              alltrue(
                [for ref in address.ref : anytrue([
                  address.ref.location == null,
                  alltrue([
                    can(length(address.ref.location) >= 1),
                    can(length(address.ref.location) <= 128),
                    can(regex("^[0-9a-z-]+$", address.ref.location))
                  ])
                ])]
              )
            ) : true
          )
        ]
      )
    )
    error_message = "Value should be a valid location"
  }

  validation {
    condition = alltrue(
      flatten(
        [for address in var.addresses :
          (address.ref != null ?
            (
              alltrue(
                [for ref in address.ref : anytrue([
                  address.ref.service_instance == null,
                  alltrue([
                    can(length(address.ref.service_instance) >= 1),
                    can(length(address.ref.service_instance) <= 128),
                    can(regex("^[0-9a-z-/]+$", address.ref.service_instance))
                  ])
                ])]
              )
            ) : true
          )
        ]
      )
    )
    error_message = "Value should be a valid service instance"
  }

  validation {
    condition = alltrue(
      flatten(
        [for address in var.addresses :
          (address.ref != null ?
            (
              alltrue(
                [for ref in address.ref : anytrue([
                  address.ref.service_name == null,
                  alltrue([
                    can(length(address.ref.service_name) >= 1),
                    can(length(address.ref.service_name) <= 128),
                    can(regex("^[0-9a-z-/]+$", address.ref.service_name))
                  ])
                ])]
              )
            ) : true
          )
        ]
      )
    )
    error_message = "Value should be a valid service name"
  }

  validation {
    condition = alltrue(
      flatten(
        [for address in var.addresses :
          (address.ref != null ?
            (
              alltrue(
                [for ref in address.ref : anytrue([
                  address.ref.service_type == null,
                  alltrue([
                    can(length(address.ref.service_type) >= 1),
                    can(length(address.ref.service_type) <= 128),
                    can(regex("^[0-9a-z_]+$", address.ref.service_type))
                  ])
                ])]
              )
            ) : true
          )
        ]
      )
    )
    error_message = "Value should be a valid service type"
  }

}

variable "excluded_addresses" {
  type = list(object({
    type  = optional(string)
    value = optional(string)
  }))
  description = "(Optional, List) The list of excluded addresses in the zone"
  default     = []
  validation {
    condition = alltrue([
      for address in var.excluded_addresses : contains(["ipAddress", "ipRange", "subnet"], address.type)
    ])
    error_message = "Valid values for address types are 'ipAddress', 'ipRange' and 'subnet'"
  }
  validation {
    condition = alltrue([
      for address in var.excluded_addresses : alltrue([
        length(address.value) >= 2,
        length(address.value) <= 45,
        can(regex("^[a-zA-Z0-9:.]+$", address.value))
      ])
    ])
    error_message = "Value should be a valid as per the type"
  }
}

variable "existing_zone_id" {
  type = string
  validation {
    condition     = var.existing_zone_id == null || (can(regex("^[0-9a-fA-F]{32}$", var.existing_zone_id)))
    error_message = "Value should be a valid zone ID with 32 alphanumeric characters"
  }
  description = "Provide an existing CBR zone ID"
  default     = null
}

variable "use_existing_cbr_zone" {
  type        = bool
  description = "Whether to update CBR zone using existing zone ID. This allows the inclusion of one or more addresses in an existing zone"
  default     = false
}
