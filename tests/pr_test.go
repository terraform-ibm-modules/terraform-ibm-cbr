// Tests in this file are run in the PR pipeline
package test

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/IBM/platform-services-go-sdk/contextbasedrestrictionsv1"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const zoneExampleTerraformDir = "examples/zone"
const completeExampleTerraformDir = "examples/multizone-rule"
const multiServiceExampleTerraformDir = "examples/multi-service-profile"
const fsCloudExampleTerraformDir = "examples/fscloud"
const updateExistingCBRZone = "examples/update-existing-zone-addresses"
const permanentResourcesYaml = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"
const fullyConfigurableDADir = "solutions/fully-configurable"

var (
	permanentResources map[string]interface{}
)

// TestMain will be run before any parallel tests, used to set up permanentResources object
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(permanentResourcesYaml)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func TestRunZoneExample(t *testing.T) {
	t.Parallel()
	cloudInfoSvc, err := cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	assert.Nil(t, err, "Failed to create cloud info service")

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: zoneExampleTerraformDir,
		Prefix:       "cbr-zone",
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
			Testing:      t,
			TerraformDir: completeExampleTerraformDir,
			Prefix:       "cbr-multizone",
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
				rules, _, err := cloudInfoSvc.GetCBRRuleByID(outputs["rule_id"].(string))
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
					t.Run("verify rule operation set", func(t *testing.T) {
						expectedOperations := &contextbasedrestrictionsv1.NewRuleOperations{
							APITypes: []contextbasedrestrictionsv1.NewRuleOperationsAPITypesItem{
								{
									APITypeID: core.StringPtr("crn:v1:bluemix:public:context-based-restrictions::::api-type:"),
								},
							},
						}
						assert.Equal(t, expectedOperations, rules.Operations, "expected operations not found")
					})

				}
			}

		}
		options.TestTearDown()
	}
}

func TestMultiServiceProfileExample(t *testing.T) {
	t.Parallel()
	cloudInfoSvc, err := cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	assert.Nil(t, err, "Failed to create cloud info service")

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: multiServiceExampleTerraformDir,
		Prefix:       "cbr-msp",
	})
	options.SkipTestTearDown = true
	output, err := options.RunTestConsistency()

	if assert.Nil(t, err, "This should not have errored") &&
		assert.NotNil(t, output, "Expected some output") {

		outputs := terraform.OutputAll(options.Testing, options.TerraformOptions)
		expectedOutputs := []string{"rule_ids", "zone_ids", "account_id"}
		_, outputErr := testhelper.ValidateTerraformOutputs(outputs, expectedOutputs...)
		if assert.NoErrorf(t, outputErr, "Some outputs not found or nil") {

			//Service Reference verification
			zones := outputs["zone_ids"].([]interface{})
			if assert.Nil(t, err, "Failed to get rules") &&
				assert.NotNil(t, zones, "No zones found") {
				t.Run("verify service reference exist", func(t *testing.T) {
					var serviceRefExists bool
					var actual_references []string
					expected_references := []string{"cloud-object-storage", "server-protect", "directlink", "event-notifications"}

					zoneIds := zones[0].([]interface{})
					for index := range zoneIds {
						zone := zoneIds[index].(string)
						zone_details, err := cloudInfoSvc.GetCBRZoneByID(zone)
						if assert.Nil(t, err, "Failed to get the zone") &&
							assert.NotNil(t, zone_details, "No zone found") {
							uniqueMap := make(map[string]struct{})
							for addr_index := range zone_details.Addresses {
								switch zone_details.Addresses[addr_index].(type) {
								case *contextbasedrestrictionsv1.AddressServiceRef:
									serviceRefExists = true
									serviceRef := zone_details.Addresses[addr_index].(*contextbasedrestrictionsv1.AddressServiceRef)
									serviceName := *serviceRef.Ref.ServiceName
									if _, ok := uniqueMap[serviceName]; !ok {
										// Adding multilocation support for COS causing same number of COS as items in list as serviceRef, to avoid duplicates, making the list as unique
										uniqueMap[serviceName] = struct{}{}
										actual_references = append(actual_references, serviceName)
									}
								}
							}
						}
					}
					assert.True(t, serviceRefExists, "Service Ref does not exist in the zone")
					assert.ElementsMatch(t, expected_references, actual_references, "service name referred is not as expected ")
				})
			}

			// Rule context verification
			rules := outputs["rule_ids"]
			if assert.Nil(t, err, "Failed to get rules") &&
				assert.NotNil(t, rules, "No rules found") {
				ruleIds := strings.Split(rules.([]interface{})[0].(string), ",")
				for index := range ruleIds {

					rule, _, err := cloudInfoSvc.GetCBRRuleByID(ruleIds[index])
					if assert.Nil(t, err, "Failed to get the rule") &&
						assert.NotNil(t, rule, "No rule found") {

						t.Run("verify all zone ids exist", func(t *testing.T) {
							zoneIds_output := outputs["zone_ids"]
							var expectedContexts []contextbasedrestrictionsv1.RuleContext
							zoneIds := strings.Join(strings.Fields(fmt.Sprint(zoneIds_output.([]interface{})[0])), ",")
							// Check the contexts loop through zones in output there should be 1 context per zone
							currentAttribute := []contextbasedrestrictionsv1.RuleContextAttribute{
								{
									Name:  core.StringPtr("endpointType"),
									Value: core.StringPtr("private"),
								},
								{
									Name:  core.StringPtr("networkZoneId"),
									Value: core.StringPtr(zoneIds[1 : len(zoneIds)-1]),
								},
							}
							expectedContexts = append(expectedContexts, contextbasedrestrictionsv1.RuleContext{
								Attributes: currentAttribute,
							})
							assert.ElementsMatch(t, expectedContexts, rule.Contexts, "expected contexts not found")
						})

					}
				}
			}
		}
	}
	options.TestTearDown()
}

func TestFSCloudInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			fsCloudExampleTerraformDir + "/*.tf",
			"modules/fscloud/*.tf",
			"modules/cbr-zone-module/*.tf",
			"modules/cbr-rule-module/*.tf",
		},
		TemplateFolder:         fsCloudExampleTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		Prefix:                 "fs",
		Region:                 "us-south",
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: options.Region, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpdateCBRZone(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: updateExistingCBRZone,
		Prefix:       "upd-zones",
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: zoneExampleTerraformDir,
		Prefix:       "cbr-upg",
	})

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestFullyConfigurableDAInSchematics(t *testing.T) {
	t.Parallel()

	// Sample data for cbr_zones
	cbrZones := map[string]interface{}{
		"zone1": map[string]interface{}{
			"name": "test-zone-1",
			"addresses": []map[string]interface{}{
				{
					"type":  "ipAddress",
					"value": "192.168.99.99",
				},
			},
		},
		"zone2": map[string]interface{}{
			"name": "test-zone-2",
			"addresses": []map[string]interface{}{
				{
					"type":  "ipAddress",
					"value": "192.168.98.98",
				},
			},
		},
	}

	cbrZonesJSON, err := json.Marshal(cbrZones)
	if err != nil {
		t.Fatalf("Failed to marshal cbr_zones: %v", err)
	}

	// Sample data for cbr_rules
	cbrRules := map[string]interface{}{
		"rule1": map[string]interface{}{
			"rule_description": "Only allow App Configuration access from zone1 with ipAddress 192.168.99.99 and zone2 with ipAddress 192.168.98.98",
			"enforcement_mode": "disabled",
			"resources": []map[string]interface{}{
				{
					"attributes": []map[string]interface{}{
						{
							"name":  "accountId",
							"value": permanentResources["ge_dev_account_id"],
						},
						{
							"name":  "serviceName",
							"value": "apprapp",
						},
					},
				},
			},
			"operations": []map[string]interface{}{
				{
					"api_types": []map[string]interface{}{
						{
							"api_type_id": "crn:v1:bluemix:public:context-based-restrictions::::api-type:",
						},
					},
				},
			},
			"zone_keys": []string{"zone1", "zone2"},
		},
		"rule2": map[string]interface{}{
			"rule_description": "Only allow Container Registry access from zone2 with ipAddress 192.168.98.98",
			"resources": []map[string]interface{}{
				{
					"attributes": []map[string]interface{}{
						{
							"name":  "accountId",
							"value": permanentResources["ge_dev_account_id"],
						},
						{
							"name":  "serviceName",
							"value": "container-registry",
						},
					},
				},
			},
			"operations": []map[string]interface{}{
				{
					"api_types": []map[string]interface{}{
						{
							"api_type_id": "crn:v1:bluemix:public:context-based-restrictions::::api-type:",
						},
					},
				},
			},
			"zone_keys": []string{"zone2"},
		},
	}

	cbrRulesJSON, err := json.Marshal(cbrRules)
	if err != nil {
		t.Fatalf("Failed to marshal cbr_rules: %v", err)
	}

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "cbr-da",
		TarIncludePatterns: []string{
			"*.tf",
			"modules/cbr-zone-module/*.tf",
			"modules/cbr-rule-module/*.tf",
			fullyConfigurableDADir + "/*.tf",
		},
		TemplateFolder:         fullyConfigurableDADir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "cbr_zones", Value: string(cbrZonesJSON), DataType: "map(object{})"},
		{Name: "cbr_rules", Value: string(cbrRulesJSON), DataType: "map(object{})"},
	}

	err = options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgradeFullyConfigurableDAInSchematics(t *testing.T) {
	t.Parallel()

	// Sample data for cbr_zones
	cbrZones := map[string]interface{}{
		"zone3": map[string]interface{}{
			"name": "test-zone-3",
			"addresses": []map[string]interface{}{
				{
					"type":  "ipAddress",
					"value": "192.168.99.99",
				},
			},
		},
		"zone4": map[string]interface{}{
			"name": "test-zone-4",
			"addresses": []map[string]interface{}{
				{
					"type":  "ipAddress",
					"value": "192.168.98.98",
				},
			},
		},
	}

	cbrZonesJSON, err := json.Marshal(cbrZones)
	if err != nil {
		t.Fatalf("Failed to marshal cbr_zones: %v", err)
	}

	// Sample data for cbr_rules
	cbrRules := map[string]interface{}{
		"rule1": map[string]interface{}{
			"rule_description": "Only allow Redis access from zone3 with ipAddress 192.168.99.99 and zone4 with ipAddress 192.168.98.98",
			"enforcement_mode": "disabled",
			"resources": []map[string]interface{}{
				{
					"attributes": []map[string]interface{}{
						{
							"name":  "accountId",
							"value": permanentResources["ge_dev_account_id"],
						},
						{
							"name":  "serviceName",
							"value": "databases-for-redis",
						},
					},
				},
			},
			"operations": []map[string]interface{}{
				{
					"api_types": []map[string]interface{}{
						{
							"api_type_id": "crn:v1:bluemix:public:context-based-restrictions::::api-type:data-plane",
						},
					},
				},
			},
			"zone_keys": []string{"zone3", "zone4"},
		},
		"rule2": map[string]interface{}{
			"rule_description": "Only allow Postgres access from zone3 with ipAddress 192.168.98.98",
			"resources": []map[string]interface{}{
				{
					"attributes": []map[string]interface{}{
						{
							"name":  "accountId",
							"value": permanentResources["ge_dev_account_id"],
						},
						{
							"name":  "serviceName",
							"value": "databases-for-postgresql",
						},
					},
				},
			},
			"operations": []map[string]interface{}{
				{
					"api_types": []map[string]interface{}{
						{
							"api_type_id": "crn:v1:bluemix:public:context-based-restrictions::::api-type:data-plane",
						},
					},
				},
			},
			"zone_keys": []string{"zone4"},
		},
	}

	cbrRulesJSON, err := json.Marshal(cbrRules)
	if err != nil {
		t.Fatalf("Failed to marshal cbr_rules: %v", err)
	}

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "cbr-da",
		TarIncludePatterns: []string{
			"*.tf",
			"modules/cbr-zone-module/*.tf",
			"modules/cbr-rule-module/*.tf",
			fullyConfigurableDADir + "/*.tf",
		},
		TemplateFolder:         fullyConfigurableDADir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "cbr_zones", Value: string(cbrZonesJSON), DataType: "map(object{})"},
		{Name: "cbr_rules", Value: string(cbrRulesJSON), DataType: "map(object{})"},
	}

	err = options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}
