# Noobis

This is a from-scratch Ansible+Terraform deployment script for a private cloud infrastructure on the Hetzner Cloud to be used as a automation/DevOps playground.

Once deployed you will have:
- A server node on Hetzner with a Nomad and Consul server agent
- A client node on Hetzner with a Nomad and Consul client agent
- A loadbalancer node with Caddy as an authentication service and a reverse proxy to the Nomad UI, Consul UI, Prometheus UI and Grafana UI as well as any consul services configured to be [userfacing](#caddy)
- A bastion node to SSH into all of the other nodes
- DNS entries on Cloudflare for the configured domain

<details>
<summary>Architecture Diagram</summary>

![Architecture Diagram](/assets/noobis_arch.png)
</details>

## Prerequisites

- Ansible
- Terraform
- Hetzner Account API key
    - SSH Key set up on Hetzner Cloud
- Cloudflare Account API Token
    - Domain (Zone) registered on cloudflare

## Deploying

### Setup Environment
```bash
cp noobis.env.example noobis.env
vim noobis.env
```
Edit the env vars according to the [Environment Variables Section](#environment-variables)

### Deploy
```bash
source noobis.env
ansible-playbook build.yml --private-key <path/to/ssh/key>
```
And wait ~15 minutes

## Usage

Once deployed (and once the Cloudflare DNS records have been propagated) the available URLs should look like:
```
# Internal
https://auth.example.com
https://consul.example.com
https://nomad.example.com
https://grafana.example.com
https://prometheus.example.com

# User-facing
https://service1.example.com
https://service2.example.com
```
The internal links have SSO so the first time you visit any of them you will be redirected for authentication using the configured credentials. You can go to `auth.example.com` to  change the password, access user info and links to internal services

You can SSH into the nodes with
```bash
ssh -J bastion_user@<lb_ip> <noobis_user>@10.0.0.<x>
```

## Configuration

### Environment Variables

- Required
    - `HCLOUD_TOKEN` - Hetzner Cloud API token
    - `CLOUDFLARE_API_TOKEN` - Cloudflare API Token with permissions to edit the DNS entries for the zone of the domain to use
    - `NOOBIS_HCLOUD_SSH_KEY` - Name of the SSH key set up on Hetzner Cloud that will be used to provision the instances
    - `NOOBIS_DOMAIN` - The domain that caddy wil serve (i.e Cloudflare Zone name)
    - `NOOBIS_PASSWORD` - Password of the linux user that Ansible should create on the remote instances
- Optional
    - `NOOBIS_USERNAME`(default: noobis) - Name of the linux user to create on the remote hosts
    - `NOOBIS_AUTH_PORTAL_USERNAME`(default: same as `<NOOBIS_USERNAME>`) - Username used for authentication through the web auth portal
    - `NOOBIS_AUTH_PORTAL_EMAIL`(default: `<NOOBIS_USERNAME>@<NOOBIS_DOMAIN>`) - Email used for authentication through the web auth portal
    - `NOOBIS_AUTH_PORTAL_PASSWORD`(default: same as `NOOBIS_PASSWORD`) - Password used for authentication through the web auth portal
    - `NOOBIS_GRAFANA_ADMIN_PASS` (default: admin) - Password for the admin user on grafana

### Ansible Variables

Edit the [vars/main.yml](/vars/main.yml) file for further configuration

### Service/Job Configuration

- [Read this](#caddy) to understand how to expose a service from the loadbalancer
- [Read this](#prometheus) to understand how to allow metrics collection from a service's sidecar proxy

## Deployment Details

<details>
<summary>Deployment Flow</summary>

![Deployment Flow](/assets/noobis_flow.png)
</details>

- Ansible takes all the supplied variables and creates a `terraform.tfvars` file, which is read by terraform when ansible uses it to deploy the instances and networks on Hetzner
- Terraform then creates an `inventory.yml` file, which is used by ansible for all further steps. This file has the IPs of all the created instances as well as the ACL, encryption and other secrets required for deployment of nomad and consul

### Nodes

####  Bastion Node

- Provisioned using cloud-init from terraform
- Uses the provided HCloud SSH key

#### Loadbalancer Nodes

- Caddy for reverse proxying to all the services and nomad, consul, prometheus & grafana
- Prometheus to collect consul and nomad cluster health metrics and metrics from consul service mesh's envoy sidecar proxies
- Grafana to visualize metrics from Prometheus

#### Server Nodes

- Nomad server agent
- Consul server agent

#### Client Nodes

- Nomad client agent
- Consul client agent
- Docker
- Nomad jobs

### Software

#### TLS

- CA certs for nomad and consul are generated and stored on the ansible controller machine
- Client and server certs for momad and consul are generated on the corresponding nodes
- Certs are generated with openSSL not consul builtin CA

#### SSH

- The bastion does not allow any user login, only SSH jumping
- The key configured on Hetzner should be used

#### Caddy

- Services (i.e Nomad tasks) that need to be reverse-proxied from caddy should have a consul tag `userfacing:<subdomain>:<port>` where:
    - The `<subdomain>` is the subdomain that caddy should use to reverse-proxy to this service
    - The `<port>` is the port on the host (i.e the client node) of the service to which caddy should reverse-proxy
- Only http(s) traffic is allowed into caddy
- Caddyfile is generated using [consul-template](https://github.com/hashicorp/consul-template)
- [caddy-security](https://github.com/greenpau/caddy-security) is used to provide SSO, configured to use a local identity store with a single registered user (using credentials from the [env vars](#environment-variables))

#### Ansible

- Consul and Nomad ports are all set to default and aren't configurable yet

#### Consul

- ACL, TLS and gossip encryption are enabled
- ACL tokens are generated by terraform and registered through the API
- TLS verification is used on both outgoing and incoming requests

#### Nomad

- TLS and gossip encryption are enabled
- ACLs are disabled since they are only needed for operator authorization, nomad agents don't use them
- ACL tokens for consul are required though, they are generated in the same way as with consul agents
- TLS verification is used on both outgoing and incoming requests
- Docker and raw_exec plugins are enabled on the clients

#### Prometheus

- Collects metrics from Consul server agents, all Nomad agents and envoy sidecar proxies configured for it
- To configure an envoy sidecar proxy in a nomad job to be queried by prometheus, it needs to have:
    - A port mapping in the `network` stanza specific to prometheus
    - A **consul** meta tag `prometheus_port` with the value of the host port from the above port mapping
    - `envoy_prometheus_bind_addr` in the sidecar proxy config set to the service port from the above port mapping
    - See the [jobs/countdash.nomad](/jobs/countdash.nomad) job file for an example

## Todo

- [x] DNS record setup
- [ ] Create SSH key if not provided
- [ ] Append /etc/hosts if no domain provided
- [x] Caddy auth
- [ ] Logging
- [x] More metrics (caddy, node-exporter, prometheus)
- [x] Example services
- [ ] Post-provision management playbooks (nomad jobs, terraform destroy)
- [ ] Linting
- [ ] Update Consul
- [ ] ~~Provision root domain too~~
