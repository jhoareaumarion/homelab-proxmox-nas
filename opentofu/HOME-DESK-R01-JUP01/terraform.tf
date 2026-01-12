terraform {
  backend "pg" {
    schema_name       =   "homelab-proxmox-nas"
  }
}