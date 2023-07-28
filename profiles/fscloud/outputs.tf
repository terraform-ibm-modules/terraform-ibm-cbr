# ##############################################################################
# # Outputs
# ##############################################################################

output "account_id" {
  value       = data.ibm_iam_account_settings.iam_account_settings.account_id
  description = "Account ID"
}
output "map_service_ref_name_zoneid" {
  value = { for key, value in local.cbr_zones :
    key => {
      zone_id = value.zone_id
  } }
  description = "Map of service reference and zone ids"
}

output "map_vpc_zoneid" {
  value = {
    zone_id = local.cbr_zone_vpcs.zone_id
  }
  description = "Map of VPC and zone ids"
}

output "map_target_service_rule_ids" {
  value = { for key, value in module.cbr_rule :
    key => {
      rule_id = value.rule_id
  } }
  description = "Map of target service and rule ids"
}
