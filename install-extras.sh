#!/bin/bash
# Restore the original desktop's appearance with pinned upstream sources.
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
data_home=${XDG_DATA_HOME:-$HOME/.local/share}
state_home=${XDG_STATE_HOME:-$HOME/.local/state}
backup="$state_home/niri-extras-backup"
prefix="$data_home/niri-extras"
mode=${1:-install}
packages=(gcc meson ninja-build pkgconf-pkg-config wayland-devel wayland-protocols-devel
  libxkbcommon-devel cairo-devel gdk-pixbuf2-devel pam-devel libxcrypt-devel cargo rust
  lz4-devel sassc gum zsh fzf eza google-noto-serif-cjk-fonts)
case "$mode" in
  --dry-run)
    printf 'Dependencies:'; printf ' %q' sudo dnf install "${packages[@]}"; printf '\n'
    echo 'Would build swaylock-effects and awww; install Starship, Zinit, Colloid themes and Nerd Fonts.'
    echo 'Would install pwvucontrol from Flathub, configure Zsh for Alacritty, and apply the desktop theme.'
    echo "Would back up modified user files and theme settings in $backup."
    echo 'Firefox needs browser confirmation; Spotify is excluded. No changes made.'
    exit 0 ;;
  --rollback|--rollback-dry-run)
    action=restore; [[ $mode == --rollback-dry-run ]] && action=preview
    exec python3 "$source_dir/extras/state.py" "$action" "$backup" ;;
  install|--skip-packages) ;;
  *) echo 'Usage: ./install-extras.sh [--dry-run|--skip-packages|--rollback|--rollback-dry-run]'; exit 1 ;;
esac
(( EUID != 0 )) || { echo 'Run as your desktop user, without sudo.' >&2; exit 1; }
[[ -d $config_home/niri-setup ]] || { echo 'Run setup.sh first.' >&2; exit 1; }
[[ $(uname -m) == x86_64 ]] || { echo 'This extras installer currently requires x86_64.' >&2; exit 1; }
if [[ $mode != --skip-packages ]]; then
  sudo dnf install "${packages[@]}"
fi
for tool in gcc meson ninja cargo sassc gum zsh curl git python3 flatpak gsettings; do
  command -v "$tool" >/dev/null || { echo "Missing dependency: $tool" >&2; exit 1; }
done
[[ -f /etc/pam.d/swaylock ]] || { echo 'Install the Fedora swaylock package for its PAM configuration.' >&2; exit 1; }
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fetch() {
  git init -q "$stage/$1"
  git -C "$stage/$1" fetch -q --depth 1 "$2" "$3"
  git -C "$stage/$1" checkout -q --detach FETCH_HEAD
}
fetch lock https://github.com/DRAGONTOS/swaylock-effects.git e4217804364e381f6d9d9f0480dfa273e5e84a1c
fetch awww https://codeberg.org/LGFae/awww.git 25ea4fd7a42359379da9ddadedda1c477caa4ae0
fetch gtk https://github.com/vinceliuice/Colloid-gtk-theme.git fe11342f37f124f1b29d44cf33e9a06053f4bba2
fetch icons https://github.com/vinceliuice/Colloid-icon-theme.git ceac6608ecd0e40025cbc2ebbd32bf0e0f4ebc6a
fetch zinit https://github.com/zdharma-continuum/zinit.git c182cc5d0d72c960ab8320d48723e9169a46f1f2
meson setup "$stage/lock/build" "$stage/lock" -Dpam=enabled -Dman-pages=disabled
meson compile -C "$stage/lock/build"
(cd "$stage/awww" && cargo build --release --locked)
mkdir -p "$stage/payload/bin" "$stage/themes" "$stage/icons"
cp "$stage/lock/build/swaylock" "$stage/payload/bin/swaylock-effects"
cp "$stage/awww/target/release/awww" "$stage/awww/target/release/awww-daemon" "$stage/payload/bin/"
cp -a "$stage/zinit" "$stage/payload/zinit"
curl -fL --retry 2 https://github.com/starship/starship/releases/download/v1.26.0/starship-x86_64-unknown-linux-musl.tar.gz -o "$stage/starship.tar.gz"
curl -fL --retry 2 https://github.com/starship/starship/releases/download/v1.26.0/starship-x86_64-unknown-linux-musl.tar.gz.sha256 -o "$stage/starship.sha256"
expected=$(awk '{print $1}' "$stage/starship.sha256")
printf '%s  %s\n' "$expected" "$stage/starship.tar.gz" | sha256sum -c -
tar -xzf "$stage/starship.tar.gz" -C "$stage/payload/bin" starship
bash "$stage/gtk/install.sh" -d "$stage/themes" -t grey -c dark
bash "$stage/icons/install.sh" -d "$stage/icons"
# Back up once; repeated installs keep the true pre-extras state.
mkdir -p "$state_home"
python3 "$source_dir/extras/state.py" backup "$backup" \
  "$prefix" "$data_home/themes/Colloid-Grey-Dark" \
  "$data_home/icons/Colloid" "$data_home/icons/Colloid-Dark" "$data_home/icons/Colloid-Light" \
  "$config_home/gtk-3.0/settings.ini" "$config_home/gtk-4.0" \
  "$HOME/.zshrc" "$config_home/starship.toml" "$config_home/niri-setup" \
  "$data_home/fonts/niri-setup"
mkdir -p "$prefix" "$data_home/themes" "$data_home/icons" "$config_home/gtk-3.0"
cp -a "$stage/payload/." "$prefix/"
cp -a "$stage/themes/." "$data_home/themes/"
cp -a "$stage/icons/." "$data_home/icons/"
bash "$source_dir/install-fonts.sh" UbuntuMono JetBrainsMono Ubuntu
cp "$source_dir/extras/zshrc" "$HOME/.zshrc"
cp "$source_dir/extras/starship.toml" "$config_home/starship.toml"
python3 - "$source_dir" "$config_home" "$data_home" <<'PY'
import configparser
from pathlib import Path
import shutil
import sys
source, config, data = map(Path, sys.argv[1:])
installed = config / 'niri-setup'
# Update only the changed desktop files; preserve monitor settings and wallpapers.
files = ['scripts/swaylock.sh', 'scripts/start-wallpaper.sh', 'scripts/start-backdrop.sh',
         'scripts/change-wallpaper.sh', 'scripts/audio-control.sh', 'niri/wallpapers.kdl']
for relative in files:
    original = source / relative
    dest = installed / relative
    dest.write_text(original.read_text().replace('$NIRICONF', str(installed)))
    shutil.copymode(original, dest)
modules = installed / 'waybar/modules.jsonc'
text = modules.read_text().replace('"on-click": "pavucontrol"',
                                  f'"on-click": "{installed}/scripts/audio-control.sh"')
modules.write_text(text)
for name in ('default.toml', 'float.toml'):
    path = installed / 'alacritty' / name
    text = path.read_text()
    if '[terminal.shell]' not in text and '[shell]' not in text:
        path.write_text(text + '\n[terminal.shell]\nprogram = "/usr/bin/zsh"\n')
settings = config / 'gtk-3.0/settings.ini'
parser = configparser.ConfigParser()
parser.read(settings)
if not parser.has_section('Settings'):
    parser.add_section('Settings')
parser['Settings'].update({'gtk-theme-name': 'Colloid-Grey-Dark', 'gtk-icon-theme-name': 'Colloid',
                          'gtk-font-name': 'Ubuntu Nerd Font 12', 'gtk-application-prefer-dark-theme': 'true'})
with settings.open('w') as handle:
    parser.write(handle)
gtk4 = config / 'gtk-4.0'
gtk4.mkdir(exist_ok=True)
for name in ('gtk.css', 'gtk-dark.css'):
    path = gtk4 / name
    if path.is_symlink():
        path.unlink()
    uri = (data / 'themes/Colloid-Grey-Dark/gtk-4.0' / name).as_uri()
    path.write_text(f'@import url("{uri}");\n')
PY
gsettings set org.gnome.desktop.interface gtk-theme Colloid-Grey-Dark
gsettings set org.gnome.desktop.interface icon-theme Colloid
gsettings set org.gnome.desktop.interface font-name 'Ubuntu Nerd Font 12'
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub com.saivert.pwvucontrol
niri validate --config "$config_home/niri/config.kdl"
echo 'Desktop extras installed. Log out and back in; open a new terminal for Zsh.'
echo 'Zinit downloads its three shell plugins on first launch.'
echo 'Firefox: enable Dark space at https://addons.mozilla.org/firefox/addon/nicothin-space/'
echo 'Rollback: bash install-extras.sh --rollback (Flatpak apps and RPMs are retained).'
