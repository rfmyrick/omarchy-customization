# Customization Guide

This guide explains how to customize the configurations in this repository before running the installation.

> **System Requirements**: These configurations are designed for Omarchy 3.4.1+ with Limine bootloader and systemd.

## Overview

All configuration files are in the `configs/` directory. These are production-ready configurations with extensive comments explaining what each setting does.

**Workflow:**
1. Review the configuration files
2. Make your desired changes
3. Run `./install.sh` to apply

## Configuration Files

### Hyprland (`~/.config/hypr/`)

Hyprland configuration files in `~/.config/hypr/` are your personal customizations. These files are sourced by Omarchy's default configuration and override any defaults.

**Main configuration files:**
- `bindings.conf` - Custom keybindings and application shortcuts
- `window-rules.conf` - Window behavior rules
- `monitors.conf` - Display/monitor configuration
- `input.conf` - Keyboard and mouse settings
- `looknfeel.conf` - Appearance settings
- `autostart.conf` - Startup applications

#### bindings.conf

This file contains custom keybindings that override or extend Omarchy's defaults.

**To add your own keybindings:**

```bash
# 1. Unbind the existing key (if any)
unbind = SUPER, F

# 2. Add your new binding
bindd = SUPER, F, File Manager, exec, nautilus
```

**To add window rules:**

```bash
# Source window rules from separate file (already done)
source = ~/.config/hypr/window-rules.conf

# Or add directly:
windowrule = workspace 5, class:^(cider)$
windowrule = float, class:^(pavucontrol)$
```

#### window-rules.conf

Template file for window behavior rules.

**Examples:**

```bash
# Assign app to specific workspace
windowrule = workspace 10, class:^(cider)$

# Make window float
windowrule = float, class:^(pavucontrol)$

# Set window size for floating windows
windowrule = size 800 600, class:^(my-floating-app)$

# Center floating windows
windowrule = center, class:^(my-floating-app)$
```

**Important:** Window rule syntax changes frequently. Always check the [Hyprland Wiki](https://github.com/hyprwm/hyprland-wiki/blob/main/content/Configuring/Window-Rules.md) for current syntax.

### System Settings (`configs/systemd/`)

#### sleep.conf.d/99-custom-sleep.conf

Controls suspend and hibernate behavior.

**Settings:**
- `HibernateDelaySec=90min` - Time before hibernating after suspend
- `HibernateOnACPower=no` - Never hibernate when plugged in

**To change:**
```bash
# Edit the file
nano configs/systemd/sleep.conf.d/99-custom-sleep.conf

# Change the delay
HibernateDelaySec=30min  # Back to Omarchy default
HibernateDelaySec=90min  # Current customization (90 minutes)
HibernateDelaySec=120min # 2 hours
```

#### logind.conf.d/99-custom-lid.conf

Controls laptop lid behavior.

**Settings:**
- `HandleLidSwitch=suspend` - Suspend when lid closed on battery
- `HandleLidSwitchExternalPower=ignore` - Don't suspend on AC power
- `HandleLidSwitchDocked=ignore` - Don't suspend when docked

**To change:**
```bash
# Always suspend (even on AC)
HandleLidSwitchExternalPower=suspend

# Hibernate instead of suspend
HandleLidSwitch=hibernate
```

### Power Profiles

The customization script modifies Omarchy's default power profile rule at `/etc/udev/rules.d/99-power-profile.rules` to use `power-saver` on battery instead of `balanced`.

**Current behavior:**
- On battery → power-saver
- On AC → performance

**To change:**

Edit `/etc/udev/rules.d/99-power-profile.rules`:

```bash
# Use balanced instead of power-saver on battery
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"

# Always use balanced
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
```

**To restore Omarchy's default:**
```bash
omarchy-refresh-config udev/rules.d/99-power-profile.rules
```

### Flatpak Applications

The customization scripts automatically set up Flatpak and install Plex Media Server client.

**Installed Flatpaks:**
- **Plex Desktop** (`tv.plex.PlexDesktop`) - Media server client

**Authentication Required:**
Plex requires signing in with your Plex account on first launch. The application will prompt for credentials when opened.

**Manual Management:**
```bash
# Install Plex (if not already installed)
flatpak install flathub tv.plex.PlexDesktop

# Update all Flatpaks
flatpak update

# List installed Flatpaks
flatpak list

# Launch Plex
flatpak run tv.plex.PlexDesktop
```

**Plex Data Location:**
Plex stores its data in: `~/.var/app/tv.plex.PlexDesktop/`

## Package Lists (`config/packages.conf`)

### Adding Simple Packages

Edit `config/packages.conf`:

```bash
PACMAN_PACKAGES=(
    # ... existing packages ...
    
    # Add your packages here
    vim              # If you prefer vim over neovim
    gimp             # Image editor
    vlc              # Media player
)
```

### Adding AUR Packages

Only use AUR when necessary:

```bash
AUR_PACKAGES=(
    # Add AUR-only packages here
    google-chrome    # If you prefer Chrome over Brave
    spotify          # If you want native Spotify
)
```

## Themes

### Changing the Default Theme

Edit `scripts/70-themes.sh`:

```bash
# Change this line
set_default_theme() {
    local current_theme=$(omarchy-theme-current 2>/dev/null || echo "unknown")
    
    if [[ "$current_theme" == "Tokyo Night" ]]; then  # Change from "Ethereal"
        print_success "Tokyo Night theme is already active"
    else
        omarchy-theme-set "Tokyo Night"  # Change theme name
        print_success "Tokyo Night theme activated"
    fi
}
```

### Adding Custom Themes

1. Create theme directory:
   ```bash
   mkdir -p ~/.config/omarchy/themes/my-custom-theme
   ```

2. Add theme files (colors.toml, btop.theme, etc.)

3. Add wallpapers to the directory

4. Set the theme:
   ```bash
   omarchy-theme-set "my-custom-theme"
   ```

## Hardware-Specific Configs

### Adding Support for Your Laptop

1. Detect your hardware:
   ```bash
   cat /sys/class/dmi/id/sys_vendor
   cat /sys/class/dmi/id/product_name
   ```

2. Create directory:
   ```bash
   mkdir hardware/dell-xps-13
   ```

3. Create config script:
   ```bash
   cat > hardware/dell-xps-13/config.sh << 'EOF'
   #!/bin/bash
   print_step "Applying Dell XPS 13 specific configurations..."
   
   # Your customizations here
   # Example: Adjust trackpad sensitivity
   # Example: Configure fingerprint reader
   
   print_success "Dell XPS 13 configuration applied"
   EOF
   ```

## Web Apps

### Adding Your Own Web Apps

Edit `scripts/30-webapps.sh`:

```bash
install_my_webapp() {
    local desktop_file="$HOME/.local/share/applications/My App.desktop"
    
    if [[ -f "$desktop_file" ]]; then
        print_success "My App is already installed"
        return 0
    fi
    
    print_info "Installing My App..."
    omarchy-webapp-install "My App" "https://myapp.com" "https://myapp.com/favicon.ico"
}

# Add to main section:
install_t3_chat
install_my_webapp  # Add this line
```

## Testing Your Changes

### Dry Run

Always test with dry-run first:

```bash
./install.sh --dry-run
```

This shows:
- What packages would be installed
- What files would be modified
- What backups would be created
- Any errors or missing prerequisites

### Review Logs

After running (even dry-run), check the logs:

```bash
cat ~/.local/share/omarchy-customization/logs/latest.log
```

## Common Customizations

### Change Keybindings

Edit `~/.config/hypr/bindings.conf`:

```bash
# Change file manager from Super+Shift+F to Super+E
unbind = SUPER SHIFT, F
bindd = SUPER, E, File Manager, exec, uwsm-app -- nautilus --new-window
```

### Add Workspace-Specific Apps

Edit `configs/hypr/window-rules.conf`:

```bash
# Always open browser on workspace 2
windowrule = workspace 2, class:^(brave-browser|chromium|firefox)$

# Always open music on workspace 10
windowrule = workspace 10, class:^(cider|spotify)$

# Always open chat on workspace 3
windowrule = workspace 3, class:^(discord|signal|telegram)$
```

### Configure Floating Windows

Edit `configs/hypr/window-rules.conf`:

```bash
# Make these apps float
windowrule = float, class:^(pavucontrol)$
windowrule = float, class:^(nm-connection-editor)$
windowrule = float, title:^(Open File|Save File)$

# Size and center floating windows
windowrule = size 800 600, class:^(pavucontrol)$
windowrule = center, class:^(pavucontrol)$
```

### Change Suspend Behavior

Edit `configs/systemd/sleep.conf.d/99-custom-sleep.conf`:

```bash
[Sleep]
# Never hibernate (only suspend)
HibernateDelaySec=0

# Or hibernate immediately after suspend
HibernateDelaySec=1min
```

## Best Practices

1. **Always backup before major changes**
   ```bash
   cp -r configs configs.backup
   ```

2. **Test one change at a time**
   - Easier to debug
   - Easier to revert

3. **Use version control**
   ```bash
   git init
   git add .
   git commit -m "Initial customizations"
   ```

4. **Document your changes**
   - Add comments in config files
   - Update this guide if needed

5. **Share your configs**
   - Fork this repository
   - Share your customizations with others

## Getting Help

- **Omarchy docs**: https://manuals.omamix.org/
- **Hyprland wiki**: https://wiki.hyprland.org/
- **Arch wiki**: https://wiki.archlinux.org/
- **This repo**: Check docs/TROUBLESHOOTING.md
