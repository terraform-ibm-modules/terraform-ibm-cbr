# Multi resource rule example

An end-to-end example to show how to apply a rule to multiple resources. This example uses the IBM Cloud Provider to automate the following infrastructure:

- Creates a VPC
- Creates a VPC Subnet
- Creates a CBR Zone for the VPC
- Creates a COS Instance and a COS Bucket
- Applies a single CBR rule to only allow access form the VPC zone to the COS Instance and the same rule for the Bucket
