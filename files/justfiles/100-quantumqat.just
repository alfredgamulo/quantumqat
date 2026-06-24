# Connect the 1Password app to a Flatpak browser's extension.
# Pass a browser: brave (default), chrome, firefox, or any Flatpak app id.
#   ujust setup-1password-browser            # brave
#   ujust setup-1password-browser firefox
#   ujust setup-1password-browser com.google.Chrome
setup-1password-browser browser="brave":
    @/usr/libexec/quantumqat/setup-1password-browser {{browser}}
