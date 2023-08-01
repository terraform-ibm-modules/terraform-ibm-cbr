# Pre-wired CBR configuration for FS Cloud

This module creates default coarse-grained CBR rules in a given account following a "secure by default" approach - that is: deny all flows by default, except known documented communication in the [Financial Services Cloud Reference Architecture](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-vpc-architecture-about):
- COS -> KMS
- Block storage -> KMS
- ROKS -> KMS
- Activity Tracker route -> COS (pending addition of AT as zone)
- VPCs -> container registry
- VPCs where clusters are deployed -> COS

This module is designed to allow the consumer to add additional custom rules to open up additional flows necessarity for their usage. See the `custom_rule_contexts_by_service` input variable, and an [usage example](../../examples/fscloud/) demonstrating how to open up more flows.

The module also pre-create CBR zone for each service in the account as a best practice. CBR rules associated with these CBR zone can be set by using the `custom_rule_contexts_by_service` variable.

Important: In order to avoid unexpected breakage in the account against which this module is executed, the CBR rule enforcement mode is set to 'report' (or 'disabled' for services not supporting 'report' mode) by default. It is recommended to test out this module first with these default, and then use the `target_service_details` variable to set the enforcement mode to "enabled" gradually by service. The [usage example](../../examples/fscloud/) demonstrates how to set the enforcement mode to 'enabled' for the key protect ("kms") service.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | ./cbr-rule-module | n/a |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | ./cbr-zone-module | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addresses"></a> [addresses](#input\_addresses) | (List) The list of addresses in the zone | <pre>list(object({<br>    type  = optional(string)<br>    value = optional(string)<br>    ref = optional(object({<br>      account_id       = string<br>      location         = optional(string)<br>      service_instance = optional(string)<br>      service_name     = optional(string)<br>      service_type     = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_enforcement_mode"></a> [enforcement\_mode](#input\_enforcement\_mode) | (String) The rule enforcement mode | `string` | `"report"` | no |
| <a name="input_excluded_addresses"></a> [excluded\_addresses](#input\_excluded\_addresses) | (Optional, List) The list of excluded addresses in the zone | <pre>list(object({<br>    type  = optional(string)<br>    value = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional, String) The name of the zone | `string` | `null` | no |
| <a name="input_operations"></a> [operations](#input\_operations) | (Optional, List) The operations this rule applies to | <pre>list(object({<br>    api_types = list(object({<br>      api_type_id = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | (Optional, List) The resources this rule apply to | <pre>list(object({<br>    attributes = list(object({<br>      name     = string<br>      value    = string<br>      operator = optional(string)<br>    }))<br>    tags = optional(list(object({ #These access tags should match to the target service access tags for the CBR rules to work<br>      name     = string<br>      value    = string<br>      operator = optional(string)<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_rule_contexts"></a> [rule\_contexts](#input\_rule\_contexts) | (List) The contexts the rule applies to | <pre>list(object({<br>    attributes = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "attributes": [<br>      {<br>        "name": "va",<br>        "value": "va"<br>      }<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_rule_description"></a> [rule\_description](#input\_rule\_description) | (Optional, String) The description of the rule | `string` | `null` | no |
| <a name="input_zone_description"></a> [zone\_description](#input\_zone\_description) | (Optional, String) The description of the zone | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_crn"></a> [rule\_crn](#output\_rule\_crn) | CBR rule resource instance crn |
| <a name="output_rule_href"></a> [rule\_href](#output\_rule\_href) | CBR rule resource href |
| <a name="output_rule_id"></a> [rule\_id](#output\_rule\_id) | CBR rule resource instance id |
| <a name="output_zone_crn"></a> [zone\_crn](#output\_zone\_crn) | cbr\_zone resource instance crn |
| <a name="output_zone_href"></a> [zone\_href](#output\_zone\_href) | cbr\_zone resource instance link |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | cbr\_zone resource instance id |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
