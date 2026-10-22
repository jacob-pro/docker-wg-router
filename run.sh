#!/usr/bin/env bash
set -e

if [ -z "$LAN_INTERFACE" ]
then
      echo "LAN_INTERFACE not set" && exit 1
fi
if [ -z "$CONF_FILE" ]
then
      echo "CONF_FILE not set" && exit 1
fi

echo "Creating wg interface"
ip link add dev wg0 type wireguard
wg setconf wg0 "/etc/wg/${CONF_FILE}"

echo "Routing from $LAN_INTERFACE to tun0"
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
iptables -A FORWARD -i wg0 -o $LAN_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $LAN_INTERFACE -o wg0 -j ACCEPT

for PORT_TUPLE in $FORWARD_PORTS
do
    SPACED=(${PORT_TUPLE//:/ })
    IP=${SPACED[0]}
    PORT_NUMBER=${SPACED[1]}
    PROTO=${SPACED[2]}
    echo "Opening ${PROTO} port ${PORT_NUMBER} for ${IP}"
    iptables -t nat -A PREROUTING -i tun0 -p ${PROTO} --dport ${PORT_NUMBER} -j DNAT --to-destination ${IP}
done

# TODO: Need to use natpmpc to open on provider side
sleep infinity
