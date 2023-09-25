# Multi CBR Rule Module

Creates multiple rules for Context Based Restrictions

## Usage

```hcl
module "cbr_rules" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.9.0"
  cbr_rule_list = [{
      description = "rule_description_1"
      rule_contexts = [
      {
        name     = "accountId"
        value    = "1234"
        operator = "stringEquals"
      },
        {
        name     = "serviceInstance"
        value    = "service_instance_id"
        operator = "stringEquals"
        },
        {
        name     = "serviceName"
        value    = "service_name_1"
        operator = "stringEquals"
        },]
      enforcement_mode = "report"
      tags = [{
            name  = "tag_name_1"
            value = "tag_value_1"
            },]
      operations = [{
          api_types = [{
              api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
            },]
        },]
    },
    {
      description = "rule_description_2"
      account_id  = "123456"
      rule_contexts = [
        {
          name     = "accountId"
          value    = "1234"
          operator = "stringEquals"
        },
        {
          name     = "serviceInstance"
          value    = "service_instance_id"
          operator = "stringEquals"
        },
        {
          name     = "serviceName"
          value    = "service_name_2"
          operator = "stringEquals"
        },]
      enforcement_mode = "report"
      tags = [{
        name  = "tag_name_2"
        value = "tag_value_2"
      },]
      operations = [{
        api_types = [{
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
        },]
      },]
    }
  ]
}

```

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
| <a name="input_cbr_rule_list"></a> [cbr\_rule\_list](#input\_cbr\_rule\_list) | List of CBR Rules to be created | <pre>list(object({<br>    description = string<br>    resources = list(object({<br>      attributes = optional(list(object({<br>        name     = string<br>        value    = string<br>        operator = optional(string)<br>      })))<br>      tags = optional(list(object({<br>        name     = string<br>        value    = string<br>        operator = optional(string)<br>      })))<br>    }))<br>    service_instance = optional(string)<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_rules"></a> [rules](#output\_rules) | List of all CBR rules created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
