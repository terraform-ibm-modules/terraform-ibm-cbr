# Pre-wired CBR Configuration for FS Cloud Example

This example demonstrates how to use the [fscloud profile](../../profiles/fscloud/) module to lay out a complete "secure by default" coarse-grained CBR topology in a given account.

This example is designed to showcase some of the key customization options for the module. In addition to the pre-wired CBR rules documented at [fscloud profile](../../profiles/fscloud/), this example shows how to customize the module to:
1. Allow network traffic flow from ICD MongoDB, ICD PostgreSQL to the Key Protect private endpoints.
2. Allow network traffic flow from Schematics to Key Protect public endpoints.
3. Allow network traffic flow from a block of IPs to the Schematics public endpoint.
4. Open up network traffic flow from the VPC created in this example to ICD PostgreSQL private endpoints.
5. Customize the rule description for `kms` and the zone name for `codeengine`.

Context: This example covers a "pseudo" real-world scenario where:
1. ICD Mongodb and Postgresql instances are encrypted using keys stored in Key Protect.
2. Schematics is used to execute terraform that creates Key Protect keys and key rings over its public endpoint.
3. Operators use machines with a set list of public IPs to interact with Schematics.
4. Applications are running in the VPC and need access to PostgreSQL via the private endpoint - e.g., a VPE.
5. Skips creation of zones for these two service references ["user-management", "iam-groups"].

## Note
- The services 'compliance', 'directlink', 'iam-groups', 'containers-kubernetes', 'user-management' do not support location-based restrictions for zone creation.
