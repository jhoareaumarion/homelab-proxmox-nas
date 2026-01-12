# homelab-proxmox-nas
A small repository to bootstrap my PVE install on NAS UGREEN DXP4800

## Setting up devcontainer using template

### Requirements
- **Docker**: Ensure Docker is installed and running on your machine.
- **Dev Container CLI**: Install the [Dev Container CLI](https://github.com/devcontainers/cli). *(I developed and tested this in a **WSL** environment.)*
- **VS Code**: Install [Visual Studio Code](https://code.visualstudio.com/) and the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension. *(While [other supporting tools](https://containers.dev/supporting) may work, I’ve only tested this setup with VS Code.)*


Run this command at this repository's root:
```bash
devcontainer templates apply \
--workspace-folder . \
--template-id ghcr.io/jhoareaumarion/devcontainers/ansible-bitwarden-kubernetes-tofu:latest \
--template-args '{ "additionalAnsibleCollections":"netbox.netbox", "additionalPythonPackages":"passlib,requests,pytest,pytz" }'
```


## Setting up Bitwarden sync (only if running Ansible ONLY)
Secrets depends on a Bitwarden account located on a specific Bitwarden server. Please do
```bash
bw config server <SERVER>
```
then
```bash
bw login
```
and
```bash
export BW_SESSION="<TOKEN_PROVIDED>"
```

## Installation workflow
### PVE Installation and first configuration on NAS hardware
- Use a bootable USB key to install PVE manually on the device
- From `ansible` directory run `ansible-playbook ./initialize-pve-node.yml`

### (WIP) TrueNAS scale installation
- Set the postgreSQL backend credential to PG_CONN_STR environment variable `export PG_CONN_STR="<<CONNECTION STRING>>"`
- Unlock bw and put the BW_SESSION value in the BW_SESSION env var of the resource `null_resource.attach_physical_disk_to_homelab_nas_playbook[0]`
- From the device folder (e.g. `opentofu/HOME-DESK-R01-JUP01`), run the command `tofu apply -var-file="../common/bitwarden_provider.tfvars"`
- Log into PVE Web UI and finalize TrueNAS installation
- From `ansible` directory run `ansible-playbook ./attach-physical-disk-to-home-desk-r01-jup01-tnas-01.yml`
- Pass SSH keys
- From `ansible` directory run `ansible-playbook ./initialize-home-desk-r01-jup01-tnas-01.yml`