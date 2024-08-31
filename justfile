_:
    @just --list -u --list-heading $'🐈‍⬛ QuantumQat \n'

# Build the local offline ISO
build-iso:
    #!/usr/bin/env bash
    sudo podman run --rm --privileged \
    --volume .:/build-container-installer/build \
    --security-opt label=disable --pull=newer \
    ghcr.io/jasonn3/build-container-installer:latest \
    IMAGE_REPO="ghcr.io/alfredgamulo" \
    IMAGE_NAME="quantumqat" \
    IMAGE_TAG="latest" \
    VARIANT="Silverblue"
