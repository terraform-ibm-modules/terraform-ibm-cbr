##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}
##############################################################################
# Context Based Restrictions module
#
# Creates CBR Zone & Rule
##############################################################################

module "cbr_zone" {
  source             = "./cbr-zone-module"
  name               = var.name
  account_id         = data.ibm_iam_account_settings.iam_account_settings.account_id
  zone_description   = var.zone_description
  addresses          = var.addresses
  excluded_addresses = var.excluded_addresses
}

module "cbr_rule" {
  source           = "./cbr-rule-module"
  rule_description = var.rule_description
  enforcement_mode = var.enforcement_mode
  rule_contexts    = var.rule_contexts
  resources        = var.resources
  operations       = var.operations
}
