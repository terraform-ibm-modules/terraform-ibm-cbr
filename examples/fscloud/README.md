# Pre-wired CBR configuration for FS Cloud example

This example demonstrates how to use the [fscloud profile](../../profiles/fscloud/) module to lay out a complete "secure by default" coarse-grained CBR topology in a given account.

This examples is designed to show case some of the key customization options for the module. In addition to the pre-wired CBR rules documented at [fscloud profile](../../profiles/fscloud/), this example shows how to customize the module to:
1. Open up network traffic flow from Schematics to Key Protect and HPCS public endpoints. Note that for illustration purpose, this example configures the use of both Key Protect and HPCS through the `kms_service_targeted_by_prewired_rules` variable. In a real-world scenario, only one Key Management Service would be used
2. Open up network traffic flow from a block of IPs to the Schematics public endpoint.
3. Open up network traffic flow from the VPC created in this example to ICD postgresql private endpoints.

Context: this examples covers a "pseudo" real-world scenario where:
1. Schematics is used to execute terraform that create Key Protect, and HPCS keys and key ring over its public endpoint.
2. Operators use machines with a set list of public IPs to interact with Schematics.
3. Applications are running the VPC and need access to PostgreSQL via the private endpoint - eg: a VPE.
4. Skips creation of zones for these two service references ["user-management", "iam-groups"].

## Note
- The services 'compliance', 'directlink', 'iam-groups', 'containers-kubernetes', 'user-management' do not support restriction per location for zone creation.
