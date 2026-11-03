terraform {
  # OpenTofu ≥ 1.8 (mock_provider dans les essais) ; Terraform ≥ 1.7 lit aussi ce module.
  required_version = ">= 1.7.0"

  required_providers {
    recodanse = {
      source  = "arcodange-org/recodanse"
      version = ">= 0.2.0, < 1.0.0"
    }
  }
}
