package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformDevValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../terraform/environments/dev",
		
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			// Mock variables if needed
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// Run `terraform init` and `terraform validate`
	// We don't run Apply here to avoid spinning up resources during basic testing
	// To run full integration tests, we would use InitAndApply
	initString := terraform.Init(t, terraformOptions)
	validateString := terraform.Validate(t, terraformOptions)

	assert.Contains(t, initString, "Terraform has been successfully initialized")
	assert.Contains(t, validateString, "Success! The configuration is valid")
}

func TestTerraformStagingValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform/environments/staging",
		NoColor: true,
	}

	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
}

func TestTerraformProdValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform/environments/prod",
		NoColor: true,
	}

	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
}
