##############################################################################
# Outputs
##############################################################################

output "rule_description" {
  value       = ibm_cbr_rule.cbr_rule.description
  description = "CBR rule resource instance description"
}

output "rule_id" {
  value       = ibm_cbr_rule.cbr_rule.id
  description = "CBR rule resource instance id"
}

output "rule_crn" {
  value       = ibm_cbr_rule.cbr_rule.crn
  description = "CBR rule resource instance crn"
}

output "rule_href" {
  value       = ibm_cbr_rule.cbr_rule.href
  description = "CBR rule resource href"
}
