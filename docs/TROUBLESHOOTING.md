# Troubleshooting

This guide helps you resolve common issues with the Omarchy customization scripts.

> **System Compatibility**: These scripts are designed for Omarchy 3.4.1+ with Limine bootloader and systemd. If you're using an older version of Omarchy or a different bootloader, some configurations may need manual adjustment.

## Installation Issues

### Script fails to run

**Symptom:**
```
bash: ./install.sh: Permission denied
```

**Solution:**
```bash
chmod +x install.sh
./install.sh
```

### "Omarchy installation not detected"

**Symptom:**
```
✗ Omarchy installation not detected!
```

**Causes:**
1. Omarchy is not installed
2. Omarchy was installed in non-standard location

**Solutions:**
1. Install Omarchy first: https://omarchy.org/
2. Check if Omarchy exists:
   ```bash
   ls -la ~/.local/share/omarchy
   ```
3. If Omarchy is installed elsewhere, you may need to modify the detection in `scripts/00-prerequisites.sh`

### "Do not run this script as root"

**Symptom:**
```
✗ Do not run this script as root!
```

**Solution:**
```bash
# Run as regular user (not root)
./install.sh

# Script will prompt for sudo when needed
```

### Missing commands

**Symptom:**
```
⚠ Missing commands: yay git
```

**Solution:**
```bash
# Install yay (AUR helper)
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install git
sudo pacman -S git
```

## Package Installation Issues

### Package installation fails

**Symptom:**
```
✗ Failed to install <package>
```

**Solutions:**

1. **Check internet connection**:
   ```bash
   ping 8.8.8.8
   ```

2. **Update package database**:
   ```bash
   sudo pacman -Sy
   ```

3. **Check for conflicts**:
   ```bash
   sudo pacman -S <package> 2>&1 | head -20
   ```

4. **Try manual installation**:
   ```bash
   sudo pacman -S <package>
   # or for AUR:
   yay -S <package>
   ```

### AUR package fails to build

**Symptom:**
```
✗ Failed to install <package> from AUR
```

**Solutions:**

1. **Check build dependencies**:
   ```bash
   yay -Si <package>
   # Look for "Depends On" and "Make Depends"
   ```

2. **Clean build**:
   ```bash
   yay -Scc  # Clear cache
   yay -S <package> --rebuildtree
   ```

3. **Check AUR page**:
   - Visit https://aur.archlinux.org/packages/<package>
   - Check comments for known issues
   - Check if package is orphaned

4. **Manual installation**:
   ```bash
   cd /tmp
   git clone https://aur.archlinux.org/<package>.git
   cd <package>
   makepkg -si
   ```

## Cider Installation Issues

### "Cider package not found"

**Symptom:**
```
⚠ Cider package not found in ~/Downloads/
```

**Solutions:**

1. **Verify download location**:
   ```bash
   ls ~/Downloads/cider-*-linux-x64.pkg.tar.zst
   ```

2. **Check file name**:
   - Should match pattern: `cider-*-linux-x64.pkg.tar.zst`
   - If different, rename it:
     ```bash
     mv ~/Downloads/cider-linux-x64.pkg.tar.zst ~/Downloads/cider-v3.1.8-linux-x64.pkg.tar.zst
     ```

3. **Download Cider**:
   - Visit: https://cider.sh/
   - Purchase and download
   - Place in `~/Downloads/`

4. **Manual installation**:
   ```bash
   sudo pacman -U ~/Downloads/cider-*-linux-x64.pkg.tar.zst
   ```

### Cider installation fails

**Symptom:**
```
✗ Failed to install Cider
```

**Solutions:**

1. **Check file integrity**:
   ```bash
   tar -tzf ~/Downloads/cider-*-linux-x64.pkg.tar.zst
   # Should list files without errors
   ```

2. **Re-download**:
   - File may be corrupted
   - Download again from source

3. **Check dependencies**:
   ```bash
   sudo pacman -U ~/Downloads/cider-*-linux-x64.pkg.tar.zst 2>&1
   ```

## System Configuration Issues

### Hibernate not working

**Symptom:**
- Laptop doesn't hibernate
- Hibernate option not available

**Solutions:**

1. **Check if hibernation is set up**:
   ```bash
   ls /etc/mkinitcpio.conf.d/omarchy_resume.conf
   ```

2. **Check swap file**:
   ```bash
   swapon --show
   ls -lh /swap/swapfile
   ```

3. **Re-run hibernation setup**:
   ```bash
   omarchy-hibernation-setup
   ```

4. **Check kernel parameters**:
   ```bash
   cat /proc/cmdline | grep resume
   # Should show: resume=UUID=xxx
   ```

5. **Regenerate initramfs**:
   ```bash
   sudo limine-mkinitcpio
   sudo limine-update
   ```

### Lid close doesn't suspend

**Symptom:**
- Closing laptop lid doesn't suspend
- Or suspends when on AC power (shouldn't)

**Solutions:**

1. **Check configuration**:
   ```bash
   cat /etc/systemd/logind.conf.d/99-custom-lid.conf
   ```

2. **Check power status**:
   ```bash
   cat /sys/class/power_supply/Mains/online
   # 1 = on AC, 0 = on battery
   ```

3. **Restart logind**:
   ```bash
   sudo systemctl restart systemd-logind
   ```

4. **Check for inhibitors**:
   ```bash
   systemd-inhibit --list
   ```

### Power profiles not switching

**Symptom:**
- Power profile doesn't change when plugging/unplugging

**Solutions:**

1. **Check current profile**:
   ```bash
   powerprofilesctl get
   ```

2. **Check udev rules**:
   ```bash
   cat /etc/udev/rules.d/99-power-profile.rules
   ```

3. **Reload udev rules**:
   ```bash
   sudo udevadm control --reload-rules
   ```

4. **Test manually**:
   ```bash
   powerprofilesctl set power-saver
   powerprofilesctl set performance
   ```

## Desktop Environment Issues

### Keybindings not working

**Symptom:**
- `SUPER+SHIFT+M` doesn't open Cider
- `SUPER+SHIFT+A` doesn't open t3.chat

**Solutions:**

1. **Check keybindings file**:
   ```bash
   cat ~/.config/hypr/bindings.conf | grep -E "(Cider|t3.chat)"
   ```

2. **Verify keybindings are loaded**:
   ```bash
   omarchy-menu-keybindings --print | grep -E "(Cider|t3.chat)"
   ```

3. **Reload Hyprland**:
   ```bash
   hyprctl reload
   # or log out and back in
   ```

5. **Check for conflicts**:
   ```bash
   grep -r "SUPER SHIFT, M" ~/.config/hypr/
   grep -r "SUPER SHIFT, A" ~/.config/hypr/
   ```

### Theme not set to Ethereal

**Symptom:**
- Theme is not Ethereal after installation

**Solutions:**

1. **Check current theme**:
   ```bash
   omarchy-theme-current
   ```

2. **Set manually**:
   ```bash
   omarchy-theme-set "Ethereal"
   ```

3. **Check if theme is installed**:
   ```bash
   ls ~/.config/omarchy/themes/
   omarchy-theme-list | grep -i ethereal
   ```

4. **Install theme**:
   ```bash
   omarchy-theme-install "https://github.com/omarchy/theme-ethereal"
   ```

### Window rules not working

**Symptom:**
- Apps don't open on specified workspaces
- Windows don't float when they should

**Solutions:**

1. **Check syntax**:
   - Window rule syntax changes frequently
   - Check: https://github.com/hyprwm/hyprland-wiki/blob/main/content/Configuring/Window-Rules.md

2. **Check rules file**:
   ```bash
   cat ~/.config/hypr/window-rules.conf
   ```

3. **Check if window-rules.conf is sourced**:
   ```bash
   grep "window-rules" ~/.config/hypr/hyprland.conf
   ```

4. **Reload Hyprland**:
   ```bash
   hyprctl reload
   ```

## Application Issues

### PIA VPN won't connect

**Symptom:**
- PIA app opens but won't connect
- Connection drops immediately

**Solutions:**

1. **Check credentials**:
   - Verify username/password are correct
   - Try logging in on PIA website

2. **Check service status**:
   ```bash
   sudo systemctl status piavpn
   sudo systemctl restart piavpn
   ```

3. **Check firewall**:
   ```bash
   sudo ufw status
   # PIA ports should be allowed
   ```

4. **Try different server**:
   - Some servers may be temporarily down
   - Try different region

5. **Change protocol**:
   - Settings → Network → Protocol
   - Try WireGuard or OpenVPN

### Syncthing not syncing

**Symptom:**
- Files don't sync between devices
- Devices show as "Disconnected"

**Solutions:**

1. **Check service status**:
   ```bash
   systemctl --user status syncthing
   systemctl --user restart syncthing
   ```

2. **Check web UI**:
   - http://localhost:8384
   - Look for errors or warnings

3. **Check firewall**:
   ```bash
   sudo ufw status
   # Ports 22000/tcp, 22000/udp, 21027/udp should be allowed
   ```

4. **Check device IDs**:
   - Verify Device IDs are correct
   - No typos in paired devices

5. **Check discovery**:
   - Settings → Connections
   - Enable "Local Discovery" and/or "Global Discovery"

6. **Check logs**:
   ```bash
   journalctl --user -u syncthing -f
   ```

## Theme Installation Issues

### Themes fail to install

**Symptom:**
- Some themes show as "failed" in output
- Themes don't appear in theme list

**Solutions:**

1. **Check internet connection**:
   ```bash
   ping github.com
   ```

2. **Check individual theme**:
   ```bash
   omarchy-theme-install "https://github.com/USER/THEME"
   # Run manually to see error
   ```

3. **Check disk space**:
   ```bash
   df -h ~/.config/omarchy/themes/
   ```

4. **Install specific theme**:
   ```bash
   omarchy-theme-install "https://github.com/omarchy/theme-name"
   ```

## Hardware-Specific Issues

### NVIDIA suspend/resume problems

**Symptom:**
- Laptop doesn't resume from suspend
- Black screen after resume
- System crashes on resume

**Solutions:**

1. **Check if NVIDIA config is applied**:
   ```bash
   cat /etc/default/grub | grep nvidia
   ```

2. **Apply NVIDIA suspend fix**:
   - Should be automatic for NVIDIA GPUs
   - Check: `hardware/nvidia/suspend-fix.sh`

3. **Add kernel parameters**:
   ```bash
   sudo nano /etc/default/grub
   # Add to GRUB_CMDLINE_LINUX_DEFAULT:
   # nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1
   
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

4. **Enable persistence mode**:
   ```bash
   sudo nvidia-smi -pm 1
   ```

5. **Restart**:
   - Kernel parameter changes require restart

### Thunderbolt Dock Lockups (HP ZBook)

**Symptom:**
- System locks up when connecting/disconnecting Thunderbolt dock
- Trackpad stops working
- Keyboard stops working
- Display goes blank or doesn't switch
- Issues occur inconsistently

**Quick Fix:**
```bash
# If you can get to a terminal, reload Hyprland:
hyprctl reload
```

**Permanent Solutions:**

The `scripts/61-thunderbolt-fix.sh` applies these fixes automatically:

1. **Remove conflicting logind config**:
   ```bash
   sudo rm -f /etc/systemd/logind.conf.d/lid.conf
   ```

2. **Disable USB autosuspend** (creates udev rule):
   ```bash
   sudo tee /etc/udev/rules.d/99-thunderbolt-dock.rules << 'EOF'
   ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", ATTR{power/control}="on"
   ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{power/control}="on"
   ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/control}="on"
   ACTION=="add|remove", SUBSYSTEM=="thunderbolt", RUN+="/bin/sh -c 'sleep 2 && /usr/bin/hyprctl reload 2>/dev/null || true'"
   EOF
   sudo udevadm control --reload-rules
   ```

3. **Disable kernel autosuspend**:
   ```bash
   sudo tee /etc/modprobe.d/thunderbolt-dock.conf << 'EOF'
   options usbcore autosuspend=-1
   options thunderbolt auto_suspend=0
   EOF
   sudo limine-mkinitcpio
   ```

4. **Restart required** after applying all fixes.

**See also:** [docs/THUNDERBOLT_FIX.md](THUNDERBOLT_FIX.md) for complete documentation.

## Logging and Debugging

### View installation logs

```bash
# Latest log
cat ~/.local/share/omarchy-customization/logs/latest.log

# Specific log
cat ~/.local/share/omarchy-customization/logs/install-YYYYMMDD_HHMMSS.log

# Follow log in real-time
tail -f ~/.local/share/omarchy-customization/logs/latest.log
```

### Enable verbose mode

Edit `scripts/lib/common.sh`:
```bash
# Add at top:
set -x  # Enable bash debug mode
```

### Check what was changed

```bash
# List backups
ls -la ~/.local/share/omarchy-customization/backups/

# Compare files
diff ~/.local/share/omarchy-customization/backups/YYYYMMDD_HHMMSS/hyprland.conf ~/.config/hypr/hyprland.conf
```

## Recovery

### Restore from backup

If something goes wrong:

```bash
# List available backups
ls ~/.local/share/omarchy-customization/backups/

# Restore specific file
cp ~/.local/share/omarchy-customization/backups/YYYYMMDD_HHMMSS/hyprland.conf ~/.config/hypr/

# Restore entire config directory
cp -r ~/.local/share/omarchy-customization/backups/YYYYMMDD_HHMMSS/* ~/.config/
```

### Reset to Omarchy defaults

```bash
# Reset specific component
omarchy-refresh-hyprland
omarchy-refresh-waybar

# Full reinstall of configs
omarchy-reinstall-configs
```

### Complete removal

To remove all customizations:

```bash
# Remove custom configs (optional - your personal configs in ~/.config/hypr/)
rm ~/.config/hypr/window-rules.conf

# Remove system configs
sudo rm /etc/systemd/sleep.conf.d/99-custom-sleep.conf
sudo rm /etc/systemd/logind.conf.d/99-custom-lid.conf
# Note: Power profile rule is modified from Omarchy default
# To restore Omarchy's default, run: omarchy-refresh-config udev/rules.d/99-power-profile.rules

# Remove installed packages (optional)
sudo pacman -R cider piavpn-bin syncthing flatpak

## Getting Help

### Before asking for help

1. **Check the logs**:
   ```bash
   cat ~/.local/share/omarchy-customization/logs/latest.log
   ```

2. **Try dry-run**:
   ```bash
   ./install.sh --dry-run
   ```

3. **Check documentation**:
   - docs/ARCHITECTURE.md
   - docs/CUSTOMIZATION_GUIDE.md
   - docs/POWER_MANAGEMENT.md

4. **Check Omarchy docs**:
   - https://manuals.omamix.org/

### Where to ask

- **Omarchy issues**: https://github.com/omarchy/omarchy/issues
- **General Linux**: https://www.reddit.com/r/linuxquestions/
- **Arch Linux**: https://bbs.archlinux.org/

### Information to provide

When asking for help, include:

1. **Log file**:
   ```bash
   cat ~/.local/share/omarchy-customization/logs/latest.log
   ```

2. **System info**:
   ```bash
   omarchy-debug --no-sudo --print
   ```

3. **What you tried**:
   - Steps you've already taken
   - What worked/didn't work

4. **Error messages**:
   - Exact error text
   - When it occurs
