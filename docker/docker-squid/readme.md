![Image of squid-cache](http://www.squid-cache.org/Images/img4.jpg)

# Docker Alpine Proxy

- [Introduction](#introduction)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Command-line arguments](#command-line-arguments)
  - [Persistence](#persistence)
  - [Configuration](#configuration)
  - [Usage](#usage)
  - [Logs](#logs)
  - [Test](#test)
  
  
# Introduction

This is a `Dockerfile` to create a [Docker](https://www.docker.com/) image/container for [Squid](http://www.squid-cache.org/) proxy server based on [Alpine](https://hub.docker.com/_/alpine/) for minimal images.


# Getting started

## Installation

On [hub.docker.com](https://hub.docker.com/r/homelan/docker-squid/) is the offical docker repository with automated build of the image. The recommended method to pull the images is to use

```console
$ docker pull homelan/docker-squid
```


## Quickstart

The easyest way to start is to use the supplied [docker-compose.yml](docker-compose.yml) file 

```yaml
version: '2'

services:
  cache:
    image: homelan/docker-squid
    #build: ./squid
    restart: always
    network_mode: "bridge"
    ports:
      # Take care: Proxmox VE/SPICE proxy is also on port 3128
      - "$BIND_PORT:3128"
    env_file:
      - .env
    volumes:
      - "cache:/var/cache/squid"

volumes:
   cache:
```

to start the container using [Docker Compose](https://docs.docker.com/compose/) inside the directory:

```console
$ docker-compose up -d
```

Alternatively, you can use the docker syntax, like:

```console
$ docker run --name squid_cache -d --restart=always \
  --publish 3128:3128 \
  --volume /path/to/squid/cache:/var/spool/squid \
  docker pull homelan/docker-squid
```


## Command-line arguments

The image is designed to allow passing arguments, e.g. to dump the configuration actually used:

```
$ docker-compose exec cache squid -k parse
```

> *Note the *SERVICE_NAME* `cache` from `docker-compose.yml` called by [docker-compose exec](https://docs.docker.com/compose/reference/exec/))*

respectively:

```console
$ docker exec squid_cache squid -k parse
```

which both show the output similar this:


```text
2017/11/28 17:19:12| Startup: Initializing Authentication Schemes ...
2017/11/28 17:19:12| Startup: Initialized Authentication Scheme 'basic'
2017/11/28 17:19:12| Startup: Initialized Authentication Scheme 'digest'
2017/11/28 17:19:12| Startup: Initialized Authentication Scheme 'negotiate'
2017/11/28 17:19:12| Startup: Initialized Authentication Scheme 'ntlm'
2017/11/28 17:19:12| Startup: Initialized Authentication.
2017/11/28 17:19:12| Processing Configuration File: /etc/squid/squid.conf (depth 0)
2017/11/28 17:19:12| Processing: acl localnet src 10.0.0.0/8	# RFC1918 possible internal network
2017/11/28 17:19:12| Processing: acl localnet src 172.16.0.0/12	# RFC1918 possible internal network
2017/11/28 17:19:12| Processing: acl localnet src 192.168.0.0/16	# RFC1918 possible internal network
2017/11/28 17:19:12| Processing: acl localnet src fc00::/7       # RFC 4193 local private network range
2017/11/28 17:19:12| Processing: acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines
2017/11/28 17:19:12| Processing: acl SSL_ports port 443
2017/11/28 17:19:12| Processing: acl Safe_ports port 80		# http
2017/11/28 17:19:12| Processing: acl Safe_ports port 21		# ftp
2017/11/28 17:19:12| Processing: acl Safe_ports port 443		# https
2017/11/28 17:19:12| Processing: acl Safe_ports port 70		# gopher
2017/11/28 17:19:12| Processing: acl Safe_ports port 210		# wais
2017/11/28 17:19:12| Processing: acl Safe_ports port 1025-65535	# unregistered ports
2017/11/28 17:19:12| Processing: acl Safe_ports port 280		# http-mgmt
2017/11/28 17:19:12| Processing: acl Safe_ports port 488		# gss-http
2017/11/28 17:19:12| Processing: acl Safe_ports port 591		# filemaker
2017/11/28 17:19:12| Processing: acl Safe_ports port 777		# multiling http
2017/11/28 17:19:12| Processing: acl CONNECT method CONNECT
2017/11/28 17:19:12| Processing: http_access deny !Safe_ports
2017/11/28 17:19:12| Processing: http_access deny CONNECT !SSL_ports
2017/11/28 17:19:12| Processing: http_access allow localhost manager
2017/11/28 17:19:12| Processing: http_access deny manager
2017/11/28 17:19:12| Processing: http_access allow localnet
2017/11/28 17:19:12| Processing: http_access allow localhost
2017/11/28 17:19:12| Processing: http_access deny all
2017/11/28 17:19:12| Processing: http_port 3128
2017/11/28 17:19:12| Processing: coredump_dir /var/cache/squid
2017/11/28 17:19:12| Processing: refresh_pattern ^ftp:		1440	20%	10080
2017/11/28 17:19:12| Processing: refresh_pattern ^gopher:	1440	0%	1440
2017/11/28 17:19:12| Processing: refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
2017/11/28 17:19:12| Processing: refresh_pattern .		0	20%	4320
2017/11/28 17:19:12| Processing: cache_effective_user squid
2017/11/28 17:19:12| Processing: cache_effective_group squid
2017/11/28 17:19:12| Processing: cache_mem 256 MB
2017/11/28 17:19:12| Processing: maximum_object_size_in_memory 512 KB
2017/11/28 17:19:12| Processing: memory_replacement_policy heap GDSF
2017/11/28 17:19:12| Processing: cache_dir aufs /var/cache/squid 100 16 256
2017/11/28 17:19:12| Processing: cache_replacement_policy heap LFUDA
2017/11/28 17:19:12| Processing: acl DOCKER_NET src 172.17.0.0/16
2017/11/28 17:19:12| Processing: http_access allow DOCKER_NET
2017/11/28 17:19:12| Initializing https proxy context
```

The same concept you can use for maintenance purposes, namely shell access:

```console
$ docker-compose exec cache sh
```

or docker's way:

```console
$ docker exec -it squid_cache sh
```

> *Note, [Alpine Linux](https://hub.docker.com/_/alpine/) is built arround [BusyBox](https://busybox.net/), hence `console` isn't installed by default.*



## Persistence

For the cache to preserve its state across container shutdown and startup you should mount a volume at `/var/cache/squid`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker, e.g.:

```console
$ mkdir -p /path/to/squid/cache
$ chcon -Rt svirt_sandbox_file_t /path/to/squid/cache
```

## Configuration


Squid is a full featured caching proxy server and a large number of configuration parameters. 

If the configured parameters are not sufficient you can provide your own `squid.conf` and volume mount it at `/etc/squid/squid.conf`:

```console
$ docker run --name squid -d --restart=always \
  --publish 3128:3128 \
  --volume /path/to/squid.conf:/etc/squid/squid.conf \
  --volume /path/to/squid/cache:/var/cache/squid \
  homelan/docker-squid
```

or change it on the `docker-compose.yml` file. 

To reload the Squid configuration on a running instance you can send than the `HUP` signal to the container.

```console
$ docker kill -s HUP squid
```

Otherwise image's defaults should be sufficient.


### Environment Variables

The image takes care of some environment variables. The table below lists the image defaults used (some equals to squid's defaults):

| environment variable                | Squid companion                                                                                      | default value    |
|-------------------------------------|------------------------------------------------------------------------------------------------------|------------------|
| SQUID_EFFECTIVE_USER                | [cache_effective_user](http://www.squid-cache.org/Doc/config/cache_effective_user)                   | squid            |
| SQUID_EFFECTIVE_GROUP               | [cache_effective_group](http://www.squid-cache.org/Doc/config/cache_effective_group)                 | squid            |
| SQUID_CACHE_MEM                     | [cache_mem](http://www.squid-cache.org/Doc/config/cache_mem/)                                        | 256 MB           |
| SQUID_MAXIMUM_OBJECT_SIZE_IN_MEMORY | [maximum_object_size_in_memory](http://www.squid-cache.org/Doc/config/maximum_object_size_in_memory/)| 512 KB           |
| SQUID_MEMORY_REPLACEMENT_POLICY     | [memory_replacement_policy](http://www.squid-cache.org/Doc/config/memory_replacement_policy/)        | heap GDSF        |
| SQUID_CACHE_DIR                     | [cache_dir](http://www.squid-cache.org/Doc/config/cache_dir/)                                        | /var/cache/squid |
| SQUID_CACHE_SIZE                    | see [cache_dir](http://www.squid-cache.org/Doc/config/cache_dir/)                                    | 100 MB           |
| SQUID_MAXIMUM_OBJECT_SIZE           | [maximum_object_size](http://www.squid-cache.org/Doc/config/maximum_object_size/)                    | 16 MB            |
| SQUID_CACHE_REPLACEMENT_POLICY      | [cache_replacement_policy](http://www.squid-cache.org/Doc/config/cache_replacement_policy/)          | heap LFUDA       |


Other environment variables are optional, namely networks to be enabled for caching. The [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) are set to defaults than and if they fit your setup they can be omitted (since they are applied) - otherwise set them.

| environment variable | default value |
|----------------------|---------------|
| SQUID_NET           | N/A           |
| SQUID_NET_CIDR      | 24            |

To get the docker's network cached, check for the network (as of here shown it's the default):

```console
$ ip addr show docker0
6: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:e4:99:91:f2 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:e4ff:fe99:91f2/64 scope link 
       valid_lft forever preferred_lft forever
```

and set the environment variabled `SQUID_NET` and `SQUID_NET_CIDR` to `16`; or set caching for your LAN (you should know your network, `hostname -I` shows all networks connected to).


### Volumes

- `/var/cache/squid`, see also at [Persistence](#persistence).


### Ports

- `3128` 

> *Note, [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) is using the same port for the SPICE proxy, see [Ports](https://pve.proxmox.com/wiki/Ports).


## Usage

As usual, there are several ways to configure the clients. 

As for your web browser configure network/connection settings to use the proxy server (of course available only if the squid cache is configured appropriate). 

On Linux the shell's environment variables can be set like:

```bash
export http_proxy=http://<IP>:3128
export https_proxy=http://<IP>:3128
export ftp_proxy=http://<IP>:3128
```

e.g. inside your `.bashrc'.

The offical docker docs shows a way to [Use a proxy server with containers](https://docs.docker.com/engine/userguide/networking/#use-a-proxy-server-with-containers) which works only on [Docker CE Edge](https://docs.docker.com/edge/), hence untested for docker containers.
Otherwise the environment variables can be given to the `Dockerfile`

```dockerfile
ENV http_proxy=http://<IP:3128 \
    https_proxy=http://<IP>:3128 \
    ftp_proxy=http://<IP>:3128
```

or even using the `environment` section of the `docker-compose.yml` file.


## Logs

To access the container's log files, located at `/var/log/squid/`, you can use:

```console
$ docker-compose logs -f
```

or even use the `docker exec` way:

```console
$ docker exec -it squid \
  tail -f /var/log/squid/access.log
```

Also, you can also mount a volume at `/var/log/squid/` so that the logs are directly accessible on the host.


## Test

For testing here [thinkbroadband](https://www.thinkbroadband.com) [Download Test Files](https://www.thinkbroadband.com/download) are used. Open two terminals, one for [curl](https://curl.haxx.se/) and one to access squid's `access.log`, e.g. using [tmux](https://github.com/tmux/tmux/wiki).

On the first:

```console
$ http_proxy=172.17.0.1:3128 time -f "%e" curl --silent http://ipv4.download.thinkbroadband.com/5MB.zip -o /dev/null
1.16
...
$ http_proxy=172.17.0.1:3128 time -f "%e" curl --silent http://ipv4.download.thinkbroadband.com/5MB.zip -o /dev/null
0.84
```

On the second:

```console
$ docker-compose exec cache tail -f /var/log/squid/access.log 
1511811115.897    859 172.17.0.1 TCP_MISS/200 5243272 GET http://ipv4.download.thinkbroadband.com/5MB.zip - HIER_DIRECT/80.249.99.148 application/zip
1511811126.453    825 172.17.0.1 TCP_MISS/200 5243272 GET http://ipv4.download.thinkbroadband.com/5MB.zip - HIER_DIRECT/80.249.99.148 application/zip
```

or even check it even use temporary "benchmark" container:

```console
$ docker run -ti --rm --name alpine_cache_test alpine
/ # apk --no-cache add curl
fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/community/x86_64/APKINDEX.tar.gz
(1/4) Installing ca-certificates (20161130-r2)
(2/4) Installing libssh2 (1.8.0-r1)
(3/4) Installing libcurl (7.56.1-r0)
(4/4) Installing curl (7.56.1-r0)
Executing busybox-1.26.2-r7.trigger
Executing ca-certificates-20161130-r2.trigger
OK: 6 MiB in 15 packages
/ # http_proxy=172.17.0.1:3128 curl http://ipv4.download.thinkbroadband.com/5MB.zip -o /dev/null 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 5120k  100 5120k    0     0  5120k      0  0:00:01 --:--:--  0:00:01 6251k
```

Honesty, the improvement isn't amazing, it's obviously working but maybe something is wrong ....
