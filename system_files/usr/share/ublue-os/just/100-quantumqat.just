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
    brew install openjdk
    BURP_VERSION=$(curl -s https://portswigger.net/burp/releases | grep community | sed -nE "s/.*professional-community-(.*)\" class=\".*/\1/p" | head -n  1 | tr -d '\n' | tr '-' '.' | tr -d '\0')
    mkdir -p $HOME/.local/lib/
    curl -JL -o $HOME/.local/lib/burpsuite.jar https://portswigger-cdn.net/burp/releases/download?product=community&version=$BURP_VERSIONtype=Linux && wait < <(jobs -p)
    rpm-ostree install --idempotent metasploit-framework netcat nmap wireshark

# Run Burpsuite
run-burpsuite:
    #!/usr/bin/env bash
    java -jar -Xmx4g $HOME/.local/lib/burpsuite.jar
