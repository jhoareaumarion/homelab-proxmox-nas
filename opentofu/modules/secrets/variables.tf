variable "master_password" {
  description = "The master password of the Bitwarden account"
  type        = string
  sensitive   = true
}

variable "server" {
  description = "The server of the Bitwarden account"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "The client secret of the Bitwarden account"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "The client ID of the Bitwarden account"
  type        = string
  sensitive   = true
}

variable "ssh_key_names" {
  description = "The SSH keys to retrieve"
  type        = map(string)
}
variable "login_names" {
  description = "The Login entries to retrieve"
  type        = map(string)
}