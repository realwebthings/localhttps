#!/bin/bash
# localhttps installer
# Usage: curl -fsSL https://raw.githubusercontent.com/realwebthings/localhttps/main/install.sh | bash

set -e

GREEN="\033[0;32m"
CYAN="\033[0;36m"
BOLD="\033[1m"
NC="\033[0m"

log()  { echo -e "${GREEN}[✔] $1${NC}"; }
info() { echo -e "${CYAN}${BOLD}$1${NC}"; }
error() { echo -e "\033[0;31m[✘] $1${NC}"; exit 1; }

OS="$(uname -s)"
case "$OS" in
  Darwin) ;;
  Linux)  ;;
  *)      error "Unsupported OS: $OS. For Windows, run install.ps1 instead." ;;
esac

CLI_DEST="/usr/local/bin/localhttps"
CLI_HOME="$HOME/.localhttps"
mkdir -p "$CLI_HOME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/bin/localhttps" ]; then
  cp "$SCRIPT_DIR/bin/localhttps" "$CLI_HOME/localhttps"
else
  curl -fsSL "https://raw.githubusercontent.com/realwebthings/localhttps/main/bin/localhttps" -o "$CLI_HOME/localhttps"
fi
chmod +x "$CLI_HOME/localhttps"
sudo ln -sf "$CLI_HOME/localhttps" "$CLI_DEST"
log "Installed 'localhttps' command to $CLI_DEST"

echo ""
info "╔══════════════════════════════════════════════╗"
info "║               Setup complete!                ║"
info "╚══════════════════════════════════════════════╝"
echo ""
echo "  Run this from any project, any time:"
echo ""
echo "    localhttps use <domain> [port]   # serve https://<domain> -> :port"
echo "    localhttps stop [domain]         # stop one domain, or all"
echo "    localhttps list                  # show active domains"
echo "    localhttps update                # update to the latest version"
echo "    localhttps help                  # show usage"
echo ""
echo "  Everything else — mkcert, nginx, /etc/hosts, certificates — is handled"
echo "  automatically the first time you run 'localhttps use'."
echo ""
