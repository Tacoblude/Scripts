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

install_pkg() {
  local pkg="$1"
  if command -v apt-get >/dev/null 2>&1; then
    DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get update -y
    DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get install -y "$pkg"
  elif command -v pacman >/dev/null 2>&1; then
    ${SUDO} pacman -Syu --noconfirm --needed "$pkg"
  elif command -v dnf >/dev/null 2>&1; then
    ${SUDO} dnf -y install "$pkg" || true
  elif command -v zypper >/dev/null 2>&1; then
    ${SUDO} zypper --non-interactive install -y "$pkg" || true
  else
    log "No supported package manager found. Please install $pkg manually."
    return 1
  fi
}

ensure_ufw_installed() {
  if ! command -v ufw >/dev/null 2>&1; then
    log "Installing ufw..."
    install_pkg ufw
  else
    log "ufw already installed."
  fi
}

configure_ufw() {
  log "Configuring ufw defaults..."
  ${SUDO} ufw --force default deny incoming
  ${SUDO} ufw --force default allow outgoing

  log "Allowing OpenSSH..."
  # Using application profile name when available; fallback to 22/tcp
  if ${SUDO} ufw app list >/dev/null 2>&1 && ${SUDO} ufw app list | grep -qi "openssh"; then
    ${SUDO} ufw allow OpenSSH || true
  else
    ${SUDO} ufw allow 22/tcp || true
  fi

  # Common optional allowances (commented out). Uncomment as needed.
  # ${SUDO} ufw allow 80/tcp   # HTTP
  # ${SUDO} ufw allow 443/tcp  # HTTPS
}

enable_ufw() {
  if ${SUDO} ufw status | grep -q "Status: active"; then
    log "ufw already enabled."
  else
    log "Enabling ufw..."
    ${SUDO} ufw --force enable
  fi
}

main() {
  ensure_ufw_installed
  configure_ufw
  enable_ufw
  log "ufw setup complete. Current status:"
  ${SUDO} ufw status verbose || true
}

main "$@"
