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
> This configuration requires [niri v26.04](https://github.com/niri-wm/niri/releases/tag/v26.04) or newer.

- Empower niri with waybar, fuzzel, dunst, swaylock, and more - A full experience!
- Idle time and power profile picker available as waybar widgets and fuzzel menus
- A wallpaper switching script that creates blurred overview backdrop at the same time
- A curated color palette smoothly applied across the setup
- A clean and minimalistic UI you cannot resist to daily drive

# Installation on Fedora

This port targets conventional, DNF-based Fedora with **niri 26.04 or newer**
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

## Original appearance and desktop extras

After the base setup, run:

```bash
bash install-extras.sh --dry-run
bash install-extras.sh
```

Run as your normal user; the installer asks sudo for Fedora build dependencies.
It currently supports x86_64 and downloads pinned upstream sources. Builds can
use several gigabytes of disk and take several minutes. It installs:

- **swaylock-effects:** screenshot blur, vignette, clock, and date. The custom
  binary uses the existing Fedora swaylock PAM configuration. Standard swaylock
  remains available as a fallback.
- **awww:** the blurred overview backdrop, with the existing swaybg workspace
  wallpaper. Gum selects wallpapers and all five modes (stretch, fill, fit,
  center, tile); the selected mode persists across logins.
- **pwvucontrol:** the upstream-recommended Flatpak from Flathub. The bar opens
  it when installed and otherwise falls back to pavucontrol.
- **Fonts:** Ubuntu Mono Nerd Font, JetBrains Mono Nerd Font, Ubuntu Nerd Font,
  and Noto Serif CJK fonts.
- **Colloid-Grey-Dark and Colloid icons:** GTK3/GTK4 styling and desktop font
  settings. GTK4 applications may vary in how they support custom styles.
- **Zsh, Zinit, and Starship:** Alacritty opens Zsh; plugins provide suggestions,
  highlighting, and FZF completion. The shell uses Fedora package commands and
  a prompt matching the desktop palette. Zinit fetches plugins on first launch.
  This is an adapted shell configuration, not a copy of the author's personal
  aliases. Your login shell remains unchanged.

The installer backs up the files and GSettings it changes in
`~/.local/state/niri-extras-backup`. It preserves your monitor settings and
wallpaper images. Repeated runs retain the first backup. To undo the extras:

```bash
bash install-extras.sh --rollback-dry-run
bash install-extras.sh --rollback
```

Undo extras **before** running the base `rollback.sh`. Restored files and theme
settings return to their pre-extras state. RPMs, Flatpak apps, and downloaded
Zinit plugins remain installed. Files replaced during rollback are archived.

For Firefox, visit [Dark space](https://addons.mozilla.org/firefox/addon/nicothin-space/)
and click **Install Theme**, then confirm Firefox's prompt. This requires a
browser interaction; the installer does not edit browser profile databases.
Spotify/Spicetify are deliberately excluded from this port's extras installer.

The base installer uses DNF updates, LXPolkit, and Fedora's tuned-ppd power-profile
integration. The update widget covers RPMs, not Flatpaks or Fedora release
upgrades. `install-extras.sh --skip-packages` skips DNF when its build dependencies
are already installed. A normal base setup rerun restores the base configuration;
rerun the extras installer afterward to reapply the extras.

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

## Background blur

Press **Super + Ctrl + B** to select Off, Low, Medium, or High. The default is
Medium. This controls compositor blur behind Alacritty, Waybar, and Fuzzel;
applications must have a transparent background for the effect to be visible.
The Off preset also disables protocol-requested blur globally.

The menu updates `~/.config/niri/blur.kdl`; niri reloads the setting immediately.
For manual tuning, change `passes`, `offset`, `noise`, and `saturation` there.
`xray true` blurs the wallpaper; `xray false` blurs the content behind the surface
and costs more GPU work. Selecting a preset overwrites manual changes in that
file. Lock-screen blur and the pre-blurred overview image are separate controls.
See [niri's blur settings](https://niri-wm.github.io/niri/Configuration:-Miscellaneous.html#blur).

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
