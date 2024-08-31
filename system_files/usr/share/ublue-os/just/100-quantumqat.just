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
    rpm-ostree install netcat nmap wireshark
    # Metasploit
    brew install rbenv
    rbenv install -l | sed -n '/^[[:space:]]*[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}[[:space:]]*$/ h;${g;p;}'
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall
    # Burpsuite
    brew install openjdk
    BURP_VERSION=$(curl -s https://portswigger.net/burp/releases | grep community | sed -nE "s/.*professional-community-(.*)\" class=\".*/\1/p" | head -n  1 | tr -d '\n' | tr '-' '.' | tr -d '\0')
    curl -JL -o $HOME/burpsuite.jar https://portswigger-cdn.net/burp/releases/download?product=community&version=$BURP_VERSIONtype=Linux && wait < <(jobs -p)

# Run Burpsuite
burp:
    #!/usr/bin/env bash
    java -jar -Xmx4g $HOME/burpsuite.jar
