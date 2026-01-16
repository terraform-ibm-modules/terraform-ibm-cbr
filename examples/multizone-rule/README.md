# Multi-zone example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cbr-multizone-rule-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/examples/multizone-rule"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end example that uses the module's default variable values. This example uses the IBM Cloud Provider to automate the following infrastructure::

 - Creates a VPC
 - Creates a VPC Subnet
 - Create two zones for context-based restrictions.
 - Create a rule for context-based restrictions that uses the zone and attaches the service to it.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
