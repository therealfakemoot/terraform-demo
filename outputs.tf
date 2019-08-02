output "publicIP" {
  value = "${digitalocean_droplet.web.ipv4_address}"
}
