#!/usr/bin/env bash

set -ouex pipefail

echo "import \"/usr/share/ublue-os/just/100-quantumqat.just\"" >> /usr/share/ublue-os/justfile

rm -f /etc/skel/.config/autostart/steam.desktop

cat > /usr/share/ublue-os/custom-image-info.json <<EOF
{
  "image-name": "quantumqat",
  "image-vendor": "alfredgamulo",
  "image-ref": "ostree-image-signed:docker://ghcr.io/alfredgamulo/quantumqat",
  "base-image-name": "bazzite",
  "version": "$VERSION_TAG",
  "version-pretty": "$VERSION_PRETTY"
}
EOF
