#!/bin/sh

set -e

cp /etc/hosts /etc/hosts.new
sed -i 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' /etc/hosts.new
cat /etc/hosts.new > /etc/hosts

exec "$@"
