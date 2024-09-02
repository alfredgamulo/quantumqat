#!/usr/bin/env bash

set -ouex pipefail

docker_packages=(
  "docker-ce"
  "docker-ce-cli"
  "containerd.io"
  "docker-buildx-plugin"
  "docker-compose-plugin"
)

programming_packages=(
  "code"
)

packages=(
  ${docker_packages[@]}
  ${programming_packages[@]}
)

rpm-ostree install --idempotent --allow-inactive ${packages[@]}

chmod +x /scripts/1password.sh && /scripts/1password.sh
