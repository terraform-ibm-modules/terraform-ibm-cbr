##############################################################################
# Outputs
##############################################################################

output "zone_names" {
  value       = ibm_cbr_zone.cbr_zone.name
  description = "CBR zone resource instance name"
}

output "zone_description" {
  value       = var.zone_description
  description = "CBR zone resource instance description"
}

output "zone_id" {
  value       = ibm_cbr_zone.cbr_zone.id
  description = "CBR zone resource instance id"
}

output "zone_crn" {
  value       = ibm_cbr_zone.cbr_zone.crn
  description = "CBR zone resource instance crn"
}

output "zone_href" {
  value       = ibm_cbr_zone.cbr_zone.href
  description = "CBR zone resource instance link"
}
