resource "hcloud_firewall" "bastion_firewall" {
  name = "bastion_firewall"

  rule {
    description = "SSH from internet"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall" "loadbalancer_firewall" {
  name = "loadbalancer_firewall"

  rule {
    description = "HTTP from internet"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "HTTPS from internet"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Any TCP port from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Any UDP port from subnet"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }
}

resource "hcloud_firewall" "server_firewall" {
  name = "server_firewall"

  rule {
    description = "SSH from bastion"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = [hcloud_server_network.bastion_network.ip]
  }

  rule {
    description = "Consul HTTPS from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "8501"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Consul gRPC from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "8502"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Consul LAN Serf TCP from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "8301"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Consul LAN Serf UDP from subnet"
    direction   = "in"
    protocol    = "udp"
    port        = "8301"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Consul WAN Serf TCP from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "8302"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Consul WAN Serf UDP from subnet"
    direction   = "in"
    protocol    = "udp"
    port        = "8302"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Consul RPC from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "8300"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Nomad HTTP(S) from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "4646"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Nomad RPC from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "4647"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Nomad LAN/WAN Serf TCP from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "4648"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Nomad LAN/WAN Serf UDP from subnet"
    direction   = "in"
    protocol    = "udp"
    port        = "4648"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }
}

resource "hcloud_firewall" "client_firewall" {
  name = "client_firewall"

  # TODO: probably better to just use the same ports as server
  # firewall plus the 21000 to 21255 ports used by sidecar proxies

  rule {
    description = "Any TCP port from subnet"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }

  rule {
    description = "Any UDP port from subnet"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips  = [hcloud_network_subnet.private_subnet.ip_range]
  }
}
