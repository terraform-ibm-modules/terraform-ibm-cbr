# CBR service module

This module creates a list of CBR zones and rules. Accepts a list of VPC CRNs / service references to create CBR zones and a list of target services to create the rule matching these profiles. It supports to target the service using name, account id, tags, resource group.
## Usage

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
### Requirements

No requirements.

### Modules

No modules.

### Resources

No resources.

### Inputs

No inputs.

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
