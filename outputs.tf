##############################################################################
# Outputs
##############################################################################

output "zone_id" {
  value       = join("", ibm_cbr_zone.cbr_zone[*].id)
  description = "cbr_zone resource instance id"
}

output "zone_crn" {
  value       = join("", ibm_cbr_zone.cbr_zone[*].crn)
  description = "cbr_zone resource instance crn"
}

output "zone_href" {
  value       = join("", ibm_cbr_zone.cbr_zone[*].href)
  description = "cbr_zone resource instance link"
}

output "rule_id" {
  value       = join("", ibm_cbr_rule.cbr_rule[*].id)
  description = "CBR rule resource instance id"
}

output "rule_crn" {
  value       = join("", ibm_cbr_rule.cbr_rule[*].crn)
  description = "CBR rule resource instance crn"
}

output "rule_href" {
  value       = join("", ibm_cbr_rule.cbr_rule[*].href)
  description = "CBR rule resource href"
}
