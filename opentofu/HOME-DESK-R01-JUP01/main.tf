terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.92.0"
    }
    
    http = {
      source = "hashicorp/http"
      version = "3.5.0"
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

locals{
  api_key = [
    for f in module.secrets_module.logins["netbox"].field : f
    if f.name == "api-key"
  ][0].hidden # Get the first match
  netbox_url = module.secrets_module.logins["netbox"].uri[0].value
  vm_name = "HOME-DESK-R01-JUP01-50-TNAS-01"
  vm = jsondecode(data.http.get_vm.response_body).results[0]
  host = jsondecode(data.http.get_host.response_body).results[0]
  module_bay = jsondecode(data.http.get_module_bay.response_body).results[0]
  cluster = jsondecode(data.http.get_cluster.response_body).results[0]
  interface = jsondecode(data.http.get_interface.response_body).results[0]
}

data "http" "get_vm" {
  url = "${local.netbox_url}/api/virtualization/virtual-machines/?name=${local.vm_name}"

  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.api_key}"
  }
}

data "http" "get_host" {
  url = "${local.netbox_url}/api/dcim/devices/?name=${local.vm.device.name}"

  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.api_key}"
  }
}

data "http" "get_cluster" {
  url = "${local.netbox_url}/api/virtualization/clusters/?name=${local.vm.cluster.name}"

  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.api_key}"
  }
}

data "http" "get_module_bay" {
  url = "${local.netbox_url}/api/dcim/module-bays/?device=${local.vm.device.name}"

  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.api_key}"
  }
}
data "http" "get_interface" {
  url = "${local.netbox_url}/api/virtualization/interfaces/?virtual_machine=${local.vm_name}"

  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.api_key}"
  }
}

resource "proxmox_virtual_environment_vm" "home-desk-r01-jup01-50-tnas01" {
  name = "${lower(local.vm_name)}"
  description = "Managed by OpenTofu"  
  tags = [local.vm.role.slug]

  node_name = local.cluster.custom_fields.proxmox_hostname
  vm_id = local.vm.custom_fields.proxmox_id

  cpu {
    cores      = local.vm.vcpus
    sockets    = 1
    type       = "x86-64-v2-AES"
  }
  
  memory     {
    dedicated = local.vm.memory
  }

  efi_disk {
    type = "4m"
    datastore_id = "local-lvm"
  }

  disk {
    datastore_id  = "local-lvm"
    interface = "scsi0"
    iothread = true
    backup = true
    discard = "on"
    size     = 64
  }
  keyboard_layout = "fr"
      
  network_device {
    model  = "virtio"
    bridge = split(":", local.interface.custom_fields.interface_bridge.name)[1]
    mac_address = local.interface.mac_address
    vlan_id = 50
  }  
  cdrom {
    file_id ="images:iso/TrueNAS_25.10.1.iso"
  }

  operating_system {
    type = "l26"
  }
  on_boot = local.vm.custom_fields.vm_on_boot
  scsi_hardware     = "virtio-scsi-single"

  started = false
  agent {
    enabled = true
    type    = "virtio" 
  }
  boot_order = ["virtio0"]

  stop_on_destroy = true

  lifecycle {
    ignore_changes = [ 
      started,
      cdrom
    ]
  }
}

resource "null_resource" "attach_physical_disk_to_homelab_nas_playbook" {
  count = local.vm.status.value == "staged" ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOF
    ansible-playbook ../../ansible/attach-physical-disk-to-home-desk-r01-jup01-tnas-01.yml \
    EOF
    environment = {
      ANSIBLE_FORCE_COLOR = "true"
      ANSIBLE_TIMEOUT     = "120"
      ANSIBLE_CONFIG      = "../../ansible/ansible.cfg"
      BW_SESSION          = "redacted"
    }
  }
  depends_on = [proxmox_virtual_environment_vm.home-desk-r01-jup01-50-tnas01]
}