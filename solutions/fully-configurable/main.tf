##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# CBR Zone Creation
##############################################################################

locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""

  cbr_zone_ids = flatten([
    for zone in module.cbr_zone : [
      zone.zone_id
    ]
  ])
}

module "cbr_zone" {
  for_each              = var.cbr_zones
  source                = "../../modules/cbr-zone-module"
  name                  = "${local.prefix}${each.value.name}"
  account_id            = each.value.account_id == null ? data.ibm_iam_account_settings.iam_account_settings.account_id : each.value.account_id
  zone_description      = each.value.zone_description
  addresses             = each.value.addresses
  excluded_addresses    = each.value.excluded_addresses
  use_existing_cbr_zone = each.value.use_existing_cbr_zone
  existing_zone_id      = each.value.existing_zone_id
}


##############################################################################
# CBR Rule Creation
##############################################################################

locals {
  rule_zone_contexts = {
    for rule_key, rule_val in var.cbr_rules : rule_key => [
      for zone_key in rule_val.zone_keys : {
        attributes = [
          {
            name  = "networkZoneId"
            value = module.cbr_zone[zone_key].zone_id
          }
        ]
      }
    ]
  }

  cbr_rule_ids = flatten([
    for rule in module.cbr_rule : [
      rule.rule_id
    ]
  ])

}

module "cbr_rule" {
  for_each         = var.cbr_rules
  source           = "../../modules/cbr-rule-module"
  rule_description = each.value.rule_description
  # rule_contexts    = concat(local.rule_zone_contexts[each.key], each.value.rule_contexts)
  rule_contexts    = local.rule_zone_contexts[each.key]
  enforcement_mode = each.value.enforcement_mode
  resources        = each.value.resources
  operations       = each.value.operations
}

##############################################################################
# Access policy to view CBRs
##############################################################################

data "ibm_iam_access_group" "service_id_access_group" {
  access_group_name = var.cabin_service_id_access_group
}

resource "ibm_iam_access_group_policy" "network_zone_access_policy" {
  for_each        = var.cabin_service_id_access_group != null ? module.cbr_zone : {}
  access_group_id = data.ibm_iam_access_group.service_id_access_group.groups[0].id
  roles           = ["Administrator"]

  resource_attributes {
    name  = "resource"
    value = each.value.zone_id
  }

  resource_attributes {
    name  = "resourceType"
    value = "zone"
  }

  resource_attributes {
    name  = "serviceName"
    value = "context-based-restrictions"
  }
}
