#!/usr/bin/env bash
# =============================================================================
# install.sh — Yozakura btop theme installer
# Place this file at the btop repo root (alongside the themes/ folder).
# Run without arguments for interactive menu, or pass flags directly.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Colors & symbols
# ---------------------------------------------------------------------------
PINK='\033[38;5;218m'
LAVENDER='\033[38;5;183m'
GREEN='\033[38;5;157m'
RED='\033[38;5;210m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "  ${LAVENDER}›${RESET} $*"; }
success() { echo -e "  ${GREEN}✓${RESET} $*"; }
error()   { echo -e "  ${RED}✗${RESET} $*" >&2; }
banner()  {
    echo
    echo -e "${PINK}${BOLD}  夜桜 Yozakura — btop Theme Installer${RESET}"
    echo -e "${DIM}  ──────────────────────────────────────${RESET}"
    echo
}

# ---------------------------------------------------------------------------
# Defaults (used in flag mode; overridden by menu in interactive mode)
# ---------------------------------------------------------------------------
FLAVOR=""
BG=""
INTERACTIVE=false

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF

  Usage: $(basename "$0") [OPTIONS]

  Options:
    --theme <flavor>   Theme flavor: yoru | hiru
    --bg    <bool>     theme_background: true | false
    -h, --help         Show this help message

  Run without any options to launch the interactive menu.

  Examples:
    $(basename "$0") --theme hiru --bg false
    $(basename "$0") --theme yoru --bg true

EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --theme)
            [[ -z "${2-}" ]] && { error "--theme requires a value (yoru|hiru)."; exit 1; }
            FLAVOR="$2"; shift 2 ;;
        --bg)
            [[ -z "${2-}" ]] && { error "--bg requires a value (true|false)."; exit 1; }
            BG="${2,,}"; shift 2 ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            error "Unknown option: $1"
            usage; exit 1 ;;
    esac
done

# ---------------------------------------------------------------------------
# If no flags given, launch interactive menu
# ---------------------------------------------------------------------------
if [[ -z "$FLAVOR" && -z "$BG" ]]; then
    INTERACTIVE=true
fi

banner

if [[ "$INTERACTIVE" == true ]]; then

    # — Flavor picker —
    echo -e "  ${BOLD}Select a flavor:${RESET}"
    echo -e "  ${PINK}1)${RESET} 🌸  Yoru ${DIM}(night — deep moonlit background)${RESET}"
    echo -e "  ${LAVENDER}2)${RESET} ☀️   Hiru ${DIM}(day  — warm ivory canvas)${RESET}"
    echo
    while true; do
        read -rp $'  \e[2mFlavor\e[0m [1/2] (default: 1): ' flavor_input
        flavor_input="${flavor_input:-1}"
        case "$flavor_input" in
            1) FLAVOR="yoru";  break ;;
            2) FLAVOR="hiru";  break ;;
            *) echo -e "  ${RED}Please enter 1 or 2.${RESET}" ;;
        esac
    done

    echo

    # — Background picker —
    echo -e "  ${BOLD}Use theme background?${RESET}"
    echo -e "  ${PINK}1)${RESET} Yes ${DIM}(theme_background = true)${RESET}"
    echo -e "  ${LAVENDER}2)${RESET} No  ${DIM}(theme_background = false — use terminal transparency)${RESET}"
    echo
    while true; do
        read -rp $'  \e[2mBackground\e[0m [1/2] (default: 1): ' bg_input
        bg_input="${bg_input:-1}"
        case "$bg_input" in
            1) BG="true";  break ;;
            2) BG="false"; break ;;
            *) echo -e "  ${RED}Please enter 1 or 2.${RESET}" ;;
        esac
    done

    echo
    echo -e "${DIM}  ──────────────────────────────────────${RESET}"
    echo

fi

# ---------------------------------------------------------------------------
# Validate flag-mode values (menu always produces valid values)
# ---------------------------------------------------------------------------
if [[ "$FLAVOR" != "yoru" && "$FLAVOR" != "hiru" ]]; then
    error "Invalid --theme '$FLAVOR'. Valid values: yoru, hiru"
    exit 1
fi

BG="${BG,,}"
if [[ "$BG" != "true" && "$BG" != "false" ]]; then
    error "Invalid --bg '$BG'. Valid values: true, false"
    exit 1
fi

# ---------------------------------------------------------------------------
# Resolve script location
# ---------------------------------------------------------------------------
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_SRC="$SCRIPT_PATH/themes"

if [[ ! -d "$THEMES_SRC" ]]; then
    error "themes/ directory not found at: $THEMES_SRC"
    error "Make sure install.sh is at the btop repo root alongside themes/."
    exit 1
fi

THEME_FILE="yozakura-${FLAVOR}.theme"
if [[ ! -f "$THEMES_SRC/$THEME_FILE" ]]; then
    error "Theme file not found: $THEMES_SRC/$THEME_FILE"
    exit 1
fi

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
BTOP_CONF_DIR="$HOME/.config/btop"
BTOP_THEMES_DIR="$BTOP_CONF_DIR/themes"
BTOP_CONF="$BTOP_CONF_DIR/btop.conf"
THEME_DEST_PATH="$BTOP_THEMES_DIR/$THEME_FILE"

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------
info "Creating theme directory: $BTOP_THEMES_DIR"
mkdir -p "$BTOP_THEMES_DIR"

info "Copying theme files → $BTOP_THEMES_DIR"
cp "$THEMES_SRC"/yozakura-*.theme "$BTOP_THEMES_DIR/"

if [[ ! -f "$BTOP_CONF" ]]; then
    error "btop.conf not found at: $BTOP_CONF"
    error "Launch btop once to generate the config, then re-run this script."
    exit 1
fi

info "Patching btop.conf"

if grep -q '^color_theme' "$BTOP_CONF"; then
    sed -i "s|^color_theme = .*|color_theme = \"$THEME_DEST_PATH\"|" "$BTOP_CONF"
else
    echo "color_theme = \"$THEME_DEST_PATH\"" >> "$BTOP_CONF"
fi

if grep -q '^theme_background' "$BTOP_CONF"; then
    sed -i "s|^theme_background = .*|theme_background = $BG|" "$BTOP_CONF"
else
    echo "theme_background = $BG" >> "$BTOP_CONF"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo
echo -e "${DIM}  ──────────────────────────────────────${RESET}"
success "${BOLD}Theme      ${RESET}: yozakura-${FLAVOR}"
success "${BOLD}Background ${RESET}: $BG"
success "${BOLD}Config     ${RESET}: $BTOP_CONF"
echo -e "${DIM}  ──────────────────────────────────────${RESET}"
echo
echo -e "  ${PINK}Restart btop to apply the theme.${RESET}"
echo