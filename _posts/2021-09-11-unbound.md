---
title: Unbound on OpenBSD
date: 2021-09-11
---

This is a simple guide on how to get Unbound running as a forwarding and local DNS server on your network.
Just install a base OpenBSD installation, and drop to shell after first boot. Be sure to setup so that the
VM has a static IP on your network. For me that's 10.10.0.145.

<!--more-->

I will also be using nextdns.io for AD blocking and forwarding.

## Setting up unbound

```bash
$ rcctl enable unbound
$ cat > /var/unbound/etc/unbound.conf << EOF
server:
        interface: 10.10.0.145
        interface: 127.0.0.1
        access-control: 10.10.0.1/32 allow
        access-control: 127.0.0.1/32 allow
        do-not-query-localhost: no
        hide-identity: yes
        hide-version: yes

        tls-cert-bundle: /etc/ssl/cert.pem

        local-zone: "crnkovic.family." static

        local-data: "router.crnkovic.family. IN A 10.10.0.1"

forward-zone:
        name: "."
        forward-tls-upstream: yes
        forward-addr: 45.90.28.0#<REPLACE ME>.dns1.nextdns.io
        forward-addr: 45.90.30.0#<REPLACE ME>.dns2.nextdns.io
EOF
$ rcctl start unbound
```

The idea is that only the Unifi UDM is going to make DNS requests to this instance
and then provide the results using dnsmasq, so we don't allow querying form any
other IP except 10.10.0.1 and 127.0.0.1.

## Making sure we are caching our own DNS requests

Since my network is using DHCP I had to override the DNS provided by the router:

```bash
$ cat > /etc/dhclient.conf << EOF
supersede domain-name-servers 127.0.0.1;
EOF
$ sh /etc/netstart
```
