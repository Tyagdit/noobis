resource "cloudflare_record" "noobis_record" {
  count   = length(hcloud_server.loadbalancer)
  zone_id = data.cloudflare_zone.noobis_zone.id
  type    = "A"
  name    = "*"
  value   = hcloud_server.loadbalancer[count.index].ipv4_address
  proxied = true
}
