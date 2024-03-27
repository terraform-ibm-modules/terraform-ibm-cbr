# ##############################################################################
# # Get Cloud Account ID
# ##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
#
# CBR Rule for a list of target services
##############################################################################
locals {
  # tflint-ignore: terraform_unused_declarations
  validate_zone_inputs = ((length(var.zone_vpc_crn_list) == 0) && (length(var.zone_service_ref_list) == 0)) ? tobool("Error: Provide a valid zone vpc and/or service references") : true
  # tflint-ignore: terraform_unused_declarations
  validate_location_and_service_name = (length(setintersection(["compliance", "directlink", "iam-groups", "containers-kubernetes", "user-management"], var.zone_service_ref_list)) > 0 && var.location != null) ? tobool("Error: The services 'compliance','directlink','iam-groups','containers-kubernetes','user-management' does not support location") : true



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
    messages-for-rabbitmq       = local.icd_api_types
  }

  vpc_zone_list = (length(var.zone_vpc_crn_list) > 0) ? [{
    name             = "${var.prefix}-cbr-vpc-zone"
    account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
    zone_description = "${var.prefix}-cbr-vpc-zone-terraform"
    addresses = [
      for zone_vpc_crn in var.zone_vpc_crn_list :
      { "type" = "vpc", value = zone_vpc_crn }
    ]
  }] : []

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
            location     = var.location
          }
        }
      ]
  }] : []

  zone_list = concat(tolist(local.vpc_zone_list), tolist(local.service_ref_zone_list))
}
module "cbr_zone" {
  count            = length(local.zone_list)
  source           = "../cbr-zone-module"
  name             = local.zone_list[count.index].name
  zone_description = local.zone_list[count.index].zone_description
  account_id       = local.zone_list[count.index].account_id
  addresses        = local.zone_list[count.index].addresses
}

locals {
  rule_contexts = [{
    attributes = [
      {
        "name" : "endpointType",
        "value" : join(",", ([for endpoint in var.endpoints : endpoint]))
      },
      {
        name  = "networkZoneId"
        value = join(",", ([for zone in module.cbr_zone : zone.zone_id]))
    }]
  }]
}

module "cbr_rule" {
  count            = length(var.target_service_details)
  source           = "../cbr-rule-module"
  rule_description = "${var.prefix}-${var.target_service_details[count.index].target_service_name}-serviceprofile-rule"
  enforcement_mode = var.target_service_details[count.index].enforcement_mode
  rule_contexts    = local.rule_contexts
  operations = (length(lookup(local.operations_apitype_val, var.target_service_details[count.index].target_service_name, [])) > 0) ? [{
    api_types = [
      # lookup the map for the target service name, if empty then pass default value
      for apitype in lookup(local.operations_apitype_val, var.target_service_details[count.index].target_service_name, []) : {
        api_type_id = apitype
    }]
    }] : [{
    api_types = [{
      api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
    }]
  }]

  resources = [{
    tags = var.target_service_details[count.index].tags != null ? [for tag in var.target_service_details[count.index].tags : {
      name  = split(":", tag)[0]
      value = split(":", tag)[1]
    }] : []
    attributes = var.target_service_details[count.index].target_rg != null ? [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      {
        name     = "resourceGroupId",
        operator = "stringEquals",
        value    = var.target_service_details[count.index].target_rg
      },
      {
        name     = "serviceName",
        operator = "stringEquals",
        value    = var.target_service_details[count.index].target_service_name
      }] : [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      {
        name     = "serviceName",
        operator = "stringEquals",
        value    = var.target_service_details[count.index].target_service_name
    }]
  }]
}
