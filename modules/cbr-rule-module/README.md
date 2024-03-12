# CBR Rule Module

Creates a rule for Context Based Restrictions

### Usage

```hcl
module "ibm_cbr" "rule" {
  # replace main with version
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  name             = "rule_for_pg_access"
  rule_description = "rule from terraform"
  enforcement_mode = "enabled"
  rule_contexts    = [{
                      attributes = [{
                        name  = "networkZoneId"
                        value = "afe33d0061b6cea2c2e6f543111f5c8a" # pragma: allowlist secret
                      }]
                     }]
  resources        = [{
                      attributes = [
                        {
                          name     = "accountId"
                          value    = "defc0df06b644a9cabc6e44f55b3880s"
                          operator = "stringEquals"
                        },
                        {
                          name     = "resourceGroupId",
                          value    = "8ce996b5e6ed4592ac0e39f4105351d6" # pragma: allowlist secret
                          operator = "stringEquals"
                        },
                        {
                          name     = "serviceInstance"
                          value    = "10732830-c128-48f0-aec6-c9eaa8d10c68"
                          operator = "stringEquals"
                        },
                        {
                          name     = "serviceName"
                          value    = "cloud-object-storage"
                          operator = "stringEquals"
                        }
                       ]
                     }]
  operations       = [{ api_types = [{
                        api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
                      }]
                     }]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_cbr_rule.cbr_rule](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cbr_rule) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enforcement_mode"></a> [enforcement\_mode](#input\_enforcement\_mode) | (String) The rule enforcement mode | `string` | `"report"` | no |
| <a name="input_operations"></a> [operations](#input\_operations) | (Optional, List) The operations this rule applies to, by default it will protect all of the service and platform APIs the target service supports. | <pre>list(object({<br>    api_types = list(object({<br>      api_type_id = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "api_types": [<br>      {<br>        "api_type_id": "crn:v1:bluemix:public:context-based-restrictions::::api-type:"<br>      }<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_resources"></a> [resources](#input\_resources) | (List) The resources this rule apply to | <pre>list(object({<br>    attributes = optional(list(object({<br>      name     = string<br>      value    = string<br>      operator = optional(string)<br>    })))<br>    tags = optional(list(object({<br>      name     = string<br>      value    = string<br>      operator = optional(string)<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_rule_contexts"></a> [rule\_contexts](#input\_rule\_contexts) | (List) The contexts the rule applies to | <pre>list(object({<br>    attributes = optional(list(object({<br>      name  = string<br>      value = string<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_rule_description"></a> [rule\_description](#input\_rule\_description) | (Optional, String) The description of the rule | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_crn"></a> [rule\_crn](#output\_rule\_crn) | CBR rule resource instance crn |
| <a name="output_rule_description"></a> [rule\_description](#output\_rule\_description) | CBR rule resource instance description |
| <a name="output_rule_href"></a> [rule\_href](#output\_rule\_href) | CBR rule resource href |
| <a name="output_rule_id"></a> [rule\_id](#output\_rule\_id) | CBR rule resource instance id |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
