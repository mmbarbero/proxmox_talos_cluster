variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_endpoint" {
  type = string
}

variable "pve_node_name" {
  type = string
}

variable "controller_cpu_cores" {
  type = number
}

variable "controller_memory" {
  type = number
}

variable "datastore_id" {
  type = string
}

variable "talos_image_location" {
  type = string
}

variable "gateway_ip" {
  type = string
}

variable "dns_servers" {
  type = set(string)
}

variable "controller_ips" {
  type = set(string)
}

variable "worker_cpu_cores" {
  type = number
}

variable "worker_memory" {
  type = number
}

variable "cluster_name" {
  type = string
}

variable "worker_ips" {
  type = set(string)
}

variable "cluster_endpoint" {
  type = string
}

variable "talos_install_image_custom" {
  type = string
}

variable "github_user" {
  type = string
}

variable "github_token" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "create_gitops_repo" {
  type = bool
  default = false
}

variable "github_username" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "oidc_client_id" {
  type = string
}
