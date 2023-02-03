terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.36.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.28.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
provider "hcloud" {
  token = var.hcloud_token
}
provider "local" {}
provider "random" {}
