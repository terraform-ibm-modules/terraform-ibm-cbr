##############################################################################
# Outputs
##############################################################################

output "zone_ids" {
  value       = module.cbr_rule_multi_service_profile[*].zone_ids
  description = "CBR zone id(s)"
}

output "zone_crns" {
  value       = module.cbr_rule_multi_service_profile[*].zone_crns
  description = "CBR zones crn(s)"
}

output "zone_hrefs" {
  value       = module.cbr_rule_multi_service_profile[*].zone_hrefs
  description = "CBR zones href(s)"
}

output "rule_ids" {
  value       = module.cbr_rule_multi_service_profile[*].rule_ids
  description = "CBR rule id(s)"
}

output "rule_crns" {
  value       = module.cbr_rule_multi_service_profile[*].rule_crns
  description = "CBR rule crn(s)"
}

output "rule_hrefs" {
  value       = module.cbr_rule_multi_service_profile[*].rule_hrefs
  description = "CBR rule href(s)"
}

output "vpc_crn" {
  value       = ibm_is_vpc.example_vpc.crn
  description = "VPC CRN"
}

output "account_id" {
  value       = data.ibm_iam_account_settings.iam_account_settings.account_id
  description = "Account ID (used in tests)"
}
