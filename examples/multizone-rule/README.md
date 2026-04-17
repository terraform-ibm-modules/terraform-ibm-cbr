# Multi-zone example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cbr-multizone-rule-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/examples/multizone-rule">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end example that uses the module's default variable values. This example uses the IBM Cloud Provider to automate the following infrastructure::

 - Creates a VPC
 - Creates a VPC Subnet
 - Create two zones for context-based restrictions.
 - Create a rule for context-based restrictions that uses the zone and attaches the service to it.
