# Omarchy Customization - Agent Instructions

## Overview

This repository contains idempotent shell scripts and configuration files to customize Omarchy Linux systems. All changes must follow the patterns and requirements documented here.

## Critical Rules

### NEVER Modify Omarchy Source Files
- **NEVER** edit anything in `~/.local/share/omarchy/`
- **NEVER** edit Omarchy's default config files directly
- **ALWAYS** use override patterns (source custom configs)
- **ALWAYS** use Omarchy commands when available (`omarchy-*`)

### Required Skill
When making ANY changes to this repository, you **MUST** invoke the omarchy skill first:
```
Use the skill tool with name "omarchy"
```

## Architecture Patterns

### 1. Direct Configuration (Hyprland)
Edit files directly in `~/.config/hypr/` - these are your personal configurations:
- `bindings.conf` - Keybindings and shortcuts
- `window-rules.conf` - Window behavior rules
- `monitors.conf` - Display configuration
- `input.conf` - Keyboard/mouse settings
- `looknfeel.conf` - Appearance settings
- `autostart.conf` - Startup applications

These files automatically override Omarchy's defaults.

**Note:** Use `unbind` before rebinding keys that are already bound.

### 2. Idempotency
Every script must be safe to run multiple times:
- Check if already done before doing it
- Use marker files in `~/.local/share/omarchy-customization/`
- Check if packages already installed
- Check if configs already applied

### 3. Backup Strategy
Before modifying ANY file:
```bash
backup_file "$source_file"
```
This creates timestamped backups in `~/.local/share/omarchy-customization/backups/`

### 4. Logging
All actions must be logged:
- Use provided logging functions from `scripts/lib/common.sh`
- Logs go to `~/.local/share/omarchy-customization/logs/`
- Symlink `latest.log` always points to most recent
- 1-year log rotation (auto-deleted after 365 days)

### 5. Dry-Run Support
All scripts must support `--dry-run`:
- Check `$DRY_RUN` variable
- Use `run_cmd` wrapper for commands
- Print what would be done without doing it

### 6. Error Handling
- Continue on errors when possible
- Record failures with `record_failure`
- Print summary at end with all failures
- Never stop entire installation for one failed component

### 7. Sudo Usage
- Scripts must NOT run as root
- Use sudo only for specific commands that need it
- Auto-detect if sudo needed, prompt only when required

## Omarchy Integration

### Use Omarchy Commands When Available

| Task | Omarchy Command | Fallback |
|------|----------------|----------|
| Install theme | `omarchy-theme-install <url>` | Manual git clone |
| Set theme | `omarchy-theme-set <name>` | - |
| Install Tailscale | `omarchy-install-tailscale` | Manual install |
| Install AUR pkg | `omarchy-pkg-aur-add <pkg>` | `yay -S` |
| Restart waybar | `omarchy-restart-waybar` | Manual kill/start |
| Toggle suspend | `omarchy-toggle-suspend` | - |
| Hibernation setup | `omarchy-hibernation-setup` | - |

### Package Installation Priority
1. Check if Omarchy has install command
2. Try pacman (official repos)
3. Use yay for AUR (last resort)
4. Log when AUR is used

## Configuration Standards

### Keybinding Changes
1. Check existing bindings: `omarchy-menu-keybindings --print`
2. Add `unbind` BEFORE new `bind`
3. Document what was previously bound

### Window Rules
- **CRITICAL**: Check current Hyprland wiki for syntax
- URL: https://github.com/hyprwm/hyprland-wiki/blob/main/content/Configuring/Window-Rules.md
- Syntax changes frequently between versions

### System Configs
Use drop-in directories (don't edit main files):
- `/etc/systemd/sleep.conf.d/` for sleep settings
- `/etc/systemd/logind.conf.d/` for lid switch
- `/etc/udev/rules.d/` for udev rules

## Hardware-Specific Configs

### Detection
Use functions from `scripts/lib/hardware-detect.sh`:
- `detect_gpu` - Returns nvidia/amd/intel/unknown
- `get_system_vendor` - Manufacturer
- `get_product_name` - Model name
- `get_full_model` - Combined vendor:product

### Adding Hardware Support
1. Create directory under `hardware/<vendor>-<model>/`
2. Add detection logic to `hardware/detect.sh`
3. Scripts in hardware directories auto-executed if match

### Current Hardware
- **HP ZBook G1a**: No special configs needed (AMD integrated graphics)

## Script Organization

### Numbered Scripts (run in order)
- `00-prerequisites.sh` - Setup, checks
- `05-packages-simple.sh` - Simple package installs
- `10-system-config.sh` - System-level configs (power, hibernation)
- `15-packages-complex.sh` - Complex packages (Syncthing)
- `16-flatpak-setup.sh` - Flatpak setup and app installation
- `17-hidpi-config.sh` - HiDPI display configuration
- `20-apps-setup.sh` - Cider, PIA VPN
- `30-webapps.sh` - Web apps (t3.chat)
- `40-hyprland-overrides.sh` - Hyprland override source
- `50-keybindings.sh` - Custom keybindings
- `55-starship.sh` - Starship prompt configuration
- `60-hardware-specific.sh` - Hardware configs
- `61-thunderbolt-fix.sh` - Thunderbolt dock hotplug fixes (HP ZBook)
- `70-themes.sh` - Install all themes
- `80-configs-only.sh` - Config-only changes
- `90-terminals.sh` - Terminal configs (placeholder)
- `99-finalize.sh` - Summary, restart check

### Script Requirements
- Source `scripts/lib/common.sh` at start
- Use provided print_* functions for output
- Log all actions
- Support --dry-run
- Handle errors gracefully

## Theme Installation

### Parallel Installation
- Max 5 concurrent installations
- 60-second timeout per theme
- Track successes/failures
- Continue on individual failures

### All Extra Themes
Install all themes from Omarchy's extra themes list (80+ themes):
- Aetheria, Amberbyte, Arc Blueberry, Archwave, etc.
- Full list in `scripts/70-themes.sh`

## Firewall Configuration

### Auto-Detection
Detect which firewall Omarchy installed:
1. Check if ufw active/enabled
2. Check if firewalld active
3. Fall back to iptables check

### Configuration
- ufw: Use `ufw allow` commands
- firewalld: Use `firewall-cmd` commands
- iptables: Log manual instructions

## Restart Tracking

Scripts must mark when restart is needed:
```bash
mark_restart_needed
```

Finalize script checks and notifies user only if needed.

## Documentation Requirements

When adding features:
1. Update relevant docs/*.md file
2. Add to CHECKLIST.md if user action required
3. Document in code with comments
4. Update ARCHITECTURE.md if pattern changes

## Testing Checklist

Before committing changes:
- [ ] Test with --dry-run first
- [ ] Verify idempotency (run twice)
- [ ] Check logs are created properly
- [ ] Verify backups are created
- [ ] Test error conditions
- [ ] Update documentation

## Common Tasks

### Adding a New Package

**Simple package** (no config):
1. Add to `config/packages.conf`
2. Script `05-packages-simple.sh` handles automatically

**Complex package** (needs config):
1. Create script `15-packages-complex.sh` or similar
2. Install package
3. Configure service/firewall/etc.
4. Document in docs/

### Adding a New Keybinding
1. Edit `~/.config/hypr/bindings.conf`
2. Add unbind directive first
3. Add new bindd directive
4. Document what was previously bound

### Adding Hardware Support
1. Create `hardware/<vendor>-<model>/` directory
2. Add detection to `hardware/detect.sh`
3. Create config script in hardware directory
4. Document in docs/HARDWARE_SUPPORT.md

## File Locations

### Safe to Edit
- `~/.config/` - User configs
- `~/.config/omarchy/themes/` - Custom themes
- `/etc/systemd/*.conf.d/` - System drop-ins
- `/etc/udev/rules.d/` - udev rules

### READ-ONLY (Never Edit)
- `~/.local/share/omarchy/` - Omarchy source
- `/usr/share/` - System defaults

## Contact & Support

For Omarchy issues: https://manuals.omamix.org/
For customization issues: Check docs/TROUBLESHOOTING.md
