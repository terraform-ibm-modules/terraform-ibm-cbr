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
| <a name="module_cbr_rule_multi_service_profile_1"></a> [cbr\_rule\_multi\_service\_profile\_1](#module\_cbr\_rule\_multi\_service\_profile\_1) | ../../cbr-service-profile | n/a |
| <a name="module_cbr_rule_multi_service_profile_2"></a> [cbr\_rule\_multi\_service\_profile\_2](#module\_cbr\_rule\_multi\_service\_profile\_2) | ../../cbr-service-profile | n/a |

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
| <a name="input_enforcement_mode"></a> [enforcement\_mode](#input\_enforcement\_mode) | The rule enforcement mode on a rule upon creation. Allowable values are: enabled, disabled, report. | `string` | `"enabled"` | no |
| <a name="input_existing_access_tags"></a> [existing\_access\_tags](#input\_existing\_access\_tags) | Optional list of existing access tags to be added https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create, Provide the access tags with key:value format in a list | `list(string)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all vpc\_zone\_list, service\_ref\_zone\_list and cbr\_rule\_description created by this submodule | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the instance will be created. | `string` | n/a | yes |
| <a name="input_zone_vpc_crn_list"></a> [zone\_vpc\_crn\_list](#input\_zone\_vpc\_crn\_list) | (List) VPC CRN for the zones | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | Account ID (used in tests) |
| <a name="output_rule_crns"></a> [rule\_crns](#output\_rule\_crns) | CBR rule resource instance crn(s) |
| <a name="output_rule_hrefs"></a> [rule\_hrefs](#output\_rule\_hrefs) | CBR rule resource instance href(s) |
| <a name="output_rule_ids"></a> [rule\_ids](#output\_rule\_ids) | CBR rule id(s) |
| <a name="output_zone_crns"></a> [zone\_crns](#output\_zone\_crns) | CBR zones crn(s) |
| <a name="output_zone_hrefs"></a> [zone\_hrefs](#output\_zone\_hrefs) | CBR zones href(s) |
| <a name="output_zone_ids"></a> [zone\_ids](#output\_zone\_ids) | CBR zone resource instance id(s) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
