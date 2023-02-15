##############################################################################
#
# CBR Rule for a list of target services
##############################################################################
module "cbr_rule" {
  count            = length(var.target_service_details)
  source           = "../cbr-rule-module"
  rule_description = var.rule_description
  enforcement_mode = var.enforcement_mode
  rule_contexts    = var.rule_contexts
  operations       = var.target_service_details[count.index].operations
  resources = [{
    tags       = var.target_service_details[count.index].tags
    attributes = var.target_service_details[count.index].attributes,
  }]
}
