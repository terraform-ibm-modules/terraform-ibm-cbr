##############################################################################
# Outputs
##############################################################################

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
