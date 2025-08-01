# CBR Rule Profile

Accepts a list of VPC crns / service references to create CBR zones and a list of target services, to create the rule matching these profiles.  It supports to target the service using name, account id, tags, resource group.

### Usage

```hcl
module "cbr_rule_multi_service_profile" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-service-profile"
  version          = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  prefix                 = "multi-service-profile"
  zone_service_ref_list  = {
                              "cloud-object-storage" = {
                                serviceRef_location = = ["syd", "au"]
                              },
                              "server-protect" = {
                                serviceRef_location = ["au"]
                              },
                                "directlink"          = {}, # directlink does not support restriction per location, hence no value is specified for serviceRef_location.
                                "event-notifications" = {}
                             }
  zone_vpc_crn_list      = ["crn:v1:bluemix:public:is:us-south:a/abac0df06b644a9cabc6e44f55b3880e::vpc:r006-069c6449-03a9-49f1-9070-4d23fc79285e"]
  target_service_details = [
                            {
                              target_service_name = "secrets-manager",
                              target_rg           = "a8cff104f1764e98aac9ab879198230a" # pragma: allowlist secret
                              enforcement_mode    = "report"
                            }
                           ]
  endpoints              = "private"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.0, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | ../cbr-rule-module | n/a |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | ../cbr-zone-module | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | List specific endpoint types for target services, valid values for endpoints are 'public', 'private' or 'direct' | `list(string)` | <pre>[<br/>  "private"<br/>]</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all vpc\_zone\_list, service\_ref\_zone\_list and cbr\_rule\_description created by this submodule | `string` | `"serviceprofile"` | no |
| <a name="input_target_service_details"></a> [target\_service\_details](#input\_target\_service\_details) | (String) Details of the target service for which the rule has to be created | <pre>list(object({<br/>    target_service_name = string<br/>    target_rg           = optional(string)<br/>    enforcement_mode    = string<br/>    tags                = optional(list(string))<br/>  }))</pre> | n/a | yes |
| <a name="input_zone_service_ref_list"></a> [zone\_service\_ref\_list](#input\_zone\_service\_ref\_list) | Provide a valid service reference with the location where the context-based restriction zones are created. If no value is specified for `serviceRef_location`, the zones are not scoped to any location. | <pre>map(object({<br/>    serviceRef_location = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_zone_vpc_crn_list"></a> [zone\_vpc\_crn\_list](#input\_zone\_vpc\_crn\_list) | (List) VPC CRN for the zones | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_crns"></a> [rule\_crns](#output\_rule\_crns) | CBR rule crn(s) |
| <a name="output_rule_hrefs"></a> [rule\_hrefs](#output\_rule\_hrefs) | CBR rule href(s) |
| <a name="output_rule_ids"></a> [rule\_ids](#output\_rule\_ids) | CBR rule id(s) |
| <a name="output_zone_crns"></a> [zone\_crns](#output\_zone\_crns) | CBR zone crn(s) |
| <a name="output_zone_hrefs"></a> [zone\_hrefs](#output\_zone\_hrefs) | CBR zone href(s) |
| <a name="output_zone_ids"></a> [zone\_ids](#output\_zone\_ids) | CBR zone id(s) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
