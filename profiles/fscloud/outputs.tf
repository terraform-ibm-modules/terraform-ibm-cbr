# ##############################################################################
# # Outputs
# ##############################################################################

# output "zone_ids" {
#   value       = [module.cbr_rule_multi_service_profile_1[*].zone_ids, module.cbr_rule_multi_service_profile_2[*].zone_ids]
#   description = "CBR zone resource instance id(s)"
# }

# output "zone_crns" {
#   value       = [module.cbr_rule_multi_service_profile_1[*].zone_crns, module.cbr_rule_multi_service_profile_2[*].zone_crns]
#   description = "CBR zones crn(s)"
# }

# output "zone_hrefs" {
#   value       = [module.cbr_rule_multi_service_profile_1[*].zone_hrefs, module.cbr_rule_multi_service_profile_2[*].zone_hrefs]
#   description = "CBR zones href(s)"
# }

# output "rule_ids" {
#   value       = [module.cbr_rule_multi_service_profile_1[*].rule_ids, module.cbr_rule_multi_service_profile_2[*].rule_ids]
#   description = "CBR rule id(s)"
# }

# output "rule_crns" {
#   value       = [module.cbr_rule_multi_service_profile_1[*].rule_crns, module.cbr_rule_multi_service_profile_2[*].rule_crns]
#   description = "CBR rule resource instance crn(s)"
# }

# output "rule_hrefs" {
#   value       = [module.cbr_rule_multi_service_profile_1[*].rule_hrefs, module.cbr_rule_multi_service_profile_2[*].rule_hrefs]
#   description = "CBR rule resource instance href(s)"
# }

# output "account_id" {
#   value       = data.ibm_iam_account_settings.iam_account_settings.account_id
#   description = "Account ID (used in tests)"
# }

# output "all_services" {
#   value = [local.allow_rules_by_service]
# }

# output "module_rule" {
#   value = module.cbr_rule
# }

# output "ip_zone_list" {
#   value = local.allow_rules_by_service
# }

output "somevalue" {
  value = local.cbr_zone_ip
}

# output "prewired_rule_contexts_by_service" {
#   value = local.prewired_rule_contexts_by_service
# }
