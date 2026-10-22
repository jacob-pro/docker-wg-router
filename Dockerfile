FROM alpine:latest

RUN apk update && apk add bash wireguard-tools nftables iptables

HEALTHCHECK --interval=60s --timeout=5s --retries=3 \
             CMD ping -c 1 -I tun0 8.8.8.8

COPY run.sh /

ENTRYPOINT ["/run.sh"]
