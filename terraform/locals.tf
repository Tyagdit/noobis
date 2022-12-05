locals {
  server_hosts = {
    for i, network in hcloud_server_network.server_node_network :
    # map of hosts' private IP to host's ansible vars
    network.ip => {
      node_id = "server-node-${i}"
      # consul ACL token needed by nomad servers
      consul_acl_nomad_token = random_uuid.consul_acl_nomad_server_token[i].result
    }
  }

  client_hosts = {
    for i, network in hcloud_server_network.client_node_network :
    network.ip => {
      node_id = "client-node-${i}"
      # consul ACL token needed by consul clients
      consul_acl_client_token = random_uuid.consul_acl_client_token[i].result
      # consul ACL token needed by nomad clients
      consul_acl_nomad_token = random_uuid.consul_acl_nomad_client_token[i].result
    }
  }

  loadbalancer_hosts = {
    for i, network in hcloud_server_network.loadbalancer_network :
    network.ip => {
      node_id = "loadbalancer-${i}"
      # consul ACL token needed by consul clients (loadbalancers in this case)
      consul_acl_client_token = random_uuid.consul_acl_loadbalancer_token[i].result
      # consul ACL token for prometheus to access consul metrics endpoints
      consul_acl_prometheus_metrics_token = random_uuid.consul_acl_prometheus_metrics_token[i].result
    }
  }
}
