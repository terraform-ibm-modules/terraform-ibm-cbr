# ##############################################################################
# # Get Cloud Account ID
# ##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# CBR zone & rule creation
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_allow_rules = var.allow_cos_to_kms || var.allow_block_storage_to_kms || var.allow_roks_to_kms || var.allow_vpcs_to_container_registry || var.allow_vpcs_to_cos ? true : tobool("Minimum of one rule has to be set to True")
}

module "cbr_rule_multi_service_profile_1" {
  source = "../../cbr-service-profile"
  count  = var.allow_cos_to_kms || var.allow_block_storage_to_kms || var.allow_roks_to_kms ? 1 : 0
  zone_service_ref_list = concat(var.allow_cos_to_kms ? ["cloud-object-storage"] : [],
    var.allow_block_storage_to_kms ? ["server-protect"] : [],
  var.allow_roks_to_kms ? ["containers-kubernetes"] : [])
  target_service_details = [{
    target_service_name = "kms",
    target_rg           = var.resource_group_id
    enforcement_mode    = var.enforcement_mode,
  }]
}

module "cbr_rule_multi_service_profile_2" {
  source            = "../../cbr-service-profile"
  count             = var.allow_vpcs_to_container_registry || var.allow_vpcs_to_cos ? 1 : 0
  zone_vpc_crn_list = var.zone_vpc_crn_list
  target_service_details = concat(var.allow_vpcs_to_container_registry ? [{
    target_service_name = "container-registry",
    target_rg           = var.resource_group_id
    enforcement_mode    = var.enforcement_mode,
    }] : [],
    var.allow_vpcs_to_cos ? [{
      target_service_name = "cloud-object-storage",
      tags                = var.existing_access_tags,
      enforcement_mode    = var.enforcement_mode,
  }] : [])
}
