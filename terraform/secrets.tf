# TODO: add 'keepers' parameter to these
resource "random_id" "consul_gossip_key" {
  byte_length = 32
}

resource "random_uuid" "consul_acl_bootstrap_token" {}

resource "random_uuid" "consul_acl_client_token" {
  count = length(hcloud_server.client_node)
}
