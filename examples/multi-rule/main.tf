##############################################################################
# Rule Setup
##############################################################################
locals {
  bucket_cbr_rules = [
    {
      description      = "sample rule for buckets"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
      operations = [{
        api_types = [{
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
        }]
      }]
    }
  ]

  instance_cbr_rules = [
    {
      description      = "sample rule for the instance"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
      operations = [{
        api_types = [{
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
        }]
      }]
    }
  ]
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

module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.9.0"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone containing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}

module "cos_instance" {
  source                        = "terraform-ibm-modules/cos/ibm"
  version                       = "6.12.2"
  resource_group_id             = module.resource_group.resource_group_id
  region                        = var.region
  create_cos_instance           = true
  create_cos_bucket             = false
  skip_iam_authorization_policy = true
  cos_instance_name             = "${var.prefix}-cos-instance"
}

module "cos_buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "6.12.2"
  bucket_configs = [
    {
      bucket_name            = "${var.prefix}-bucket-1"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_group_id      = module.resource_group.resource_group_id
      resource_instance_id   = module.cos_instance.cos_instance_id
    },
    {
      bucket_name            = "${var.prefix}-bucket-2"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_group_id      = module.resource_group.resource_group_id
      resource_instance_id   = module.cos_instance.cos_instance_id
    }
  ]
}

locals {
  # Filter out empty iam resource access tags access tags for buckets
  # With out this each bucket gets a tag with an empty value if no tags are specified
  filtered_bucket_tags = {
    for bucket in module.cos_buckets.buckets : bucket.bucket_name => [
      for cbr_rule in local.bucket_cbr_rules : {
        name  = lookup(cbr_rule, "tags[*].name", null)
        value = lookup(cbr_rule, "tags[*].value", null)
      } if length([for tag in lookup(cbr_rule, "tags[*].name", []) : tag]) > 0
    ]
  }


  bucket_tags = {
    for bucket, tags in local.filtered_bucket_tags : bucket => tags
  }


  bucket_rule_resources = {
    for bucket in module.cos_buckets.buckets : bucket.bucket_name => [
      {
        attributes = [
          {
            name     = "accountId"
            value    = data.ibm_iam_account_settings.iam_account_settings.account_id
            operator = "stringEquals"
          },
          {
            name     = "serviceInstance"
            value    = coalesce(bucket.bucket_crn, "test")
            operator = "stringEquals"
          },
          {
            name     = "serviceName"
            value    = "cloud-object-storage"
            operator = "stringEquals"
          }
        ],
        tags = local.bucket_tags[bucket.bucket_name] == null ? [] : local.bucket_tags[bucket.bucket_name]
      }
    ]
  }
  bucket_rule_descriptions = {
    for bucket in module.cos_buckets.buckets : bucket.bucket_name => [
      for cbr_rule in local.bucket_cbr_rules : "${cbr_rule.description} for bucket ${bucket.bucket_name}"
    ]
  }


  bucket_rules = [
    for cbr_rule in local.bucket_cbr_rules : {
      account_id       = cbr_rule.account_id
      enforcement_mode = cbr_rule.enforcement_mode
      rule_contexts    = cbr_rule.rule_contexts
      operations       = cbr_rule.operations
    }
  ]


}


# Create CBR Rules Last
#
module "bucket_cbr_rules" {
  for_each = { for bucket in module.cos_buckets.buckets : bucket.bucket_name => bucket }

  depends_on = [module.cos_buckets]
  source     = "../../modules/cbr-mutli-rule-module"

  rule_list         = local.bucket_rules
  rule_descriptions = local.bucket_rule_descriptions[each.key]
  rule_resources    = local.bucket_rule_resources[each.key]
}

module "instance_cbr_rule" {
  depends_on       = [module.bucket_cbr_rules]
  count            = length(local.instance_cbr_rules)
  source           = "../../modules/cbr-rule-module"
  rule_description = local.instance_cbr_rules[count.index].description
  enforcement_mode = local.instance_cbr_rules[count.index].enforcement_mode
  rule_contexts    = local.instance_cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = local.instance_cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = module.cos_instance.cos_instance_guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
      }
    ],
  }]
  operations = local.instance_cbr_rules[count.index].operations
}

locals {
  # Get a complete list of all CBR rule IDs
  bucket_rule_ids = flatten([
    for instance in module.bucket_cbr_rules :
    [
      for rule in instance.rules :
      rule.id
    ]
  ])

  instance_rule_ids = module.instance_cbr_rule[*].rule_id
  all_rule_ids      = concat(local.bucket_rule_ids, local.instance_rule_ids)
}
