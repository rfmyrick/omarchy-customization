# Architecture

This document explains the architecture and design patterns used in the Omarchy Customization repository.

> **Compatibility**: These patterns are designed for Omarchy 3.4.1+ which uses Limine bootloader (not GRUB) and modern systemd features.

## Overview

The goal of this project is to customize Omarchy Linux systems while ensuring:
1. **Idempotency** - Scripts can be run multiple times safely
2. **Update Survival** - Customizations survive Omarchy updates
3. **Extensibility** - Easy to add new hardware support and configurations
4. **Transparency** - Full logging and dry-run support

## Core Patterns

### 1. Override Pattern (The Key to Update Survival)

Instead of modifying Omarchy's default configuration files, we add a single line to source our customizations:

```bash
# In ~/.config/hypr/hyprland.conf, add:
source = ~/.config/hypr/custom-overrides.conf
```

**Why this works:**
- Omarchy's `hyprland.conf` sources Omarchy defaults, then user configs
- By adding our source line at the end, our configs override defaults
- When Omarchy updates, our single source line persists
- We re-add it if needed during script runs
- All our customizations are in separate files that won't be touched by updates

**Example flow:**
1. Omarchy update replaces `~/.config/hypr/hyprland.conf`
2. Script detects our source line is missing
3. Script re-adds: `source = ~/.config/hypr/custom-overrides.conf`
4. Our customizations in `custom-overrides.conf` continue to work

### 2. Idempotency

Every operation checks if it's already been done:

```bash
# Check if package installed before installing
if ! pacman -Q "$pkg" &>/dev/null; then
    sudo pacman -S "$pkg"
fi

# Check if config exists before modifying
if ! grep -q "custom-overrides" "$hypr_conf"; then
    echo "source = ..." >> "$hypr_conf"
fi

# Use marker files for complex operations
if [[ ! -f "$MARKER_DIR/theme-install-done" ]]; then
    install_themes
    touch "$MARKER_DIR/theme-install-done"
fi
```

### 3. Backup Strategy

Every file modification creates a backup:

```bash
backup_file() {
    local file="$1"
    local backup_dir="$HOME/.backups/$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$file" ]]; then
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/"
        echo "Backed up to $backup_dir"
    fi
}
```

Backups are stored in: `~/.local/share/omarchy-customization/backups/`

### 4. Logging System

All actions are logged for transparency:

- **Log location**: `~/.local/share/omarchy-customization/logs/`
- **Latest log**: `latest.log` (symlink to most recent)
- **Retention**: 1-year automatic cleanup
- **Format**: Timestamped with [INFO], [SUCCESS], [WARNING], [ERROR], [AUR] tags

Example log:
```
[2025-02-20 15:30:01] [INFO] Starting installation
[2025-02-20 15:30:02] [INFO] STEP: Checking prerequisites
[2025-02-20 15:30:03] [SUCCESS] Omarchy installation detected
[2025-02-20 15:30:04] [AUR] Installing piavpn-bin from AUR
```

### 5. Dry-Run Support

Every script supports `--dry-run` to preview changes:

```bash
if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] Would install package: $pkg"
else
    sudo pacman -S "$pkg"
fi
```

This allows users to:
- See what would be changed
- Verify prerequisites are met
- Check for potential conflicts
- Build confidence before applying

## Script Organization

### Numbering System

Scripts are numbered to ensure execution order:

- **00-09**: Setup and prerequisites
- **10-19**: System-level configurations
- **20-29**: Application installations
- **30-39**: Web applications
- **40-49**: Desktop environment (Hyprland)
- **50-59**: Keybindings and shortcuts
- **60-69**: Hardware-specific
- **70-79**: Themes and appearance
- **80-89**: Config-only changes
- **90-99**: Finalization

### Library System

Common functions are in `scripts/lib/`:

- **common.sh**: Logging, backups, dry-run, error handling
- **hardware-detect.sh**: Hardware detection functions

All scripts source these libraries:
```bash
source scripts/lib/common.sh
```

## Omarchy Integration

### Command Priority

When installing anything, follow this priority:

1. **Omarchy command** (if available)
   ```bash
   omarchy-install-tailscale
   omarchy-theme-install <url>
   ```

2. **Pacman** (official repositories)
   ```bash
   sudo pacman -S <package>
   ```

3. **Yay/AUR** (last resort)
   ```bash
   yay -S <package>
   # Log AUR usage!
   ```

### Why This Matters

- Omarchy commands may include additional setup
- They ensure consistency with Omarchy conventions
- They handle edge cases specific to Omarchy

## Hardware Support Architecture

### Detection Hierarchy

```
Detect Hardware
├── GPU Type (nvidia/amd/intel)
│   └── Apply GPU-specific fixes
│       └── nvidia/suspend-fix.sh
│
├── Model (vendor-product)
│   └── Apply model-specific configs
│       └── hardware/hp-zbook-g1a/*.sh
│
└── No match
    └── Skip (no special configs needed)
```

### Adding Hardware Support

1. Detect hardware:
   ```bash
   cat /sys/class/dmi/id/sys_vendor    # HP
   cat /sys/class/dmi/id/product_name  # ZBook Ultra G1a
   lspci | grep -i vga                  # NVIDIA/AMD/Intel
   ```

2. Create directory: `hardware/<vendor>-<product>/`

3. Add config script: `hardware/<vendor>-<product>/config.sh`

4. Automatically applied on next run!

## Configuration File Organization

### Configs Directory

```
configs/
├── hypr/
│   ├── custom-overrides.conf    # Main Hyprland overrides
│   └── window-rules.conf        # Window behavior rules
├── systemd/
│   ├── sleep.conf.d/            # Sleep/hibernate settings
│   └── logind.conf.d/           # Lid switch behavior
└── udev/
    └── rules.d/                 # Power profile switching
```

### System Drop-Ins

We use systemd drop-in directories instead of editing main files:

```bash
# Instead of editing /etc/systemd/sleep.conf:
sudo mkdir -p /etc/systemd/sleep.conf.d/
cat | sudo tee /etc/systemd/sleep.conf.d/99-custom-sleep.conf << 'EOF'
[Sleep]
HibernateDelaySec=90min
EOF
```

**Benefits:**
- Survives systemd updates
- Easy to see what's customized
- Easy to revert (just delete the file)

## Error Handling

### Philosophy

- Continue on errors when possible
- Never stop entire installation for one failure
- Record all failures
- Report summary at the end

### Implementation

```bash
declare -a FAILED_STEPS=()

record_failure() {
    FAILED_STEPS+=("$1")
    log_error "Failed: $1"
}

# In scripts:
if ! some_operation; then
    record_failure "Operation X"
    print_warning "Continuing despite error..."
fi

# At end:
if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
    echo "Some steps failed:"
    printf '  - %s\n' "${FAILED_STEPS[@]}"
fi
```

## Restart Tracking

Scripts track if a restart is needed:

```bash
RESTART_NEEDED=false

mark_restart_needed() {
    RESTART_NEEDED=true
}

# Scripts call this when system-level changes made:
# - Kernel parameters
# - Systemd service changes
# - Module configuration

# Finalize script checks:
if [[ "$RESTART_NEEDED" == true ]]; then
    echo "⚠ RESTART REQUIRED"
    echo "Some changes need a restart to take effect."
fi
```

## Best Practices

### When Adding New Features

1. **Create script** in appropriate numbered slot
2. **Use library functions** from `scripts/lib/common.sh`
3. **Make it idempotent** - check before doing
4. **Add backup calls** - before modifying files
5. **Log everything** - use provided log functions
6. **Support dry-run** - check `$DRY_RUN` variable
7. **Handle errors** - use `record_failure()` and continue
8. **Update docs** - add to appropriate docs/*.md file

### When Modifying Existing Features

1. Test with `--dry-run` first
2. Verify idempotency (run twice)
3. Check logs are created properly
4. Verify backups are created
5. Test error conditions
6. Update documentation

## Security Considerations

- Scripts never run as root (only use sudo for specific commands)
- Backups protect against misconfiguration
- Dry-run allows preview before changes
- Logging provides audit trail
- Idempotency prevents repeated damage

## Future Extensibility

The architecture supports:

- **New hardware**: Just add to `hardware/` directory
- **New apps**: Add numbered script in appropriate slot
- **New configs**: Add to `configs/` and reference in scripts
- **New themes**: Automatic via Omarchy's theme system
- **New users**: Clone, customize configs, run install.sh

## Resources

- [Omarchy Documentation](https://manuals.omamix.org/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Systemd Documentation](https://systemd.io/)
