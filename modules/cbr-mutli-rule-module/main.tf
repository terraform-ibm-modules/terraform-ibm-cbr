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
  resources        = var.cbr_rule_list[count.index].resources
  tags             = var.cbr_rule_list[count.index].tags
  operations       = var.cbr_rule_list[count.index].operations == null ? [] : var.cbr_rule_list[count.index].operations
}
