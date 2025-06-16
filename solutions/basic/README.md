# Cloud automation for Context Based Restriction

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1, < 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ibm"></a> [ibm](#provider\_ibm) | >= 1.56.1, < 2.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.19.0 |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module | 1.19.0 |

## Resources

| Name | Type |
|------|------|
| [ibm_iam_access_group_policy.network_zone_access_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_access_group_policy) | resource |
| [ibm_iam_access_group.service_id_access_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_access_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cabin_service_id_access_group"></a> [cabin\_service\_id\_access\_group](#input\_cabin\_service\_id\_access\_group) | The name of the service id access group for the cabin.  Format: <cabin-name>\_service\_id where <cabin-name> is from the cabin config 'cabin\_data.name' | `string` | n/a | yes |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (Optional, map) Map of CBR rules to create | <pre>map(object({<br>    # Description of the rule<br>    description = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>      })))<br>    }))<br><br>    # report, enable, disable<br>    enforcement_mode = string<br>    resources = list(object({<br>      attributes = optional(list(object({<br>        name     = string<br>        value    = string<br>        operator = optional(string)<br>      })))<br>      tags = optional(list(object({<br>        name     = string<br>        value    = string<br>        operator = optional(string)<br>      })))<br>    }))<br>    operations = list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_cbr_zones"></a> [cbr\_zones](#input\_cbr\_zones) | (Optional map) Map of CBR Zones to create | <pre>map(object({<br>    # Should this zone be added to the included cbr_rules<br>    add_zone_to_rules = bool<br><br>    # Name of the zone<br>    name = string<br><br>    # Account ID for the zone<br>    account_id = string<br><br>    # Description of the zone<br>    description = optional(string)<br><br>    addresses = list(object({<br>      type  = optional(string)<br>      value = optional(string)<br>      ref = optional(object({<br>        account_id       = optional(string)<br>        location         = optional(string)<br>        service_instance = optional(string)<br>        service_name     = optional(string)<br>        service_type     = optional(string)<br>      }))<br>    }))<br>    excluded_addresses = list(object({<br>      type  = optional(string)<br>      value = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API Key | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cbr_rule_crns"></a> [cbr\_rule\_crns](#output\_cbr\_rule\_crns) | CBR rule resource instance crns |
| <a name="output_cbr_rule_ids"></a> [cbr\_rule\_ids](#output\_cbr\_rule\_ids) | CBR rule resource instance ids |
| <a name="output_network_zone_ids"></a> [network\_zone\_ids](#output\_network\_zone\_ids) | Array of all the network zones created |
