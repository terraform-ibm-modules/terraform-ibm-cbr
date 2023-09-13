##############################################################################
# Outputs
##############################################################################

output "account_id" {
  value       = data.ibm_iam_account_settings.iam_account_settings.account_id
  description = "Account ID (used in tests)"
}

output "map_service_ref_name_zoneid" {
  value       = module.cbr_account_level.map_service_ref_name_zoneid
  description = "Map of service reference and zone ids"
}

output "map_vpc_zoneid" {
  value       = module.cbr_account_level.map_vpc_zoneid
  description = "Map of VPC and zone ids"
}

output "map_target_service_rule_ids" {
  value       = module.cbr_account_level.map_target_service_rule_ids
  description = "Map of target service and rule ids"
}

output "example_event_notification_zone" {
  value       = data.ibm_cbr_rule.event_notification_rule
  description = "Example of rule created by the module. Demonstrates data lookup."
}

output "example_event_notification_rule" {
  value       = data.ibm_cbr_zone.event_notifications_zone
  description = "Example of zone created by the module. Demonstrates data lookup."
}
