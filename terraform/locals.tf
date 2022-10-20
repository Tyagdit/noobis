locals {
  server_hosts = {
    for i, network in hcloud_server_network.server_node_network :
    # map of hosts' private IP to host's ansible vars
    network.ip => { consul_node_name = "server_node_${i}" }
  }

  client_hosts = {
    for i, network in hcloud_server_network.client_node_network :
    network.ip => {
      consul_node_name = "client_node_${i}"
      consul_acl_client_token = random_uuid.consul_acl_client_token[i]
    }
  }

  loadbalancer_hosts = {
    for i, network in hcloud_server_network.loadbalancer_network :
    network.ip => { consul_node_name = "loadbalancer_${i}" }
  }
}
