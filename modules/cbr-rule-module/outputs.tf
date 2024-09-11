##############################################################################
# Outputs
##############################################################################

output "rule_description" {
  value       = ibm_cbr_rule.cbr_rule.description
  description = "CBR rule description"
}

output "rule_id" {
  value       = ibm_cbr_rule.cbr_rule.id
  description = "CBR rule id"
}

output "rule_crn" {
  value       = ibm_cbr_rule.cbr_rule.crn
  description = "CBR rule crn"
}

output "rule_href" {
  value       = ibm_cbr_rule.cbr_rule.href
  description = "CBR rule href"
}
