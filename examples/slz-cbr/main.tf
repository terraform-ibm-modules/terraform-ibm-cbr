# ##############################################################################
# # Get Cloud Account ID
# ##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

### TEST ANOTHER ACC ID ========>>>>>>

module "cbr_fscloud" {
  count  = var.provision_cbr ? 1 : 0
  source = "../../modules/fscloud"
  prefix = var.cbr_prefix
}
