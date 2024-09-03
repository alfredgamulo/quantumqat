#!/usr/bin/env bash

set -ouex pipefail

# Clean up the yum repos (updates are baked into new images)
rm -f /etc/yum.repos.d/docker-ce.repo
rm -f /etc/yum.repos.d/vscode.repo

/usr/libexec/containerbuild/image-info
/usr/libexec/containerbuild/build-initramfs
/usr/libexec/containerbuild/cleanup.sh
