###############################################################################
## Get Cloud Account ID
###############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

locals {

  service_group_ids = ["IAM"] # List of pseudo services for which service_group_id is required

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
    "hs-crypto" : {
      "enforcement_mode" : "report"
    },
    "containers-kubernetes-management" : {
      "enforcement_mode" : "disabled"
    },
    "containers-kubernetes-cluster" : {
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
      "enforcement_mode" : "disabled"
    },
    "compliance" : {
      "enforcement_mode" : "report"
    },
    "IAM" : {
      "enforcement_mode" : "report"
    },
    "context-based-restrictions" : {
      "enforcement_mode" : "report"
    },
    "globalcatalog-collection" : {
      "enforcement_mode" : "report"
    },
    "logdna" : {
      "enforcement_mode" : "report"
    },
    "logdnaat" : {
      "enforcement_mode" : "report"
    },
    "sysdig-monitor" : {
      "enforcement_mode" : "report"
    },
    "sysdig-secure" : {
      "enforcement_mode" : "report"
    }
  }

  target_service_details = merge(local.target_service_details_default, var.target_service_details)

  zone_final_service_ref_list = {
    for service_ref, service_ref_name in var.zone_service_ref_list : service_ref => service_ref_name if !contains(var.skip_specific_services_for_zone_creation, service_ref)
  }
}

###############################################################################
# Pre-create coarse grained CBR zones for each service
###############################################################################

locals {
  service_ref_zone_list = (length(local.zone_final_service_ref_list) > 0) ? {
    for service_ref, service_ref_name in local.zone_final_service_ref_list : service_ref => {
      name             = service_ref_name == null ? "${var.prefix}-${service_ref}-service-zone" : service_ref_name
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      zone_description = "Single zone for service ${service_ref}."
      # when the target service is containers-kubernetes or any icd services, context cannot have a serviceref
      addresses = [
        {
          type = "serviceRef"
          ref = {
            account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
            service_name = service_ref
            location     = (service_ref == "directlink" || service_ref == "globalcatalog-collection" || service_ref == "user-management" || service_ref == "iam-groups") ? null : var.location
          }
        }
      ]
  } } : {}

  service_ref_zone_map_check = merge(local.service_ref_zone_list, var.existing_serviceref_zone)

  service_ref_zone_map = { for service_ref, service_ref_name in local.service_ref_zone_map_check : service_ref => service_ref_name if !contains(keys(service_ref_name), "zone_id") }

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
# Create CBR rules for each service
##############################################################################

locals {
  kms_values = [
    for kms_val in var.kms_service_targeted_by_prewired_rules :
    kms_val == "key-protect" ? "kms" : kms_val # It maps 'key-protect' input to 'kms' because target service name supported by CBR for Key Protect is 'kms'.
  ]
  ## define FsCloud pre-wired CBR rule context - contains the known default flow that must be open for fscloud ref architecture
  cos_cbr_zone_id = local.cbr_zones["cloud-object-storage"].zone_id
  # tflint-ignore: terraform_naming_convention
  server-protect_cbr_zone_id = local.cbr_zones["server-protect"].zone_id # block storage
  # tflint-ignore: terraform_naming_convention
  containers-kubernetes_cbr_zone_id = local.cbr_zones["containers-kubernetes"].zone_id
  # tflint-ignore: terraform_naming_convention
  databases-for-cassandra_cbr_zone_id = local.cbr_zones["databases-for-cassandra"].zone_id
  # tflint-ignore: terraform_naming_convention
  databases-for-elasticsearch_cbr_zone_id = local.cbr_zones["databases-for-elasticsearch"].zone_id
  # tflint-ignore: terraform_naming_convention
  databases-for-enterprisedb_cbr_zone_id = local.cbr_zones["databases-for-enterprisedb"].zone_id
  # tflint-ignore: terraform_naming_convention
  databases-for-etcd_cbr_zone_id = local.cbr_zones["databases-for-etcd"].zone_id
  # tflint-ignore: terraform_naming_convention
  databases-for-mongodb_cbr_zone_id = local.cbr_zones["databases-for-mongodb"].zone_id
  # tflint-ignore: terraform_naming_convention
  databases-for-mysql_cbr_zone_id = local.cbr_zones["databases-for-mysql"].zone_id
  # tflint-ignore: terraform_naming_convention
  databases-for-postgresql_cbr_zone_id = local.cbr_zones["databases-for-postgresql"].zone_id
  # tflint-ignore: terraform_naming_convention
  databases-for-redis_cbr_zone_id = local.cbr_zones["databases-for-redis"].zone_id
  # tflint-ignore: terraform_naming_convention
  logdnaat_cbr_zone_id = local.cbr_zones["logdnaat"].zone_id
  # tflint-ignore: terraform_naming_convention
  is_cbr_zone_id = local.cbr_zones["is"].zone_id
  # tflint-ignore: terraform_naming_convention
  event_streams_cbr_zone_id = local.cbr_zones["messagehub"].zone_id

  prewired_rule_contexts_by_service = merge({
    # COS -> HPCS, Block storage -> HPCS, ROKS -> HPCS, ICD -> HPCS, Event Streams (Messagehub) -> HPCS
    for key in local.kms_values : key => [{
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_cos_to_kms ? [local.cos_cbr_zone_id] : [],
        var.allow_block_storage_to_kms ? [local.server-protect_cbr_zone_id] : [],
        var.allow_roks_to_kms ? [local.containers-kubernetes_cbr_zone_id] : [],
        var.allow_icd_to_kms ? [local.databases-for-cassandra_cbr_zone_id,
          local.databases-for-elasticsearch_cbr_zone_id,
          local.databases-for-enterprisedb_cbr_zone_id,
          local.databases-for-etcd_cbr_zone_id,
          local.databases-for-mongodb_cbr_zone_id,
          local.databases-for-mysql_cbr_zone_id,
          local.databases-for-postgresql_cbr_zone_id,
        local.databases-for-redis_cbr_zone_id] : [],
        var.allow_event_streams_to_kms ? [local.event_streams_cbr_zone_id] : []
      ])
    }] }, {
    # Fs VPCs -> COS, AT -> COS, VPC Infrastructure Services (IS) -> COS
    "cloud-object-storage" : [{
      endpointType : "direct",
      networkZoneIds : flatten([
        var.allow_vpcs_to_cos ? [local.cbr_zone_vpcs.zone_id] : [],
      ])
      }, {
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_at_to_cos ? [local.logdnaat_cbr_zone_id] : [],
        var.allow_is_to_cos ? [local.is_cbr_zone_id] : []
      ])
    }] }, {
    # VPCs -> container registry
    "container-registry" : [{
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_vpcs_to_container_registry ? [local.cbr_zone_vpcs.zone_id] : []
      ])
    }] }, {
    # IKS -> IS (VPC Infrastructure Services)
    "is" : [{
      endpointType : "private",
      networkZoneIds : flatten([
        var.allow_iks_to_is ? [local.containers-kubernetes_cbr_zone_id] : []
      ])
    }]
  })

  prewired_rule_contexts_by_service_check = { for key, value in local.prewired_rule_contexts_by_service :
    key => [
      for rule in value :
      rule if length(rule.networkZoneIds) > 0
    ]
  }

  ## define default 'deny' rule context
  deny_rule_context_by_service = { for target_service_name in keys(local.target_service_details) :
    target_service_name => []
  }

  global_deny_target_service_details = { for target_service_name, attributes in local.target_service_details :
    target_service_name => attributes if try(attributes.global_deny, false) == true
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
    databases-for-enterprisedb       = local.icd_api_types,
    containers-kubernetes            = ["crn:v1:bluemix:public:containers-kubernetes::::api-type:cluster", "crn:v1:bluemix:public:containers-kubernetes::::api-type:management"],
    containers-kubernetes-cluster    = ["crn:v1:bluemix:public:containers-kubernetes::::api-type:cluster"],
    containers-kubernetes-management = ["crn:v1:bluemix:public:containers-kubernetes::::api-type:management"]
    databases-for-cassandra          = local.icd_api_types,
    databases-for-elasticsearch      = local.icd_api_types,
    databases-for-etcd               = local.icd_api_types,
    databases-for-mongodb            = local.icd_api_types,
    databases-for-postgresql         = local.icd_api_types,
    databases-for-redis              = local.icd_api_types,
    messages-for-rabbitmq            = local.icd_api_types,
    databases-for-mysql              = local.icd_api_types
    mqcloud                          = local.icd_api_types
  }

  fake_service_names = {
    "containers-kubernetes-cluster"    = "containers-kubernetes",
    "containers-kubernetes-management" = "containers-kubernetes"
  }
}

locals {

  target_service_details_attributes = { for key, value in local.target_service_details :
    key => [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      contains(local.service_group_ids, key) ? {
        name     = "service_group_id",
        operator = "stringEquals",
        value    = key
        } : {
        name     = "serviceName",
        operator = "stringEquals",
        value    = lookup(local.fake_service_names, key, key)
      },
      try(value.target_rg, null) != null ? {
        name     = "resourceGroupId",
        operator = "stringEquals",
        value    = value.target_rg
      } : {},
      try(value.instance_id, null) != null ? {
        name     = "serviceInstance",
        operator = "stringEquals",
        value    = value.instance_id
      } : {},
      try(value.region, null) != null ? {
        name     = "region",
        operator = "stringEquals",
        value    = value.region
      } : {}
  ] }
}

# Create a rule for all services by default
module "cbr_rule" {
  for_each         = local.target_service_details
  source           = "../../modules/cbr-rule-module"
  rule_description = try(each.value.description, null) != null ? each.value.description : "${var.prefix}-${each.key}-rule"
  enforcement_mode = each.value.enforcement_mode
  rule_contexts    = lookup(local.allow_rules_by_service, each.key, [])
  operations = (length(lookup(local.operations_apitype_val, each.key, [])) > 0) ? [{
    api_types = [
      # lookup the map for the target service name, if empty then pass default value
      for apitype in lookup(local.operations_apitype_val, each.key, []) : {
        api_type_id = apitype
    }]
    }] : [{
    api_types = [{
      api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
    }]
  }]

  resources = [{
    tags = try(each.value.tags, null) != null ? [for tag in each.value.tags : {
      name  = split(":", tag)[0]
      value = split(":", tag)[1]
    }] : []
    attributes = flatten([
      for key, value in local.target_service_details_attributes : [
        for attribute in value :
        attribute if length(attribute) > 0
      ] if key == each.key
    ])
  }]
}

module "global_deny_cbr_rule" {
  depends_on       = [module.cbr_rule]
  for_each         = local.global_deny_target_service_details
  source           = "../../modules/cbr-rule-module"
  rule_description = try(each.value.description, null) != null ? each.value.description : "${var.prefix}-${each.key}-global-deny-rule"
  enforcement_mode = each.value.enforcement_mode
  rule_contexts    = []

  resources = [{
    tags = try(each.value.tags, null) != null ? [for tag in each.value.tags : {
      name  = split(":", tag)[0]
      value = split(":", tag)[1]
    }] : []
    attributes = [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      contains(local.service_group_ids, each.key) ? {
        name     = "service_group_id",
        operator = "stringEquals",
        value    = each.key
        } : {
        name     = "serviceName",
        operator = "stringEquals",
        value    = lookup(local.fake_service_names, each.key, each.key)
      }
    ]
  }]
}
