terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.90.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.10.0"
    }

    flux  = {
      source = "fluxcd/flux"
      version = ">= 1.7.6"
    }

    github = {
      source  = "integrations/github"
      version = ">= 6.11.0"
    }

  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = "false"
}

provider "github" {
  owner = var.github_user
  token = var.github_token
}

provider "flux" {
  kubernetes = {
    host = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    client_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key         = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  }
  git = {
    url = "https://github.com/${var.github_user}/${var.repository_name}.git"
    http = {
      username = "git"
      password = var.github_token
    }
  }

}
