# Multi CBR Rule Module

Creates multiple rules for Context Based Restrictions

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rules"></a> [cbr\_rules](#module\_cbr\_rules) | ../cbr-rule-module | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cbr_rule_list"></a> [cbr\_rule\_list](#input\_cbr\_rule\_list) | List of CBR rules to be created | <pre>list(object({<br>    description      = string<br>    account_id       = string<br>    resource         = optional(string)<br>    service_instance = optional(string)<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_resource"></a> [resource](#input\_resource) | Resource to be used in the rule, applied to all rules in list and overrides rule specific resource if provided | `string` | `""` | no |
| <a name="input_service_instance"></a> [service\_instance](#input\_service\_instance) | Service Instance to be used in the rule, applied to all rules in list and overrides rule specific serviceInstance if provided | `string` | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_rules"></a> [rules](#output\_rules) | List of all CBR rules created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
