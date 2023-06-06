#!/bin/bash
function log { logger -t "vpc" -- $1; }

function die {
    [ -n "$1" ] && log "$1"
    log "Configuration of PAT failed!"
    exit 1
}

log "Enabling PAT..."
dnf update -y
dnf install -y iptables
sysctl -q -w net.ipv4.ip_forward=1 net.ipv4.conf.ens5.send_redirects=0 && (
   iptables -t nat -C POSTROUTING -o ens5 -s ${vpc_cidr_range} -j MASQUERADE 2> /dev/null ||
   iptables -t nat -A POSTROUTING -o ens5 -s ${vpc_cidr_range} -j MASQUERADE ) ||
       die

sysctl net.ipv4.ip_forward net.ipv4.conf.ens5.send_redirects | log
iptables -n -t nat -L POSTROUTING | log

log "Configuration of PAT complete."
exit 0
