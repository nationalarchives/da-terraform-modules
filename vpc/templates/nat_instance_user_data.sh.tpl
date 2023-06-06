#!/bin/bash

dnf update -y
dnf install -y iptables
sysctl -q -w net.ipv4.ip_forward=1 net.ipv4.conf.ens5.send_redirects=0
iptables -t nat -A POSTROUTING -s -o ens5 ${vpc_cidr_range} -j MASQUERADE
exit 0
