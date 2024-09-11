# CBR Zone Module

Creates a zone for Context Based Restrictions or updates addresses in an existing zone.

### Usage

```hcl
# Creates a new zone
module "ibm_cbr" "zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  name             = "zone_for_pg_access"
  account_id       = "defc0df06b644a9cabc6e44f55b3880s"
  zone_description = "Zone created from terraform"
  addresses        = [{type  = "vpc",value = "vpc_crn"}]
}
```

```hcl
# Updates an existing zone with new addresses
module "ibm_cbr" "zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific
  use_existing_cbr_zone = true
  zone_id          = "7714beceb512dffef0746cd0e4105309" # pragma: allowlist secret
  addresses        = [{type  = "vpc",value = "vpc_crn"}]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.69.0, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_cbr_zone.cbr_zone](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cbr_zone) | resource |
| [ibm_cbr_zone_addresses.update_cbr_zone_address](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cbr_zone_addresses) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Optional, String) The id of the account owning this zone | `string` | `null` | no |
| <a name="input_addresses"></a> [addresses](#input\_addresses) | (List) The list of addresses in the zone | <pre>list(object({<br>    type  = optional(string)<br>    value = optional(string)<br>    ref = optional(object({<br>      account_id       = string<br>      location         = optional(string)<br>      service_instance = optional(string)<br>      service_name     = optional(string)<br>      service_type     = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_excluded_addresses"></a> [excluded\_addresses](#input\_excluded\_addresses) | (Optional, List) The list of excluded addresses in the zone | <pre>list(object({<br>    type  = optional(string)<br>    value = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_existing_zone_id"></a> [existing\_zone\_id](#input\_existing\_zone\_id) | Provide an existing CBR zone ID | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional, String) The name of the zone | `string` | `null` | no |
| <a name="input_use_existing_cbr_zone"></a> [use\_existing\_cbr\_zone](#input\_use\_existing\_cbr\_zone) | Whether to update CBR zone using existing zone ID. This allows the inclusion of one or more addresses in an existing zone | `bool` | `false` | no |
| <a name="input_zone_description"></a> [zone\_description](#input\_zone\_description) | (Optional, String) The description of the zone | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_zone_crn"></a> [zone\_crn](#output\_zone\_crn) | CBR zone resource crn |
| <a name="output_zone_description"></a> [zone\_description](#output\_zone\_description) | CBR zone resource description |
| <a name="output_zone_href"></a> [zone\_href](#output\_zone\_href) | CBR zone resource link |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | CBR zone resource id |
| <a name="output_zone_names"></a> [zone\_names](#output\_zone\_names) | CBR zone resource name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
