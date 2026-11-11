# dotfiles

My personal Arch Linux + Hyprland setup: configs, wallpapers, scripts and an
install script that rebuilds the whole thing on a new machine.

> **This is my personal setup.** The install script gives you my whole system:
> my apps, configs, bookmarks, news feeds and wallpapers. If you want it as a
> starting point for your own, [fork it](https://github.com/offluencer-com/dotfiles/fork),
> remove what you don't need (see [Make it yours](#make-it-yours)) and install
> from your fork. You are also welcome to just take a single config or script.

## What is inside

| Path | Contents |
|---|---|
| `home/.config/` | Configs, linked into `~/.config` with GNU Stow |
| `scripts/` | `wallpaper.sh` (wallpaper picker + pywal colors), `writing.sh` (open a writing project in nvim), `commitgraph.sh` + `writingstats.sh` (GitHub graph and writing stats shown when a terminal opens) |
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
curl -O https://raw.githubusercontent.com/offluencer-com/dotfiles/main/install.sh
bash install.sh
```

Run it as your normal user, not as root. It asks for your sudo password.
It is safe to run again if something fails halfway.

### 3. After it finishes

1. Reboot, choose Hyprland in the ly login screen and log in.
2. Press `SUPER + W` once to pick a wallpaper. This also generates the colors.
3. Open `nvim` once and wait while Mason installs the language servers.
4. Run `gh auth login` so the GitHub graph in the terminal fills in.

## What the script does

1. Installs the packages from `pkglist.txt` and `aurlist.txt` (builds `yay` first).
2. Clones this repo to `~/dotfiles` and links the configs with Stow.
   Existing files that are in the way are moved to `~/config-backup-<date>`.
   Asks for your git name and email and saves them in `~/.gitconfig`, outside
   the repo.
3. Runs pywal once so waybar, rofi, zathura, dunst and GTK have colors.
4. Sets zsh as the shell, writes `/etc/zsh/zshenv`, adds the user to the
   `seat` and `wheel` groups.
5. Enables NetworkManager, bluetooth, cups, power-profiles-daemon, seatd,
   time sync, fstrim and the ly login manager.
6. Installs the neovim plugins at the versions pinned in `lazy-lock.json`.

At the end it lists anything that failed.

## Make it yours

1. Fork the repo on GitHub.
2. In your fork, change `REPO_URL` at the top of `install.sh` and the `curl`
   link above to point to your fork.
3. Remove what you don't want: apps from `pkglist.txt` and `aurlist.txt`,
   my bookmarks (`home/.config/qutebrowser/`), news feeds
   (`home/.config/newsraft/feeds`), wallpapers, and the GitHub user in
   `scripts/commitgraph.sh`.
4. Install from your fork.

Things to know:

- The repo has to live in `~/dotfiles`. Some paths depend on it.
- Your git name and email are never taken from this repo. The script asks
  for yours.
- The writing stats read `~/Documents/Writing`. Without that folder they
  stay empty.
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
