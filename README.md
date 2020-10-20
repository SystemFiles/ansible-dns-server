<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=250px src="/images/ansible.png" alt="Ansible Project"></a>
</p>

<h3 align="center">DNS Server Install</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)](https://sykesdev.ca/projects/)
[![Build Status](https://github.com/systemfiles/ansible-dns-server/workflows/test-local/badge.svg)](https://github.com/systemfiles/ansible-dns-server/actions?query=workflow%3Atest-local)
[![GitHub Issues](https://img.shields.io/github/issues/systemfiles/ansible-dns-server.svg)](https://github.com/SystemFiles/ansible-dns-server/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/systemfiles/ansible-dns-server.svg)](https://github.com/SystemFiles/ansible-dns-server/issues)
[![License](https://img.shields.io/badge/license-Apache2.0-blue.svg)](/LICENSE)

</div>

---

<p align="center"> Simple ansible configuration role to install and configure a DNS server
    <br> 
</p>

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)

## 🧐 About <a name = "about"></a>

This role will allow you to install and configure a Bind9 (non-authoritative) DNS server on a linux machine. The role allows you to customize a number of DNS server options inside of the `vars/main.yml` file, including a list of host and IP addresses that you would like your DNS server to resolve. I did make this for my own purposes to set up a raspberry pi DNS server on my home network to route traffic to my media server through a domain name, but it hopefully should work just fine for anyone else too. Feel free to fork to modify for your own purposes 😊

## ✍️ Getting Started <a name = "getting_started" >

Using this role should be pretty much the same as any other role, but just to make sure, I will include the following directions for different ways of consuming the role.

### Docker

Create a Dockerfile similar to the [provided one](/Dockerfile.dev) in this repo.

```dockerfile

FROM ubuntu:20.04

RUN apt update && apt install -y ansible
RUN mkdir -p /ansible-plays/

WORKDIR /
COPY ./install_configure_play.yml ./ansible-plays/
COPY ./config-dns-server/ /etc/ansible/roles/config-dns-server/

# Run the play (CAN BE OVERIDDEN)
CMD [ "ansible-playbook", "./ansible-plays/install_configure_play.yml" ]

```

Build the container image

```bash

docker build -t ansible-dev:latest -f Dockerfile .

```

Run the container using your image

```

docker run -it -p 53:53/udp -p 53:53/tcp ansible-dev:latest

```

### Manual

Installing manually requires a couple of extra steps than the previous methods of installation. This method is, however, more clear.

First fork the repository and make your customizations to the `config-dns-server/vars/` role variables

```yml

---
# vars file for config-dns-server

# Directory for the DNS cache
bind_directory: /var/cache/bind

# What address shall be configured for this DNS server host
dns_server_address: 127.0.0.1

# Which secondary DNS server (default: google) shall be used to find anything not found in primary DNS server (this)
forwarding_dns_server: 8.8.8.8

# Used to identify / configure the zone for a subnet running this DNS server
# If you have a 192.168.0.0/16 then then you would use the reversed octet 168.192. If you use 10.128.0.0/16 you would use 128.10 here
subnet_reversed_octet: 168.192

# List of zone configs to be created in DNS configuration
# available_zone_domains: List of all domains this DNS server will resolve
# host_name: name of computer/server on the network
# host_address: The static IP address of the computer/server on the network
# domain: The domain that this host_name is a part of on the network
# All together: host_name.domain => host_address
available_zone_domains:
  - sykeshome
  - sykesdev
zone_hosts:
  - { host_name: webserver, host_address: 192.168.0.107, domain: sykeshome }
  - { host_name: mac, host_address: 192.168.0.113, domain: sykesdev}
  - { host_name: bad, host_address: 192.168.0.117, domain: sykesdev}
  - { host_name: bob, host_address: 192.168.0.133, domain: sykeshome}
  - { host_name: good, host_address: 192.168.0.140, domain: sykesdev}


```

Copy the role to your master or node `/etc/ansible/roles/` and create a playbook

**local**

```yml

---
- hosts: 127.0.0.1
  connection: local
  become: true
  roles:
    - config-dns-server

```

**master**

```yml

---
- hosts: webservers
  become: true
  roles:
    - config-dns-server

```

## 👷‍♂️ Authors <a name = "authors" >

- [Ben Sykes (SystemFiles)](https://sykesdev.ca/)