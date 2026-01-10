terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.0"
    }
    
    http = {
      source = "hashicorp/http"
      version = "3.4.5"
    }    
  }
}

module "secrets_module" {
  source                  = "${path.module}/../modules/secrets"  
  master_password = var.master_password
  client_id       = var.client_id
  client_secret   = var.client_secret
  server          = var.server
  ssh_key_names   = var.ssh_key_names
  login_names     = var.login_names
}
