# Environment Setup

Personal dotfiles and setup scripts for getting a dev environment running on a new machine in one command. Mostly so I don't have to remember what tools I use every time I switch machines.

Currently bouncing between macOS and Arch Linux. Recently moved from WSL to a proper Arch setup with Hyprland (still figuring out Wayland quirks but it's been pretty smooth).

## What's Included

- ZSH configuration with custom aliases and functions
- Oh My Posh theme and configuration
- Micro editor settings
- Ghostty terminal configuration
- Yabai window manager configuration (macOS)
- Hyprland window manager configuration (Linux/Wayland)
- Rofi application launcher configuration
- Ashell configuration

## Installation

Clone the repo:
```bash
git clone https://github.com/joshuaisaact/env-setup.git
cd env-setup
```

Then run the script for your system:

**macOS:**
```bash
./mac.sh
```

**Arch Linux:**
```bash
./arch-linux.sh
```

**Other Linux (Ubuntu/Debian/Fedora):**
```bash
./linux.sh
```

Scripts will backup your existing configs before copying anything over.
