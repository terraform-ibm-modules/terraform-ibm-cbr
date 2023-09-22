##############################################################################
# Context Based Restrictions module
#
# Creates CBR Rules
##############################################################################
module "cbr_rules" {
  count            = length(var.cbr_rule_list)
  source           = "../cbr-rule-module"
  rule_description = var.cbr_rule_list[count.index].description
  enforcement_mode = var.cbr_rule_list[count.index].enforcement_mode
  rule_contexts    = var.cbr_rule_list[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.cbr_rule_list[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "resource"
        value    = var.resource == "" ? var.cbr_rule_list[count.index].resource : var.resource
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = var.service_instance == "" ? var.cbr_rule_list[count.index].service_instance : var.service_instance
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
      }
    ],
    tags = var.cbr_rule_list[count.index].tags
  }]
  operations = var.cbr_rule_list[count.index].operations == null ? [] : var.cbr_rule_list[count.index].operations
}
