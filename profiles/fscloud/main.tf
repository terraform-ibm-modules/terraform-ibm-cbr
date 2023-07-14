# ##############################################################################
# # Get Cloud Account ID
# ##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# VPC
##############################################################################
resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = var.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_public_gateway" "testacc_gateway" {
  name           = "${var.prefix}-pgateway"
  vpc            = ibm_is_vpc.example_vpc.id
  zone           = "${var.region}-1"
  resource_group = var.resource_group_id
}

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "${var.region}-1"
  public_gateway           = ibm_is_public_gateway.testacc_gateway.id
  total_ipv4_address_count = 256
  resource_group           = var.resource_group_id
}

##############################################################################
# CBR zone & rule creation
##############################################################################

locals {
  zone_vpc_crn_list = [var.zone_vpc_crn_list]
  enforcement_mode  = var.enforcement_mode

  zone_service_ref_list = []
  # Merge zone ids to pass as contexts to the rule
  target_services_details = [
    {
      target_service_name = "kms",
      target_rg           = var.resource_group_id
      enforcement_mode    = local.enforcement_mode,
    }
  ]
}

module "cbr_rule_multi_service_profile" {
  source                 = "../../cbr-service-profile"
  zone_service_ref_list  = ["cloud-object-storage"]
  zone_vpc_crn_list      = local.zone_vpc_crn_list
  target_service_details = local.target_services_details
}
