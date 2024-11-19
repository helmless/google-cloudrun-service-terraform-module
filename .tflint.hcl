plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "google" {
    enabled = true
    version = "0.29.0"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
}


rule "google_cloud_run_v2_service_invalid_ingress" {
  enabled = false # not compatible with the Helmless deployment
}

rule "google_cloud_run_v2_service_invalid_launch_stage" {
  enabled = false # not compatible with the Helmless deployment
}
