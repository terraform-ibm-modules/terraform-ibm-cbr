# Zone example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cbr-update-existing-zone-addresses-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/examples/update-existing-zone-addresses">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

Example that creates a zone for context-based restrictions. This example uses the IBM Cloud Provider to automate the following infrastructure:

- Creates 2 VPCs.
- Creates 2 Public Gateways.
- Creates 2 VPC Subnets.
- Creates a CBR Zone for the VPC.
- Updates an existing CBR Zone created above with new addresses containing another VPC created above and a `compliance` serviceRef.
