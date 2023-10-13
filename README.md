# Context-based restrictions module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cbr?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-cbr/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module can be used to provision and configure [Context Based Restrictions](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-create&interface=ui).

See in particular the [fscloud module](./modules/fscloud/) that enables creating an opiniated account-level coarse-grained set of CBR rules and zones aligned with the "secure by default" principles.

<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-cbr](#terraform-ibm-cbr)
* [Submodules](./modules)
    * [cbr-rule-module](./modules/cbr-rule-module)
    * [cbr-service-profile](./modules/cbr-service-profile)
    * [cbr-zone-module](./modules/cbr-zone-module)
    * [fscloud](./modules/fscloud)
* [Examples](./examples)
    * [CBR multi service profile](./examples/multi-service-profile)
    * [Multi resource rule example](./examples/multi-resource-rule)
    * [Multi-zone example](./examples/multizone-rule)
    * [Pre-wired CBR configuration for FS Cloud example](./examples/fscloud)
    * [Zone example](./examples/zone)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-cbr

### Usage

```hcl
module "ibm_cbr" "zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  name             = "zone_for_pg_access"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  zone_description = "Zone created from terraform"
  addresses        = [{type  = "vpc",value = "vpc_crn"}]
}

module "ibm_cbr" "rule" {
  # replace main with version
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  name             = "rule_for_pg_access"
  rule_description = "rule from terraform"
  enforcement_mode = "enabled"
  rule_contexts    = var.rule_contexts
  resources        = var.pg_resource
  operations       = []
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - `Editor` role access
- VPC Infrastructure Services
    - `Editor` role access


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | ./modules/cbr-rule-module | n/a |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | ./modules/cbr-zone-module | n/a |

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
| <a name="input_operations"></a> [operations](#input\_operations) | (Optional, List) The operations this rule applies to | <pre>list(object({<br>    api_types = list(object({<br>      api_type_id = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "api_types": [<br>      {<br>        "api_type_id": "crn:v1:bluemix:public:context-based-restrictions::::api-type:"<br>      }<br>    ]<br>  }<br>]</pre> | no |
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

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
