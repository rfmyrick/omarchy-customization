# Power Management

This document explains the power management configurations applied by these scripts.

> **Compatibility Note**: These configurations are designed for Omarchy 3.4.1+ which uses systemd's native power profile support and Limine bootloader (not GRUB).

## Overview

The customization scripts configure several power management features to optimize battery life while maintaining performance when plugged in.

## Configurations

### 1. Power Profile Switching

**What it does:**
Automatically switches power profiles based on AC power status.

**Configuration:**
- **On battery (unplugged)**: Switches to `power-saver` mode
- **On AC (plugged in)**: Switches to `performance` mode

**File:** `/etc/udev/rules.d/99-power-profile.rules` (modified from Omarchy default)

```bash
# On battery: use power-saver (modified from Omarchy default of 'balanced')
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"

# On AC: use performance
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set performance"
```

**Why this matters:**
- **Power-saver**: Reduces CPU frequency, extends battery life
- **Performance**: Maximum CPU frequency for demanding tasks
- **Automatic**: No manual switching needed

**Omarchy default:**
- On battery: `balanced` (middle ground)
- On AC: `performance`

**Our change:** More aggressive power saving on battery.

### 2. Suspend-Then-Hibernate

**What it does:**
Suspends the laptop (low power, quick resume), then after a delay, hibernates (saves to disk, zero power).

**Configuration:**
- **Delay**: 60 minutes (changed from Omarchy's 30 minutes)
- **On AC**: Never hibernate

**File:** `configs/systemd/sleep.conf.d/99-custom-sleep.conf`

```bash
[Sleep]
HibernateDelaySec=90min
HibernateOnACPower=no
```

**Why 90 minutes?**
- 90 minutes allows for longer work sessions and meetings
- Still protects battery if you forget the laptop in suspend
- Provides ample time before automatic hibernation

**How it works:**
1. You close the lid (or trigger suspend)
2. Laptop enters suspend (RAM powered, ~1-3W consumption)
3. After 60 minutes, automatically wakes and hibernates
4. Hibernate saves RAM to disk and powers off (0W consumption)
5. Next power-on restores from hibernate (slower but safe)

### 3. Lid Switch Behavior

**What it does:**
Controls what happens when you close the laptop lid.

**Configuration:**
- **On battery**: Suspend (save battery)
- **On AC power**: Do nothing (for docked/external monitor use)
- **When docked**: Do nothing

**File:** `configs/systemd/logind.conf.d/99-custom-lid.conf`

```bash
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

**Why ignore on AC?**
- Many users dock their laptops with external monitors
- Closing the lid shouldn't interrupt work in this case
- Laptop stays awake, external monitor remains active
- Better for presentations, extended desktop setups

**Omarchy default:**
- Suspend in all cases

**Our change:** Smarter behavior based on power source.

### 4. Suspend Menu Item

**What it does:**
Enables the "Suspend" option in the Omarchy system menu.

**Command:** `omarchy-toggle-suspend`

**Why:**
- Omarchy ships with suspend disabled by default
- Users must explicitly enable it
- Provides a safety mechanism against accidental suspend

## Power Consumption Comparison

| State | Power Draw | Resume Time | Use Case |
|-------|-----------|-------------|----------|
| Active | 10-30W | Instant | Working |
| Idle | 5-10W | Instant | Brief pause |
| Suspend | 1-3W | 1-3 seconds | Short breaks |
| Hibernate | 0W | 10-30 seconds | Long breaks, travel |
| Off | 0W | 30-60 seconds | Extended storage |

## Customization

### Change Hibernate Delay

Edit `configs/systemd/sleep.conf.d/99-custom-sleep.conf`:

```bash
# 30 minutes (Omarchy default)
HibernateDelaySec=30min

# 2 hours
HibernateDelaySec=120min

# Never hibernate (only suspend)
# Remove or comment out the line
```

### Change Lid Behavior

Edit `configs/systemd/logind.conf.d/99-custom-lid.conf`:

```bash
# Always suspend (even on AC)
HandleLidSwitchExternalPower=suspend

# Hibernate instead of suspend
HandleLidSwitch=hibernate

# Do nothing in all cases
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
```

### Change Power Profiles

Edit `/etc/udev/rules.d/99-power-profile.rules`:

```bash
# Use balanced on battery (less aggressive) - Omarchy default
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"

# Always use balanced
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
```

**Note:** The customization script modifies Omarchy's default rule file directly. If you want to revert to Omarchy's defaults, you can restore the original using `omarchy-refresh-config`.

## Monitoring

### Check Current Power Profile

```bash
powerprofilesctl get
```

Output: `power-saver`, `balanced`, or `performance`

### Check Power Consumption

```bash
# Real-time monitoring
powertop

# Or use btop
btop
```

### Check Battery Status

```bash
# Battery percentage
omarchy-battery-remaining

# Detailed info
upower -i $(upower -e | grep BAT)
```

### Check Sleep Configuration

```bash
# Current sleep settings
systemd-analyze cat-config systemd/sleep.conf

# Current logind settings
systemd-analyze cat-config systemd/logind.conf
```

## Troubleshooting

### Suspend not working

1. Check if suspend is enabled:
   ```bash
   ls ~/.local/state/omarchy/toggles/suspend-on
   ```

2. Check systemd status:
   ```bash
   systemctl status systemd-logind
   ```

3. Check for inhibitors:
   ```bash
   systemd-inhibit --list
   ```

### Hibernate not working

1. Check if hibernation is set up:
   ```bash
   ls /etc/mkinitcpio.conf.d/omarchy_resume.conf
   ```

2. Check swap file:
   ```bash
   swapon --show
   ls /swap/swapfile
   ```

3. Check resume hook:
   ```bash
   grep resume /etc/mkinitcpio.conf.d/omarchy_resume.conf
   ```

4. Re-run hibernation setup:
   ```bash
   omarchy-hibernation-setup
   ```

### Lid close doesn't suspend

1. Check logind configuration:
   ```bash
   cat /etc/systemd/logind.conf.d/99-custom-lid.conf
   ```

2. Check if on AC power:
   ```bash
   cat /sys/class/power_supply/Mains/online
   # 1 = on AC, 0 = on battery
   ```

3. Restart logind:
   ```bash
   sudo systemctl restart systemd-logind
   ```

### Power profiles not switching

1. Check udev rules:
   ```bash
   cat /etc/udev/rules.d/99-power-profile.rules
   ```

2. Reload udev rules:
   ```bash
   sudo udevadm control --reload-rules
   ```

3. Check if powerprofilesctl works:
   ```bash
   powerprofilesctl list
   powerprofilesctl set power-saver
   ```

## Advanced Topics

### Disable Suspend-Then-Hibernate

If you only want suspend (no automatic hibernation):

```bash
# Edit sleep configuration
sudo rm /etc/systemd/sleep.conf.d/99-custom-sleep.conf

# Or set HibernateDelaySec to 0
# This disables automatic hibernation
```

### Manual Hibernate

Even with suspend-then-hibernate, you can manually hibernate:

```bash
systemctl hibernate
```

### Hybrid Sleep

Some systems support hybrid sleep (suspend + hibernate simultaneously):

```bash
# Check if supported
cat /sys/power/state | grep hybrid

# If supported, configure in sleep.conf:
[Sleep]
SuspendMode=hybrid-sleep
```

### Wake-on-LAN

To allow waking the laptop via network:

```bash
# Check if supported
ethtool eth0 | grep Wake-on

# Enable (requires compatible hardware)
sudo ethtool -s eth0 wol g
```

## References

- [Systemd Sleep Documentation](https://www.freedesktop.org/software/systemd/man/systemd-sleep.conf.html)
- [Systemd Logind Documentation](https://www.freedesktop.org/software/systemd/man/logind.conf.html)
- [Power Profiles Daemon](https://gitlab.freedesktop.org/upower/power-profiles-daemon)
- [Arch Wiki - Power Management](https://wiki.archlinux.org/title/Power_management)
