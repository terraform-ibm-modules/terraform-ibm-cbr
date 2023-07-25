# Pre-wired CBR configuration for FS Cloud


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | ../../cbr-rule-module | n/a |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | ../../cbr-zone-module | n/a |
| <a name="module_cbr_zone_deny"></a> [cbr\_zone\_deny](#module\_cbr\_zone\_deny) | ../../cbr-zone-module | n/a |
| <a name="module_cbr_zone_vpcs"></a> [cbr\_zone\_vpcs](#module\_cbr\_zone\_vpcs) | ../../cbr-zone-module | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.49.0/docs/data-sources/iam_account_settings) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_block_storage_to_kms"></a> [allow\_block\_storage\_to\_kms](#input\_allow\_block\_storage\_to\_kms) | Set rule for block storage to KMS, deafult is true | `bool` | `true` | no |
| <a name="input_allow_cos_to_kms"></a> [allow\_cos\_to\_kms](#input\_allow\_cos\_to\_kms) | Set rule for COS to KMS, deafult is true | `bool` | `true` | no |
| <a name="input_allow_roks_to_kms"></a> [allow\_roks\_to\_kms](#input\_allow\_roks\_to\_kms) | Set rule for ROKS to KMS, deafult is true | `bool` | `true` | no |
| <a name="input_allow_vpcs_to_container_registry"></a> [allow\_vpcs\_to\_container\_registry](#input\_allow\_vpcs\_to\_container\_registry) | Set rule for VPCs to container registry, deafult is true | `bool` | `true` | no |
| <a name="input_allow_vpcs_to_cos"></a> [allow\_vpcs\_to\_cos](#input\_allow\_vpcs\_to\_cos) | Set rule for VPCs to COS, deafult is true | `bool` | `true` | no |
| <a name="input_custom_rule_contexts_by_service"></a> [custom\_rule\_contexts\_by\_service](#input\_custom\_rule\_contexts\_by\_service) | Any additional context to add to the CBR rules created by this module. The context are added to the CBR rule targetting the service passed as a key. | <pre>map(object(<br>    {<br>      endpointType = string # "private, public or direct"<br><br>      # Service-name (module lookup for existing network zone) and/or CBR zone id<br>      service_ref_names = optional(list(string), [])<br>      zone_ids          = optional(list(string), [])<br>  }))</pre> | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all vpc\_zone\_list, service\_ref\_zone\_list and cbr\_rule\_description created by this submodule | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the instance will be created. | `string` | n/a | yes |
| <a name="input_target_service_details"></a> [target\_service\_details](#input\_target\_service\_details) | (String) Details of the target service for which the rule has to be created | <pre>list(object({<br>    target_service_name = string<br>    target_rg           = optional(string)<br>    enforcement_mode    = string<br>    tags                = optional(list(string))<br>  }))</pre> | <pre>[<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "iam-groups"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "iam-access-management"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "iam-identity"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "user-management"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "cloud-object-storage"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "codeengine"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "container-registry"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "databases-for-cassandra"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "databases-for-enterprisedb"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "databases-for-elasticsearch"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "databases-for-etcd"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "databases-for-mongodb"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "databases-for-mysql"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "databases-for-postgresql"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "databases-for-redis"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "directlink"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "dns-svcs"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "messagehub"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "kms"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "containers-kubernetes"<br>  },<br>  {<br>    "enforcement_mode": "disabled",<br>    "target_service_name": "messages-for-rabbitmq"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "secrets-manager"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "transit"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "is"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "schematics"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "apprapp"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "event-notifications"<br>  },<br>  {<br>    "enforcement_mode": "report",<br>    "target_service_name": "compliance"<br>  }<br>]</pre> | no |
| <a name="input_zone_service_ref_list"></a> [zone\_service\_ref\_list](#input\_zone\_service\_ref\_list) | (List) Service reference for the zone creation | `list(string)` | <pre>[<br>  "cloud-object-storage",<br>  "codeengine",<br>  "containers-kubernetes",<br>  "databases-for-cassandra",<br>  "databases-for-elasticsearch",<br>  "databases-for-enterprisedb",<br>  "databases-for-etcd",<br>  "databases-for-mongodb",<br>  "databases-for-mysql",<br>  "databases-for-postgresql",<br>  "databases-for-redis",<br>  "directlink",<br>  "iam-groups",<br>  "is",<br>  "messagehub",<br>  "messages-for-rabbitmq",<br>  "schematics",<br>  "secrets-manager",<br>  "server-protect",<br>  "user-management",<br>  "apprapp",<br>  "compliance",<br>  "event-notifications"<br>]</pre> | no |
| <a name="input_zone_vpc_crn_list"></a> [zone\_vpc\_crn\_list](#input\_zone\_vpc\_crn\_list) | (List) VPC CRN for the zones | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | Account ID (used in tests) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
