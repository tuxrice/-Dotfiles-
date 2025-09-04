#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# CONFIG
DOTFILES_DIR="$(pwd)"
WAYBAR_SRC="${DOTFILES_DIR}/waybar"
HYPR_SRC="${DOTFILES_DIR}/hypr"

WAYBAR_DEST="${HOME}/.config/waybar"
HYPR_DEST="${HOME}/.config/hypr"

# ─────────────────────────────────────────────────────────────
# 1. Install Waybar
echo "Installing Waybar..."
if ! command -v pacman &>/dev/null; then
  echo "Error: Only Arch-based systems (pacman) are supported."
  exit 1
fi
sudo pacman -Syu --needed waybar

# ─────────────────────────────────────────────────────────────
# 2. Setup Waybar Config
echo "Setting up Waybar config..."
mkdir -p "$WAYBAR_DEST"

if [ -f "$WAYBAR_SRC/config" ]; then
  ln -sf "$WAYBAR_SRC/config" "$WAYBAR_DEST/config"
  echo "Linked Waybar config"
fi

if [ -f "$WAYBAR_SRC/style.css" ]; then
  ln -sf "$WAYBAR_SRC/style.css" "$WAYBAR_DEST/style.css"
  echo "Linked Waybar style.css"
fi

# ─────────────────────────────────────────────────────────────
# 3. Setup Hyprland Config (skip hyprpaper.conf)
echo "Setting up Hyprland config..."
mkdir -p "$HYPR_DEST"

for file in "$HYPR_SRC"/*; do
  basefile=$(basename "$file")

  if [[ "$basefile" == "hyprpaper.conf" ]]; then
    echo "Skipping hyprpaper.conf"
    continue
  fi

  ln -sf "$file" "$HYPR_DEST/$basefile"
  echo "Linked Hyprland file: $basefile"
done

# ─────────────────────────────────────────────────────────────
# 4. Reload Waybar if running
if pgrep waybar &>/dev/null; then
  echo "Reloading Waybar..."
  pkill -SIGUSR2 waybar || echo "Failed to reload Waybar"
else
  echo "Waybar not running — start it manually with: waybar &"
fi

echo "Dotfiles installation complete!"
