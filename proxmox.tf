resource "proxmox_virtual_environment_vm" "talos-controllers" {
  for_each = var.controller_ips 
  
  name  = "talos-controller-${split(".", each.key)[3]}"
  vm_id = 1000 + tonumber(split(".", each.key)[3])
  node_name = var.pve_node_name
  
  agent {
    enabled = true
  }

  cpu {
    cores = var.controller_cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.controller_memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 20
  }

  cdrom {
    file_id   = var.talos_image_location
  }
  network_device {
    bridge = "vmbr0"
  }
  
  initialization {
    datastore_id = var.datastore_id
    dns {
      servers = var.dns_servers
    }
    ip_config {
      ipv4 {
        address = "${each.value}/24"
        gateway = var.gateway_ip
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "talos-workers"{

  for_each = var.worker_ips 
  
  name  = "talos-worker-${split(".", each.key)[3]}"
  vm_id = 1000 + tonumber(split(".", each.key)[3])
  node_name = var.pve_node_name
  agent {
    enabled = true
  }

  cpu {
    cores = var.worker_cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.worker_memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 20
  }

  cdrom {
    file_id   = var.talos_image_location 
  }
  network_device {
    bridge = "vmbr0"
  }
  
  initialization {
    datastore_id = var.datastore_id
    dns {
      servers = var.dns_servers
    }
    ip_config {
      ipv4 {
        address = "${each.value}/24"
        gateway = var.gateway_ip
      }
    }
  }

}
