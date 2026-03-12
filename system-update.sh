#!/usr/bin/env bash

set -euo pipefail

log() { printf '[%s] %s\n' "$(date +'%F %T')" "$*"; }

need_sudo() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo sudo
  else
    echo
  fi
}

SUDO=$(need_sudo)

update_apt() {
  log "Detected apt-get (Debian/Ubuntu). Updating package lists..."
  ${SUDO} apt-get update
  log "Upgrading packages (non-interactive)..."
  DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get -y upgrade
  log "Autoremoving unused packages..."
  ${SUDO} apt-get -y autoremove
  log "Autocleaning cache..."
  ${SUDO} apt-get -y autoclean
}

update_pacman() {
  log "Detected pacman (Arch). Syncing and upgrading packages..."
  ${SUDO} pacman -Syu --noconfirm --needed
}

update_dnf() {
  log "Detected dnf (Fedora/RHEL). Refreshing metadata and upgrading..."
  ${SUDO} dnf -y upgrade --refresh || ${SUDO} dnf -y upgrade
}

update_zypper() {
  log "Detected zypper (openSUSE). Refreshing and updating..."
  ${SUDO} zypper --non-interactive refresh
  ${SUDO} zypper --non-interactive update
}

main() {
  if command -v apt-get >/dev/null 2>&1; then
    update_apt
  elif command -v pacman >/dev/null 2>&1; then
    update_pacman
  elif command -v dnf >/dev/null 2>&1; then
    update_dnf
  elif command -v zypper >/dev/null 2>&1; then
    update_zypper
  else
    log "No supported package manager found (apt-get, pacman, dnf, zypper). Skipping."
    exit 0
  fi

  log "System update completed."
}

main "$@"