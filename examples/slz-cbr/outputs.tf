##############################################################################
# Outputs
##############################################################################

output "account_id" {
  value       = data.ibm_iam_account_settings.iam_account_settings.account_id
  description = "Account ID (used in tests)"
}

output "cbr_map_service_ref_name_zoneid" {
  value       = one(module.cbr_fscloud[*].map_service_ref_name_zoneid)
  description = "Map of service reference and zone ids"
}

output "cbr_map_target_service_rule_ids" {
  value       = one(module.cbr_fscloud[*].map_target_service_rule_ids)
  description = "Map of target service and rule ids"
}

output "map_vpc_zoneid" {
  value       = one(module.cbr_fscloud[*].map_vpc_zoneid)
  description = "Map of VPC and zone ids"
}