# CBR multi service profile

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cbr-multi-service-profile-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cbr/tree/main/examples/multi-service-profile"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end example that uses the submodule cbr-service-profile. This example uses the IBM Cloud Provider to automate the following infrastructure::

 - Create a VPC and create a CBR zone to allowlist the VPC.
 - Create a service reference based CBR zone.
 - Create a set of CBR rules.
   - Based on the list of target service details provided, create rules for each of them.
   - Target service instances access is granted based on the following parameters.
     - Based on the account.
     - Based on the access tags.
     - Based on the resource group.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
