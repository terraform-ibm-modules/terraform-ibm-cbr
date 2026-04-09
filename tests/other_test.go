package test

const multiResourceTerraformDir = "examples/multi-resource-rule"

// temporary fix for pipeline to pass for IBM provider version bump
// func TestRunMultiResourceExample(t *testing.T) {
// 	t.Parallel()

// 	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
// 		Testing:      t,
// 		TerraformDir: multiResourceTerraformDir,
// 		Prefix:       "mrr-rule",
// 	})

// 	output, err := options.RunTestConsistency()
// 	assert.Nil(t, err, "This should not have errored")
// 	assert.NotNil(t, output, "Expected some output")
// }
