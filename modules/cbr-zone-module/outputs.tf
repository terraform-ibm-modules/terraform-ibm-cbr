# ##############################################################################
# # Outputs
# ##############################################################################

output "zone_names" {
  value       = var.existing_zone_id == null ? ibm_cbr_zone.cbr_zone[0].name : null
  description = "CBR zone resource name"
}

output "zone_description" {
  value       = var.existing_zone_id == null ? var.zone_description : null
  description = "CBR zone resource description"
}

output "zone_id" {
  value       = var.existing_zone_id == null ? ibm_cbr_zone.cbr_zone[0].id : ibm_cbr_zone_addresses.update_cbr_zone_address[0].id
  description = "CBR zone resource id"
}

output "zone_crn" {
  value       = var.existing_zone_id == null ? ibm_cbr_zone.cbr_zone[0].crn : null
  description = "CBR zone resource crn"
}

output "zone_href" {
  value       = var.existing_zone_id == null ? ibm_cbr_zone.cbr_zone[0].href : null
  description = "CBR zone resource link"
}
