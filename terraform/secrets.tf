# TODO: add 'keepers' parameter to these
resource "random_id" "consul_gossip_encrypt_key" {
  byte_length = 32
}

resource "random_id" "nomad_gossip_encrypt_key" {
  byte_length = 32
}

resource "random_uuid" "consul_acl_bootstrap_token" {}

resource "random_uuid" "consul_acl_client_token" {
  count = length(hcloud_server.client_node)
}

resource "random_uuid" "consul_acl_loadbalancer_token" {
  count = length(hcloud_server.loadbalancer)
}

resource "random_uuid" "consul_acl_nomad_server_token" {
  count = length(hcloud_server.server_node)
}

resource "random_uuid" "consul_acl_nomad_client_token" {
  count = length(hcloud_server.client_node)
}
