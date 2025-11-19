#!/usr/bin/env bash

set -ouex pipefail

. /scripts/21_install-github-helper.sh

# Main: Define external RPMs to install
echo "=== Installing External RPMs from GitHub ==="

# Winboat - latest release
echo ""
echo "--- Winboat ---"

WINBOAT_URL=$(get_latest_github_release "TibixDev/winboat" "x86_64.rpm")
if [ -n "${WINBOAT_URL}" ]; then
  install_external_rpm "winboat" "${WINBOAT_URL}"

  # Move /opt/winboat to /usr/lib/winboat to persist in ostree image
  if [ -d "/opt/winboat" ]; then
    echo "Moving /opt/winboat to /usr/lib/winboat..."
    mv /opt/winboat /usr/lib/winboat
  fi
else
  echo "ERROR: Could not determine latest Winboat release URL"
  exit 1
fi

# Ensure symlink for Winboat
cat >/usr/lib/tmpfiles.d/winboat.conf <<EOF
L /opt/winboat - - - - /usr/lib/winboat
EOF

echo ""
echo "=== External RPM installation complete ==="
