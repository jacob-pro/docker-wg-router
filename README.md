# Docker WireGuard Router

[![Build status](https://github.com/jacob-pro/docker-wg-router/actions/workflows/docker.yml/badge.svg)](https://github.com/jacob-pro/docker-wg-router/actions)

A docker image to provide a NAT router to a VLAN using an WireGuard tunnel as the upstream connection.

## Usage

```
services:
    wgrouter:
        image: ghcr.io/jacob-pro/wg-router:latest
        cap_add:
            - NET_ADMIN                         # Required so that the container can run iptables rules
        sysctls:
            net.ipv4.conf.all.src_valid_mark: 1    
        volumes:
            - config:/etc/wireguard:ro          # Put your wg0.conf file in here
        networks:
            default:                            # Use default network for Internet to connect to Wireguard server
            external_vlan:
                ipv4_address: 192.168.1.254     # The IP address this container will use on the VLAN
        environment:
            - LAN_INTERFACE=eth1       # The adapter the `external_vlan` appears as to the container (eth0 will be taken by the default network)
            - FORWARD_PORTS=192.168.1.5:80:TCP 192.168.1.8:3389:TCP 192.168.1.3:25565:UDP   # Optional list in format IP:PORT:PROTO
        restart: unless-stopped
    dhcp:
        image: networkboot/dhcpd            # Optionally add a DHCP server to the network
        volumes:
            - ./dhcpd.conf:/data/dhcpd.conf:ro
        network_mode: "service:wgrouter"
        restart: unless-stopped
networks:
    external_vlan:  # Note: If connected to a virtual network switch, then make sure MAC Address Spoofing is allowed   
        driver: macvlan
        driver_opts:
            parent: eth1        # The adapter the VLAN is connected to on the docker host
        ipam:
            config:
                - subnet: 192.168.1.1/24
volumes:
    config:
```

