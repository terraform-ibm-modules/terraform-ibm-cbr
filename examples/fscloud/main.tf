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

# todo: rename module
module "cbr_account_level" {
  source                           = "../../profiles/fscloud"
  prefix                           = var.prefix
  zone_vpc_crn_list                = [ibm_is_vpc.example_vpc.crn]
  allow_cos_to_kms                 = var.allow_cos_to_kms
  allow_block_storage_to_kms       = var.allow_block_storage_to_kms
  allow_roks_to_kms                = var.allow_roks_to_kms
  allow_vpcs_to_container_registry = var.allow_vpcs_to_container_registry
  allow_vpcs_to_cos                = var.allow_vpcs_to_cos
  zone_allowed_ip_list             = var.zone_allowed_ip_list
  zone_allowed_ip_range_list       = var.zone_allowed_ip_range_list
  zone_excluded_ip_range_list      = var.zone_excluded_ip_range_list
  zone_exluded_ip_list             = var.zone_exluded_ip_list
  zone_excluded_subnet_list        = var.zone_excluded_subnet_list
  # Demonstrates how additional context to the rules created by this module
  # Example below open up flows from icd mongodb, postgres to kms
  custom_rule_contexts_by_service = {
    "kms" = {
      endpointType      = "public" # TODO: review input to allow passing different end point type for same service
      service_ref_names = ["databases-for-mongodb", "databases-for-postgresql"]
    }
    #  "kms" = {
    #   endpointType      = "private" # TODO: review input to allow passing different end point type for same service
    #   service_ref_names = ["databases-for-postgresql"]
    # }
  }
}
