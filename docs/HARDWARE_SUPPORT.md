# Hardware Support

This document explains how to add hardware-specific configurations to support different laptops and GPUs.

## Overview

While Omarchy works well on most hardware out-of-the-box, some devices require specific configurations for optimal functionality. This repository provides an extensible framework for hardware-specific customizations.

> **Compatibility Note**: These configurations are designed for Omarchy 3.4.1+ which uses Limine bootloader instead of GRUB. NVIDIA kernel parameters require manual Limine configuration.

## Current Hardware Support

### Laptops

| Vendor | Model | Status | Notes |
|--------|-------|--------|-------|
| HP | ZBook G1a | ✅ Supported | No special config needed |

### GPUs

| GPU | Status | Notes |
|-----|--------|-------|
| AMD Integrated | ✅ Supported | No special config needed |
| Intel Integrated | ✅ Supported | No special config needed |
| NVIDIA Discrete | ⚠️ Needs config | Suspend/hibernation fixes may be needed |

## How Hardware Detection Works

### Detection Process

1. **GPU Detection**: Checks `lspci` output for GPU vendor
2. **System Detection**: Reads DMI data from `/sys/class/dmi/id/`
3. **Matching**: Looks for matching directories in `hardware/`
4. **Execution**: Runs applicable configuration scripts

### Detection Functions

```bash
# In scripts/lib/hardware-detect.sh

# Get system vendor (e.g., "HP", "Dell")
get_system_vendor

# Get product name (e.g., "ZBook Ultra G1a")
get_product_name

# Get combined identifier (e.g., "HP:ZBook Ultra G1a 14 inch Mobile Workstation PC")
get_full_model

# Detect GPU type (nvidia/amd/intel/unknown)
detect_gpu

# Get sanitized directory name
echo "$(get_system_vendor)-$(get_product_name)" | tr '[:upper:]' '[:lower:]' | tr ' ' '-'
```

## Adding Hardware Support

### Step 1: Identify Your Hardware

```bash
# Get vendor and model
cat /sys/class/dmi/id/sys_vendor
cat /sys/class/dmi/id/product_name
cat /sys/class/dmi/id/product_version

# Get GPU info
lspci | grep -i vga

# Or use the detection script
source scripts/lib/hardware-detect.sh
print_hardware_info
```

Example output:
```
Hardware Information:
  Vendor: HP
  Product: ZBook Ultra G1a 14 inch Mobile Workstation PC
  Version: SBKPFV3
  GPU: amd
  CPU: amd
  Model Dir: hp-hp-zbook-ultra-g1a-14-inch-mobile-workstation-pc
```

### Step 2: Create Hardware Directory

```bash
# Create directory based on model
mkdir -p "hardware/$(get_model_directory)"

# Example for HP ZBook G1a:
mkdir -p hardware/hp-zbook-ultra-g1a-14-inch-mobile-workstation-pc
```

### Step 3: Create Configuration Script

```bash
# Create config script
cat > "hardware/$(get_model_directory)/config.sh" << 'EOF'
#!/bin/bash

# Hardware-specific configurations for [Your Laptop Model]
# Vendor: [Vendor]
# Model: [Model]

print_step "Applying [Vendor] [Model] specific configurations..."

# Add your configurations here
# Examples below...

print_success "[Vendor] [Model] configuration complete"
EOF
```

### Step 4: Add GPU-Specific Config (if needed)

For NVIDIA GPUs, you might need suspend fixes:

```bash
# Already exists: hardware/nvidia/suspend-fix.sh
# Edit it to add more NVIDIA-specific configurations
```

## Common Hardware Configurations

### Suspend/Resume Fixes

NVIDIA GPUs often need special kernel parameters for proper suspend/resume functionality.

**Note for Omarchy 3.4.1+**: Omarchy uses Limine bootloader (not GRUB). NVIDIA kernel parameters must be configured manually in Limine:

```bash
# Add to /etc/limine-entry-tool.d/nvidia.conf
echo 'KERNEL_CMDLINE[default]+="nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"' | sudo tee /etc/limine-entry-tool.d/nvidia.conf
sudo limine-update
```

The NVIDIA script automatically handles:
- Persistence mode configuration
- Systemd suspend/resume service enablement

But kernel parameters require manual configuration due to Limine's different architecture.

### Keyboard Backlight

Some laptops need specific configurations for keyboard backlight:

```bash
# hardware/dell-xps-13/config.sh
setup_keyboard_backlight() {
    # Enable keyboard backlight on boot
    echo "options dell-laptop kbd_backlight=on" | sudo tee /etc/modprobe.d/dell-keyboard.conf
}
```

### Fingerprint Reader

Configure fingerprint reader support:

```bash
# hardware/lenovo-thinkpad-x1/config.sh
setup_fingerprint() {
    # Install fingerprint driver if needed
    if ! package_installed fprintd; then
        sudo pacman -S fprintd
    fi
    
    # Enable service
    sudo systemctl enable fprintd
    
    print_info "Fingerprint reader configured"
    print_info "Enroll fingerprints with: fprintd-enroll"
}
```

### Trackpad Gestures

Configure multi-touch gestures:

```bash
# hardware/framework-13/config.sh
setup_trackpad() {
    # Install touchégg for gestures
    if ! package_installed touchegg; then
        yay -S touchegg
    fi
    
    # Enable service
    systemctl --user enable touchegg
    systemctl --user start touchegg
    
    print_info "Trackpad gestures configured"
}
```

### WiFi Power Management

Some WiFi cards need power management tweaks:

```bash
# hardware/asus-zenbook/config.sh
setup_wifi() {
    # Disable WiFi power save (prevents disconnections)
    echo "options iwlwifi power_save=0" | sudo tee /etc/modprobe.d/iwlwifi.conf
    
    print_info "WiFi power management configured"
    mark_restart_needed
}
```

### Audio Fixes

Some laptops need specific audio configurations:

```bash
# hardware/hp-envy/config.sh
setup_audio() {
    # Install sof-firmware for Intel sound cards
    if ! package_installed sof-firmware; then
        sudo pacman -S sof-firmware
    fi
    
    # Configure ALSA
    echo "options snd_hda_intel power_save=0" | sudo tee /etc/modprobe.d/audio.conf
    
    print_info "Audio configured"
}
```

### Display/HDR

Configure display settings:

```bash
# hardware/apple-macbook-pro/config.sh
setup_display() {
    # Enable HDR support
    echo "export ENABLE_HDR_WSI=1" >> ~/.config/hypr/envs.conf
    
    print_info "Display settings configured"
}
```

## Testing Hardware Configs

### Test in Isolation

```bash
# Test just the hardware script
source scripts/lib/common.sh
source scripts/lib/hardware-detect.sh
source hardware/nvidia/suspend-fix.sh
```

### Test with Dry Run

```bash
# Test with full installer
./install.sh --dry-run
```

### Verify Detection

```bash
# Check if your hardware is detected
source scripts/lib/hardware-detect.sh

# Should match your created directory
get_model_directory

# Check if GPU detected correctly
detect_gpu
```

## Directory Naming

### Automatic Naming

The detection script creates directory names automatically:

```bash
# Input
Vendor: HP
Product: ZBook Ultra G1a

# Output
hp-zbook-ultra-g1a
```

### Rules

- Convert to **lowercase**
- Replace **spaces** with **hyphens**
- Remove **special characters**

### Manual Override

If automatic naming doesn't work, you can create multiple aliases:

```bash
# Create symlinks for common variations
ln -s hp-zbook-ultra-g1a-14-inch-mobile-workstation-pc hardware/hp-zbook-g1a
ln -s hp-zbook-ultra-g1a-14-inch-mobile-workstation-pc hardware/zbook-g1a
```

## GPU-Specific Configs

### NVIDIA

Common issues:
- Suspend/resume problems
- Screen tearing
- Wayland compatibility

See: `hardware/nvidia/suspend-fix.sh`

### AMD

Usually works out-of-the-box, but sometimes needs:
- FreeSync configuration
- Power profile tuning
- Kernel parameter tweaks

### Intel

Usually works out-of-the-box, but sometimes needs:
- Iris/Xe driver configuration
- Video acceleration setup
- Panel self-refresh (PSR) tweaks

## Submitting Hardware Support

If you add support for a new device:

1. **Test thoroughly**
   - Test suspend/resume
   - Test all hardware features
   - Run installer multiple times (idempotency check)

2. **Document in README**
   - What the config does
   - Why it's needed
   - Any special notes

3. **Create minimal config**
   - Only include necessary changes
   - Don't duplicate Omarchy defaults
   - Comment all changes

4. **Consider upstreaming**
   - Some fixes might belong in Omarchy itself
   - Check with Omarchy developers
   - https://github.com/omarchy/omarchy

## Troubleshooting

### Hardware config not running

1. **Check detection**:
   ```bash
   source scripts/lib/hardware-detect.sh
   get_full_model
   get_model_directory
   ```

2. **Verify directory exists**:
   ```bash
   ls -la hardware/$(get_model_directory)/
   ```

3. **Check script is executable**:
   ```bash
   chmod +x hardware/$(get_model_directory)/*.sh
   ```

4. **Test script directly**:
   ```bash
   bash hardware/$(get_model_directory)/config.sh
   ```

### Config causes problems

1. **Remove the config**:
   ```bash
   mv hardware/$(get_model_directory) hardware/$(get_model_directory).disabled
   ```

2. **Revert changes**:
   ```bash
   # Restore from backup
   cp ~/.local/share/omarchy-customization/backups/YYYYMMDD_HHMMSS/* ~/.config/
   ```

3. **Fix the config**:
   - Debug the issue
   - Update the script
   - Test again

## Resources

- [Arch Wiki - Laptop](https://wiki.archlinux.org/title/Laptop)
- [Arch Wiki - NVIDIA](https://wiki.archlinux.org/title/NVIDIA)
- [Arch Wiki - AMDGPU](https://wiki.archlinux.org/title/AMDGPU)
- [Arch Wiki - Intel graphics](https://wiki.archlinux.org/title/Intel_graphics)
- [Linux Laptop Compatibility](https://linux-laptop.net/)

## Examples in This Repository

- `hardware/hp-zbook-g1a/` - Example with no special config needed
- `hardware/nvidia/suspend-fix.sh` - NVIDIA suspend/resume workaround

## Contributing

When adding new hardware support:
1. Follow the AGENTS.md guidelines
2. Test thoroughly
3. Document clearly
4. Update this file
