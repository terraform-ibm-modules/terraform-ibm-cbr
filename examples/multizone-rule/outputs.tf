##############################################################################
# Outputs
##############################################################################

output "zone_id" {
  value       = module.cbr_zone[*].zone_id
  description = "CBR zone resource instance id"
}

output "zone_crn" {
  value       = module.cbr_zone[*].zone_crn
  description = "CBR zone resource instance crn"
}

output "zone_href" {
  value       = module.cbr_zone[*].zone_href
  description = "CBR zone resource instance href"
}

output "cos_guid" {
  value       = ibm_resource_instance.cos_instance.guid
  description = "COS guid (used in tests)"
}

output "account_id" {
  value       = data.ibm_iam_account_settings.iam_account_settings.id
  description = "Account ID (used in tests)"
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "Resource group ID (used for tests)"
}

output "rule_id" {
  value       = module.cbr_rule.rule_id
  description = "CBR rule resource instance id"
}

output "rule_description" {
  value       = module.cbr_rule.rule_description
  description = "CBR rule description"
}

output "rule_crn" {
  value       = module.cbr_rule.rule_crn
  description = "CBR rule resource instance crn"
}

output "rule_href" {
  value       = module.cbr_rule.rule_href
  description = "CBR rule resource instance href"
}
