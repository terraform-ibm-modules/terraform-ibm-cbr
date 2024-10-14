##############################################################################
# Context Based Restrictions module
#
# Creates CBR Zone
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_zone_id_values = !var.use_existing_cbr_zone && (var.account_id == null || var.name == null) ? tobool("When passing values for var.zone_id, you must set var.use_existing_cbr_zone to true.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_zone_id_vars = var.use_existing_cbr_zone && var.existing_zone_id == null ? tobool("When setting var.use_existing_cbr_zone to true, a value must be passed for var.zone_id.") : true
}

resource "ibm_cbr_zone" "cbr_zone" {
  count       = var.use_existing_cbr_zone ? 0 : 1
  account_id  = var.account_id
  name        = var.name
  description = var.zone_description

  dynamic "addresses" {
    for_each = var.addresses
    iterator = address
    content {
      type  = address.value["type"]
      value = address.value["value"]
      dynamic "ref" {
        for_each = address.value["ref"] == null ? [] : ["true"]
        content {
          account_id       = address.value["ref"].account_id
          location         = address.value["ref"].location
          service_instance = address.value["ref"].service_instance
          service_name     = address.value["ref"].service_name
          service_type     = address.value["ref"].service_type
        }
      }
    }
  }

  dynamic "excluded" {
    for_each = var.excluded_addresses
    iterator = excluded_addres
    content {
      type  = excluded_addres.value["type"]
      value = excluded_addres.value["value"]
    }
  }
}

resource "ibm_cbr_zone_addresses" "update_cbr_zone_address" {
  count = var.use_existing_cbr_zone ? 1 : 0

  zone_id = var.existing_zone_id
  dynamic "addresses" {
    for_each = var.addresses
    iterator = address
    content {
      type  = address.value["type"]
      value = address.value["value"]
      dynamic "ref" {
        for_each = address.value["ref"] == null ? [] : ["true"]
        content {
          account_id       = address.value["ref"].account_id
          location         = address.value["ref"].location
          service_instance = address.value["ref"].service_instance
          service_name     = address.value["ref"].service_name
          service_type     = address.value["ref"].service_type
        }
      }
    }
  }
}
