# Cider (Apple Music Client)

Cider is a beautiful, open-source Apple Music client for Linux.

## Prerequisites

Before the installation script can install Cider, you must:

1. **Purchase Cider** from one of these sources:
   - Official website: https://cider.sh/
   - Itch.io: https://cidercollective.itch.io/cider
   
2. **Download the Linux package**:
   - Look for a file named like `cider-*-linux-x64.pkg.tar.zst`
   - Any version is acceptable (the script auto-detects)

3. **Place the downloaded file in `~/Downloads/`**:
   ```bash
   mv ~/Downloads/cider-*-linux-x64.pkg.tar.zst ~/Downloads/
   ```

## Installation

The installation script will:
- Detect the Cider package in `~/Downloads/`
- Install it using `sudo pacman -U`
- Make it available in the system

## Usage

Once installed:
- Launch with `SUPER+SHIFT+M` (custom keybinding)
- Or find it in the app launcher (SUPER+SPACE)
- Sign in with your Apple ID

## Note

Cider requires a purchase to download. This supports the developers who maintain this excellent open-source application.

## Troubleshooting

**Package not found error:**
- Ensure the `.pkg.tar.zst` file is in `~/Downloads/`
- The script looks for files matching `cider-*-linux-x64.pkg.tar.zst`

**Installation fails:**
- Check that you have sudo access
- Verify the downloaded file is not corrupted
- Try manually installing with: `sudo pacman -U ~/Downloads/cider-*.pkg.tar.zst`

## Updates

Cider will prompt you when updates are available within the application.
