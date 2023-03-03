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

# Resource to create COS instance if create_cos_instance is true
resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.prefix}-mz-rule-example"
  resource_group_id = module.resource_group.resource_group_id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  tags              = var.resource_tags
}

locals {

  # Merge zone ids to pass as contexts to the rule
  rule_contexts = [{
    attributes = [{
      name  = "networkZoneId"
      value = module.cbr_zone[0].zone_id
    }] }, {
    attributes = [
      {
        name  = "networkZoneId"
        value = module.cbr_zone[1].zone_id
      }
    ]
  }]

  rule_resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
        operator = "stringEquals"
      },
      {
        "name" : "resourceGroupId",
        "value" : module.resource_group.resource_group_id
      },
      {
        name     = "serviceInstance"
        value    = ibm_resource_instance.cos_instance.guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
      }
    ],
    tags = [
      # Note these are access tags and all iam access tags must be present on the resource for the rule to match
      {
        name  = "iam_access_tag"
        value = "allow-access"
      },
      {
        name  = "sample_tag"
        value = "secondary_example_tag"
      }
    ]
  }]
}

# Dont forget to add the access tags
resource "ibm_resource_tag" "tags" {
  resource_id = ibm_resource_instance.cos_instance.crn
  tags        = ["allow-access", "secondary_example_tag"]
  tag_type    = "access"
}

module "cbr_rule" {
  source           = "../../cbr-rule-module"
  rule_description = "${var.prefix} ${var.rule_description}"
  enforcement_mode = var.enforcement_mode
  rule_contexts    = local.rule_contexts
  resources        = local.rule_resources
  operations       = []
}
