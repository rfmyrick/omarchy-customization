# HP ZBook G1a

This directory contains hardware-specific configurations for the HP ZBook G1a laptop.

## Status

**No special configuration required.**

The HP ZBook G1a works out-of-the-box with Omarchy and requires no hardware-specific modifications.

## Hardware Specifications

- **Vendor**: HP
- **Model**: ZBook Ultra G1a 14 inch Mobile Workstation PC
- **CPU**: AMD Ryzen AI MAX+ PRO 395 with Radeon 8060S Graphics
- **GPU**: AMD Strix Halo (integrated graphics)
- **Network**: MediaTek MT7925 WiFi 7

## Why No Special Config?

This laptop uses:
- AMD integrated graphics (no NVIDIA discrete GPU)
- Standard ACPI implementation
- Well-supported WiFi chipset
- Standard keyboard and trackpad

All hardware is properly supported by the Linux kernel and Omarchy defaults.

## If You Have Issues

If you experience any hardware-specific issues:

1. Check the [Omarchy forums](https://github.com/omarchy/omarchy/discussions)
2. Review [Arch Linux Wiki - HP ZBook](https://wiki.archlinux.org/)
3. Create an issue in this repository

## Testing

To verify hardware detection:

```bash
source scripts/lib/hardware-detect.sh
print_hardware_info
```

Should output:
```
Hardware Information:
  Vendor: HP
  Product: HP ZBook Ultra G1a 14 inch Mobile Workstation PC
  Version: SBKPFV3
  GPU: amd
  CPU: amd
  Model Dir: hp-hp-zbook-ultra-g1a-14-inch-mobile-workstation-pc
```
