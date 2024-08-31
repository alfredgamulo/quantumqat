install-system-flatpaks:
    #!/usr/bin/env bash
    echo "Installing Bazzite Flatpaks..."
    just _install-system-flatpaks
    echo "Installing QuantumQat Flatpaks..."
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/alfredgamulo/quantumqat/main/installer/isengard_flatpaks | tr '\n' ' ')"
    flatpak --system -y install --or-update ${FLATPAK_LIST}
