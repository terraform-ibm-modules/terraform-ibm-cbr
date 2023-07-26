##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

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
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_public_gateway" "testacc_gateway" {
  name           = "${var.prefix}-pgateway"
  vpc            = ibm_is_vpc.example_vpc.id
  zone           = "${var.region}-1"
  resource_group = module.resource_group.resource_group_id
}

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "${var.region}-1"
  public_gateway           = ibm_is_public_gateway.testacc_gateway.id
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

##############################################################################
# CBR zone & rule creation
##############################################################################

module "cbr_rule_multi_service_profile" {
  source            = "../../profiles/fscloud"
  prefix            = var.prefix
  zone_vpc_crn_list = [ibm_is_vpc.example_vpc.crn]
  # zone_allowed_ip_list             = var.zone_allowed_ip_list
  # zone_allowed_ip_range_list       = var.zone_allowed_ip_range_list
  resource_group_id                = module.resource_group.resource_group_id
  existing_access_tags             = var.existing_access_tags
  enforcement_mode                 = var.enforcement_mode
  allow_cos_to_kms                 = var.allow_cos_to_kms
  allow_block_storage_to_kms       = var.allow_block_storage_to_kms
  allow_roks_to_kms                = var.allow_roks_to_kms
  allow_vpcs_to_container_registry = var.allow_vpcs_to_container_registry
  allow_vpcs_to_cos                = var.allow_vpcs_to_cos
}
