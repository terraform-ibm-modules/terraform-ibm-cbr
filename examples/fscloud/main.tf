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

##############################################################################
# Key Protect Instance
##############################################################################
module "key_protect_module" {
  source            = "terraform-ibm-modules/key-protect/ibm"
  version           = "v2.3.0"
  key_protect_name  = "${var.prefix}-key-protect-instance"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  service_endpoints = "private"
  plan              = "tiered-pricing"
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
  source                           = "../../modules/fscloud"
  prefix                           = var.prefix
  zone_vpc_crn_list                = [ibm_is_vpc.example_vpc.crn]
  allow_cos_to_kms                 = var.allow_cos_to_kms
  allow_block_storage_to_kms       = var.allow_block_storage_to_kms
  allow_roks_to_kms                = var.allow_roks_to_kms
  allow_vpcs_to_container_registry = var.allow_vpcs_to_container_registry
  allow_vpcs_to_cos                = var.allow_vpcs_to_cos

  # Demonstrates how zone creation will be skipped for these two service references ["user-management", "iam-groups"]
  skip_specific_services_for_zone_creation = ["user-management", "iam-groups"]

  ## Enable enforcement for key protect as an example
  ## The other services not referenced here, are either report, or disabled (when not support report)
  target_service_details = {
    "kms" = {
      "enforcement_mode" = "enabled"
      "instance_id"      = module.key_protect_module.key_protect_guid
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
      },
      {
        endpointType = "public"
      zone_ids = [module.cbr_zone_operator_ips.zone_id] }
    ],
    "schematics" = [{
      endpointType = "public"
      zone_ids     = [module.cbr_zone_operator_ips.zone_id]
    }],
    "databases-for-postgresql" = [{
      endpointType = "private"
      ## Give access to the zone containing the VPC passed in zone_vpc_crn_list input
      add_managed_vpc_zone = true
    }]
  }
}

## Example of zone using ip addresses, and reference in one of the zone created by the cbr_account_level above.
## A zone used to group operator machine ips.
module "cbr_zone_operator_ips" {
  source           = "../../modules/cbr-zone-module"
  name             = "${var.prefix}-List of operator environment public IPs"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  zone_description = "Zone grouping list of known public ips for operator machines"
  addresses = [{
    type  = "subnet"
    value = "0.0.0.0/0" # All ip for this public example - this would be narrowed down typically to an enterprise ip block
  }]
}

## Examples of data lookup on objects (zone, rule) created by the fscloud profile module
## Get rule targetting "event-notification"
data "ibm_cbr_rule" "event_notification_rule" {
  rule_id = module.cbr_account_level.map_target_service_rule_ids["event-notifications"].rule_id
}

## Get zone having "event-notification" as single source
data "ibm_cbr_zone" "event_notifications_zone" {
  zone_id = module.cbr_account_level.map_service_ref_name_zoneid["event-notifications"].zone_id
}
