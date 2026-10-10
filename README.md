# dotfiles

My personal Arch Linux + Hyprland setup: configs, wallpapers, scripts and an
install script that rebuilds the whole thing on a new machine.

It is written for my own machines. You are welcome to browse it and take any
part you like: a config, a script, a wallpaper, or the whole setup.

## What is inside

| Path | Contents |
|---|---|
| `home/.config/` | Configs, linked into `~/.config` with GNU Stow |
| `scripts/` | `wallpaper.sh` (wallpaper picker + pywal colors), `writing.sh` (open a writing project in nvim) |
| `wallpapers/` | Wallpapers used by `wallpaper.sh` |
| `pkglist.txt` | Packages from the official Arch repos |
| `aurlist.txt` | Packages from the AUR |
| `install.sh` | Installs everything on a fresh Arch system |

Main pieces: Hyprland, waybar, rofi, dunst, kitty, zsh with starship, neovim
(with vimtex and LaTeX for writing), zathura, yazi, qutebrowser, newsraft.
Colors everywhere follow the wallpaper through pywal.

## Install on a fresh machine

### 1. Install Arch with `archinstall`

Pick these, leave the rest as you like:

- **Profile:** Minimal. No desktop is needed, the script installs Hyprland
  and everything else.
- **User:** create your user and make it a superuser (sudo).
- **Network:** NetworkManager.
- **Bootloader, disk, locale, keyboard, timezone:** your choice.

### 2. Run the script

Reboot, log in on the console as your user and get online
(`nmtui` for Wi-Fi). Then:

```bash
curl -O https://codeberg.org/offluencer/dotfiles/raw/branch/main/install.sh
bash install.sh
```

Run it as your normal user, not as root. It asks for your sudo password.
It is safe to run again if something fails halfway.

### 3. After it finishes

1. Reboot, choose Hyprland in the ly login screen and log in.
2. Press `SUPER + W` once to pick a wallpaper. This also generates the colors.
3. Open `nvim` once and wait while Mason installs the language servers.

## What the script does

1. Installs the packages from `pkglist.txt` and `aurlist.txt` (builds `yay` first).
2. Clones this repo to `~/dotfiles` and links the configs with Stow.
   Existing files that are in the way are moved to `~/config-backup-<date>`.
3. Runs pywal once so waybar, rofi, zathura, dunst and GTK have colors.
4. Sets zsh as the shell, writes `/etc/zsh/zshenv`, adds the user to the
   `seat` and `wheel` groups.
5. Enables NetworkManager, bluetooth, cups, power-profiles-daemon, seatd,
   time sync, fstrim and the ly login manager.
6. Installs the neovim plugins at the versions pinned in `lazy-lock.json`.

At the end it lists anything that failed.

## If you use this yourself

- The repo has to live in `~/dotfiles`. Some paths depend on it.
- `home/.config/git/config` contains my name and email. Change them.
- `install.sh` clones my repo. If you fork it, change `REPO_URL` at the top.
- The package list includes Intel, AMD and Nvidia open drivers, so it is not
  tied to my hardware.
- Arch is a rolling release, so you get current package versions, not the
  exact ones I had.
- The install script has not been tested on a fresh install yet. Try it in a
  virtual machine first (archinstall, Minimal profile, then the two commands
  above) and read it before you run it.

## Not included

Things that are private and stay out of a public repo: SSH keys, logins,
saved Wi-Fi networks and my writing. I restore those from my own backups.

## Keeping it up to date

```bash
cd ~/dotfiles
pacman -Qqen > pkglist.txt && pacman -Qqem > aurlist.txt
git add -A && git commit -m "Update" && git push
```

## Wallpapers

The wallpapers are images I collected. I did not make them, and the rights
belong to their authors. If one is yours and you want it removed, open an issue.
