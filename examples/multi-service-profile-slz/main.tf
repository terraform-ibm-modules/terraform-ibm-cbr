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

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

##############################################################################
# CBR zone & rule creation
##############################################################################

locals {
  zone_vpc_crn_list = [ibm_is_vpc.example_vpc.crn]
  enforcement_mode  = "report"
}


##############################################################################
# CBR rule for KMS service
# Allow calls from COS, ROKS, Block Storage services
##############################################################################

module "cbr_rule_kms" {
  source                = "../../cbr-service-profile"
  prefix                = "slz-kms-2"
  zone_service_ref_list = ["cloud-object-storage", "server-protect", "containers-kubernetes"]
  target_service_details = [{
    target_service_name = "kms",
    tags                = var.existing_access_tags,
    enforcement_mode    = local.enforcement_mode,
  }]
}

##############################################################################
# CBR rule for COS service
# Allow calls to COS from VPC compute resources, Activity Tracker (TODO)
##############################################################################

module "cbr_rule_cos" {
  source = "../../cbr-service-profile"
  prefix = "slz-cos-2"
  zone_vpc_crn_list = local.zone_vpc_crn_list
  target_service_details = [{
    target_service_name = "cloud-object-storage",
    tags                = var.existing_access_tags,
    enforcement_mode    = local.enforcement_mode,
  }]
}

##############################################################################
# CBR rule for container registry
# Allow calls to container registry from VPC compute resources
##############################################################################

module "cbr_rule_cr" {
  source            = "../../cbr-service-profile"
  prefix            = "slz-cr-2"
  zone_vpc_crn_list = local.zone_vpc_crn_list
  target_service_details = [{
    target_service_name = "container-registry",
    tags                = var.existing_access_tags,
    enforcement_mode    = local.enforcement_mode,
  }]
}

