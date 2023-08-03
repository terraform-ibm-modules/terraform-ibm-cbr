##############################################################################
# Context Based Restrictions module
#
# Creates CBR Zone
##############################################################################

resource "ibm_cbr_zone" "cbr_zone" {
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
