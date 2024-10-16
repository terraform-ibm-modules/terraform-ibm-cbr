# Pre-wired CBR configuration for FS Cloud

This module creates default coarse-grained CBR rules in a given account following a "secure by default" approach - that is: deny all flows by default, except known documented communication in the [Financial Services Cloud Reference Architecture](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-vpc-architecture-about):
- Cloud Object Storage (COS) -> Hyper Protect Crypto Services (HPCS)
- Block Storage -> Hyper Protect Crypto Services (HPCS)
- IBM Cloud Kubernetes Service (IKS) -> Hyper Protect Crypto Services (HPCS)
- All IBM Cloud Databases (ICD) services -> Hyper Protect Crypto Services (HPCS)
- Event Streams (Messagehub) -> Hyper Protect Crypto Services (HPCS)
- Virtual Private Clouds (VPCs) where clusters are deployed -> Cloud Object Storage (COS)
- Virtual Private Clouds (VPCs) where clusters are deployed -> IAM groups
- Virtual Private Clouds (VPCs) where clusters are deployed -> IAM access management
- Activity Tracker route -> Cloud Object Storage (COS)
- IBM Cloud VPC Infrastructure Services (IS) -> Cloud Object Storage (COS)
- Security and Compliance Center (SCC) -> Cloud Object Storage (COS)
- Virtual Private Clouds (VPCs) workload (eg: Kubernetes worker nodes) -> IBM Cloud Container Registry
- IBM Cloud Kubernetes Service (IKS) -> VPC Infrastructure Services (IS)


**Note on KMS**: the module supports setting up rules for Key Protect, and Hyper Protect Crypto Services. By default the modules set rules for Hyper Protect Crypto Services, but this can be modified to use Key Protect, Hyper Protect, or both Key Protect and Hyper Protect Crypto Services using the input variable `kms_service_targeted_by_prewired_rules`.

**Note on containers-kubernetes**: the module supports the pseudo-service names `containers-kubernetes-management` and `containers-kubernetes-cluster` to distinguish between the cluster and management APIs (see [details](https://cloud.ibm.com/docs/containers?topic=containers-cbr&interface=ui#protect-api-types-cbr) ). The module creates separates CBR rules for the two types of APIs by default to align with common real-world scenarios. `containers-kubernetes` can be used to create a CBR targetting both the cluster and management APIs.

This module is designed to allow the consumer to add additional custom rules to open up additional flows necessarity for their usage. See the `custom_rule_contexts_by_service` input variable, and an [usage example](../../examples/fscloud/) demonstrating how to open up more flows.

The module also pre-create CBR zone for each service in the account as a best practice. CBR rules associated with these CBR zone can be set by using the `custom_rule_contexts_by_service` variable.

Important: In order to avoid unexpected breakage in the account against which this module is executed, the CBR rule enforcement mode is set to 'report' (or 'disabled' for services not supporting 'report' mode) by default. It is recommended to test out this module first with these default, and then use the `target_service_details` variable to set the enforcement mode to "enabled" gradually by service. The [usage example](../../examples/fscloud/) demonstrates how to set the enforcement mode to 'enabled' for the key protect ("kms") service.

**Note on Event Notifications**: By default, `disabled` enforcement mode is set for Event Notifications as the SMTP API does not support `report` enforcement mode.

**Note on global_deny variable**: When a `scope` is specified in a rule for the target service, a new separate `global rule` will be created for the respective target service to scope `all the resources` of that service. This can be opted out by setting the variable `global_deny = false`. It is also mandatory to set `global_deny = false` when no scope is specified for the target service.

**Note on `mqcloud`**: Region and/or instance_id is/are required for service `mqcloud` to create the CBR rule. This service is only available in eu-fr2 region.

**Note on `Security and Compliance Center (SCC) scan`**: Compliance can only be claimed after all the enforcement mode have been set to enabled.

## Note
The services 'directlink', 'globalcatalog-collection', 'iam-groups' and 'user-management' do not support restriction per location.

### Usage

```hcl
module "cbr_fscloud" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/fscloud"
  version          = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  prefix                           = "fs-cbr"
  zone_vpc_crn_list                = ["crn:v1:bluemix:public:is:us-south:a/abac0df06b644a9cabc6e44f55b3880e::vpc:r006-069c6449-03a9-49f1-9070-4d23fc79285e"]

  # True or False to set prewired rule
  allow_cos_to_kms                 = true
  allow_block_storage_to_kms       = true
  allow_roks_to_kms                = true
  allow_icd_to_kms                 = true
  allow_vpcs_to_container_registry = true
  allow_vpcs_to_cos                = true
  allow_at_to_cos                  = true
  allow_iks_to_is                  = true

  # Will skip the zone creation for service ref. present in the list
  skip_specific_services_for_zone_creation = ["user-management", "iam-groups"]

 target_service_details = {
    "kms" = {
      "enforcement_mode" = "enabled"
      "instance_id"      = "dhd2-2bdjd-2bdjd-asgd3" # pragma: allowlist secret
      "target_rg"        = "a8cff104f1764e98aac9ab879198230a" # pragma: allowlist secret
    }
    "cloud-object-storage" = {
      "enforcement_mode" = "enabled"
      "target_rg"        = "a8cff104f1764e98aac9ab879198230a" # pragma: allowlist secret
      "global_deny"      = false # opting out from creating a new global rule
    }
    "messagehub" = {
      "enforcement_mode" = "enabled"
      "global_deny"      = false # mandatory to set 'global_deny = false' when no scope is defined
    }
    "IAM" : {
      "enforcement_mode" = "report"
      "global_deny"      = false
    }
  }

  custom_rule_contexts_by_service = {
                                    "schematics" = [{
                                      endpointType = "public"
                                      zone_ids     = "93a51a1debe2674193217209601dde6f" # pragma: allowlist secret
                                    }]
                                  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.65.0, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | ../../modules/cbr-rule-module | n/a |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | ../../modules/cbr-zone-module | n/a |
| <a name="module_cbr_zone_vpcs"></a> [cbr\_zone\_vpcs](#module\_cbr\_zone\_vpcs) | ../../modules/cbr-zone-module | n/a |
| <a name="module_global_deny_cbr_rule"></a> [global\_deny\_cbr\_rule](#module\_global\_deny\_cbr\_rule) | ../../modules/cbr-rule-module | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_at_to_cos"></a> [allow\_at\_to\_cos](#input\_allow\_at\_to\_cos) | Set rule for Activity Tracker to COS, default is true | `bool` | `true` | no |
| <a name="input_allow_block_storage_to_kms"></a> [allow\_block\_storage\_to\_kms](#input\_allow\_block\_storage\_to\_kms) | Set rule for block storage to KMS, default is true | `bool` | `true` | no |
| <a name="input_allow_cos_to_kms"></a> [allow\_cos\_to\_kms](#input\_allow\_cos\_to\_kms) | Set rule for COS to KMS, default is true | `bool` | `true` | no |
| <a name="input_allow_event_streams_to_kms"></a> [allow\_event\_streams\_to\_kms](#input\_allow\_event\_streams\_to\_kms) | Set rule for Event Streams (Messagehub) to KMS, default is true | `bool` | `true` | no |
| <a name="input_allow_icd_to_kms"></a> [allow\_icd\_to\_kms](#input\_allow\_icd\_to\_kms) | Set rule for ICD to KMS, default is true | `bool` | `true` | no |
| <a name="input_allow_iks_to_is"></a> [allow\_iks\_to\_is](#input\_allow\_iks\_to\_is) | Set rule for IKS to IS (VPC Infrastructure Services), default is true | `bool` | `true` | no |
| <a name="input_allow_is_to_cos"></a> [allow\_is\_to\_cos](#input\_allow\_is\_to\_cos) | Set rule for IS (VPC Infrastructure Services) to COS, default is true | `bool` | `true` | no |
| <a name="input_allow_roks_to_kms"></a> [allow\_roks\_to\_kms](#input\_allow\_roks\_to\_kms) | Set rule for ROKS to KMS, default is true | `bool` | `true` | no |
| <a name="input_allow_scc_to_cos"></a> [allow\_scc\_to\_cos](#input\_allow\_scc\_to\_cos) | Set rule for SCC (Security and Compliance Center) to COS, default is true | `bool` | `true` | no |
| <a name="input_allow_vpcs_to_container_registry"></a> [allow\_vpcs\_to\_container\_registry](#input\_allow\_vpcs\_to\_container\_registry) | Set rule for VPCs to container registry, default is true | `bool` | `true` | no |
| <a name="input_allow_vpcs_to_cos"></a> [allow\_vpcs\_to\_cos](#input\_allow\_vpcs\_to\_cos) | Set rule for VPCs to COS, default is true | `bool` | `true` | no |
| <a name="input_allow_vpcs_to_iam_access_management"></a> [allow\_vpcs\_to\_iam\_access\_management](#input\_allow\_vpcs\_to\_iam\_access\_management) | Set rule for VPCs to IAM access management, default is true | `bool` | `true` | no |
| <a name="input_allow_vpcs_to_iam_groups"></a> [allow\_vpcs\_to\_iam\_groups](#input\_allow\_vpcs\_to\_iam\_groups) | Set rule for VPCs to IAM groups, default is true | `bool` | `true` | no |
| <a name="input_custom_rule_contexts_by_service"></a> [custom\_rule\_contexts\_by\_service](#input\_custom\_rule\_contexts\_by\_service) | Any additional context to add to the CBR rules created by this module. The context are added to the CBR rule targetting the service passed as a key. The module looks up the zone id when service\_ref\_names or add\_managed\_vpc\_zone are passed in. | <pre>map(list(object(<br/>    {<br/>      endpointType = string # "private, public or direct"<br/><br/>      # Service-name (module lookup for existing network zone) and/or CBR zone id<br/>      service_ref_names    = optional(list(string), [])<br/>      add_managed_vpc_zone = optional(bool, false)<br/>      zone_ids             = optional(list(string), [])<br/>  })))</pre> | `{}` | no |
| <a name="input_existing_cbr_zone_vpcs"></a> [existing\_cbr\_zone\_vpcs](#input\_existing\_cbr\_zone\_vpcs) | Provide a existing zone id for VPC | <pre>object(<br/>    {<br/>      zone_id = string<br/>  })</pre> | `null` | no |
| <a name="input_existing_serviceref_zone"></a> [existing\_serviceref\_zone](#input\_existing\_serviceref\_zone) | Provide a valid service reference and existing zone id | <pre>map(object(<br/>    {<br/>      zone_id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_kms_service_targeted_by_prewired_rules"></a> [kms\_service\_targeted\_by\_prewired\_rules](#input\_kms\_service\_targeted\_by\_prewired\_rules) | IBM Cloud offers two distinct Key Management Services (KMS): Key Protect and Hyper Protect Crypto Services (HPCS). This variable determines the specific KMS service to which the pre-configured rules will be applied. Use the value 'key-protect' to specify the Key Protect service, and 'hs-crypto' for the Hyper Protect Crypto Services (HPCS). | `list(string)` | <pre>[<br/>  "hs-crypto"<br/>]</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all vpc\_zone\_list, service\_ref\_zone\_list and cbr\_rule\_description created by this submodule | `string` | n/a | yes |
| <a name="input_skip_specific_services_for_zone_creation"></a> [skip\_specific\_services\_for\_zone\_creation](#input\_skip\_specific\_services\_for\_zone\_creation) | Provide a list of service references for which zone creation is not required | `list(string)` | `[]` | no |
| <a name="input_target_service_details"></a> [target\_service\_details](#input\_target\_service\_details) | Details of the target service for which a rule is created. The key is the service name. | <pre>map(object({<br/>    description      = optional(string)<br/>    target_rg        = optional(string)<br/>    instance_id      = optional(string)<br/>    enforcement_mode = string<br/>    tags             = optional(list(string))<br/>    region           = optional(string)<br/>    geography        = optional(string)<br/>    global_deny      = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_zone_service_ref_list"></a> [zone\_service\_ref\_list](#input\_zone\_service\_ref\_list) | (Optional) Provide a valid service reference with the customized name of the zone and location where the context-based restriction zones are created. If no value is specified for `serviceRef_location`, the zones are not scoped to any location and if no value is specified for `zone_name` default zone name with the prefix will be created. | <pre>object({<br/>    cloud-object-storage = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    codeengine = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    containers-kubernetes = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    databases-for-cassandra = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    databases-for-elasticsearch = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    databases-for-enterprisedb = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    databases-for-etcd = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    databases-for-mongodb = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    databases-for-mysql = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    databases-for-postgresql = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    databases-for-redis = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    directlink = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    iam-groups = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    is = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    messagehub = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    messages-for-rabbitmq = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    schematics = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    secrets-manager = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    server-protect = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    user-management = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    apprapp = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    compliance = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    event-notifications = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    logdna = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    logdnaat = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    cloudantnosqldb = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    globalcatalog-collection = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    sysdig-monitor = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    sysdig-secure = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>    toolchain = optional(object({<br/>      zone_name           = optional(string)<br/>      serviceRef_location = optional(list(string))<br/>    }))<br/><br/>  })</pre> | `{}` | no |
| <a name="input_zone_vpc_crn_list"></a> [zone\_vpc\_crn\_list](#input\_zone\_vpc\_crn\_list) | (List) VPC CRN for the zones | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | Account ID |
| <a name="output_map_service_ref_name_zoneid"></a> [map\_service\_ref\_name\_zoneid](#output\_map\_service\_ref\_name\_zoneid) | Map of service reference and zone ids |
| <a name="output_map_target_service_rule_ids"></a> [map\_target\_service\_rule\_ids](#output\_map\_target\_service\_rule\_ids) | Map of target service and rule ids |
| <a name="output_map_vpc_zoneid"></a> [map\_vpc\_zoneid](#output\_map\_vpc\_zoneid) | Map of VPC and zone ids |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
