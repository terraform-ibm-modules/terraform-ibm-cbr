// Tests in this file are run in the PR pipeline
package test

import (
	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/IBM/platform-services-go-sdk/contextbasedrestrictionsv1"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const resourceGroup = "geretain-test-cbr"
const zoneExampleTerraformDir = "examples/zone"
const completeExampleTerraformDir = "examples/multizone-rule"
const permanentResourcesYaml = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

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

	permanentResources, err := common.LoadMapFromYaml(permanentResourcesYaml)
	if assert.Nilf(t, err, "Could Not load permanent resource list %s", err) {
		// Convert the accessTags field slice of strings
		var accessTags []string
		accessTagsRaw, ok := permanentResources["accessTags"].([]interface{})
		if ok {
			for _, tag := range accessTagsRaw {
				accessTags = append(accessTags, tag.(string))
			}
		}

		options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
			Testing:       t,
			TerraformDir:  completeExampleTerraformDir,
			Prefix:        "cbr-multizone",
			ResourceGroup: resourceGroup,
			TerraformVars: map[string]interface{}{
				"existing_access_tags": accessTags,
			},
		})
		options.SkipTestTearDown = true

		output, err := options.RunTestConsistency()

		if assert.Nil(t, err, "This should not have errored") &&
			assert.NotNil(t, output, "Expected some output") {

			outputs := terraform.OutputAll(options.Testing, options.TerraformOptions)
			expectedOutputs := []string{"rule_id", "zone_id", "account_id", "cos_guid", "resource_group_id"}
			_, outputErr := testhelper.ValidateTerraformOutputs(outputs, expectedOutputs...)
			if assert.NoErrorf(t, outputErr, "Some outputs not found or nil") {
				rules, err := cloudInfoSvc.GetCBRRuleByID(outputs["rule_id"].(string))
				assert.Nil(t, err, "Failed to get rules")
				if assert.NotNil(t, rules, "No rules found") {

					t.Run("verify all zone ids exist", func(t *testing.T) {
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
					})
					t.Run("verify all attributes set", func(t *testing.T) {
						// Check the Resource Attributes ensure multiple attributes are correctly applied
						// Note: could not find a valid example where there were multiple attribute blocks or multiple resources
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
					})
					t.Run("verify all tags present", func(t *testing.T) {
						// Check the Resource Tags ensure multiple Tags are correctly applied
						var expectedTags []contextbasedrestrictionsv1.ResourceTagAttribute
						for _, tag := range accessTags {
							name := strings.Split(tag, ":")[0]
							value := strings.Split(tag, ":")[1]

							expectedTags = append(expectedTags, contextbasedrestrictionsv1.ResourceTagAttribute{
								Name:  core.StringPtr(name),
								Value: core.StringPtr(value)})
						}

						assert.ElementsMatch(t, expectedTags, rules.Resources[0].Tags, "expected resource tags not found")
					})
					t.Run("verify no operation set", func(t *testing.T) {
						// Note: COS has no operations that can be set
						//       Leaving this code here as a reference for others
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
						//
						//assert.ElementsMatch(t, expectedOperations, rules.Operations)

						// Assert COS has no operations set as expected
						assert.Nil(t, rules.Operations)
					})

				}
			}

		}
		options.TestTearDown()
	}
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
