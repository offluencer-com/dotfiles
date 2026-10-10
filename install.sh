#!/usr/bin/env bash
# install.sh - rebuild offluencer's Arch + Hyprland setup from this repo.
#
# Run as your normal user (not root) on a fresh Arch install that already has:
#   a user with sudo rights, a working internet connection.
# Safe to run more than once.

set -euo pipefail

REPO_URL="https://codeberg.org/offluencer/dotfiles.git"
DOTFILES="$HOME/dotfiles"
LY_TTY="tty2"                      # ly runs as ly@tty2.service
DEFAULT_WALLPAPER="pipesmoker.jpg" # used for the first pywal run

FAILED=()
step() { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*"; }

[ "$EUID" -ne 0 ] || { echo "Run this as your normal user, not root."; exit 1; }
command -v pacman >/dev/null || { echo "This script is for Arch Linux."; exit 1; }

# ---------------------------------------------------------------- 1. repo
step "Base tools and dotfiles repo"
sudo pacman -Syu --needed --noconfirm git base-devel stow
if [ ! -d "$DOTFILES/.git" ]; then
  git clone "$REPO_URL" "$DOTFILES"
fi
cd "$DOTFILES"

# ------------------------------------------------------- 2. pacman packages
step "Official packages"
mapfile -t WANTED < <(grep -vE '^\s*(#|$)' pkglist.txt | sort -u)
mapfile -t AVAILABLE < <(comm -12 <(printf '%s\n' "${WANTED[@]}") <(pacman -Slq | sort -u))
mapfile -t MISSING < <(comm -23 <(printf '%s\n' "${WANTED[@]}") <(pacman -Slq | sort -u))
for p in "${MISSING[@]}"; do
  warn "$p is no longer in the Arch repos, skipping"
  FAILED+=("$p (not in repos)")
done
sudo pacman -S --needed --noconfirm "${AVAILABLE[@]}"

# ---------------------------------------------------------- 3. AUR packages
step "AUR helper (yay)"
if ! command -v yay >/dev/null; then
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

step "AUR packages"
while read -r p; do
  yay -S --needed --noconfirm "$p" || { warn "$p failed to build"; FAILED+=("$p (AUR)"); }
done < <(grep -vE '^\s*(#|$)' aurlist.txt | grep -vE '^yay$|-debug$')

# ------------------------------------------------------------- 4. dotfiles
step "Linking dotfiles with stow"
# These must be real folders, so app data written next to the configs
# stays out of the repo.
mkdir -p "$HOME/.config"/{qutebrowser,zsh,spotifast,Thunar,gtk-3.0}

# Move aside anything that would block a link.
BACKUP="$HOME/config-backup-$(date +%F-%H%M%S)"
while IFS= read -r -d '' f; do
  target="$HOME/${f#home/}"
  if [ -e "$target" ] && [ ! "$target" -ef "$f" ]; then
    mkdir -p "$BACKUP/$(dirname "${f#home/}")"
    mv "$target" "$BACKUP/${f#home/}"
    warn "moved existing ${target/#$HOME/\~} to ${BACKUP/#$HOME/\~}"
  fi
done < <(find home \( -type f -o -type l \) -print0)

stow -v -t "$HOME" home

# ------------------------------------------------- 5. folders, links, pywal
step "Folders, wallpapers and pywal colors"
mkdir -p "$HOME/.local/state/zsh" "$HOME/.cache/wal" "$HOME/Pictures/Screenshots"
command -v xdg-user-dirs-update >/dev/null && xdg-user-dirs-update

if [ ! -e "$HOME/Pictures/wallpapers" ]; then
  ln -s "$DOTFILES/wallpapers" "$HOME/Pictures/wallpapers"
fi

# Links to files pywal generates (not stored in the repo).
ln -sfn "$HOME/.cache/wal/colors-waybar.css" "$DOTFILES/home/.config/waybar/colors-wal.css"
ln -sfn "$HOME/.cache/wal/gtk-colors.css"    "$HOME/.config/gtk-3.0/gtk-colors.css"

WALL="$DOTFILES/wallpapers/$DEFAULT_WALLPAPER"
if [ ! -f "$WALL" ]; then
  WALL="$(find "$DOTFILES/wallpapers" -maxdepth 1 -type f | sort | head -n 1)"
fi

if command -v wal >/dev/null && [ -n "$WALL" ]; then
  wal -q -n -s -t -e -i "$WALL" || warn "pywal failed, press SUPER+W after login"
  if [ -f "$HOME/.cache/wal/spotifast.json" ]; then
    cp "$HOME/.cache/wal/spotifast.json" "$HOME/.config/spotifast/themes/pywal.json"
  fi
else
  warn "pywal not installed, colors will be missing until it is"
  FAILED+=("pywal first run")
fi

HYPRPAPER="$HOME/.config/hypr/hyprpaper.conf"
if [ ! -f "$HYPRPAPER" ] && [ -n "$WALL" ]; then
  cat > "$HYPRPAPER" <<EOF
splash = false

wallpaper {
    monitor =
    path = $WALL
}
EOF
fi

# ------------------------------------------------------------ 6. system
step "System settings"
echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee /etc/zsh/zshenv >/dev/null
sudo usermod -aG seat,wheel "$USER"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "/usr/bin/zsh" ]; then
  sudo chsh -s /usr/bin/zsh "$USER"
fi

step "Services"
for unit in NetworkManager.service bluetooth.service cups.service cups.socket \
            cups.path power-profiles-daemon.service seatd.service \
            systemd-timesyncd.service fstrim.timer; do
  sudo systemctl enable "$unit" || { warn "could not enable $unit"; FAILED+=("$unit"); }
done
sudo systemctl disable "getty@$LY_TTY.service" 2>/dev/null || true
sudo systemctl enable "ly@$LY_TTY.service" || { warn "could not enable ly"; FAILED+=("ly@$LY_TTY.service"); }

# ---------------------------------------------------------------- 7. nvim
step "Neovim plugins (versions from lazy-lock.json)"
nvim --headless "+Lazy! restore" +qa 2>/dev/null || warn "plugin install will finish on first nvim start"

# -------------------------------------------------------------- 8. summary
step "Done"
if [ "${#FAILED[@]}" -gt 0 ]; then
  echo "These need a look:"
  printf '  - %s\n' "${FAILED[@]}"
else
  echo "Everything installed without errors."
fi
cat <<'EOF'

Left to do by hand:
  1. Reboot, pick Hyprland in ly and log in.
  2. Press SUPER+W once to choose a wallpaper.
  3. Open nvim once and wait for Mason to install the language servers.
  4. Restore ~/.ssh and ~/Documents/Writing from your private backups.
  5. Sign in to Proton Mail, Brave, Spotify and Claude.
EOF
