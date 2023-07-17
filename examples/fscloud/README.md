# Pre-wired CBR configuration for FS Cloud example

- An end-to-end example that uses the fscloud profile to create pre-wired CBR configuration.

- Creates a following pre-defined CBR rules based on the boolean value set to the variables:
COS -> KMS
Block storage -> KMS
ROKS -> KMS
VPCs -> container registry
VPCs -> where clusters are deployed -> COS

 - Create a VPC and create a CBR zone to allowlist the VPC.
 - Create a service reference based CBR zone.
 - Create a following pre-wired CBR rules :
   - COS -> KMS
   - Block storage -> KMS
   - ROKS -> KMS
   - VPCs -> container registry
   - VPCs -> where clusters are deployed -> COS
- Target service instances access is granted based on the following parameters :
    - Based on the account.
    - Based on the access tags.
    - Based on the resource group.
