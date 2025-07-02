##############################################################################
# Outputs
##############################################################################

output "network_zone_ids" {
  value       = local.cbr_zone_ids
  description = "List of all the CBR zones created"
}

output "cbr_rule_ids" {
  value       = local.cbr_rule_ids
  description = "List of all the CBR rules created"
}
