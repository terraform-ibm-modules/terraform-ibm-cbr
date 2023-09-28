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
  value       = module.cos_instance.cos_instance_guid
  description = "COS guid"
}

output "account_id" {
  value       = data.ibm_iam_account_settings.iam_account_settings.id
  description = "Account ID"
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "Resource group ID"
}

output "rule_ids" {
  value       = local.all_rule_ids
  description = "Created Rule IDs"
}
