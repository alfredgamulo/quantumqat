#!/usr/bin/env bash

set -ouex pipefail

systemctl --global enable docker.socket
