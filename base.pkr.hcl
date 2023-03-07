variable "proxmox_hostname" {
  type    = string
}

variable "proxmox_api_key" {
  type      = string
  sensitive = true
}

variable "proxmox_source_template" {
  type = string
}

variable "vm_name" {
  type    = string
}

variable "proxmox_url" {
  type    = string
}

variable "proxmox_node" {
  type    = string
}

variable "proxmox_username" {
  type    = string
  default = "root@pam"
}

source "proxmox-clone" "test-cloud-init" {
  insecure_skip_tls_verify = true
  full_clone = false

  template_name = "${var.vm_name}"
  clone_vm      = "${var.proxmox_source_template}"
  
  os              = "l26"
  cores           = "1"
  memory          = "512"
  scsi_controller = "virtio-scsi-pci"

  ssh_username = "ubuntu"

  qemu_agent = true

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  node          = "${var.proxmox_node}"
  username      = "${var.proxmox_username}"
  token         = "${var.proxmox_api_key}"
  proxmox_url   = "${var.proxmox_hostname}"
}

build {
  sources = ["source.proxmox-clone.test-cloud-init"]

  provisioner "shell" {
    inline         = [
            "sudo cloud-init clean",
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
    ]
  }
}
