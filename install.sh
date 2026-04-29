#!/usr/bin/env bash
# iota installer — sets up the CLI and dependencies

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_LINK="/usr/local/bin/iota"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()    { echo -e "${CYAN}[install]${RESET} $*"; }
success(){ echo -e "${GREEN}[✓]${RESET} $*"; }
warn()   { echo -e "${YELLOW}[!]${RESET} $*"; }
error()  { echo -e "${RED}[✗]${RESET} $*" >&2; }

echo ""
echo -e "${BOLD}iota installer${RESET}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_dep() {
  local bin="$1" install_hint="$2"
  if command -v "$bin" &>/dev/null; then
    success "$bin found ($(command -v "$bin"))"
  else
    error "$bin not found. $install_hint"
    exit 1
  fi
}

log "Checking dependencies..."
check_dep docker   "Install Docker Desktop: https://docs.docker.com/desktop/"
check_dep openssl  "Install via: brew install openssl"
check_dep python3  "Install via: brew install python3"
check_dep mkcert   "Install via: brew install mkcert  (then re-run this installer)"

# Ensure mkcert local CA is trusted by browsers/system
log "Ensuring mkcert local CA is installed in system trust store..."
if mkcert -CAROOT &>/dev/null 2>&1; then
  success "mkcert CA already installed"
else
  log "Installing mkcert CA (requires sudo — this lets your browser trust local certs)..."
  mkcert -install
  success "mkcert CA installed"
fi

# Make scripts executable
chmod +x "$SCRIPT_DIR/iota"

# Create symlink
if [[ -L "$INSTALL_LINK" ]] || [[ -f "$INSTALL_LINK" ]]; then
  warn "Removing existing $INSTALL_LINK..."
  sudo rm -f "$INSTALL_LINK"
fi

log "Creating symlink at $INSTALL_LINK (requires sudo)..."
sudo ln -sf "$SCRIPT_DIR/iota" "$INSTALL_LINK"
success "Symlink created: $INSTALL_LINK → $SCRIPT_DIR/iota"

# Ensure sites dir exists
mkdir -p "$SCRIPT_DIR/sites"
success "Sites directory ready: $SCRIPT_DIR/sites"

echo ""
echo -e "${GREEN}${BOLD}Installation complete!${RESET}"
echo ""
echo -e "Get started:"
echo -e "  ${CYAN}iota create mysite mysite.local${RESET}"
echo -e "  ${CYAN}iota start mysite${RESET}"
echo -e "  # → https://mysite.local  (trusted SSL, no browser warnings)"
echo -e ""
echo -e "  ${CYAN}iota list${RESET}"
echo -e "  ${CYAN}iota help${RESET}"
echo ""
