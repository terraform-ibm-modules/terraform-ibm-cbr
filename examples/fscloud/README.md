# Pre-wired CBR configuration for FS Cloud example

This example demonstrates how to use the [fscloud profile](../../profiles/fscloud/) module to lay out a complete "secure by default" coarse-grained CBR topology in a given account.

This examples is designed to show case some of the key customization options for the module. In addition to the pre-wired CBR rules documented at [fscloud profile](../../profiles/fscloud/), this examples show how to customize the module to:
1. Open up network traffic flow from ICD mongodb, ICD Postgresql to the Key Protect private endpoints
2. Open up network traffic flow from Schematics to Key Protect public endpoints
3. Open up network traffic flow from a block of IPs to the Schematics public endpoint
4. Open up network traffic flow from the VPC created in this example to ICD postgresql private endpoints

Context: this examples covers a "pseudo" real-world scenario where:
1. ICD Mongodb, and Postgresql instances are encrypted using keys storage in Key Protect.
2. Schematics is used to execute terraform that create Key Protect keys and key ring over its public endpoint.
3. Operators use machines with a set list of public IPs to interact with Schematics.
4. Applications are running the VPC and need access to PostgreSQL via the private endpoint - eg: a VPE.
5. Skips creation of zones for these two service references ["user-management", "iam-groups"].

## Note
- The services 'compliance', 'directlink', 'iam-groups', 'containers-kubernetes', 'user-management' do not support restriction per location for zone creation.
