resource "hcloud_network" "private_network" {
  name     = "private_network"
  ip_range = var.network_ip_range
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private_network.id
  type         = "cloud"
  ip_range     = var.subnet_ip_range
  network_zone = "eu-central"
}
