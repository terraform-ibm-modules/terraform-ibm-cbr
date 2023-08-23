# CBR Zone Module

Creates a zone for Context Based Restrictions

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_cbr_zone.cbr_zone](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cbr_zone) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Optional, String) The id of the account owning this zone | `string` | `null` | no |
| <a name="input_addresses"></a> [addresses](#input\_addresses) | (List) The list of addresses in the zone | <pre>list(object({<br>    type  = optional(string)<br>    value = optional(string)<br>    ref = optional(object({<br>      account_id       = string<br>      location         = optional(string)<br>      service_instance = optional(string)<br>      service_name     = optional(string)<br>      service_type     = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_excluded_addresses"></a> [excluded\_addresses](#input\_excluded\_addresses) | (Optional, List) The list of excluded addresses in the zone | <pre>list(object({<br>    type  = optional(string)<br>    value = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional, String) The name of the zone | `string` | `null` | no |
| <a name="input_zone_description"></a> [zone\_description](#input\_zone\_description) | (Optional, String) The description of the zone | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_zone_crn"></a> [zone\_crn](#output\_zone\_crn) | CBR zone resource instance crn |
| <a name="output_zone_description"></a> [zone\_description](#output\_zone\_description) | CBR zone resource instance description |
| <a name="output_zone_href"></a> [zone\_href](#output\_zone\_href) | CBR zone resource instance link |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | CBR zone resource instance id |
| <a name="output_zone_names"></a> [zone\_names](#output\_zone\_names) | CBR zone resource instance name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
