# Install system flatpaks
install-system-flatpaks:
    #!/usr/bin/env bash
    echo "Installing Bazzite Flatpaks..."
    just _install-system-flatpaks
    echo "Installing QuantumQat Flatpaks..."
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/alfredgamulo/quantumqat/main/installer/flatpaks | tr '\n' ' ')"
    flatpak --system -y install --or-update ${FLATPAK_LIST}

# Install infosec tools
install-infosec-tools:
    #!/usr/bin/env bash
    rpm-ostree install --idempotent --allow-inactive bluez-tools netcat nmap sox
