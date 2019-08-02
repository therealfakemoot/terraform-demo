variable "do_token" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "terraform_key" {
  name       = "terraform_default"
  public_key = "${file("/Users/dumasn/.ssh/terraform.pub")}"
}

resource "digitalocean_domain" "nmh" {
  name = "noodlemilkhotel.com"
}

resource "digitalocean_record" "demo" {
  domain = "${digitalocean_domain.nmh.name}"
  type   = "CNAME"
  name   = "demo"
  value  = digitalocean_droplet.web.ipv4_address
}

resource "digitalocean_droplet" "web" {
  image      = "ubuntu-16-04-x64"
  name       = "terraform-1"
  region     = "nyc3"
  size       = "s-1vcpu-1gb"
  monitoring = true
  ssh_keys   = [digitalocean_ssh_key.terraform_key.id]
}
