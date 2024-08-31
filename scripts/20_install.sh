#!/usr/bin/env bash

set -ouex pipefail

programming_packages=(
  "code"
)

docker_packages=(
  "docker-ce"
  "docker-ce-cli"
  "containerd.io"
  "docker-buildx-plugin"
  "docker-compose-plugin"
)

packages=(
  ${programming_packages[@]}
  ${docker_packages[@]}
)

rpm-ostree install ${packages[@]}