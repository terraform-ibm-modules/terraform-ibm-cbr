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
# Key Protect Instance
##############################################################################
module "key_protect_module" {
  source            = "terraform-ibm-modules/key-protect/ibm"
  version           = "v2.8.5"
  key_protect_name  = "${var.prefix}-key-protect-instance"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  allowed_network   = "private-only"
  plan              = "tiered-pricing"
}

# ##############################################################################
# # Get Cloud Account ID
# ##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
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

module "cbr_account_level" {
  source            = "../../modules/fscloud"
  prefix            = var.prefix
  zone_vpc_crn_list = [ibm_is_vpc.example_vpc.crn]
  # Demonstrates how to target either key-protect, hpcs, or both. Both in this fictional example.
  kms_service_targeted_by_prewired_rules = ["key-protect", "hs-crypto"]

  # Demonstrates how zone creation will be skipped for these two service references ["user-management", "iam-groups"]
  skip_specific_services_for_zone_creation = ["user-management", "iam-groups"]

  ## Enable enforcement for key protect as an example
  ## The other services not referenced here, are either report, or disabled (when not support report)
  ## When a scope is specified in a rule for the target service, a new separate global rule will be created for the respective target service to scope all the resources of that service. This can be opted out by setting the variable 'global_deny = false'
  ## It is mandatory to set 'global_deny = false' when no scope is specified for the target service

  target_service_details = {
    # Using 'kms' for Key Protect value as target service name supported by CBR for Key Protect is 'kms'.
    "kms" = {
      # Demonstrates how a customized CBR description (also seen as being the rule name) can be set
      "description"      = "kms-rule-example-of-customized-description"
      "enforcement_mode" = "enabled"
      "instance_id"      = module.key_protect_module.key_protect_guid
      "target_rg"        = module.resource_group.resource_group_id
      "global_deny"      = false # opting out from creating a new global rule
    }
    "cloud-object-storage" = {
      "enforcement_mode" = "enabled"
      "global_deny"      = false # mandatory to set 'global_deny = false' when no scope is defined
    }
    "databases-for-postgresql" = {
      "enforcement_mode" = "enabled"
      "target_rg"        = module.resource_group.resource_group_id
    }
    "messagehub" = {
      # As the service is scoped, a new global rule will also get created
      "enforcement_mode" = "enabled"
      "target_rg"        = module.resource_group.resource_group_id
    }
    "IAM" : {
      "enforcement_mode" = "report"
      "global_deny"      = false
    }
    "container-registry" : {
      "enforcement_mode" : "enabled"
      "geography" : "global"
    }
  }

  # Demonstrates how a customized name and an optional location can be set for the CBR serviceRef zones
  zone_service_ref_list = {
    codeengine = {
      zone_name           = "${var.prefix}-codeengine-zone-example-of-customized-zone-name"
      serviceRef_location = ["au", "tok"]
    },
    server-protect = {
      serviceRef_location = ["eu"]
    },
    cloud-object-storage = {
      zone_name = "${var.prefix}-COS-zone-example-of-customized-zone-name"
    }
  }

  # Demonstrates how additional context to the rules created by this module can be added.
  # This example open up:
  #   1. Flow from schematics to KMS on public HPCS endpoint
  #   2. Add a block of ips to schematics public endpoint
  #   3. Flow from vpc(s) specified in input zone_vpc_crn_list to PostgreSQL private endpoint
  #   4. Add a block of ips to Key Protect public endpoint

  custom_rule_contexts_by_service = merge({
    "kms" = [
      {
        endpointType      = "private"
        service_ref_names = ["schematics"]
      }
    ] }, {
    "schematics" = [{
      endpointType = "public"
      zone_ids     = [module.cbr_zone_operator_ips.zone_id]
    }],
    "databases-for-postgresql" = [{
      endpointType = "private"
      ## Give access to the zone containing the VPC passed in zone_vpc_crn_list input
      add_managed_vpc_zone = true
    }],
    "containers-kubernetes-cluster" = [{
      endpointType = "private"
      ## Give operator access to run kubectl against private endpoints on any cluster in account
      zone_ids = [module.cbr_zone_operator_ips.zone_id]
    }]
  })
}

## Example of zone using ip addresses, and reference in one of the zone created by the cbr_account_level above.
## A zone used to group operator machine ips.
module "cbr_zone_operator_ips" {
  source           = "../../modules/cbr-zone-module"
  name             = "${var.prefix}-List of operator environment public IPs"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  zone_description = "Zone grouping list of known public ips for operator machines"
  addresses = [{
    type  = "subnet"
    value = "0.0.0.0/0" # All ip for this public example - this would be narrowed down typically to an enterprise ip block
  }]
}

## Examples of data lookup on objects (zone, rule) created by the fscloud profile module
## Get rule targetting "event-notification"
data "ibm_cbr_rule" "event_notification_rule" {
  rule_id = module.cbr_account_level.map_target_service_rule_ids["event-notifications"].rule_id
}

## Get zone having "event-notification" as single source
data "ibm_cbr_zone" "event_notifications_zone" {
  zone_id = module.cbr_account_level.map_service_ref_name_zoneid["event-notifications"].zone_id
}
