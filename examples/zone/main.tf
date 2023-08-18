##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.0.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
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

locals {
  zone_address_details = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = resource.ibm_is_vpc.example_vpc.crn,
    }, {
    type = "serviceRef" # to bind a service reference type should be 'serviceRef'
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "secrets-manager" # secrets manager service reference.
    }
  }]
}

module "ibm_cbr_zone" {
  source           = "../../modules/cbr-zone-module"
  name             = "${var.prefix}-cbr-zone"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  zone_description = var.zone_description
  addresses        = local.zone_address_details
}
