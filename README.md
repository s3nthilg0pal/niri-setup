- **Window Manager •** [niri](https://github.com/YaLTeR/niri)
- **Launcher •** [Fuzzel](https://codeberg.org/dnkl/fuzzel)
- **Panel •** [Waybar](https://github.com/Alexays/Waybar)
- **Panel Font •** [Ubuntu Mono Nerd Font](https://www.nerdfonts.com/font-downloads) + [Noto Sans Mono CJK TC](https://fonts.google.com/noto)
- **Notification •** [dunst](https://github.com/dunst-project/dunst)
- **Clipboard Manager •** [cliphist](https://github.com/sentriz/cliphist)
- **Wallpaper Engine •** [swaybg](https://github.com/swaywm/swaybg) + optional [awww](https://codeberg.org/LGFae/awww) (for overview)
- **Idle Daemon •** [swayidle](https://github.com/swaywm/swayidle)
- **Lock Screen •** [swaylock](https://github.com/swaywm/swaylock)
- **Logout Menu •** [wlogout](https://github.com/ArtsyMacaw/wlogout)
- **Fonts •** [Ubuntu](https://design.ubuntu.com/font) + [Noto Sans/Serif CJK TC](https://fonts.google.com/noto)
- **Theme •** [Colloid-gtk-theme](https://github.com/vinceliuice/Colloid-gtk-theme)
- **Icons •** [Colloid-icon-theme](https://github.com/vinceliuice/Colloid-icon-theme)
- **Cursor •** [Adwaita](https://github.com/GNOME/adwaita-icon-theme)
- **Terminal •** [Alacritty](https://github.com/alacritty/alacritty)
- **Terminal Font •** [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)
- **Shell •** [zsh](https://www.zsh.org/) + [zinit](https://github.com/zdharma-continuum/zinit) + [starship](https://github.com/starship/starship)
- **Spicetify Theme •** [Ziro (Gray Dark)](https://github.com/spicetify/spicetify-themes/tree/master/Ziro#gray-dark)
- **Firefox Theme •** [Dark space](https://addons.mozilla.org/en-US/firefox/addon/nicothin-space/)

# Screenshots

![screenshot1](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot1.png)

![screenshot2](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot2.png)

![screenshot3](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot3.png)

![screenshot4](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot4.png)

![screenshot5](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot5.png)

![screenshot6](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot6.png)

![screenshot7](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot7.png)

# Features

> [!NOTE]
> This niri configuration is up to date to: [niri v25.11](https://github.com/YaLTeR/niri/releases/tag/v25.11)

- Empower niri with waybar, fuzzel, dunst, swaylock, and more - A full experience!
- Idle time and power profile picker available as waybar widgets and fuzzel menus
- A wallpaper switching script that creates blurred overview backdrop at the same time
- A curated color palette smoothly applied across the setup
- A clean and minimalistic UI you cannot resist to daily drive

# Installation on Fedora

This port targets conventional, DNF-based Fedora with **niri 25.11 or newer**
(Fedora 44 or newer recommended). Fedora Atomic desktops are not supported by
this installer. Run as your normal desktop user:

```bash
./setup.sh
```

The script uses `sudo dnf install`, validates the configuration, copies it to
`~/.config/niri-setup`, and links `~/.config/niri` to that copy. Existing setup
and niri directories are backed up with timestamped `.backup-*` suffixes.
`XDG_CONFIG_HOME` is respected. Configuration paths must not contain spaces or
shell metacharacters. The checkout is left unchanged.

Use `./setup.sh --skip-install` if dependencies are already installed. A failed
package installation or validation stops setup before replacing your configuration.
Rerunning setup replaces the installed copy, preserving it as a backup; edit
`~/.config/niri-setup` for local customization.

Preview setup without installing packages or writing configuration:

```bash
./dryrun.sh                     # equivalent to ./setup.sh --dry-run
./dryrun.sh --skip-install      # preview configuration changes only
```

The preview prints planned actions; it does not resolve DNF dependencies or run
configuration validation.

To restore the configuration from before setup, run as your normal user:

```bash
./rollback.sh --dry-run         # inspect the restoration plan
./rollback.sh                  # undo all recorded setup runs
./rollback.sh --once            # alternatively, undo just the latest run
```

Rollback restores original directories or symlinks, including restoring their
absence on a fresh installation. It archives replaced files in
`~/.config/niri-rollback-*` and checks all required backups before changing files.
Log out and select your previous desktop afterward. Installed RPMs and runtime
state, such as the idle timer, are retained; this is a configuration rollback,
not a system/package snapshot. Rollback uses metadata written by this version
of setup. Older installations without `.rollback.json` require manual restoration
from their `.backup-*` directories. Keep those backups until you no longer need
rollback. `XDG_CONFIG_HOME` is respected by all three scripts.

Log out and choose **niri** from the login screen, or run `niri-session` from a
TTY. Review `~/.config/niri/outputs.kdl` for your monitor layout. The supplied
output names, resolution, and positions are examples from the original machine.

Fedora-specific changes:

- DNF handles the update widget and Super+U (RPM updates only, not Flatpaks or
  Fedora release upgrades). Checks run every 30 minutes.
- Standard `swaylock` uses a solid background; screenshot blur and clock effects
  from `swaylock-effects` are not required. The logout menu uses the same locker.
- `lxpolkit` handles authentication and `pavucontrol` provides audio controls.
- Fedora's `tuned-ppd` supplies power-profile integration, unless
  `power-profiles-daemon` is already installed.
- Fuzzel selects wallpapers from `~/Pictures/wallpapers`; ImageMagick prepares
  them and swaybg displays them in fill mode. The blurred overview backdrop is
  optional: install `awww` and `awww-daemon` separately to enable it, then log in
  again. Setup does not enable third-party repositories.
- Noto and Font Awesome fonts are installed as fallbacks. Run `bash install-fonts.sh`
  to install Ubuntu Mono Nerd Font for the bar and launcher, then press Super+W
  twice to restart Waybar. The helper downloads Nerd Fonts v3.4.0 from upstream
  GitHub into your user font directory; rollback leaves these fonts installed.
  For the exact original
  appearance, install Ubuntu Mono and JetBrains Mono from
  [Nerd Fonts](https://www.nerdfonts.com/font-downloads). Some Nerd Font glyphs
  require these fonts. Colloid themes/icons and shell customizations are optional
  and are not installed by this script.

Package references: [Fedora niri](https://packages.fedoraproject.org/pkgs/niri/niri/),
[Fedora swaylock](https://packages.fedoraproject.org/pkgs/swaylock/swaylock/), and
[Fedora power-profile integration](https://fedoraproject.org/wiki/Changes/TunedAsTheDefaultPowerProfileManagementDaemon).

Validation: shell syntax checks and `python3 -B -m unittest discover -s tests -v`
cover installer backups, reruns, validation/package failures, and update status
handling. The generated configuration also passes `niri validate` with Fedora's
niri 26.04 package. A full graphical session has not been tested.

For the dotfiles of the following programs, please refer to [my dotfiles repo](https://github.com/acaibowlz/dotfiles).

- `fastfetch`
- `fontconfig`
- `spicetify`
- `starship`
- `zsh`

# Keybindings

## Applications

| Keys                                                  | Action                    |
| :---------------------------------------------------- | :------------------------ |
| <kbd>Super</kbd> + <kbd>Enter</kbd>                   | Open terminal             |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Enter</kbd> | Open launcher             |
| <kbd>Super</kbd> + <kbd>B</kbd>                       | Open firefox              |
| <kbd>Super</kbd> + <kbd>E</kbd>                       | Open nautilus             |
| <kbd>Super</kbd> + <kbd>L</kbd>                       | Launch lock screen        |
| <kbd>Super</kbd> + <kbd>C</kbd>                       | Launch clipboard menu     |
| <kbd>Super</kbd> + <kbd>I</kbd>                       | Launch idle time menu     |
| <kbd>Super</kbd> + <kbd>P</kbd>                       | Launch power profile menu |
| <kbd>Super</kbd> + <kbd>U</kbd>                       | Launch updater            |
| <kbd>Super</kbd> + <kbd>W</kbd>                       | Toggle waybar             |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>W</kbd>     | Launch wallpaper selector |
| <kbd>Super</kbd> + <kbd>Backspace</kbd>               | Launch logout screen      |

## Backlight and Audio

| Keys                             | Action                    |
| :------------------------------- | :------------------------ |
| <kbd>XF86MonBrightnessUp</kbd>   | Increase brightness by 5% |
| <kbd>XF86MonBrightnessDown</kbd> | Decrease brightness by 5% |
| <kbd>XF86AudioRaiseVolume</kbd>  | Raise volume by 5%        |
| <kbd>XF86AudioLowerVolume</kbd>  | Lower volume by 5%        |
| <kbd>XF86AudioMute</kbd>         | Toggle mute               |
| <kbd>XF86AudioPlay</kbd>         | Play or pause media       |
| <kbd>XF86AudioNext</kbd>         | Next media track          |
| <kbd>XF86AudioPrev</kbd>         | Previous media track      |

## Windows and Columns

| Keys                                                   | Action                                                                   |
| :----------------------------------------------------- | :----------------------------------------------------------------------- |
| <kbd>Super</kbd> + <kbd>Q</kbd>                        | Close window                                                             |
| <kbd>Super</kbd> + <kbd>W</kbd>                        | Switch preset column width                                               |
| <kbd>Super</kbd> + <kbd>H</kbd>                        | Switch preset window height                                              |
| <kbd>Super</kbd> + <kbd>T</kbd>                        | Toggle window floating                                                   |
| <kbd>Super</kbd> + <kbd>M</kbd>                        | Toggle maximize mode                                                     |
| <kbd>Super</kbd> + <kbd>F</kbd>                        | Toggle fullscreen mode                                                   |
| <kbd>Super</kbd>+ <kbd>Left</kbd>                      | Focus column on the left                                                 |
| <kbd>Super</kbd>+ <kbd>Right</kbd>                     | Focus column on the right                                                |
| <kbd>Super</kbd>+ <kbd>Down</kbd>                      | Focus window downward                                                    |
| <kbd>Super</kbd>+ <kbd>Up</kbd>                        | Focus window upward                                                      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Left</kbd>   | Move column to the left                                                  |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Right</kbd>  | Move column to the right                                                 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Down</kbd>   | Move window downward                                                     |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Up</kbd>     | Move window upward                                                       |
| <kbd>Super</kbd> + <kbd>Home</kbd>                     | Focus the first column                                                   |
| <kbd>Super</kbd> + <kbd>End</kbd>                      | Focus the last column                                                    |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Home</kbd>   | Move column to the first                                                 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>End</kbd>    | Move column to the last                                                  |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Left</kbd>  | Resize column width by -10%                                              |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Right</kbd> | Resize column width by +10%                                              |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Up</kbd>    | Resize window height by -10%                                             |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Down</kbd>  | Resize window height by +10%                                             |
| <kbd>Super</kbd> + <kbd>BracketLeft</kbd>              | Consume from/expel to the column on the left                             |
| <kbd>Super</kbd> + <kbd>BracketRight</kbd>             | Consume from/expel to the column on the right                            |
| <kbd>Super</kbd> + <kbd>Comma</kbd>                    | Consume window from the right </br>into the bottom of the focused column |
| <kbd>Super</kbd> + <kbd>Period</kbd>                   | Expel the bottom window from </br>the focused column to the right        |
| <kbd>Alt</kbd> + <kbd>Tab</kbd>                        | Switch between recent windows                                            |

## Workspaces

| Keys                                                     | Action                          |
| :------------------------------------------------------- | :------------------------------ |
| <kbd>Super</kbd> + <kbd>PageDown</kbd>                   | Focus workspace downward        |
| <kbd>Super</kbd> + <kbd>PageUp</kbd>                     | Focus workspace upward          |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>PageDown</kbd> | Move column downward            |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>PageUp</kbd>   | Move column upward              |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>[0-9]</kbd>    | Move column to workspace [1-10] |
| <kbd>Super</kbd> + <kbd>A</kbd>                          | Toggle overview                 |

## Screenshot

| Keys                                | Action               |
| :---------------------------------- | :------------------- |
| <kbd>Print</kbd>                    | Screenshot (region)  |
| <kbd>Ctrl</kbd> + <kbd>Print</kbd>  | Screenshot (window)  |
| <kbd>Shift</kbd> + <kbd>Print</kbd> | Screenshot (monitor) |
