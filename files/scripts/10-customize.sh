#!/usr/bin/env bash

set -euo pipefail

# Remove the Steam autostart entry from the new-user skeleton
rm -f /etc/skel/.config/autostart/steam.desktop

# Write custom image info consumed by bazzite's fastfetch / about screens.
# The CI short-SHA that the old Containerfile build passed in is not available
# to BlueBuild modules, so derive a date-based version instead.
VERSION="$(date +%Y%m%d)"
cat > /usr/share/ublue-os/custom-image-info.json <<EOF
{
  "image-name": "quantumqat",
  "image-vendor": "alfredgamulo",
  "image-ref": "ostree-image-signed:docker://ghcr.io/alfredgamulo/quantumqat",
  "base-image-name": "bazzite",
  "version": "${VERSION}",
  "version-pretty": "Stable (${VERSION})"
}
EOF
