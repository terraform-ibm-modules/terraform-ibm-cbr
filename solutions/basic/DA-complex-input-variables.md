# Configuring complex inputs for Context Based Restriction in IBM Cloud projects

Several input variables in the IBM Cloud [Context Based Restriction deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

* [Context-Based Restrictions Zones](#cbr-zones) (`cbr_zones`)
* [Context-Based Restrictions Rules](#cbr-rules) (`cbr_rules`)


## Context-Based Restrictions Zones <a name="cbr-zones"></a>

The `cbr_zones` input variable allows you to define one or more Context-Based Restriction (CBR) network zones in IBM Cloud. These zones represent trusted sources of network traffic, such as IP addresses, subnets, or VPCs, which can later be referenced in CBR rules to restrict access to IBM Cloud services.

- Variable name: `cbr_zones`
- Type: A map of objects, where the key is a unique identifier for each zone (used as a reference in rules).
- Default value: An empty map (`{}`)

This variable enables you to define reusable network zone definitions, which can then be attached to one or more `cbr_rules` using `zone_keys`. It also supports both creating new zones and referencing existing zones by ID.

### Options for cbr_zones
- `account_id` (optional): The IBM Cloud account ID where the zone should be created. If not provided, the default account context is used.

- `name` (required): The name of the network zone.

- `zone_description` (optional): A description for the zone.

- `addresses` (optional): A list of allowed network sources. Each entry supports:
  - `type` (optional): The address type. Supported types include `ipAddress`, `subnet`, `vpc`, `serviceRef`, etc.
  - `value` (optional): The string value of the address (e.g., IP range, VPC CRN).
  - `ref` (optional): An object for service reference-based restrictions, containing:
    - `account_id`
    - `location`
    - `service_instance`
    - `service_name`
    - `service_type`

- `excluded_addresses` (optional): A list of addresses to explicitly exclude from the zone.
  - `type` (optional): The type of the excluded address.
  - `value` (optional): The string value of the address to exclude.

- `use_existing_cbr_zone` (optional): If `true`, skips creation and references an existing CBR zone instead.

- `existing_zone_id` (optional): The ID of the existing zone to reference (required if `use_existing_cbr_zone = true`).

### Example Context-Based Restrictions Zone Configuration

```hcl
{
    zone1 = {
      name        = "vpc-zone"
      zone_description = "Zone for VPCs"
      addresses = [
        {
          type  = "vpc"
          value = "crn:v1:bluemix:public:is:us-south:a/123456:vpc:abc123"
        }
      ]
    }
  zone2 = {
    name       = "ip-zone2"
    zone_description = "Zone for restricted IPs"
    addresses = [
      {
        type  = "ipAddress"
        value = "203.x.xxx.5"
      }
    ]
  }
  zone3 = {
    name       = "ip-zone3"
    zone_description = "Zone for restricted IPs"
    addresses = [
      {
        type  = "ipAddress"
        value = "203.x.xxx.6"
      }
    ]
  }
}
```

For more information, refer to the [IBM Cloud Context-Based Restrictions documentation](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis) and the [IBM Cloud Terraform Provider documentation for CBR Zones](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cbr_zone).

## Context-Based Restrictions Rules <a name="cbr-rules"></a>

The `cbr_rules` input variable allows you to define one or more Context-Based Restriction (CBR) rules in IBM Cloud. These rules determine who can access which services based on predefined trusted zones or dynamic context attributes.

- Variable name: `cbr_rules`.
- Type: A map of objects, where each key is a unique rule identifier
- Default value: An empty list (`{}`).

This variable enables fine-grained access control across IBM Cloud resources by applying conditions based on source zones or contextual attributes. Each rule targets specific services or instances, optionally filtering by tags or attributes.

### Options for cbr_rules
- `rule_description` (optional): A description for rule

- `enforcement_mode` (optional): Specifies how the rule is enforced. Valid values are:
  - `enabled`: Actively blocks requests not matching the rule.
  - `disabled`: Rule is inactive.
  - `report`: Logs but does not block requests.
  Defaults to `"report"`.

- `zone_keys` (required): A list of keys referencing zones defined in the `cbr_zones` map. Required if `rule_contexts` is not provided.

- `rule_contexts` (optional): A list of context-based rules that appends default  rule_contexts containing zones from `zone_keys`. Each context supports:
  - `attributes` (optional): A list of key-value pairs to define access conditions.
    - `name` (required): The attribute name.
    - `value` (required): The attribute value.

- `resources` (required): A list of IBM Cloud services and instances to restrict. Each item supports:
  - `service_name` (required): The name of the IBM Cloud service (e.g., `cloud-object-storage`).
  - `resource_instance_id` (optional): The instance ID of the service.
  - `attributes` (optional): A list of key-value filters for matching resources.
    - `name` (required): Attribute name.
    - `value` (required): Attribute value.
    - `operator` (optional): Operator for matching (e.g., `equals`, `in`, etc.).
  - `tags` (optional): A list of tag-based filters with the same structure as `attributes`.

- `operations` (optional): A list of allowed API operations for the rule. Each item includes:
  - `api_types`: A list of objects with:
    - `api_type_id` (required): The API type CRN.
  Defaults to a single generic CBR API type:
  ```hcl
  [
    {
      api_types = [
        {
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
        }
      ]
    }
  ]
  ```

### Example for Context-Based Restrictions Rule Configuration

```hcl
{
  rule1 = {
    rule_description = "Restrict redis to specific IP address only"
    enforcement_mode = "enabled"
    resources = [
      {
        attributes = [
          {
            name     = "accountId"
            operator = "stringEquals"
            value    = "d5xxxxxd5" # pragma: allowlist secret
          },
          {
            name     = "serviceName"
            operator = "stringEquals"
            value    = "databases-for-redis"
          },
          {
            name     = "resourceGroupId"
            operator = "stringEquals"
            value    = "be19xxxxx0c7d" # pragma: allowlist secret
          }
        ],

      }
    ]
    operations = [
      {
        api_types = [
          {
            api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:data-plane"
          }
        ]
      }
    ]
    zone_keys = ["zone3", "zone2"] # mapping specific zones
  },
  rule2 = {
    rule_description = "Restrict Postgresql to VPC zone only"
    enforcement_mode = "disabled"
    resources = [
      {
        attributes = [
          {
            name     = "accountId"
            operator = "stringEquals"
            value    = "d5xxxxxd5" # pragma: allowlist secret
          },
          {
            name     = "serviceName"
            operator = "stringEquals"
            value    = "databases-for-postgresql"
          },
          {
            name     = "resourceGroupId"
            operator = "stringEquals"
            value    = "be19xxxxx0c7d" # pragma: allowlist secret
          }
        ]
      }
    ]
    operations = [
      {
        api_types = [
          {
            api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:data-plane"
          }
        ]
      }
    ]
    zone_keys = ["zone1"]
  }
}
```

For more information, refer to the [IBM Cloud Context-Based Restrictions documentation](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis) and the [IBM Cloud Terraform Provider documentation for CBR Rules](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cbr_rule).
