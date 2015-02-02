# SkyDNS on CoreOS

Make SkyDNS a bit easier to run in containers on CoreOS

## Why?

Using systemd to pass the location of CoreOS's etcd endpoint is a bit painful, and makes .service definitions difficult to read. Retrieving the inet address of the host on docker0 at runtime requires a bit of parsing, and passing that value into the container requires shell-expansions, which aren't available by default in systemd. 

For example:

```ini
[Unit]
Description=SkyDNS service discovery
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/env docker kill skydns-%i
ExecStartPre=-/usr/bin/env docker rm skydns-%i
ExecStartPre=/usr/bin/env docker pull skynetservices/skydns
ExecStart=/usr/bin/env bash -c '/usr/bin/env docker run --name skydns-%i -p 53:53 -e ETCD_MACHINES="http://$(ifconfig docker0 | awk \'/\<inet\>/ { print $2}\'):4001" skynetservices/skydns'
ExecStop=-/usr/bin/env docker stop skydns-%i

[Install]
WantedBy=multi-user.target
```

## How do we fix it?

We can make a few assumptions about our container and our host, since we control both.

* The default route on the container uses our host for its gateway
* ETCD is available on port 4001 of the CoreOS host

Knowing this, we can write a simple wrapper to populate the environmental variable `ETCD_HOSTS` and pass it to skynet at runtime.

## How does it look now?

```ini
[Unit]
Description=SkyDNS service discovery
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/env docker kill skydns-%i
ExecStartPre=-/usr/bin/env docker rm skydns-%i
ExecStartPre=/usr/bin/env docker pull skynetservices/skydns
ExecStart=/usr/bin/env docker run --name skydns-%i -p 53:53 christianbladescb/skydns-coreos
ExecStop=-/usr/bin/env docker stop skydns-%i

[Install]
WantedBy=multi-user.target
```

Readable! Hooray!
