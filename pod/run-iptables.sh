#!/bin/bash
set -x
echo "Executing iptables"
# Initialize chains
sudo iptables -t mangle -N MESH_INGRESS
sudo iptables -t nat -N MESH_INGRESS
sudo iptables -t nat -N MESH_EGRESS
# Enable egress routing
# Ignore egress redirect based UID, ports, and IPs
# Don't intercept anything outgoing that is originated from 1337 which is ENVOY_UID
sudo iptables -t nat -A MESH_EGRESS -m owner --uid-owner 1337 -j RETURN
# Don't intercept outgoing ssh or DNS
sudo iptables -t nat -A MESH_EGRESS -p tcp -m multiport --dports 22,53 -j RETURN
# IP Exclusions
# sudo iptables -t nat -A MESH_EGRESS -p tcp -d "{{egressIgnoredIPs}}" -j RETURN
# Redirect everything that is not ignored
sudo iptables -t nat -A MESH_EGRESS -p tcp -j REDIRECT --to 12345
# Apply MESH_EGRESS chain to non-local traffic
sudo iptables -t nat -A OUTPUT -p tcp -m addrtype ! --dst-type LOCAL -j MESH_EGRESS

# Enable ingress routing
# Route everything arriving at the application port to Envoy. We have excluded admin
sudo iptables -t nat -A MESH_INGRESS -p tcp -m multiport --dports 8000 \
  -j REDIRECT --to-port 9211
# Apply APPMESH_INGRESS chain to non-local traffic
sudo iptables -t nat -A PREROUTING -p tcp -m addrtype ! --src-type LOCAL -j MESH_INGRESS

while true; do sleep 30; done;
