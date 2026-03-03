# Hardware-Specific Configurations

This directory contains hardware-specific configuration scripts.

## Overview

Different hardware may require specific configurations to work optimally with Omarchy. This directory provides a framework for detecting and applying these configurations automatically.

## How It Works

1. **Detection**: The `detect.sh` script and `hardware-detect.sh` library identify your hardware
2. **Matching**: The system looks for matching directories based on:
   - GPU type (nvidia, amd, intel)
   - System vendor and model
3. **Application**: Matching configuration scripts are executed automatically

## Current Hardware Support

### GPUs

- **AMD**: No special configuration needed for most systems
- **Intel**: No special configuration needed for most systems  
- **NVIDIA**: May require suspend/hibernation fixes (see `nvidia/`)

### Laptops

- **HP ZBook G1a**: No special configuration needed

## Adding Hardware Support

To add support for new hardware:

1. **Identify the hardware**:
   ```bash
   cat /sys/class/dmi/id/sys_vendor
   cat /sys/class/dmi/id/product_name
   lspci | grep -i vga
   ```

2. **Create a directory**:
   ```bash
   mkdir hardware/<vendor>-<model>
   # Example: mkdir hardware/dell-xps-13
   ```

3. **Add configuration script**:
   ```bash
   touch hardware/<vendor>-<model>/config.sh
   ```

4. **Write the configuration**:
   ```bash
   #!/bin/bash
   print_step "Applying <vendor> <model> specific configurations..."
   
   # Add your hardware-specific configurations here
   # Examples:
   # - Kernel parameters
   # - Module configurations
   # - Device-specific tweaks
   ```

5. **Test the configuration**:
   - Run `./install.sh --dry-run` to verify
   - Apply changes with `./install.sh`
   - Test all functionality

## Guidelines

- Keep configurations minimal and focused
- Document what each setting does
- Always backup before modifying system files
- Test thoroughly before committing
- Use idempotent operations (safe to run multiple times)

## Troubleshooting

If hardware-specific configs aren't being applied:

1. Check detection:
   ```bash
   source scripts/lib/hardware-detect.sh
   get_full_model
   detect_gpu
   ```

2. Verify directory naming:
   - Convert to lowercase
   - Replace spaces with hyphens
   - Match exactly what's returned by `get_model_directory`

3. Check permissions:
   - Scripts must be readable and executable
   - Use `chmod +x hardware/*/config.sh`

## Resources

- [Omarchy Hardware Forum](https://github.com/omarchy/omarchy/discussions)
- [Arch Linux Wiki - Hardware](https://wiki.archlinux.org/title/Category:Hardware)
- [Kernel Parameters](https://wiki.archlinux.org/title/Kernel_parameters)
