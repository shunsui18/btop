<div align="center">

<img src="https://github.com/shunsui18/yozakura/blob/main/icon.png?raw=true" alt="Yozakura" width="100"/>

# 夜桜 Yozakura — btop Theme

A handcrafted pastel color palette for [btop++](https://github.com/aristocratos/btop), based on the [Yozakura](https://github.com/shunsui18/yozakura) palette.

[![License: MIT](https://img.shields.io/badge/License-MIT-pink?style=flat-square)](LICENSE)
[![btop](https://img.shields.io/badge/btop++-1.4.6+-lavender?style=flat-square)](https://github.com/aristocratos/btop)
[![Shell](https://img.shields.io/badge/shell-bash-89b4fa?style=flat-square&logo=gnubash&logoColor=white)](install.sh)
[![Palette](https://img.shields.io/badge/palette-yozakura-ffb7c5?style=flat-square)](https://github.com/shunsui18/yozakura)

</div>

---

## ✦ Flavors

| | Flavor | Description |
|---|---|---|
| 🌸 | **Yoru** *(night)* | Deep, moonlit background with soft sakura accents — default |
| ☀️ | **Hiru** *(day)* | Warm ivory canvas with gentle pastel tones |

---

## ✦ Installation

### One-liner

Install directly from this repository with a single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/shunsui18/btop/main/install.sh)
```

> This runs with **Yoru** flavor and `theme_background = true` by default.

---

### Options

| Flag | Values | Default | Description |
|---|---|---|---|
| `--theme` | `yoru` \| `hiru` | `yoru` | Which flavor to activate |
| `--bg` | `true` \| `false` | `true` | Set `theme_background` in btop.conf |
| `-h`, `--help` | — | — | Show help |

---

### Examples

```bash
# Yoru (night) — background on
bash <(curl -fsSL https://raw.githubusercontent.com/shunsui18/btop/main/install.sh) --theme yoru --bg true

# Hiru (day) — no background (use terminal transparency)
bash <(curl -fsSL https://raw.githubusercontent.com/shunsui18/btop/main/install.sh) --theme hiru --bg false
```

---

### Manual Installation

If you prefer to install by hand:

```bash
# 1. Clone the repo
git clone https://github.com/shunsui18/btop.git && cd btop

# 2. Run the installer
./install.sh --theme yoru --bg true
```

---

## ✦ What the Installer Does

1. **Self-locates** — resolves its own path regardless of where it is called from or whether it is symlinked
2. **Validates** — confirms the requested theme file exists before touching anything
3. **Copies** all `yozakura-*.theme` files into `$HOME/.config/btop/themes/`, creating the directory if needed
4. **Patches** `$HOME/.config/btop/btop.conf`:
   - Sets `color_theme` to the full absolute path btop expects
   - Sets `theme_background` to your chosen value
   - Appends either key if it is missing from the config entirely
5. **Fails gracefully** — descriptive `[error]` messages if the config is missing, arguments are wrong, or a theme file is not found

> **Note:** btop must have been launched at least once so that `btop.conf` exists before running the installer.

---

## ✦ File Structure

```
btop/
├── themes/
│   ├── yozakura-yoru.theme
│   └── yozakura-hiru.theme
├── install.sh
└── README.md
```

---

<div align="center">

crafted with 🌸 by [shunsui18](https://github.com/shunsui18)

</div>