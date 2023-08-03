# CBR service profile

The CBR service profile creates a list of zones and rules for context-based restrictions. You pass a list of VPC CRNs or service references to create the CBR zones. You also pass a list of target services to create the rules that match these profiles. You can identify the services by name, account ID, tags, or resource groups.
## Usage
<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
locals {
  zone_vpc_crn_list = [ibm_is_vpc.example_vpc.crn]
  enforcement_mode  = "report"
  # Merge zone ids to pass as contexts to the rule
  target_services_details = [
    {
      target_service_name = "kms",
      target_rg           = module.resource_group.resource_group_id
      enforcement_mode    = local.enforcement_mode
    }
  ]
}

module "cbr_rule_multi_service_profile" {
  source                 = "../../cbr-service-profile"
  zone_service_ref_list  = ["cloud-object-storage", "containers-kubernetes", "server-protect"]
  zone_vpc_crn_list      = local.zone_vpc_crn_list
  target_service_details = local.target_services_details
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | ../cbr-rule-module | n/a |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | ../cbr-zone-module | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all vpc\_zone\_list, service\_ref\_zone\_list and cbr\_rule\_description created by this submodule | `string` | `"serviceprofile"` | no |
| <a name="input_target_service_details"></a> [target\_service\_details](#input\_target\_service\_details) | (String) Details of the target service for which the rule has to be created | <pre>list(object({<br>    target_service_name = string<br>    target_rg           = optional(string)<br>    enforcement_mode    = string<br>    tags                = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_zone_service_ref_list"></a> [zone\_service\_ref\_list](#input\_zone\_service\_ref\_list) | (List) Service reference for the zone creation | `list(string)` | `[]` | no |
| <a name="input_zone_vpc_crn_list"></a> [zone\_vpc\_crn\_list](#input\_zone\_vpc\_crn\_list) | (List) VPC CRN for the zones | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_crns"></a> [rule\_crns](#output\_rule\_crns) | CBR rule crn(s) |
| <a name="output_rule_hrefs"></a> [rule\_hrefs](#output\_rule\_hrefs) | CBR rule href(s) |
| <a name="output_rule_ids"></a> [rule\_ids](#output\_rule\_ids) | CBR rule id(s) |
| <a name="output_zone_crns"></a> [zone\_crns](#output\_zone\_crns) | CBR zone crn(s) |
| <a name="output_zone_hrefs"></a> [zone\_hrefs](#output\_zone\_hrefs) | CBR zone href(s) |
| <a name="output_zone_ids"></a> [zone\_ids](#output\_zone\_ids) | CBR zone resource instance id(s) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
