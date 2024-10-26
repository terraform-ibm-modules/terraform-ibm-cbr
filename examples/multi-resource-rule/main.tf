##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
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
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone
##############################################################################

module "cbr_zone_vpc" {
  source           = "../../modules/cbr-zone-module"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone containing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}

module "cos_instance_and_bucket" {
  source                        = "terraform-ibm-modules/cos/ibm"
  version                       = "8.13.5"
  resource_group_id             = module.resource_group.resource_group_id
  region                        = var.region
  create_cos_instance           = true
  create_cos_bucket             = true
  bucket_name                   = "${var.prefix}-cos-bucket"
  kms_encryption_enabled        = false
  skip_iam_authorization_policy = true
  cos_instance_name             = "${var.prefix}-cos-instance"
}

locals {
  #   List of resources to apply rules to
  resource_list = [
    [{
      attributes = [
        {
          name     = "accountId"
          value    = data.ibm_iam_account_settings.iam_account_settings.account_id
          operator = "stringEquals"
        },
        {
          name     = "serviceInstance"
          value    = module.cos_instance_and_bucket.cos_instance_guid
          operator = "stringEquals"
        },
        {
          name     = "serviceName"
          value    = "cloud-object-storage"
          operator = "stringEquals"
        }
    ] }],
    [{
      attributes = [
        {
          name     = "accountId"
          value    = data.ibm_iam_account_settings.iam_account_settings.account_id
          operator = "stringEquals"
        },
        {
          name     = "serviceInstance"
          value    = module.cos_instance_and_bucket.bucket_crn
          operator = "stringEquals"
        },
        {
          name     = "serviceName"
          value    = "cloud-object-storage"
          operator = "stringEquals"
        }
    ] }]
  ]

  # rule to be applied for each resource
  rule = {
    enforcement_mode = "report"
    rule_contexts = [
      {
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone_vpc.zone_id
          }
        ]
      }
    ]
    operations = [
      {
        api_types = [
          {
            api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
          }
        ]
      }
    ]
  }

  #  List of rule descriptions
  rule_descriptions = [
    "sample rule for the instance ${module.cos_instance_and_bucket.cos_instance_guid} access from vpc zone",
    "sample rule for the bucket ${module.cos_instance_and_bucket.bucket_name} access from vpc zone",
  ]
}

# Create CBR Rules Last
#
module "cbr_rules" {
  count            = length(local.resource_list)
  source           = "../../modules/cbr-rule-module"
  rule_description = local.rule_descriptions[count.index] != null ? local.rule_descriptions[count.index] : "sample rule"
  enforcement_mode = local.rule.enforcement_mode
  rule_contexts    = local.rule.rule_contexts
  resources        = local.resource_list[count.index]
  operations       = local.rule.operations

}
