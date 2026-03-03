# Omarchy Customization Checklist

Complete this checklist before and after running the customization scripts.

> **System Requirements**: These scripts are designed for Omarchy 3.4.1+ with Limine bootloader.

## Pre-Installation Tasks

### Required Before Running Scripts

- [ ] **Purchase and download Cider**
  - Visit: https://cider.sh/ or https://cidercollective.itch.io/cider
  - Purchase Cider (supports the developers!)
  - Download the Linux `.pkg.tar.zst` package
  - Place the downloaded file in `~/Downloads/`
  - Any version is acceptable (script auto-detects)

- [ ] **Subscribe to and download PIA VPN** (if you want VPN installed)
  - Visit: https://www.privateinternetaccess.com/
  - Subscribe to PIA VPN
  - Download the Linux `.run` installer from: https://www.privateinternetaccess.com/download/linux-vpn
  - Place the downloaded file in `~/Downloads/`
  - Any version is acceptable (script auto-detects)

### Optional (but Recommended)

- [ ] Ensure stable internet connection
- [ ] Connect to power source (for hibernation setup)
- [ ] Review `configs/` directory and customize as desired:
  - [ ] `configs/hypr/custom-overrides.conf` - Keybindings
  - [ ] `configs/hypr/window-rules.conf` - Window rules
  - [ ] `configs/systemd/sleep.conf.d/99-custom-sleep.conf` - Sleep settings
  - [ ] `configs/systemd/logind.conf.d/99-custom-lid.conf` - Lid behavior
- [ ] Run `./install.sh --dry-run` to preview changes

## Post-Installation Tasks

### Authentication & Setup (in recommended order)

1. [ ] **1Password** 
   - Launch 1Password
   - Authenticate with your account
   - This enables password management across apps

2. [ ] **Chromium Browser**
   - Launch Chromium
   - Sign into your Google account
   - Sign into GitHub
   - Sign into any other services you use
   - This enables seamless authentication for web apps

3. [ ] **t3.chat**
   - Press `SUPER+SHIFT+A` to launch t3.chat
   - Sign in with your account
   - Verify it replaced the ChatGPT binding

4. [ ] **GitHub CLI**
   - Open a terminal
   - Run: `gh auth login`
   - Follow the authentication prompts

5. [ ] **OpenCode**
   - If you have an OpenCode account, authenticate now
   - This enables AI assistance in the terminal

6. [ ] **Private Internet Access VPN**
   - Launch PIA VPN: `piavpn` or find it in the app launcher
   - Log in with your PIA credentials
   - Configure auto-connect (see [docs/VPN_SETUP.md](docs/VPN_SETUP.md))
   - Test the connection

### Verification Steps

- [ ] **Cider**
  - Press `SUPER+SHIFT+M` to launch Cider
  - Should open Apple Music client (not Spotify)
  - Sign in with your Apple ID

- [ ] **t3.chat**
  - Press `SUPER+SHIFT+A` to launch
  - Should open t3.chat web app
  - Verify it replaced ChatGPT

- [ ] **Suspend on Battery**
  - Unplug laptop from AC power
  - Close the lid
  - Wait 10 seconds
  - Open lid - should require password (was suspended)

- [ ] **No Suspend on AC**
  - Plug laptop into AC power
  - Connect external monitor (if available)
  - Close the lid
  - External monitor should remain active
  - Open lid - should not require password

- [ ] **Theme Verification**
  - Current theme should be Ethereal
  - Run: `omarchy-theme-current` to verify
  - All extra themes should be installed
  - Run: `omarchy-theme-list` to see available themes

- [ ] **Power Profile Switching**
  - Unplug laptop - should switch to power-saver
  - Plug in laptop - should switch to performance
  - Check with: `powerprofilesctl get`

- [ ] **Syncthing**
  - Access web UI: http://localhost:8384
  - Verify service is running: `systemctl --user status syncthing`
  - See [docs/SYNCTHING_SETUP.md](docs/SYNCTHING_SETUP.md) for device pairing

### System Verification

- [ ] Check installation log for any failures:
  ```bash
  cat ~/.local/share/omarchy-customization/logs/latest.log
  ```

- [ ] Review summary file:
  ```bash
  cat ~/.local/share/omarchy-customization/logs/latest-summary.txt
  ```

- [ ] Restart if prompted by the installer

## Optional Customizations

After initial setup, you may want to:

- [ ] **Add custom wallpapers**
  - Place images in `~/.config/omarchy/wallpapers/`
  - Use `omarchy-theme-bg-next` to cycle through them

- [ ] **Customize keybindings further**
  - Edit: `~/.config/hypr/custom-overrides.conf`
  - Add your own bindings
  - Use `unbind` before rebinding existing keys

- [ ] **Configure window rules**
  - Edit: `~/.config/hypr/window-rules.conf`
  - Set specific apps to open on certain workspaces
  - Configure floating windows

- [ ] **Add more web apps**
  - Use: `omarchy-webapp-install "Name" "URL" "icon-url"`
  - Or manually create .desktop files

- [ ] **Customize waybar**
  - Edit: `~/.config/waybar/config.jsonc` and `style.css`
  - Run: `omarchy-restart-waybar` to apply changes

- [ ] **Set up additional services**
  - Tailscale: `omarchy-install-tailscale`
  - Docker: `omarchy-install-docker-dbs`
  - VS Code: `omarchy-install-vscode`

## Troubleshooting

If something isn't working:

1. Check the logs:
   ```bash
   cat ~/.local/share/omarchy-customization/logs/latest.log
   ```

2. Verify the customization was applied:
   ```bash
   # Check if override is sourced
grep "custom-overrides" ~/.config/hypr/hyprland.conf
   
   # Check keybindings
   omarchy-menu-keybindings --print | grep -E "(Cider|t3.chat)"
   ```

3. Restart services:
   ```bash
   omarchy-restart-waybar
   omarchy-restart-hyprland
   ```

4. Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues

## Support

- **Omarchy issues**: https://manuals.omamix.org/
- **Customization issues**: Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Logs**: `~/.local/share/omarchy-customization/logs/latest.log`
