#!/usr/bin/env bash

set -euo pipefail

# 1Password, installed the way blue-build/modules' bling installer used to.
# Internalized (instead of `type: bling`) because that installer's
# xdg-desktop-menu step hardcodes the old `1password.desktop` filename, which
# 1Password renamed to `com.onepassword.OnePassword.desktop` as of 8.12.36 —
# breaking every build. The RPM now ships its own .desktop files and icons
# directly under /usr/share, so that step (and the icon-copying one) is both
# broken and redundant; this script keeps only the parts still needed.
RELEASE_CHANNEL="stable"

# Must be over 1000
GID_ONEPASSWORD=1500

# Must be over 1000
GID_ONEPASSWORDCLI=1600

echo "Installing 1Password"

mkdir -p /var/opt

cat << EOF > /etc/yum.repos.d/1password.repo
[1password]
name=1Password ${RELEASE_CHANNEL^} Channel
baseurl=https://downloads.1password.com/linux/rpm/${RELEASE_CHANNEL}/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF

rpm --import https://downloads.1password.com/linux/keys/1password.asc

rpm-ostree install 1password 1password-cli

# Clean up the yum repo (updates are baked into new images)
rm /etc/yum.repos.d/1password.repo -f

# chrome-sandbox requires the setuid bit to be specifically set.
# See https://github.com/electron/electron/issues/17972
chmod 4755 /opt/1Password/chrome-sandbox

# Normally, 1Password's own after-install.sh would create a group,
# "onepassword", right about now. But if we do that during the ostree build
# it'll disappear from the running system, so instead hardcode GIDs via
# sysusers.d below and cross our fingers nothing else steps on them.
#
# GID must be > 1000, and absolutely must not conflict with any real groups
# on the deployed system. Normal user group GIDs on Fedora are sequential
# starting at 1000, so skip ahead to something higher.

# BrowserSupport binary needs setgid. This gives no extra permissions to the
# binary; it only hardens it against environmental tampering.
BROWSER_SUPPORT_PATH="/opt/1Password/1Password-BrowserSupport"
chgrp "${GID_ONEPASSWORD}" "${BROWSER_SUPPORT_PATH}"
chmod g+s "${BROWSER_SUPPORT_PATH}"

# onepassword-cli also needs its own group and setgid, like the other helpers.
chgrp "${GID_ONEPASSWORDCLI}" /usr/bin/op
chmod g+s /usr/bin/op

# Dynamically create the required groups via sysusers.d, with the GID based
# on the files we just chgrp'd.
cat > /usr/lib/sysusers.d/onepassword.conf <<EOF
g onepassword ${GID_ONEPASSWORD}
EOF
cat > /usr/lib/sysusers.d/onepassword-cli.conf <<EOF
g onepassword-cli ${GID_ONEPASSWORDCLI}
EOF

# Remove the sysusers.d entries created by the onepassword RPMs. They don't
# magically set the GID like we need them to.
rm -f /usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword.conf
rm -f /usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword-cli.conf

echo "=== 1Password installation complete ==="
