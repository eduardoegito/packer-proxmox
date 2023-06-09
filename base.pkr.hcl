variable "proxmox_hostname" {
  type = string
}

variable "proxmox_api_key" {
  type      = string
  sensitive = true
}

variable "proxmox_source_template" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "proxmox_username" {
  type    = string
  default = "root@pam"
}

source "proxmox-clone" "ubuntu-server-pve01" {
  insecure_skip_tls_verify = true
  full_clone               = true

  template_name = "${var.vm_name}"
  clone_vm      = "${var.proxmox_source_template}"
  vm_id         = "1101" 

  os              = "other"
  cores           = "1"
  memory          = "2048"
  scsi_controller = "virtio-scsi-pci"

  ssh_username = "ubuntu"

  qemu_agent = true

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  cloud_init              = false
  cloud_init_storage_pool = "local-lvm"
  http_directory       = "http"
  node        = "pve01"
  username    = "${var.proxmox_username}"
  token       = "${var.proxmox_api_key}"
  proxmox_url = "${var.proxmox_hostname}"
}

source "proxmox-clone" "ubuntu-server-pve02" {
  insecure_skip_tls_verify = true
  full_clone               = true

  template_name = "${var.vm_name}"
  clone_vm      = "${var.proxmox_source_template}"
  vm_id         = "1102"

  os              = "other"
  cores           = "1"
  memory          = "2048"
  scsi_controller = "virtio-scsi-pci"

  ssh_username = "ubuntu"

  qemu_agent = true

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  cloud_init              = false
  cloud_init_storage_pool = "local-lvm"
  http_directory       = "http"
  node        = "pve02"
  username    = "${var.proxmox_username}"
  token       = "${var.proxmox_api_key}"
  proxmox_url = "${var.proxmox_hostname}"
}

source "proxmox-clone" "ubuntu-server-pve03" {
  insecure_skip_tls_verify = true
  full_clone               = true

  template_name = "${var.vm_name}"
  clone_vm      = "${var.proxmox_source_template}"
  vm_id         = "1103"

  os              = "other"
  cores           = "1"
  memory          = "2048"
  scsi_controller = "virtio-scsi-pci"

  ssh_username = "ubuntu"

  qemu_agent = true

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  cloud_init              = false
  cloud_init_storage_pool = "local-lvm"
  http_directory       = "http"
  node        = "pve03"
  username    = "${var.proxmox_username}"
  token       = "${var.proxmox_api_key}"
  proxmox_url = "${var.proxmox_hostname}"
}

build {

  name    = "Docker-Servers"
  sources = ["source.proxmox-clone.ubuntu-server-pve01",
             "source.proxmox-clone.ubuntu-server-pve02",
             "source.proxmox-clone.ubuntu-server-pve03"
  ]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

  # Provisioning the VM Template with Docker Installation #4
  provisioner "shell" {
    inline = [
      "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get -y update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
    ]
  }
}
