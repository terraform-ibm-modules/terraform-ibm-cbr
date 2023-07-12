# CBR Multi Service Profile

An end-to-end example that uses the submodule cbr-service-profile. This example uses the IBM Cloud Provider to automate the following infrastructure::

 - Create a VPC and create a CBR zone to allowlist the VPC.
 - Create a service reference based CBR zone.
 - Create a set of CBR rules.
   - Based on the list of target service details provided, create rules for each of them.
   - Target service instances access is granted based on the following parameters.
     - Based on the account.
     - Based on the access tags.
     - Based on the resource group.
