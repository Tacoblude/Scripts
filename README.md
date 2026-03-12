Scripts

Quick setup scripts for Linux systems.

Contents
- system-update.sh: Update/upgrade packages (apt, pacman, dnf, zypper).
- setup-ufw.sh: Install and configure UFW (allows SSH, sane defaults).
- Legacy scripts: Archupdate, Paru installer, Yay installer, mac-changer.

Prerequisites
- Run from this directory. Use sudo when prompted.

Run individual steps
- Update/upgrade packages only:
  bash system-update.sh
- Setup UFW only:
  bash setup-ufw.sh

Notes
- UFW: Deny incoming, allow outgoing, allow SSH (OpenSSH or 22/tcp) then enable.
- Scripts are idempotent and detect your package manager.
- On Arch, package tasks use pacman; on Debian/Ubuntu, apt-get is used.
