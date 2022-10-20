terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.35.2"
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

provider "hcloud" {}
provider "local" {}
provider "random" {}
