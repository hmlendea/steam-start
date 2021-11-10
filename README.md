[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/fund.html) [![Build Status](https://github.com/hmlendea/steam-start/actions/workflows/bash.yml/badge.svg)](https://github.com/hmlendea/steam-start/actions/workflows/bash.yml) [![Latest GitHub release](https://img.shields.io/github/v/release/hmlendea/steam-start)](https://github.com/hmlendea/steam-start/releases/latest)

# About

Script for launching Steam with compatibility fixes and support for Nvidia OPTIMUS.

# Installation

## Arch Linux

Install it using [this PKGBUILD](https://github.com/hmlendea/PKGBUILDs/tree/master/pkg/repo-synchroniser).

## Other distros

Copy `steam-start.sh` to `/usr/bin/steam-start` and make it executable:
```bash
cp "steam-start.sh" "/usr/bin/steam-start"
chmod +x "/usr/bin/steam-start"
```

# Usage

Simply run `steam-start` and Steam will start using this script.

**Note**: You can edit Steam's desktop file _(e.g. /usr/share/applications/steam.desktop)_ to use `steam-start` as it's `Exec` command, so that clicking the Steam icon on your desktop will use this script
