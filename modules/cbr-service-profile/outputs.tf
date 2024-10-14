##############################################################################
# Outputs
##############################################################################

output "zone_ids" {
  value       = module.cbr_zone[*].zone_id
  description = "CBR zone id(s)"
}

output "zone_crns" {
  value       = module.cbr_zone[*].zone_crn
  description = "CBR zone crn(s)"
}

output "zone_hrefs" {
  value       = module.cbr_zone[*].zone_href
  description = "CBR zone href(s)"
}

output "rule_ids" {
  value       = join(",", module.cbr_rule[*].rule_id)
  description = "CBR rule id(s)"
}

output "rule_crns" {
  value       = join(",", module.cbr_rule[*].rule_crn)
  description = "CBR rule crn(s)"
}

output "rule_hrefs" {
  value       = join(",", module.cbr_rule[*].rule_href)
  description = "CBR rule href(s)"
}
