# Thunderbolt Dock Fix

## Problem
HP ZBook Ultra G1a experiences lockups/hangs when connecting/disconnecting from Thunderbolt dock:
- Trackpad stops working
- Keyboard stops working  
- Display goes blank
- `hyprctl reload` temporarily fixes it

## Root Causes Identified

### 1. Conflicting Logind Configuration
**Files:**
- `/etc/systemd/logind.conf.d/lid.conf` - Sets `HandleLidSwitch=suspend-then-hibernate`
- `/etc/systemd/logind.conf.d/99-custom-lid.conf` - Sets `HandleLidSwitch=suspend`

**Impact:** Conflicting lid switch behavior causes system confusion during dock events.

### 2. USB/Thunderbolt Autosuspend
**Settings:**
- Global USB autosuspend: 2 seconds (`/sys/module/usbcore/parameters/autosuspend`)
- Thunderbolt autosuspend: 15 seconds (`/sys/bus/thunderbolt/devices/*/power/autosuspend_delay_ms`)

**Impact:** Input devices and Thunderbolt controller sleep and don't wake up properly during hotplug.

### 3. No Hotplug Handling
**Missing:** Udev rules to reload Hyprland when displays change via Thunderbolt.

## Solutions Implemented

### Script Created: `scripts/61-thunderbolt-fix.sh`

This script applies four fixes:

#### Fix 1: Remove Conflicting Logind Config
Removes `/etc/systemd/logind.conf.d/lid.conf` to eliminate the conflict.

#### Fix 2: USB/Thunderbolt Autosuspend Rules
Creates `/etc/udev/rules.d/99-thunderbolt-dock.rules`:
```udev
# Disable autosuspend for input devices
ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", ATTR{power/control}="on"

# Disable autosuspend for Thunderbolt
ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{power/control}="on"

# Disable autosuspend for USB hubs
ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/control}="on"

# Auto-reload Hyprland on dock events
ACTION=="add|remove", SUBSYSTEM=="thunderbolt", RUN+="/bin/sh -c 'sleep 2 && /usr/bin/hyprctl reload 2>/dev/null || true'"
```

#### Fix 3: Hyprland Hotplug Handler
Creates background script to monitor dock events and reload Hyprland.

#### Fix 4: Kernel Module Options
Creates `/etc/modprobe.d/thunderbolt-dock.conf`:
```
options usbcore autosuspend=-1
options thunderbolt auto_suspend=0
```

## Manual Application (Run These Commands)

```bash
# 1. Remove conflicting logind config
sudo rm -f /etc/systemd/logind.conf.d/lid.conf

# 2. Create udev rules
sudo tee /etc/udev/rules.d/99-thunderbolt-dock.rules << 'EOF'
# Disable USB autosuspend for input devices and Thunderbolt
ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/control}="on"
ACTION=="add|remove", SUBSYSTEM=="thunderbolt", ENV{DEVTYPE}=="thunderbolt_device", RUN+="/bin/sh -c 'sleep 2 && /usr/bin/hyprctl reload 2>/dev/null || true'"
EOF

# 3. Reload udev rules
sudo udevadm control --reload-rules

# 4. Create kernel module config
sudo tee /etc/modprobe.d/thunderbolt-dock.conf << 'EOF'
options usbcore autosuspend=-1
options thunderbolt auto_suspend=0
EOF

# 5. Update initramfs
sudo limine-mkinitcpio

# 6. Restart system
sudo reboot
```

## What Each Fix Does

1. **Logind Conflict Resolution**: Ensures consistent lid switch behavior
2. **USB Autosuspend Disabled**: Keeps input devices awake during dock transitions
3. **Thunderbolt Autosuspend Disabled**: Prevents controller from sleeping
4. **Auto Hyprland Reload**: Automatically refreshes display configuration on dock events
5. **Kernel Parameters**: Disables autosuspend at the driver level

## Testing

After restart:
1. Connect dock - check if display/keyboard/trackpad work immediately
2. Disconnect dock - check if laptop display/inputs work
3. Repeat 3-5 times to verify consistency

## If Issues Persist

Check logs after a dock event:
```bash
journalctl --since "5 minutes ago" | grep -iE "(thunderbolt|usb|dock|input)"
```

## Files Added to Repository

- `scripts/61-thunderbolt-fix.sh` - Automated fix script
- `install.sh` - Updated to include script in installation order

## Restart Required

**IMPORTANT:** All changes require a system restart to take full effect.
