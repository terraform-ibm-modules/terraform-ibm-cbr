# Multi resource rule example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cbr-multi-resource-rule-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/examples/multi-resource-rule"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end example to show how to apply a rule to multiple resources. This example uses the IBM Cloud Provider to automate the following infrastructure:

- Creates a VPC
- Creates a VPC Subnet
- Creates a CBR Zone for the VPC
- Creates a COS Instance and a COS Bucket
- Applies a single CBR rule to only allow access form the VPC zone to the COS Instance and the same rule for the Bucket

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
