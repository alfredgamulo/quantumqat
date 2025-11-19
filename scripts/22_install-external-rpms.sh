#!/usr/bin/env bash

set -ouex pipefail

. /scripts/21_install-github-helper.sh

# Main: Define external RPMs to install
echo "=== Installing External RPMs from GitHub ==="

# Winboat - latest release
echo ""
echo "--- Winboat ---"

# Ensure writeable directory for Winboat
cat >/usr/lib/tmpfiles.d/winboat.conf <<EOF
d /opt/winboat 0755 root root -
EOF

WINBOAT_URL=$(get_latest_github_release "TibixDev/winboat" "x86_64.rpm")
if [ -n "${WINBOAT_URL}" ]; then
  install_external_rpm "winboat" "${WINBOAT_URL}"
else
  echo "ERROR: Could not determine latest Winboat release URL"
  exit 1
fi

echo ""
echo "=== External RPM installation complete ==="
