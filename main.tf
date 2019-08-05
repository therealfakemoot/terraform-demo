variable "do_token" {}
variable "ssh_root_pubkey_path" {}
variable "ssh_root_privkey_path" {}
variable "demo_domain" {}
variable "deployment_environment" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_project" "terraform-demo" {
  name        = "terraform-demo"
  description = "A workspace for demonstrating terraform projects."
  purpose     = "Web Application"
  resources   = ["${digitalocean_droplet.puppet_master.urn}", "${digitalocean_droplet.web.urn}"]
}

resource "digitalocean_ssh_key" "terraform_key" {
  name       = "terraform_default"
  public_key = "${file(var.ssh_root_pubkey_path)}"
}

resource "digitalocean_record" "demo" {
  domain = "${var.demo_domain}"
  type   = "A"
  name   = "demo"
  value  = digitalocean_droplet.web.ipv4_address
}

resource "digitalocean_record" "puppet" {
  domain = "${var.demo_domain}"
  type   = "A"
  name   = "puppet"
  value  = digitalocean_droplet.puppet_master.ipv4_address
}

resource "digitalocean_droplet" "puppet_master" {
  image  = "ubuntu-16-04-x64"
  name   = "puppet-master"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  # monitoring = true
  ssh_keys = [digitalocean_ssh_key.terraform_key.id]

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      host        = "${digitalocean_droplet.web.ipv4_address}"
      private_key = "${file(var.ssh_root_privkey_path)}"
    }
  }
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-16-04-x64"
  name   = "web"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  # monitoring = true
  ssh_keys = [digitalocean_ssh_key.terraform_key.id]

  provisioner "puppet" {
    server      = "puppet.${var.demo_domain}"
    server_user = "root"
    open_source = false
    environment = "${var.deployment_environment}"
    extension_requests = {
      pp_role = "web"
    }

    connection {
      type        = "ssh"
      host        = "${digitalocean_droplet.web.ipv4_address}"
      private_key = "${file(var.ssh_root_privkey_path)}"
    }

  }
}

