#!/usr/bin/env bash

set -ouex pipefail

# /var/lib/alternatives is required to prevent failure with some RPM installs
mkdir -p /var/lib/alternatives

# Apply IP Forwarding before installing Docker to prevent messing with LXC networking
sysctl -p
