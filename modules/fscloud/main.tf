###############################################################################
## Get Cloud Account ID
###############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

locals {

  target_service_details_default = {
    "iam-groups" : {
      "enforcement_mode" : "report"
    },
    "iam-access-management" : {
      "enforcement_mode" : "report"
    },
    "iam-identity" : {
      "enforcement_mode" : "report"
    },
    "user-management" : {
      "enforcement_mode" : "report"
    },
    "cloud-object-storage" : {
      "enforcement_mode" : "report"
    },
    "codeengine" : {
      "enforcement_mode" : "report"
    },
    "container-registry" : {
      "enforcement_mode" : "report"
    },
    "databases-for-cassandra" : {
      "enforcement_mode" : "disabled"
    },
    "databases-for-enterprisedb" : {
      "enforcement_mode" : "disabled"
    },
    "databases-for-elasticsearch" : {
      "enforcement_mode" : "disabled"
    },
    "databases-for-etcd" : {
      "enforcement_mode" : "disabled"
    },
    "databases-for-mongodb" : {
      "enforcement_mode" : "disabled"
    },
    "databases-for-mysql" : {
      "enforcement_mode" : "disabled"
    },
    "databases-for-postgresql" : {
      "enforcement_mode" : "disabled"
    },
    "databases-for-redis" : {
      "enforcement_mode" : "disabled"
    },
    "directlink" : {
      "enforcement_mode" : "report"
    },
    "dns-svcs" : {
      "enforcement_mode" : "report"
    },
    "messagehub" : {
      "enforcement_mode" : "report"
    },
    "kms" : {
      "enforcement_mode" : "report"
    },
    "containers-kubernetes" : {
      "enforcement_mode" : "disabled"
    },
    "messages-for-rabbitmq" : {
      "enforcement_mode" : "disabled"
    },
    "secrets-manager" : {
      "enforcement_mode" : "report"
    },
    "transit" : {
      "enforcement_mode" : "report"
    },
    "is" : {
      "enforcement_mode" : "report"
    },
    "schematics" : {
      "enforcement_mode" : "report"
    },
    "apprapp" : {
      "enforcement_mode" : "report"
    },
    "event-notifications" : {
      "enforcement_mode" : "report"
    },
    "compliance" : {
      "enforcement_mode" : "report"
    }
  }

  target_service_details = merge(local.target_service_details_default, var.target_service_details)

  zone_final_service_ref_list = [
    for service in var.zone_service_ref_list : service if !contains(var.skip_specific_services_for_zone_creation, service)
  ]
}

###############################################################################
# Pre-create coarse grained CBR zones for each service
###############################################################################

locals {
  service_ref_zone_list = (length(local.zone_final_service_ref_list) > 0) ? [
    for serviceref in local.zone_final_service_ref_list : {
      name             = "${var.prefix}-${serviceref}-service-zone"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      zone_description = "Single zone for service ${serviceref}."
      # when the target service is containers-kubernetes or any icd services, context cannot have a serviceref
      addresses = [
        {
          type = "serviceRef"
          ref = {
            account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
            service_name = serviceref
          }
        }
      ]
  }] : []

  service_ref_zone_map_pre_check = zipmap(local.zone_final_service_ref_list, local.service_ref_zone_list)

  service_ref_zone_map_check = merge(local.service_ref_zone_map_pre_check, var.existing_serviceref_zone)

  service_ref_zone_map = { for k, v in local.service_ref_zone_map_check : k => v if !contains(keys(v), "zone_id") }

  cbr_zones = merge(module.cbr_zone, var.existing_serviceref_zone)

  cbr_zone_vpcs = var.existing_cbr_zone_vpcs == null ? module.cbr_zone_vpcs[0] : var.existing_cbr_zone_vpcs
}

module "cbr_zone" {
  for_each         = local.service_ref_zone_map
  source           = "../../modules/cbr-zone-module"
  name             = each.value.name
  zone_description = each.value.zone_description
  account_id       = each.value.account_id
  addresses        = each.value.addresses
}

###############################################################################
# Pre-create default 'deny' zone. Zone that acts as a deny
# Some context: CBR allow all, unless there is at least one zone defined in a rule
# There is no concept of deny by default out of the box
# We pick a "dummy" IP that we know won't route.
###############################################################################

module "cbr_zone_deny" {
  source           = "../../modules/cbr-zone-module"
  name             = "${var.prefix}-deny-all"
  zone_description = "Zone that may be used to force a deny-all."
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [
    {
      type  = "ipAddress"
      value = "1.1.1.1"
    }
  ]
}

###############################################################################
# Pre-create zones containing the fscloud VPCs
###############################################################################

module "cbr_zone_vpcs" {
  count            = var.existing_cbr_zone_vpcs != null ? 0 : 1
  source           = "../../modules/cbr-zone-module"
  name             = "${var.prefix}-vpcs-zone"
  zone_description = "Single zone grouping all VPCs participating in a fscloud topology."
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [
    for zone_vpc_crn in var.zone_vpc_crn_list :
    { "type" = "vpc", value = zone_vpc_crn }
  ]
}


##############################################################################
# Create CBR zones for each service
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_allow_rules = var.allow_cos_to_kms || var.allow_block_storage_to_kms || var.allow_roks_to_kms || var.allow_vpcs_to_container_registry || var.allow_vpcs_to_cos ? true : tobool("Minimum of one rule has to be set to True")
  ## define FsCloud pre-wired CBR rule context - contains the known default flow that must be open for fscloud ref architecture
  cos_cbr_zone_id = local.cbr_zones["cloud-object-storage"].zone_id
  # tflint-ignore: terraform_naming_convention
  server-protect_cbr_zone_id = local.cbr_zones["server-protect"].zone_id # block storage
  # tflint-ignore: terraform_naming_convention
  containers-kubernetes_cbr_zone_id = local.cbr_zones["containers-kubernetes"].zone_id

  prewired_rule_contexts_by_service = {
    # COS -> KMS, Block storage -> KMS, ROKS -> KMS
    "kms" : [{
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_cos_to_kms ? [local.cos_cbr_zone_id] : [],
        var.allow_block_storage_to_kms ? [local.server-protect_cbr_zone_id] : [],
        var.allow_roks_to_kms ? [local.containers-kubernetes_cbr_zone_id] : []
      ])
    }],
    # Fs VPCs -> COS
    "cloud-object-storage" : [{
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_vpcs_to_cos ? [local.cbr_zone_vpcs.zone_id] : []
      ])
    }],
    # VPCs -> container registry
    "container-registry" : [{
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_vpcs_to_container_registry ? [local.cbr_zone_vpcs.zone_id] : []
      ])
    }],
    # TODO: Activity Tracker route -> COS (pending support of AT as CBR zone)
  }

  prewired_rule_contexts_by_service_pre_check = { for key, value in local.prewired_rule_contexts_by_service :
    key => [
      for rule in value :
      rule if length(rule.networkZoneIds) > 0
    ]
  }

  prewired_rule_contexts_by_service_check = { for key, value in local.prewired_rule_contexts_by_service_pre_check :
    key => value if length(value) > 0
  }


  ## define default 'deny' rule context
  deny_rule_context_by_service = { for target_service_name in keys(local.target_service_details) :
    target_service_name => [{ endpointType : "public", networkZoneIds : [module.cbr_zone_deny.zone_id] }]
  }

  ## define context for any custom rules
  custom_rule_contexts_by_service = { for target_service_name, custom_rule_contexts in var.custom_rule_contexts_by_service :
    target_service_name => [for custom_rule_context in custom_rule_contexts :
      custom_rule_context.add_managed_vpc_zone == true ?
      {
        endpointType = custom_rule_context.endpointType
        networkZoneIds : [local.cbr_zone_vpcs.zone_id]
      }
      :
      {
        endpointType = custom_rule_context.endpointType
        networkZoneIds : flatten(concat([for service_name in custom_rule_context.service_ref_names : local.cbr_zones[service_name].zone_id], custom_rule_context.zone_ids))
      }
    ]
  }


  # Merge map values (array of context) under the same service-name key
  all_services = keys(merge(local.deny_rule_context_by_service, local.prewired_rule_contexts_by_service_check, local.custom_rule_contexts_by_service))
  allow_rules_by_service_intermediary = { for service_name in local.all_services :
    service_name => flatten([lookup(local.deny_rule_context_by_service, service_name, []), lookup(local.prewired_rule_contexts_by_service_check, service_name, []), lookup(local.custom_rule_contexts_by_service, service_name, [])])
  }

  allow_rules_by_service = { for target_service_name, contexts in local.allow_rules_by_service_intermediary :
    target_service_name => [for context in contexts : { attributes = [
      {
        "name" : "endpointType",
        "value" : context.endpointType
      },
      {
        "name" : "networkZoneId",
        "value" : join(",", context.networkZoneIds)
      }
    ] }]
  }

  # Some services have restrictions on the api types that can apply CBR - we codify this below
  # Restrict and allow the api types as per the target service
  icd_api_types = ["crn:v1:bluemix:public:context-based-restrictions::::api-type:data-plane"]
  operations_apitype_val = {
    databases-for-enterprisedb  = local.icd_api_types,
    containers-kubernetes       = ["crn:v1:bluemix:public:containers-kubernetes::::api-type:cluster", "crn:v1:bluemix:public:containers-kubernetes::::api-type:management"],
    databases-for-cassandra     = local.icd_api_types,
    databases-for-elasticsearch = local.icd_api_types,
    databases-for-etcd          = local.icd_api_types,
    databases-for-mongodb       = local.icd_api_types,
    databases-for-postgresql    = local.icd_api_types,
    databases-for-redis         = local.icd_api_types,
    messages-for-rabbitmq       = local.icd_api_types,
    databases-for-mysql         = local.icd_api_types
  }
}

# Create a rule for all services by default
module "cbr_rule" {
  for_each         = local.target_service_details
  source           = "../../modules/cbr-rule-module"
  rule_description = "${var.prefix}-${each.key}-rule"
  enforcement_mode = each.value.enforcement_mode
  rule_contexts    = lookup(local.allow_rules_by_service, each.key, [])
  operations = (length(lookup(local.operations_apitype_val, each.key, [])) > 0) ? [{
    api_types = [
      # lookup the map for the target service name, if not present make api_type_id as empty
      for apitype in lookup(local.operations_apitype_val, each.key, []) : {
        api_type_id = apitype
    }]
  }] : []

  resources = [{
    tags = try(each.value.tags, null) != null ? [for tag in each.value.tags : {
      name  = split(":", tag)[0]
      value = split(":", tag)[1]
    }] : []
    attributes = try(each.value.target_rg, null) != null ? [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      {
        name     = "resourceGroupId",
        operator = "stringEquals",
        value    = each.value.target_rg
      },
      {
        name     = "serviceName",
        operator = "stringEquals",
        value    = each.key
      }] : try(each.value.instance_id, null) != null ? [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      {
        name     = "serviceInstance",
        operator = "stringEquals",
        value    = each.value.instance_id
      },
      {
        name     = "serviceName",
        operator = "stringEquals",
        value    = each.key
      }] : [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      {
        name     = "serviceName",
        operator = "stringEquals",
        value    = each.key
    }]
  }]
}
