resource "cloudflare_record" "noobis_subdomain_records" {
  count   = length(hcloud_server.loadbalancer)
  zone_id = data.cloudflare_zone.noobis_zone.id
  type    = "A"
  name    = "*"
  value   = hcloud_server.loadbalancer[count.index].ipv4_address
  proxied = false
}

# don't have a root domain available to test this :(
# resource "cloudflare_record" "noobis_root_record" {
#   zone_id = data.cloudflare_zone.noobis_zone.id
#   type    = "CNAME"
#   name    = "@"
#   value   = "auth.${var.cloudflare_zone_name}"
#   proxied = false
# }

# resource "cloudflare_record" "noobis_www_cname" {
#   zone_id = data.cloudflare_zone.noobis_zone.id
#   type    = "CNAME"
#   name    = "www"
#   value   = "auth.${var.cloudflare_zone_name}"
#   proxied = false
# }
