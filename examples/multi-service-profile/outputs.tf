##############################################################################
# Outputs
##############################################################################

output "zone_id" {
  value       = module.cbr_rule_multi_service_profile[*].zone_id
  description = "CBR zone resource instance id"
}

output "zone_crn" {
  value       = module.cbr_rule_multi_service_profile[*].zone_crn
  description = "CBR zone crn"
}

output "zone_href" {
  value       = module.cbr_rule_multi_service_profile[*].zone_href
  description = "CBR zone href"
}

output "rule_id" {
  value       = module.cbr_rule_multi_service_profile[*].rule_id
  description = "CBR rule id"
}

output "rule_crn" {
  value       = module.cbr_rule_multi_service_profile[*].rule_crn
  description = "CBR rule resource instance crn"
}

output "rule_href" {
  value       = module.cbr_rule_multi_service_profile[*].rule_href
  description = "CBR rule resource instance href"
}

output "vpc_crn" {
  value       = ibm_is_vpc.example_vpc.crn
  description = "VPC CRN"
}

output "account_id" {
  value       = data.ibm_iam_account_settings.iam_account_settings.id
  description = "Account ID (used in tests)"
}
