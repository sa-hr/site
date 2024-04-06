---
title: Running your own name server with NSD
date: 2022-03-20
---

I wanted to run my own Name server forever now. Since I've started self hosting
this was on my todo list. This weekend I've decided to do just that and started
with a VM on [OpenBSD Amsterdam](https://openbsd.amsterdam/). Once you have a VM
and you SSH into it you can start setting up everything.

## Zones and domains

I had a `0x7f.hr` ready for me to use so I've picked that up. Let's start by
preparing our zone file. Our IP of the server let's say is `10.10.10.10`.

```bash
$ cat >> cat /var/nsd/zones/master/0x7f.hr.zone <<EOF
$ORIGIN             0x7f.hr.
$TTL    300
@       3600  SOA   ns1.0x7f.hr. hostmaster.0x7f.hr. (
        2018121401  ; serial YYYYMMDDnn
        1440        ; refresh
        3600        ; retry
        604800      ; expire
        300 )       ; minimum TTL
@       NS      ns1.0x7f.hr.
@       NS      ns2.0x7f.hr.
ns1     A       10.10.10.10
ns2     A       10.10.10.10
@       A       10.10.10.11
www     CNAME   0x7f.hr.

EOF
```

This will be our zone, Yes - I'm cheating and using only one server. I don't
wanna pay for two and it's a lab :D.

## `NSD` config

```bash
$ cat > /var/nsd/etc/nsd.conf <<EOF
server:
  hide-version: yes
  verbosity: 1
  database: "" # disable database

remote-control:
  control-enable: yes
  control-interface: /var/run/nsd.sock

zone:
  name: 0x7f.hr
  zonefile: master/%s.zone

EOF
```

After this is in place do the following:

```bash
$ rcctl enable nsd
$ rcctl start nsd
```

And you can try and look for your domain now:

```bash
$ dig @localhost 0x7f.hr

; <<>> dig 9.10.8-P1 <<>> @localhost 0x7f.hr
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 59864
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;0x7f.hr.                       IN      A

;; ANSWER SECTION:
0x7f.hr.                300     IN      A       10.10.10.11

;; AUTHORITY SECTION:
0x7f.hr.                300     IN      NS      ns1.0x7f.hr.
0x7f.hr.                300     IN      NS      ns2.0x7f.hr.

;; ADDITIONAL SECTION:
ns1.0x7f.hr.            300     IN      A       10.10.10.10
ns2.0x7f.hr.            300     IN      A       10.10.10.10

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Mon Mar 21 17:45:38 GMT 2022
;; MSG SIZE  rcvd: 120
```

Set up the glue records and point the domain to your new ns records: `ns1.0x7f.hr` and `ns2.0x7f.hr`.
