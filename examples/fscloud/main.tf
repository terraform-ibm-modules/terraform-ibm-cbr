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

module "cbr_account_level" {
  source                           = "../../profiles/fscloud"
  prefix                           = var.prefix
  zone_vpc_crn_list                = [ibm_is_vpc.example_vpc.crn]
  allow_cos_to_kms                 = var.allow_cos_to_kms
  allow_block_storage_to_kms       = var.allow_block_storage_to_kms
  allow_roks_to_kms                = var.allow_roks_to_kms
  allow_vpcs_to_container_registry = var.allow_vpcs_to_container_registry
  allow_vpcs_to_cos                = var.allow_vpcs_to_cos
  ip_addresses                     = var.ip_addresses
  ip_excluded_addresses            = var.ip_excluded_addresses

  target_service_details = {
    "kms" = {
      "enforcement_mode" = "enabled"
    }
  }

  # Demonstrates how additional context to the rules created by this module can be added.
  # This example open up:
  #   1. Flows from icd mongodb, postgresql to kms on private endpoint
  #   2. Flow from schematics on public kms endpoint
  #   3. Add a block of ips to schematics public endpoint
  #   4. Flow from vpc(s) specified in input zone_vpc_crn_list to postgresql private endpoint
  custom_rule_contexts_by_service = {
    "kms" = [{
      endpointType      = "private"
      service_ref_names = ["databases-for-mongodb", "databases-for-postgresql"]
      },
      {
        endpointType      = "public"
        service_ref_names = ["schematics"]
      }
    ],
    "schematics" = [{
      endpointType = "public"
      zone_ids     = [module.cbr_zone_operator_ips.zone_id]
    }],
    "databases-for-postgresql" = [{
      endpointType         = "private"
      add_managed_vpc_zone = true
    }]
  }
}

module "cbr_zone_operator_ips" {
  source           = "../../cbr-zone-module"
  name             = "List of operator environment public IPs"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  zone_description = "Zone grouping list of known public ips for operator machines"
  addresses = [{
    type  = "subnet"
    value = "0.0.0.0/0" # All ip for this public example - this would be narrowed down typically to an enterprise ip block
  }]
}