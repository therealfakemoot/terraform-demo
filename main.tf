variable "do_token" {}
variable "ssh_root_pubkey_path" {}
variable "ssh_root_privkey_path" {}
variable "demo_domain" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "terraform_key" {
  name       = "terraform_default"
  public_key = "${file(var.ssh_root_pubkey_path)}"
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-16-04-x64"
  name   = "terraform-1"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  # monitoring = true
  ssh_keys = [digitalocean_ssh_key.terraform_key.id]

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get -y install nginx",
      "mkdir -p /var/www/demo.noodlemilkhotel.com/",
    ]

    connection {
      type        = "ssh"
      private_key = "${file(var.ssh_root_privkey_path)}"
      host        = "${digitalocean_droplet.web.ipv4_address}"
    }

  }

  provisioner "file" {
    source      = "www/index.html"
    destination = "/var/www/demo.noodlemilkhotel.com/index.html"

    connection {
      type        = "ssh"
      private_key = "${file(var.ssh_root_privkey_path)}"
      host        = "${digitalocean_droplet.web.ipv4_address}"
    }
  }

  provisioner "file" {
    source      = "www/demo.noodlemilkhotel.com"
    destination = "/etc/nginx/sites-enabled/demo.noodlemilkhotel.com"

    connection {
      type        = "ssh"
      private_key = "${file(var.ssh_root_privkey_path)}"
      host        = "${digitalocean_droplet.web.ipv4_address}"
    }
  }


}

resource "digitalocean_record" "demo" {
  domain = "${var.demo_domain}"
  type   = "A"
  name   = "demo"
  value  = digitalocean_droplet.web.ipv4_address
}
