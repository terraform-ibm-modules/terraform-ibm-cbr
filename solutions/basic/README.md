# Cloud automation for Context Based Restriction

:exclamation: **Important:** This solution is not intended to be called by one or more other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

![context-based-restriction-deployable-architecture](../../reference-architecture/cbr.svg)

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | ../../modules/cbr-rule-module | n/a |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | ../../modules/cbr-zone-module | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_access_group_policy.network_zone_access_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_access_group_policy) | resource |
| [ibm_iam_access_group.service_id_access_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_access_group) | data source |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cabin_service_id_access_group"></a> [cabin\_service\_id\_access\_group](#input\_cabin\_service\_id\_access\_group) | The name of the service id access group for the cabin.  Format: <cabin-name>\_service\_id where <cabin-name> is from the cabin config 'cabin\_data.name' | `string` | `null` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | Map of CBR rules to be created. Each rule includes mapping to zone keys. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/solutions/basic/DA-complex-input-variables.md) | <pre>map(object({<br/>    rule_description = optional(string, null)<br/>    rule_contexts = optional(list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>      })))<br/>    })), [])<br/>    enforcement_mode = optional(string, "report")<br/>    resources = list(object({<br/>      attributes = optional(list(object({<br/>        name     = string<br/>        value    = string<br/>        operator = optional(string)<br/>      })))<br/>      tags = optional(list(object({<br/>        name     = string<br/>        value    = string<br/>        operator = optional(string)<br/>      })))<br/>    }))<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>      })), [<br/>      {<br/>        api_types = [<br/>          {<br/>            api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"<br/>          }<br/>        ]<br/>      }<br/>    ])<br/>    zone_keys = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_cbr_zones"></a> [cbr\_zones](#input\_cbr\_zones) | Map of CBR zones to be created. Key is a unique zone identifier. These zones are referenced by `zone_keys` inside `cbr_rules` to explicitly control which zones apply to which rules. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/solutions/basic/DA-complex-input-variables.md) | <pre>map(object({<br/>    account_id       = optional(string, null)<br/>    name             = string<br/>    zone_description = optional(string, null)<br/>    addresses = optional(list(object({<br/>      type  = optional(string)<br/>      value = optional(string)<br/>      ref = optional(object({<br/>        account_id       = optional(string)<br/>        location         = optional(string)<br/>        service_instance = optional(string)<br/>        service_name     = optional(string)<br/>        service_type     = optional(string)<br/>      }))<br/>    })), [])<br/>    excluded_addresses = optional(list(object({<br/>      type  = optional(string)<br/>      value = optional(string)<br/>    })), [])<br/>    use_existing_cbr_zone = optional(bool, false)<br/>    existing_zone_id      = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API Key | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-0205-cbr. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md). | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cbr_rule_ids"></a> [cbr\_rule\_ids](#output\_cbr\_rule\_ids) | Array of all the CBR zones created |
| <a name="output_network_zone_ids"></a> [network\_zone\_ids](#output\_network\_zone\_ids) | Array of all the CBR rules created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
