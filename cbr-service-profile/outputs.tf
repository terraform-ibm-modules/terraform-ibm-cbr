##############################################################################
# Outputs
##############################################################################

output "zone_id" {
  value       = module.cbr_zone[*].zone_id
  description = "CBR zone resource instance id"
}

output "zone_crn" {
  value       = module.cbr_zone[*].zone_crn
  description = "CBR zone crn"
}

output "zone_href" {
  value       = module.cbr_zone[*].zone_href
  description = "CBR zone href"
}

output "rule_id" {
  value       = join(",", module.cbr_rule[*].rule_id)
  description = "CBR rule id"
}

output "rule_crn" {
  value       = join(",", module.cbr_rule[*].rule_crn)
  description = "CBR rule crn"
}

output "rule_href" {
  value       = join(",", module.cbr_rule[*].rule_href)
  description = "CBR rule href"
}

output "vpczonelength" {
  value       = length([])
  description = "CBR rule href"
}

output "servicezonelength" {
  value       = length(var.zone_service_ref_list)
  description = "CBR rule href"
}
