#!/usr/bin/env bash

set -ouex pipefail

# Function to get latest release download URL from GitHub
# Usage: get_latest_github_release "owner/repo" "filename_pattern"
# Example: get_latest_github_release "TibixDev/winboat" "*x86_64.rpm"
get_latest_github_release() {
  local repo="$1"
  local pattern="$2"
  
  # Get the latest release JSON from GitHub API
  local release_url="https://api.github.com/repos/${repo}/releases/latest"
  
  # Fetch the download URL matching the pattern
  curl --silent --fail "${release_url}" | \
    grep -oP '"browser_download_url": "\K[^"]*'"${pattern}"'[^"]*' | \
    head -n1
}

# Function to download and install RPM
# Usage: install_external_rpm "package_name" "download_url"
install_external_rpm() {
  local package_name="$1"
  local download_url="$2"
  
  if [ -z "${download_url}" ]; then
    echo "ERROR: No download URL provided for ${package_name}"
    return 1
  fi
  
  local temp_file="/tmp/${package_name}.rpm"
  
  echo "Downloading ${package_name}..."
  echo "URL: ${download_url}"
  
  # Download with retry logic
  if ! curl --location --fail --retry 3 --output "${temp_file}" "${download_url}"; then
    echo "ERROR: Failed to download ${package_name} from ${download_url}"
    return 1
  fi
  
  # Verify RPM file
  if ! rpm -K "${temp_file}" &>/dev/null; then
    echo "WARNING: Could not verify RPM signature for ${package_name}, continuing anyway..."
  fi
  
  echo "Installing ${package_name}..."
  if rpm-ostree install --idempotent "${temp_file}"; then
    echo "Successfully installed ${package_name}"
    rm -f "${temp_file}"
    return 0
  else
    echo "ERROR: Failed to install ${package_name}"
    rm -f "${temp_file}"
    return 1
  fi
}
