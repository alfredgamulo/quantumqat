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

utility_packages=(
  "1password"
)

packages=(
  ${docker_packages[@]}
  ${programming_packages[@]}
  ${utility_packages[@]}
)

rpm-ostree install ${packages[@]}
