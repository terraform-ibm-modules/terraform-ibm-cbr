##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

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
  zone_list = [{
    name             = "${var.prefix}-cbr-zone1"
    account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
    zone_description = "cbr-zone1-terraform"
    addresses = [{
      type  = "vpc", # to bind a specific vpc to the zone
      value = resource.ibm_is_vpc.example_vpc.crn,
    }]
    },
    {
      name             = "${var.prefix}-cbr-zone2"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      zone_description = "cbr-zone2-terraform"
      addresses = [{
        type = "serviceRef" # to bind a service reference type should be 'serviceRef'
        ref = {
          account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
          service_name = "directlink" # secrets manager service reference.
        }
      }]
    }
  ]
}

module "cbr_zone" {
  count            = length(local.zone_list)
  source           = "../../cbr-zone-module"
  name             = local.zone_list[count.index].name
  zone_description = local.zone_list[count.index].zone_description
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses        = local.zone_list[count.index].addresses
}

locals {

  # Merge zone ids to pass as contexts to the rule
  rule_contexts = [{
    attributes = [{
      name  = "networkZoneId"
      value = join(",", ([for zone in module.cbr_zone : zone.zone_id]))
    }]
  }]

  pg_resource = [{
    attributes = [
      {
        name     = "accountId"
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
        operator = ""
      },
      {
        name     = "serviceName"
        value    = "cloud-object-storage"
        operator = ""
      }
    ],
    tags = [
      {
        name  = "terraform-rule"
        value = "allow-cos"
      }
    ]
  }]
}

module "cbr_rule" {
  source           = "../../cbr-rule-module"
  rule_description = var.rule_description
  enforcement_mode = var.enforcement_mode
  rule_contexts    = local.rule_contexts
  resources        = local.pg_resource
  operations       = []
}
