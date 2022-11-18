# TODO: provide a way to create this if it doesn't exist and make it sensitive
data "hcloud_ssh_key" "default_ssh_key" {
  name = var.ssh_key_name
}

data "cloudflare_zone" "noobis_zone" {
  name = var.cloudflare_zone_name
}
