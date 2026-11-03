terraform {
  # OpenTofu ≥ 1.8 (mock_provider dans les essais) ; Terraform ≥ 1.7 lit aussi ce module.
  required_version = ">= 1.7.0"

  required_providers {
    recodanse = {
      source  = "arcodange-org/recodanse"
      version = ">= 0.2.0, < 1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
    # N'est configuré que si `coffre` est donné : sans lui, aucune ressource Vault
    # n'existe et le fournisseur n'est jamais appelé (mesuré : plan sans VAULT_ADDR).
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.0.0"
    }
  }
}
