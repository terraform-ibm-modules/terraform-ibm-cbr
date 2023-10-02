##############################################################################
# Context Based Restrictions module
#
# Creates CBR Rules
##############################################################################
module "cbr_rules" {
  count            = length(var.rule_list)
  source           = "../cbr-rule-module"
  rule_description = var.rule_descriptions[count.index] != null ? var.rule_descriptions[count.index] : "sample rule"
  enforcement_mode = var.rule_list[count.index].enforcement_mode
  rule_contexts    = var.rule_list[count.index].rule_contexts
  resources        = var.rule_resources != null ? var.rule_resources : []
  operations       = var.rule_list[count.index].operations == null ? [] : var.rule_list[count.index].operations
}
