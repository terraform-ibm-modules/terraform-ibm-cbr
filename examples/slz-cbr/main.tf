# ##############################################################################
# # Get Cloud Account ID
# ##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}


module "cbr_fscloud" {
  count                                  = var.provision_cbr ? 1 : 0
  source                                 = "../../modules/fscloud"
  prefix                                 = var.cbr_prefix
  zone_vpc_crn_list                      = []
  allow_cos_to_kms                       = var.cbr_allow_cos_to_kms
  allow_block_storage_to_kms             = var.cbr_allow_block_storage_to_kms
  allow_roks_to_kms                      = var.cbr_allow_roks_to_kms
  allow_icd_to_kms                       = var.cbr_allow_icd_to_kms
  allow_event_streams_to_kms             = var.cbr_allow_event_streams_to_kms
  allow_vpcs_to_container_registry       = var.cbr_allow_vpcs_to_container_registry
  allow_vpcs_to_cos                      = var.cbr_allow_vpcs_to_cos
  allow_at_to_cos                        = var.cbr_allow_at_to_cos
  allow_iks_to_is                        = var.cbr_allow_iks_to_is
  allow_is_to_cos                        = var.cbr_allow_is_to_cos
  kms_service_targeted_by_prewired_rules = var.cbr_kms_service_targeted_by_prewired_rules
}
