resource "hcloud_server" "bastion" {
  name        = "bastion"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "nbg1"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  user_data = base64encode(templatefile("${path.module}/scripts/bastion_setup.sh", {
    BASTION_USER = var.bastion_username
  }))

  firewall_ids = [hcloud_firewall.bastion_firewall.id]
  ssh_keys = [
    # data.hcloud_ssh_key.default_ssh_key.id, # Admin SSH key
    data.hcloud_ssh_key.default_ssh_key.id # User SSH key
  ]
}

# using this instead of the network block in hcloud_server
# because it's annoying to iterate over that and get private IP from it
resource "hcloud_server_network" "bastion_network" {
  server_id = hcloud_server.bastion.id
  subnet_id = hcloud_network_subnet.private_subnet.id
}

resource "hcloud_server" "loadbalancer" {
  name        = "loadbalancer-${count.index}"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "nbg1"

  count = var.loadbalancer_count

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  firewall_ids = [hcloud_firewall.loadbalancer_firewall.id]
  ssh_keys     = [data.hcloud_ssh_key.default_ssh_key.id]
}

resource "hcloud_server_network" "loadbalancer_network" {
  count     = length(hcloud_server.loadbalancer)
  server_id = hcloud_server.loadbalancer[count.index].id
  subnet_id = hcloud_network_subnet.private_subnet.id
}

resource "hcloud_server" "server_node" {
  name        = "server-node-${count.index}"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "nbg1"

  count = var.server_node_count

  public_net {
    # need a public net to access the internet
    ipv4_enabled = true
    ipv6_enabled = false
  }

  firewall_ids = [hcloud_firewall.server_firewall.id]
  ssh_keys     = [data.hcloud_ssh_key.default_ssh_key.id]
}

resource "hcloud_server_network" "server_node_network" {
  count     = length(hcloud_server.server_node)
  server_id = hcloud_server.server_node[count.index].id
  subnet_id = hcloud_network_subnet.private_subnet.id
}

resource "hcloud_server" "client_node" {
  name        = "client-node-${count.index}"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "nbg1"

  count = var.client_node_count

  public_net {
    # need a public net to access the internet
    ipv4_enabled = true
    ipv6_enabled = false
  }

  firewall_ids = [hcloud_firewall.client_firewall.id]
  ssh_keys     = [data.hcloud_ssh_key.default_ssh_key.id]
}

resource "hcloud_server_network" "client_node_network" {
  count     = length(hcloud_server.client_node)
  server_id = hcloud_server.client_node[count.index].id
  subnet_id = hcloud_network_subnet.private_subnet.id
}
