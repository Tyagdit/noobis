variable "hcloud_token" {
  type = string
  description = "The Hetzner Cloud API token"
}

variable "bastion_username" {
  type        = string
  description = "The user to set up in the bastion"
  default     = "bastion_user"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the SSH key configured on Hetzner cloud"
}

variable "network_ip_range" {
  type        = string
  description = "The CIDR range for the network to be created"
  default     = "10.0.0.0/24" # 10.0.0.2 -> 10.0.0.254 (first and last IPs are reserved)
}

variable "subnet_ip_range" {
  type        = string
  description = "The CIDR range for the subnet within the network to be created"
  default     = "10.0.0.0/28" # 10.0.0.2 -> 10.0.0.14 (first and last IPs are reserved)
}

variable "loadbalancer_count" {
  type        = number
  description = "Number of loadbalancers to create"
  default     = 1
}

variable "server_node_count" {
  type        = number
  description = "Number of server nodes to create"
  default     = 1
}

variable "client_node_count" {
  type        = number
  description = "Number of client nodes to create"
  default     = 1
}
