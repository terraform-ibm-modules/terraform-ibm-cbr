# ##############################################################################
# # Outputs
# ##############################################################################

output "zone_names" {
  value       = var.existing_zone_id == null ? ibm_cbr_zone.cbr_zone[0].name : null
  description = "CBR zone name"
}

output "zone_description" {
  value       = var.existing_zone_id == null ? var.zone_description : null
  description = "CBR zone description"
}

output "zone_id" {
  value       = var.existing_zone_id == null ? ibm_cbr_zone.cbr_zone[0].id : ibm_cbr_zone_addresses.update_cbr_zone_address[0].id
  description = "CBR zone id"
}

output "zone_crn" {
  value       = var.existing_zone_id == null ? ibm_cbr_zone.cbr_zone[0].crn : null
  description = "CBR zone crn"
}

output "zone_href" {
  value       = var.existing_zone_id == null ? ibm_cbr_zone.cbr_zone[0].href : null
  description = "CBR zone link"
}
