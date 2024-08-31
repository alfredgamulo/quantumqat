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
    VARIANT="Kinoite" \
    VERSION="40" \
    SECURE_BOOT_KEY_URL="https://github.com/ublue-os/bazzite/raw/main/secure_boot.der" \
    ENROLLMENT_PASSWORD="universalblue" \
    ISO_NAME="/build-container-installer/build/quantumqat.iso" \
    ADDITIONAL_TEMPLATES="/build-container-installer/build/installer/remove_root_password_prompt.tmpl /build-container-installer/build/installer/set_default_user.tmpl"
