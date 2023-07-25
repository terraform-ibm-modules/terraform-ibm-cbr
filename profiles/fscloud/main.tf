###############################################################################
## Get Cloud Account ID
###############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

###############################################################################
# Pre-create coarse grained CBR zones for each service
###############################################################################

locals {
  service_ref_zone_list = (length(var.zone_service_ref_list) > 0) ? [
    for serviceref in var.zone_service_ref_list : {
      name             = "${var.prefix}-${serviceref}-cbr-serviceref-zone"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      zone_description = "${serviceref}-cbr-serviceref-zone-terraform"
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

  service_ref_zone_map = zipmap(var.zone_service_ref_list, local.service_ref_zone_list)
}

module "cbr_zone" {
  for_each         = local.service_ref_zone_map
  source           = "../../cbr-zone-module"
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
  source           = "../../cbr-zone-module"
  name             = "${var.prefix}-deny-all"
  zone_description = "${var.prefix}-deny-all"
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
  source           = "../../cbr-zone-module"
  name             = "${var.prefix}-cbr-vpc-zone-terraform"
  zone_description = "${var.prefix}-cbr-vpc-zone-terraform"
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
  cos_cbr_zone_id = module.cbr_zone["cloud-object-storage"].zone_id
  # tflint-ignore: terraform_naming_convention
  server-protect_cbr_zone_id = module.cbr_zone["server-protect"].zone_id # block storage
  # tflint-ignore: terraform_naming_convention
  containers-kubernetes_cbr_zone_id = module.cbr_zone["containers-kubernetes"].zone_id

  prewired_rule_contexts_by_service = {
    # COS -> KMS, Block storage -> KMS, ROKS -> KMS
    "kms" : {
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_cos_to_kms ? [local.cos_cbr_zone_id] : [],
        var.allow_block_storage_to_kms ? [local.server-protect_cbr_zone_id] : [],
        var.allow_roks_to_kms ? [local.containers-kubernetes_cbr_zone_id] : []
      ])
    },
    # Fs VPCs -> COS
    "cloud-object-storage" : {
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_vpcs_to_cos ? [module.cbr_zone_vpcs.zone_id] : []
      ])
    },
    # VPCs -> container registry
    "container-registry" : {
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_vpcs_to_container_registry ? [module.cbr_zone_vpcs.zone_id] : []
      ])
    },
    # TODO: Activity Tracker route -> COS (pending support of AT as CBR zone)
  }

  ## define default 'deny' rule context
  deny_rule_context_by_service = { for service_name in var.target_service_details[*].target_service_name :
    service_name => { endpointType : "public", networkZoneIds : [module.cbr_zone_deny.zone_id] }
  }

  ## define context for any custom rules
  custom_rule_contexts_by_service = { for k, v in var.custom_rule_contexts_by_service :
    k => {
      endpointType = v.endpointType
      networkZoneIds : flatten(concat([for service_name in v.service_ref_names : module.cbr_zone[service_name].zone_id], v.zone_ids))
    }
  }


  # Merge map values (array of context) under the same service-name key
  all_services = keys(merge(local.deny_rule_context_by_service, local.prewired_rule_contexts_by_service, local.custom_rule_contexts_by_service))
  allow_rules_by_service_intermediary = { for service_name in local.all_services :
    service_name => flatten([lookup(local.deny_rule_context_by_service, service_name, []), lookup(local.prewired_rule_contexts_by_service, service_name, []), lookup(local.custom_rule_contexts_by_service, service_name, [])])
  }

  # Convert data structure
  # From { endpointType : "private", networkZoneIds : [] } to
  # attributes = [
  #   {
  #     "name" : "endpointType",
  #     "value" : "private"
  #   },
  #   {
  #     name  = "networkZoneIds"
  #     value = join(",", networkZoneIds)
  # }]
  allow_rules_by_service = { for service_name, contexts in local.allow_rules_by_service_intermediary :
    service_name => [for context in contexts : { attributes = [
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

locals {
  target_service_details_by_service_name = { for service in var.target_service_details :
    service.target_service_name => service
  }
}

module "cbr_rule" {
  for_each = local.target_service_details_by_service_name
  #count            = length(var.target_service_details)
  source           = "../../cbr-rule-module"
  rule_description = "${var.prefix}-${each.key}-serviceprofile-rule"
  enforcement_mode = each.value.enforcement_mode
  rule_contexts    = lookup(local.allow_rules_by_service, each.key, []) #local.rule_contexts
  operations = (length(lookup(local.operations_apitype_val, each.key, [])) > 0) ? [{
    api_types = [
      # lookup the map for the target service name, if not present make api_type_id as empty
      for apitype in lookup(local.operations_apitype_val, each.key, []) : {
        api_type_id = apitype
    }]
  }] : []

  resources = [{
    tags = each.value.tags != null ? [for tag in each.value.tags : {
      name  = split(":", tag)[0]
      value = split(":", tag)[1]
    }] : []
    attributes = each.value.target_rg != null ? [
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
