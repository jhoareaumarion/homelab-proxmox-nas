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


## Setting up Bitwarden sync
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