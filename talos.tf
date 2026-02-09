resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "workers" {
  for_each = var.worker_ips

  cluster_name = var.cluster_name 
  cluster_endpoint = var.cluster_endpoint
  machine_type = "worker"
  machine_secrets = talos_machine_secrets.this.machine_secrets
  config_patches = [
  yamlencode({
      machine = {
        network = {
          interfaces = [{
            interface = "ens18"
            addresses = ["${each.value}/24"]
            routes = [{
              network = "0.0.0.0/0"
              gateway = var.gateway_ip
            }]
          }]
          nameservers = var.dns_servers
        }
        install = {
          image = var.talos_install_image_custom
        }

      }
    })
]
}
data "talos_machine_configuration" "controllers" {
  for_each = var.controller_ips
  cluster_name = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type = "controlplane"
  machine_secrets = talos_machine_secrets.this.machine_secrets
  config_patches = [
    yamlencode({
        machine = {
          network = {
            interfaces = [{
              interface = "ens18"
              addresses = ["${each.value}/24"]
              routes = [{
                network = "0.0.0.0/0"
                gateway = var.gateway_ip
              }]
            }]
            nameservers = var.dns_servers
          }
          install = {
            image = var.talos_install_image_custom
          }
        }
        cluster = {
            apiServer = {
                extraArgs = {
                  "oidc-issuer-url"     = var.oidc_issuer_url
                  "oidc-client-id"      = var.oidc_client_id
                  "oidc-username-claim" = "email" 
                  "oidc-groups-claim"   = "groups"
                }
            }
        }
    })
  ]
}


data "talos_client_configuration" "this" {
  cluster_name = var.cluster_name
  nodes = [tolist(var.controller_ips)[0]]
  client_configuration = talos_machine_secrets.this.client_configuration
}


resource "talos_machine_configuration_apply" "controllers" {
  for_each = var.controller_ips

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controllers[each.key].machine_configuration
  node                        = each.value
  
  depends_on = [proxmox_virtual_environment_vm.talos-controllers]
}

resource "talos_machine_configuration_apply" "workers" {
  for_each = var.worker_ips

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers[each.key].machine_configuration
  node                        = each.value
  
  depends_on = [proxmox_virtual_environment_vm.talos-workers]
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = tolist(var.controller_ips)[0]
  depends_on = [talos_machine_configuration_apply.controllers,talos_machine_configuration_apply.workers]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = tolist(var.controller_ips)[0]
  depends_on = [talos_machine_bootstrap.this]
}

resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "${path.module}/talosconfig"
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
}
