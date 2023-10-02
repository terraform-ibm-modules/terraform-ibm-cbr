# Multi CBR Rule Module

Creates multiple rules for Context Based Restrictions

## Usage

```hcl
module "cbr_rules" {
  source    = "terraform-ibm-modules/cbr/ibm//modules/cbr-multi-rule-module"
  version   = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  rule_list = [
    {
      enforcement_mode = "enabled"
      account_id       = "1234"
      rule_contexts    = [
        {
          attributes = [
            {
              "name" : "endpointType",
              "value" : "private"
            },
            {
              name  = "networkZoneId"
              value = "zone id here"
            }
          ]
        }
      ]
      operations = [
        {
          api_types = [
            {
              api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
            }
          ]
        }
      ]
    },
    {
      enforcement_mode = "enabled"
      account_id       = "1234"
      rule_contexts    = [
        {
          attributes = [
            {
              "name" : "endpointType",
              "value" : "private"
            },
            {
              name  = "networkZoneId"
              value = "zone id here"
            }
          ]
        }
      ]
      operations = [
        {
          api_types = [
            {
              api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
            }
          ]
        }
      ]
    }
  ]
  rule_descriptions = ["rule_description_1", "rule_description_2"]
  rule_resources    = [{
    attributes = [
      {
        name     = "accountId"
        value    = local.instance_cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = module.cos_instance.cos_instance_guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
      }
    ],
    # IAM Resource tags, must exist on the resource
    tags = [{
      name     = "tag1"
      value    = "tag1"
      operator = "stringEquals"
    }]
  }]

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
| <a name="input_rule_descriptions"></a> [rule\_descriptions](#input\_rule\_descriptions) | List of CBR Rule Descriptions to be created | `list(string)` | `[]` | no |
| <a name="input_rule_list"></a> [rule\_list](#input\_rule\_list) | List of CBR Rules to be created | <pre>list(object({<br>    service_instance = optional(string)<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_rule_resources"></a> [rule\_resources](#input\_rule\_resources) | List of CBR Rule Resources to be created | <pre>list(object({<br>    attributes = optional(list(object({<br>      name     = string<br>      value    = string<br>      operator = optional(string)<br>    })))<br>    tags = optional(list(object({<br>      name     = string<br>      value    = string<br>      operator = optional(string)<br>    })))<br>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_rules"></a> [rules](#output\_rules) | List of all CBR rules created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
