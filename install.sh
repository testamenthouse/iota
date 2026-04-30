#!/usr/bin/env bash
# iota installer — sets up the CLI and dependencies

set -euo pipefail

# Ensure Homebrew is in PATH (macOS)
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_LINK="/usr/local/bin/iota"

# Force color output from gum even inside $() subshells
export CLICOLOR_FORCE=1

# ── Colors ────────────────────────────────────────────────────────────────────
BLUE='\033[38;5;33m'
GREEN='\033[38;5;120m'
RED='\033[38;5;203m'
YELLOW='\033[38;5;221m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

HAS_GUM=false
command -v gum &>/dev/null && HAS_GUM=true

# ── Styled output ────────────────────────────────────────────────────────────
banner() {
  echo ""
  if $HAS_GUM; then
    gum style \
      --foreground 33 --border-foreground 33 \
      --border double --align center \
      --width 50 --margin "0 0" --padding "1 2" \
      '⚡ iota' 'installer'
  else
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║                                                  ║${RESET}"
    echo -e "${BLUE}║${RESET}               ${BLUE}${BOLD}⚡ iota${RESET}                            ${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}              ${BLUE}installer${RESET}                           ${BLUE}║${RESET}"
    echo -e "${BLUE}║                                                  ║${RESET}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${RESET}"
  fi
  echo ""
}

section() {
  echo ""
  if $HAS_GUM; then
    gum style --foreground 33 --bold --border rounded --border-foreground 240 \
      --padding "0 1" --margin "0 1" "$1"
  else
    echo -e "  ${BLUE}${BOLD}$1${RESET}"
    echo -e "  ${DIM}$(printf '%.0s─' {1..46})${RESET}"
  fi
}

ok()   { echo -e "  ${GREEN}✓${RESET}  $*"; }
fail() { echo -e "  ${RED}✗${RESET}  $*" >&2; }
info() { echo -e "  ${BLUE}→${RESET}  $*"; }
skip() { echo -e "  ${YELLOW}○${RESET}  $*"; }

# ── Dependency checks ────────────────────────────────────────────────────────
check_dep() {
  local bin="$1" install_hint="$2"
  if command -v "$bin" &>/dev/null; then
    ok "${BOLD}$bin${RESET} ${DIM}$(command -v "$bin")${RESET}"
  else
    fail "${BOLD}$bin${RESET} not found"
    echo -e "     ${DIM}$install_hint${RESET}"
    exit 1
  fi
}

check_optional() {
  local bin="$1" install_cmd="$2" purpose="$3"
  if command -v "$bin" &>/dev/null; then
    ok "${BOLD}$bin${RESET} ${DIM}$(command -v "$bin")${RESET}"
  else
    skip "${BOLD}$bin${RESET} ${DIM}— $purpose${RESET}"
    if command -v brew &>/dev/null; then
      read -rp "     Install now with Homebrew? [y/N] " yn
      if [[ "$yn" =~ ^[Yy]$ ]]; then
        brew install "$install_cmd"
        ok "${BOLD}$bin${RESET} installed"
        [[ "$bin" == "gum" ]] && HAS_GUM=true
      fi
    else
      echo -e "     ${DIM}Install via: brew install $install_cmd${RESET}"
    fi
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
banner

section "Required"
check_dep docker   "Install Docker Desktop: https://docs.docker.com/desktop/"
check_dep openssl  "Install via: brew install openssl"
check_dep mkcert   "Install via: brew install mkcert"

section "Optional (for iota ui)"
check_optional gum  gum  "interactive TUI"
check_optional glow glow "README viewer"

section "SSL Certificate Authority"
if mkcert -CAROOT &>/dev/null 2>&1; then
  ok "mkcert CA trusted by system"
else
  info "Installing mkcert CA (requires sudo)..."
  mkcert -install
  ok "mkcert CA installed"
fi

section "CLI Setup"
chmod +x "$SCRIPT_DIR/iota"

sudo ln -sfn "$SCRIPT_DIR/iota" "$INSTALL_LINK"
ok "Symlink ${DIM}$INSTALL_LINK → $SCRIPT_DIR/iota${RESET}"

mkdir -p "$SCRIPT_DIR/sites"
ok "Sites directory ${DIM}$SCRIPT_DIR/sites${RESET}"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
if $HAS_GUM; then
  gum style \
    --foreground 120 --border-foreground 120 \
    --border rounded --align center \
    --width 50 --padding "1 2" \
    '✓ Installation complete!'
  echo ""
  gum style --foreground 33 --bold --margin "0 1" "Get started"
else
  echo -e "  ${GREEN}${BOLD}✓ Installation complete!${RESET}"
  echo ""
  echo -e "  ${BLUE}${BOLD}Get started${RESET}"
fi

echo ""
echo -e "  ${BLUE}iota create mysite mysite.local${RESET}"
echo -e "  ${BLUE}iota start mysite${RESET}"
echo -e "  ${DIM}  → https://mysite.local  (trusted SSL)${RESET}"
echo ""
echo -e "  ${BLUE}iota ui${RESET}    ${DIM}interactive mode${RESET}"
echo -e "  ${BLUE}iota help${RESET}  ${DIM}all commands${RESET}"
echo ""
