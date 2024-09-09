# Zone example

Example that creates a zone for context-based restrictions. This example uses the IBM Cloud Provider to automate the following infrastructure:

- Creates 2 VPCs.
- Creates 2 Public Gateways.
- Creates 2 VPC Subnets.
- Creates a CBR Zone for the VPC.
- Updates an existing CBR Zone created above with a new addresses containing a new VPC and a `compliance` serviceRef.
