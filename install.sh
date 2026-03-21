#!/usr/bin/env bash
# =============================================================================
# install.sh — Yozakura btop theme installer
# Place this file at the btop repo root (alongside the themes/ folder).
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
FLAVOR="yoru"
BG="true"

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --theme <flavor>   Theme flavor to activate: yoru | hiru  (default: yoru)
  --bg    <bool>     Set theme_background in btop.conf: true | false  (default: true)
  -h, --help         Show this help message

Examples:
  $(basename "$0")
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
            [[ -z "${2-}" ]] && { echo "[error] --theme requires a value (yoru|hiru)." >&2; exit 1; }
            FLAVOR="$2"; shift 2 ;;
        --bg)
            [[ -z "${2-}" ]] && { echo "[error] --bg requires a value (true|false)." >&2; exit 1; }
            BG="$2"; shift 2 ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            echo "[error] Unknown option: $1" >&2
            usage; exit 1 ;;
    esac
done

# ---------------------------------------------------------------------------
# Validate arguments
# ---------------------------------------------------------------------------
if [[ "$FLAVOR" != "yoru" && "$FLAVOR" != "hiru" ]]; then
    echo "[error] Invalid theme flavor '$FLAVOR'. Valid values: yoru, hiru" >&2
    exit 1
fi

BG_LOWER="${BG,,}"
if [[ "$BG_LOWER" != "true" && "$BG_LOWER" != "false" ]]; then
    echo "[error] Invalid --bg value '$BG'. Valid values: true, false" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Resolve script location (works with symlinks and relative calls)
# ---------------------------------------------------------------------------
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_SRC="$SCRIPT_PATH/themes"

# ---------------------------------------------------------------------------
# Validate source themes directory
# ---------------------------------------------------------------------------
if [[ ! -d "$THEMES_SRC" ]]; then
    echo "[error] themes/ directory not found at: $THEMES_SRC" >&2
    echo "        Make sure install.sh is at the btop repo root alongside themes/." >&2
    exit 1
fi

THEME_FILE="yozakura-${FLAVOR}.theme"
if [[ ! -f "$THEMES_SRC/$THEME_FILE" ]]; then
    echo "[error] Theme file not found: $THEMES_SRC/$THEME_FILE" >&2
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
# Install theme files
# ---------------------------------------------------------------------------
echo "[info] Creating theme directory: $BTOP_THEMES_DIR"
mkdir -p "$BTOP_THEMES_DIR"

echo "[info] Copying theme files from $THEMES_SRC → $BTOP_THEMES_DIR"
cp -v "$THEMES_SRC"/yozakura-*.theme "$BTOP_THEMES_DIR/"

# ---------------------------------------------------------------------------
# Patch btop.conf
# ---------------------------------------------------------------------------
if [[ ! -f "$BTOP_CONF" ]]; then
    echo "[error] btop.conf not found at: $BTOP_CONF" >&2
    echo "        Launch btop once to generate the config, then re-run this script." >&2
    exit 1
fi

echo "[info] Patching btop.conf at: $BTOP_CONF"

# color_theme — btop stores this as a full absolute path (quoted)
if grep -q '^color_theme' "$BTOP_CONF"; then
    sed -i "s|^color_theme = .*|color_theme = \"$THEME_DEST_PATH\"|" "$BTOP_CONF"
else
    echo "color_theme = \"$THEME_DEST_PATH\"" >> "$BTOP_CONF"
fi

# theme_background — stored as an unquoted boolean
if grep -q '^theme_background' "$BTOP_CONF"; then
    sed -i "s|^theme_background = .*|theme_background = $BG_LOWER|" "$BTOP_CONF"
else
    echo "theme_background = $BG_LOWER" >> "$BTOP_CONF"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo "  ✓ Theme   : yozakura-${FLAVOR}"
echo "  ✓ Bg      : $BG_LOWER"
echo "  ✓ Config  : $BTOP_CONF"
echo ""
echo "[done] Restart btop to apply the new theme."