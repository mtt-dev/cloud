package test

import (
	"crypto/tls"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/packer"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
	"time"
)

func TestServerHello(t *testing.T) {
	packerOptions := &packer.Options{
		Template: "./serverhello.json",
		Only:     "amazon-ebs",
	}

	amiId := packer.BuildArtifact(t, packerOptions)

	defer aws.DeleteAmiAndAllSnapshots(t, "eu-central-1", amiId)

	terraformOptions := &terraform.Options{
		TerraformDir: "./",
		Vars: map[string]interface{}{
			"ami_id": amiId,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	ipv4 := terraform.Output(t, terraformOptions, "public_ipv4")
	dns := terraform.Output(t, terraformOptions, "public_dns")

	server := fmt.Sprintf("http://%s", ipv4)
	status := 200
	body := fmt.Sprintf("Hello from %s (%s)", dns, ipv4)
	retries := 5
	sleep := 10 * time.Second
	http_helper.HttpGetWithRetry(t, server, &tls.Config{}, status, body, retries, sleep)
}
