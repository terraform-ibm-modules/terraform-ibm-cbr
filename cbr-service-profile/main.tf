##############################################################################
# Get Cloud Account ID
##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
#
# CBR Rule for a list of target services
##############################################################################
locals {
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
}


module "cbr_rule" {
  count            = length(var.target_service_details)
  source           = "../cbr-rule-module"
  rule_description = "${var.target_service_details[count.index].target_service_name}-terraform-rule"
  enforcement_mode = var.target_service_details[count.index].enforcement_mode
  rule_contexts    = var.rule_contexts
  operations = (length(lookup(local.operations_apitype_val, var.target_service_details[count.index].target_service_name, [])) > 0) ? [{
    api_types = [
      # lookup the map for the target service name, if not present make api_type_id as empty
      for apitype in lookup(local.operations_apitype_val, var.target_service_details[count.index].target_service_name, []) : {
        api_type_id = apitype
    }]
  }] : []

  resources = [{
    tags = var.target_service_details[count.index].tags
    attributes = [{
      name     = "serviceName",
      operator = "stringEquals",
      value    = var.target_service_details[count.index].target_service_name
      },
      {
        "name" : "accountId",
        operator = "stringEquals",
        "value" : data.ibm_iam_account_settings.iam_account_settings.account_id
    }, ]
  }]
}
