##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
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
  zone_vpc_id_list = [ibm_is_vpc.example_vpc.crn]
  enforcement_mode = "report"
  # Merge zone ids to pass as contexts to the rule
  target_services_details = [
    {
      target_service_name = "cloud-object-storage"
      tags = [
        {
          name  = "env"
          value = "test"
        }
      ],
      enforcement_mode = local.enforcement_mode,
    },
    {
      target_service_name = "kms",
      enforcement_mode    = local.enforcement_mode,

    },
    {
      target_service_name = "messagehub",
      enforcement_mode    = local.enforcement_mode
  }]
}

module "cbr_rule_multi_service_profile" {
  source                 = "../../cbr-service-profile"
  zone_vpc_id_list       = local.zone_vpc_id_list
  zone_service_ref_list  = var.zone_service_ref_list
  target_service_details = local.target_services_details
}