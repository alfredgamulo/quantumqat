#!/usr/bin/env bash

set -ouex pipefail

# /var/lib/alternatives is required to prevent failure with some RPM installs
mkdir -p /var/lib/alternatives
