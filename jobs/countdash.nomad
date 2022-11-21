# example from https://developer.hashicorp.com/nomad/tutorials/integrate-consul/consul-service-mesh
# modified to accomodate for caddy and prometheus configurations. Has 2 tasks, both with sidecar
# proxies and one upstream from the other

job "countdash" {
  datacenters = ["dc1"]

  group "api" {
    network {
      mode = "bridge"
      # port used to expose envoy's prometheus metrics
      # endpoint, dynamically set by nomad
      port "prom" {}
    }

    service {
      name = "count-api"
      port = "9001"

      meta {
        # meta tag that nomad will set in the consul service of the
        # sidecar proxy which is used by prometheus to find the port
        # to communicate with
        prometheus_port = "${NOMAD_HOST_PORT_prom}"
      }

      connect {
        sidecar_service {
          proxy {
            config {
              # tells envoy that where to expose it's metrics endpoint
              envoy_prometheus_bind_addr = "0.0.0.0:${NOMAD_PORT_prom}"
            }
          }
        }
      }
    }

    task "api" {
      driver = "docker"
      config {
        image = "hashicorpnomad/counter-api:v1"
      }
    }
  }

  group "dashboard" {
    network {
      mode = "bridge"
      # port used to expose envoy's prometheus metrics
      # endpoint, dynamically set by nomad
      port "prom" {}

      port "http" {
        static = 9002
        to     = 9002
      }
    }

    service {
      name = "count-dashboard"
      port = "9002"
      # consul-template will find this tag and use it to create a
      # caddy config that serves this service
      #        tag finder subdomain    port to serve
      #            |         |               |
      #       |----------|-------|-----------------------|
      tags = ["userfacing:counter:${NOMAD_HOST_PORT_http}"]

      meta {
        # meta tag that nomad will set in the consul service of the
        # sidecar proxy which is used by prometheus to find the port
        # to communicate with
        prometheus_port = "${NOMAD_HOST_PORT_prom}"
      }

      connect {
        sidecar_service {
          proxy {
            config {
              # tells envoy that where to expose it's metrics endpoint
              envoy_prometheus_bind_addr = "0.0.0.0:${NOMAD_PORT_prom}"
            }
            upstreams {
              destination_name = "count-api"
              local_bind_port = 8080
            }
          }
        }
      }
    }

    task "dashboard" {
      driver = "docker"
      env {
        COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_count_api}"
      }
      config {
        image = "hashicorpnomad/counter-dashboard:v1"
      }
    }
  }
}
