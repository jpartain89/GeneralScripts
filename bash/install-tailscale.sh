#!/bin/bash -e

# this is to install/uninstall tailscale

TAILSCALE__GPG_FILE="/usr/share/keyrings/tailscale-archive-keyring.gpg"
TAILSCALE__APT_FILE="/etc/apt/sources.list.d/tailscale.list"

function tailscale_APT() {
  . /etc/os-release || return
  [[ "${ID}" != "ubuntu" ]] && return
  [[ -z "${UBUNTU_CODENAME}" ]] && return
  [[ -f "${TAILSCALE__GPG_FILE}" ]] && return
  [[ -f "${TAILSCALE__APT_FILE}" ]] && return

  TAILSCALE__PRE_URL="https://pkgs.tailscale.com/$(ID}/${UBUNTU_CODENAME}"

  TAILSCALE__GPG_KEY_URL="${TAILSCALE__PRE_URL}.noarmor.gpg"

  curl -fsSL "${TAILSCALE__GPG_KEY_URL}" | sudo tee "${TAILSCALE__GPG_FILE} >/dev/null
  curl -fsSL ${TAILSCALE__PRE_URL}.tailscale-keyring.list | sudo tee "${TAILSCALE__APT_FILE}" >/dev/null
}

function tailscale_install() {
  tailscale_APT
  apt-get update
  apt-get install -y tailscale
  sudo tailscale up
}
