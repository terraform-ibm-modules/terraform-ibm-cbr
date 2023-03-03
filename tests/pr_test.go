// Tests in this file are run in the PR pipeline
package test

import (
	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/IBM/platform-services-go-sdk/contextbasedrestrictionsv1"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const resourceGroup = "geretain-test-cbr"
const zoneExampleTerraformDir = "examples/zone"
const completeExampleTerraformDir = "examples/multizone-rule"

func TestRunZoneExample(t *testing.T) {
	t.Parallel()
	cloudInfoSvc, err := cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	assert.Nil(t, err, "Failed to create cloud info service")

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  zoneExampleTerraformDir,
		Prefix:        "cbr-zone",
		ResourceGroup: resourceGroup,
	})
	options.SkipTestTearDown = true
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	outputs := terraform.OutputAll(options.Testing, options.TerraformOptions)

	zone, err := cloudInfoSvc.GetCBRZoneByID(outputs["zone_id"].(string))
	assert.Nilf(t, err, "This should not have errored, could not get zone")

	expectedAddresses := []contextbasedrestrictionsv1.AddressIntf{
		&contextbasedrestrictionsv1.AddressVPC{
			Type:  core.StringPtr("vpc"),
			Value: core.StringPtr(outputs["vpc_crn"].(string)),
		},
		&contextbasedrestrictionsv1.AddressServiceRef{
			Type: core.StringPtr("serviceRef"),
			Ref: &contextbasedrestrictionsv1.ServiceRefValue{
				AccountID:   core.StringPtr(outputs["account_id"].(string)),
				ServiceName: core.StringPtr("secrets-manager"),
			},
		},
	}
	assert.Equal(t, outputs["zone_name"].(string), *zone.Name)
	assert.Equal(t, outputs["zone_description"].(string), *zone.Description)
	assert.Equal(t, outputs["account_id"].(string), *zone.AccountID)
	assert.EqualValues(t, expectedAddresses, zone.Addresses)
	assert.Empty(t, zone.Excluded)

	options.TestTearDown()
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()
	cloudInfoSvc, err := cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	assert.Nil(t, err, "Failed to create cloud info service")

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  completeExampleTerraformDir,
		Prefix:        "cbr-multizone",
		ResourceGroup: resourceGroup,
	})
	options.SkipTestTearDown = true

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	outputs := terraform.OutputAll(options.Testing, options.TerraformOptions)
	expectedOutputs := []string{"rule_id", "zone_id", "account_id", "cos_guid", "resource_group_id"}
	_, outputErr := testhelper.ValidateTerraformOutputs(outputs, expectedOutputs...)
	if assert.NoErrorf(t, outputErr, "Some outputs not found or nil") {
		rules, err := cloudInfoSvc.GetCBRRuleByID(outputs["rule_id"].(string))
		assert.Nil(t, err, "Failed to get rules")
		if assert.NotNil(t, rules, "No rules found") {

			zoneIds := outputs["zone_id"].([]interface{})

			var expectedContexts []contextbasedrestrictionsv1.RuleContext
			// Check the contexts loop through zones in output there should be 1 context per zone
			for _, zoneId := range zoneIds {
				t.Logf("Zone: %s", zoneId)

				currentAttribute := []contextbasedrestrictionsv1.RuleContextAttribute{
					{
						Name:  core.StringPtr("networkZoneId"),
						Value: core.StringPtr(zoneId.(string)),
					},
				}
				expectedContexts = append(expectedContexts, contextbasedrestrictionsv1.RuleContext{
					Attributes: currentAttribute,
				})
			}
			assert.ElementsMatch(t, expectedContexts, rules.Contexts, "expected contexts not found")

			// TODO: Do I need to create a list of resources and check too??
			// Check the Resource Attributes ensure multiple attributes are correctly applied
			expectedResourceAttributes := []contextbasedrestrictionsv1.ResourceAttribute{
				{
					Name:     core.StringPtr("accountId"),
					Value:    core.StringPtr(outputs["account_id"].(string)),
					Operator: core.StringPtr("stringEquals"),
				},
				{
					Name:     core.StringPtr("serviceInstance"),
					Value:    core.StringPtr(outputs["cos_guid"].(string)),
					Operator: core.StringPtr("stringEquals"),
				},
				{
					Name:     core.StringPtr("resourceGroupId"),
					Value:    core.StringPtr(outputs["resource_group_id"].(string)),
					Operator: core.StringPtr("stringEquals"),
				},
				{
					Name:     core.StringPtr("serviceName"),
					Value:    core.StringPtr("cloud-object-storage"),
					Operator: core.StringPtr("stringEquals"),
				},
			}
			assert.ElementsMatch(t, expectedResourceAttributes, rules.Resources[0].Attributes, "expected resource attributes not found")
			// Check the Resource Tags ensure multiple Tags are correctly applied
			expectedTags := []contextbasedrestrictionsv1.ResourceTagAttribute{
				{
					Name:  core.StringPtr("iam_access_tag"),
					Value: core.StringPtr("allow-access"),
				},
				{
					Name:  core.StringPtr("sample_tag"),
					Value: core.StringPtr("secondary_example_tag"),
				},
			}
			assert.ElementsMatch(t, expectedTags, rules.Resources[0].Tags, "expected resource tags not found")
			// TODO: Check the Operations ensure multiple Operations are correctly applied
			// 		 Only a single operation is currently being tested.
			//		 Need to find an example where multiple operations can be applied
			//expectedOperations := []contextbasedrestrictionsv1.OperationsList{
			//	{APITypes: []contextbasedrestrictionsv1.APIType{{
			//		APITypeID:   core.StringPtr(""),
			//		DisplayName: core.StringPtr(""),
			//		Description: core.StringPtr(""),
			//		Actions: []contextbasedrestrictionsv1.Action{{
			//			ActionID:    core.StringPtr(""),
			//			Description: core.StringPtr(""),
			//		}},
			//	},
			//	}},
			//}

			// COS has no operations that can be set
			// TODO: Replace COS with another service for test purposes
			assert.Nil(t, rules.Operations)

		}
	}
	options.TestTearDown()
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  zoneExampleTerraformDir,
		Prefix:        "cbr-upg",
		ResourceGroup: resourceGroup,
	})

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
