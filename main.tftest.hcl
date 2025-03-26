mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      project_id = "test-project"
    }
  }
  mock_data "google_service_account" {
    defaults = {
      account_id = "existing"
      name       = "existing@test-project.iam.gserviceaccount.com"
      email      = "existing@test-project.iam.gserviceaccount.com"
      id         = "projects/test-project/serviceAccounts/existing@test-project.iam.gserviceaccount.com"
    }
  }
  mock_resource "google_service_account" {
    defaults = {
      account_id   = "test-service"
      name         = "test-service@test-project.iam.gserviceaccount.com"
      id           = "projects/test-project/serviceAccounts/test-service@test-project.iam.gserviceaccount.com"
      email        = "test-service@test-project.iam.gserviceaccount.com"
      display_name = "test-service"
    }
  }
  mock_resource "google_service_account_iam_member" {
    defaults = {
      id = "test-id"
    }
  }
  mock_resource "google_cloud_run_v2_service_iam_member" {
    defaults = {
      id = "test-id"
    }
  }
  mock_resource "google_cloud_run_v2_service_iam_binding" {
    defaults = {
      id = "test-id"
    }
  }
  mock_resource "google_cloud_run_v2_service" {
    defaults = {
      id = "test-id"
    }
  }
}

variables {
  project = "test-project"
}

# Test case 1: Basic configuration with service account creation
run "create_service_account" {
  command = apply

  variables {
    name                   = "test-service"
    create_service_account = true
    project                = "test-project"
    deployment_accounts    = ["serviceAccount:deployer@test-project.iam.gserviceaccount.com"]
    iam = [
      {
        role    = "roles/run.invoker"
        members = ["serviceAccount:invoker@test-project.iam.gserviceaccount.com"]
      }
    ]
  }

  assert {
    condition     = google_service_account.cloud_run_service_account[0].account_id == "test-service"
    error_message = "Service account should be created with the same name as the Cloud Run service"
  }

  assert {
    condition     = length(google_service_account_iam_member.service_account_user) == 2
    error_message = "Expected 2 service account user IAM bindings (1 for deployment account, 1 for service account itself)"
  }

  assert {
    condition     = google_service_account_iam_member.service_account_user[0].member == "serviceAccount:${google_service_account.cloud_run_service_account[0].email}"
    error_message = "First member should be the service account itself"
  }

  assert {
    condition     = google_service_account_iam_member.service_account_user[1].member == "serviceAccount:deployer@test-project.iam.gserviceaccount.com"
    error_message = "Second member should be the deployer service account"
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_member.run_admin) == 2
    error_message = "Expected 2 run.admin IAM bindings (1 for deployment account, 1 for service account itself)"
  }

  assert {
    condition     = google_cloud_run_v2_service_iam_member.run_admin[0].member == "serviceAccount:${google_service_account.cloud_run_service_account[0].email}"
    error_message = "First run.admin member should be the service account itself"
  }

  assert {
    condition     = google_cloud_run_v2_service_iam_member.run_admin[1].member == "serviceAccount:deployer@test-project.iam.gserviceaccount.com"
    error_message = "Second run.admin member should be the deployer service account"
  }

  assert {
    condition     = google_cloud_run_v2_service.cloud_run_service.template[0].service_account == google_service_account.cloud_run_service_account[0].email
    error_message = "Cloud Run service should use the created service account"
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_binding.custom_iam) == 1
    error_message = "Expected 1 custom IAM binding"
  }

  assert {
    condition     = contains(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.invoker"].members, "serviceAccount:invoker@test-project.iam.gserviceaccount.com")
    error_message = "IAM binding should contain the specified invoker member"
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.invoker"].members) == 1
    error_message = "IAM binding should have exactly 1 member"
  }
}

# Test case 2: Using existing service account
run "use_existing_service_account" {
  command = plan

  variables {
    name                   = "test-service-2"
    create_service_account = false
    service_account_email  = "existing@test-project.iam.gserviceaccount.com"
    project                = "test-project"
  }

  assert {
    condition     = length(google_service_account.cloud_run_service_account) == 0
    error_message = "No service account should be created when using existing one"
  }

  assert {
    condition     = data.google_service_account.cloud_run_service_account[0].email == "existing@test-project.iam.gserviceaccount.com"
    error_message = "Should use the provided service account email"
  }

  assert {
    condition     = google_service_account_iam_member.service_account_user[0].member == "serviceAccount:existing@test-project.iam.gserviceaccount.com"
    error_message = "First member should be the service account itself"
  }
}

# Test case 3: Complex IAM bindings with multiple roles and members
run "complex_iam_bindings" {
  command = plan

  variables {
    name                   = "test-service-3"
    create_service_account = true
    project                = "test-project"
    deployment_accounts    = ["serviceAccount:deployer@test-project.iam.gserviceaccount.com"]
    iam = [
      {
        role = "roles/run.invoker"
        members = [
          "serviceAccount:invoker1@test-project.iam.gserviceaccount.com",
          "serviceAccount:invoker2@test-project.iam.gserviceaccount.com"
        ]
      },
      {
        role    = "roles/run.viewer"
        members = ["serviceAccount:viewer@test-project.iam.gserviceaccount.com"]
      }
    ]
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_binding.custom_iam) == 2
    error_message = "Expected 2 IAM bindings to be created"
  }

  assert {
    condition     = contains(keys(google_cloud_run_v2_service_iam_binding.custom_iam), "roles/run.invoker")
    error_message = "Expected roles/run.invoker IAM binding to be created"
  }

  assert {
    condition     = contains(keys(google_cloud_run_v2_service_iam_binding.custom_iam), "roles/run.viewer")
    error_message = "Expected roles/run.viewer IAM binding to be created"
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.invoker"].members) == 2
    error_message = "Expected 2 members for roles/run.invoker binding"
  }

  assert {
    condition     = contains(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.invoker"].members, "serviceAccount:invoker1@test-project.iam.gserviceaccount.com")
    error_message = "roles/run.invoker binding should contain the invoker1 service account"
  }

  assert {
    condition     = contains(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.invoker"].members, "serviceAccount:invoker2@test-project.iam.gserviceaccount.com")
    error_message = "roles/run.invoker binding should contain the invoker2 service account"
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.viewer"].members) == 1
    error_message = "Expected 1 member for roles/run.viewer binding"
  }

  assert {
    condition     = contains(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.viewer"].members, "serviceAccount:viewer@test-project.iam.gserviceaccount.com")
    error_message = "roles/run.viewer binding should contain the viewer service account"
  }
}

# Test case 4: Default values and project inference
run "default_values" {
  command = plan

  variables {
    name = "test-service-4"
  }

  assert {
    condition     = var.region == "us-central1"
    error_message = "Default region should be us-central1"
  }

  assert {
    condition     = var.create_service_account == true
    error_message = "create_service_account should default to true"
  }

  assert {
    condition     = length(var.deployment_accounts) == 0
    error_message = "deployment_accounts should default to empty list"
  }

  assert {
    condition     = var.deletion_protection == true
    error_message = "deletion_protection should default to true"
  }

  assert {
    condition     = local.project == "test-project"
    error_message = "Project should be inferred from data source when not provided"
  }

  assert {
    condition     = length(google_service_account_iam_member.service_account_user) == 1
    error_message = "Expected 1 service account user IAM binding for the service account itself"
  }

  assert {
    condition     = google_service_account_iam_member.service_account_user[0].member == "serviceAccount:${google_service_account.cloud_run_service_account[0].email}"
    error_message = "The only member should be the service account itself"
  }
}

# Test case 5: Input validation for deployment accounts
run "deployment_accounts_validation" {
  command = plan

  variables {
    name = "test-service-5"
    deployment_accounts = [
      "serviceAccount:valid@test-project.iam.gserviceaccount.com",
      "principalSet:principal-set-id"
    ]
  }

  assert {
    condition     = length(google_service_account_iam_member.service_account_user) == 3
    error_message = "Should create IAM bindings for both deployment accounts plus service account itself"
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_member.run_admin) == 3
    error_message = "Should create run.admin bindings for both deployment accounts plus service account itself"
  }

  assert {
    condition     = google_service_account_iam_member.service_account_user[0].member == "serviceAccount:${google_service_account.cloud_run_service_account[0].email}"
    error_message = "First member should be the service account itself"
  }

  assert {
    condition     = google_service_account_iam_member.service_account_user[1].member == "serviceAccount:valid@test-project.iam.gserviceaccount.com"
    error_message = "Second member should be the valid service account"
  }

  assert {
    condition     = google_service_account_iam_member.service_account_user[2].member == "principalSet:principal-set-id"
    error_message = "Third member should be the principal set"
  }
}

# Test case 6: Invalid deployment account format
run "invalid_deployment_account_format" {
  command = plan
  expect_failures = [
    var.deployment_accounts,
  ]

  variables {
    name = "test-service-6"
    deployment_accounts = [
      "invalid:format@test-project.iam.gserviceaccount.com"
    ]
  }
}

# Test case 7: Service account validation
run "service_account_validation_missing_email" {
  command = plan
  expect_failures = [
    var.service_account_email,
  ]

  variables {
    name                   = "test-service-7"
    create_service_account = false
    # Intentionally omitting service_account_email to trigger validation error
  }
}

# Test case 9: Deletion protection
run "deletion_protection" {
  command = plan

  variables {
    name                = "test-service-9"
    deletion_protection = false
  }

  assert {
    condition     = google_cloud_run_v2_service.cloud_run_service.deletion_protection == false
    error_message = "Deletion protection should be disabled when set to false"
  }
}

# Test case 10: Empty IAM bindings
run "empty_iam_bindings" {
  command = plan

  variables {
    name = "test-service-10"
    iam  = []
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_binding.custom_iam) == 0
    error_message = "Expected no custom IAM bindings"
  }
}

# Test case 11: Service account reference consistency
run "service_account_reference" {
  command = plan

  variables {
    name                   = "test-service-11"
    create_service_account = true
  }

  assert {
    condition     = local.service_account.email == google_service_account.cloud_run_service_account[0].email
    error_message = "Service account reference in locals should match the created service account"
  }

  assert {
    condition     = contains(local.deployment_accounts, "serviceAccount:${google_service_account.cloud_run_service_account[0].email}")
    error_message = "Service account should be added to deployment accounts"
  }
}

# Test case 12: Use with specific region
run "specific_region" {
  command = plan

  variables {
    name   = "test-service-12"
    region = "us-west1"
  }

  assert {
    condition     = google_cloud_run_v2_service.cloud_run_service.location == "us-west1"
    error_message = "Cloud Run service should be created in specified region"
  }

  assert {
    condition     = google_cloud_run_v2_service_iam_member.run_admin[0].location == "us-west1"
    error_message = "IAM bindings should use the specified region"
  }
}

# Test case 13: Multiple IAM roles with same members
run "multiple_iam_roles_same_members" {
  command = plan

  variables {
    name = "test-service-13"
    iam = [
      {
        role    = "roles/run.invoker"
        members = ["serviceAccount:same@test-project.iam.gserviceaccount.com"]
      },
      {
        role    = "roles/run.viewer"
        members = ["serviceAccount:same@test-project.iam.gserviceaccount.com"]
      }
    ]
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_binding.custom_iam) == 2
    error_message = "Expected 2 IAM bindings to be created"
  }

  assert {
    condition     = contains(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.invoker"].members, "serviceAccount:same@test-project.iam.gserviceaccount.com")
    error_message = "roles/run.invoker binding should contain the same service account"
  }

  assert {
    condition     = contains(google_cloud_run_v2_service_iam_binding.custom_iam["roles/run.viewer"].members, "serviceAccount:same@test-project.iam.gserviceaccount.com")
    error_message = "roles/run.viewer binding should contain the same service account"
  }
}

# Test case 14: Verify IAM map structure
run "verify_iam_map_structure" {
  command = plan

  variables {
    name = "test-service-14"
    iam = [
      {
        role    = "roles/run.invoker"
        members = ["user:test-user@example.com"]
      }
    ]
  }

  assert {
    condition     = local.iam_map["roles/run.invoker"].members[0] == "user:test-user@example.com"
    error_message = "IAM map should properly transform the role and members from the input variables"
  }
} 