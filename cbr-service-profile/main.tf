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
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.target_service_details[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = var.target_service_details[count.index].target_service_name
        operator = "stringEquals"
      }
    ],
    tags = var.target_service_details[count.index].tags
  }]
  operations = var.target_service_details[count.index].operations
}
