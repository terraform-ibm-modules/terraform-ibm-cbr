##############################################################################
# Outputs
##############################################################################

output "rules" {
  value = [
    for rule in module.cbr_rules : {
      description = rule.rule_description
      id          = rule.rule_id
      crn         = rule.rule_crn
      href        = rule.rule_href
    }
  ]
  description = "List of all CBR rules created"
}
