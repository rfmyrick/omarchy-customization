# Omarchy Customization

A comprehensive set of idempotent shell scripts and configuration files to customize [Omarchy](https://omarchy.org/) Linux systems after a fresh install.

## Overview

This repository provides:
- **Idempotent scripts** - Safe to run multiple times
- **Survives Omarchy updates** - Uses override patterns instead of modifying stock configs
- **Hardware-specific support** - Extensible architecture for different laptops
- **Comprehensive logging** - Full transparency of all changes
- **Dry-run support** - Preview changes before applying

## What Gets Customized

### System Configuration
- Power profiles (power-saver on battery, performance on AC)
- Suspend/hibernate behavior (90min delay, no suspend on AC)
- Lid switch behavior (suspend on battery, ignore on AC for docked use)

### Applications
- **Cider** - Apple Music client (requires manual download)
- **Private Internet Access VPN** - VPN client with auto-connect
- **Syncthing** - File synchronization with firewall rules
- **Plex Media Server** - Media client (via Flatpak, requires Plex account)

### Web Apps
- **t3.chat** - AI chat interface (replaces ChatGPT binding)

### Desktop Environment
- Custom keybindings (Cider for music, t3.chat for AI)
- Ethereal theme with all extra themes installed
- Hyprland overrides (survives Omarchy updates)

### Utilities
- Modern CLI tools (fzf, ripgrep, fd, bat, eza, etc.)

## Prerequisites

1. [Omarchy](https://omarchy.org/) installed and running
2. Cider purchased and downloaded (see [CHECKLIST.md](CHECKLIST.md))
3. Sudo access for system-level changes

## System Requirements / Compatibility

**Tested and compatible with:**
- **Omarchy**: Version 3.4.1 or later
- **Bootloader**: Limine (Omarchy default in 3.4.1+)
- **Shell**: Bash
- **Init System**: systemd

This customization is designed for Omarchy Linux systems. While it may work on other Arch-based distributions, it has been specifically tested and validated against Omarchy 3.4.1.

**Note**: Omarchy 3.4.1 uses Limine bootloader instead of GRUB. NVIDIA-specific kernel parameters require manual configuration in Limine if needed.

## Quick Start

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

```bash
# 1. Clone the repository
git clone https://github.com/YOURUSER/omarchy-customization.git
cd omarchy-customization

# 2. Review and customize configs/ as desired

# 3. Run in dry-run mode first
./install.sh --dry-run

# 4. Apply changes
./install.sh
```

## Pre-Installation Checklist

See [CHECKLIST.md](CHECKLIST.md) for complete pre and post installation tasks.

**Critical pre-requisites:**
- [ ] Purchase and download Cider from [cider.sh](https://cider.sh/)
- [ ] Place Cider package in `~/Downloads/`
- [ ] Review `configs/` directory for any customizations you want to make

## Documentation

- [QUICKSTART.md](QUICKSTART.md) - Get started quickly
- [CHECKLIST.md](CHECKLIST.md) - Pre/post installation tasks
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - How the customization system works
- [docs/CUSTOMIZATION_GUIDE.md](docs/CUSTOMIZATION_GUIDE.md) - How to customize the configs
- [docs/POWER_MANAGEMENT.md](docs/POWER_MANAGEMENT.md) - Power settings explained
- [docs/VPN_SETUP.md](docs/VPN_SETUP.md) - PIA VPN configuration
- [docs/SYNCTHING_SETUP.md](docs/SYNCTHING_SETUP.md) - Syncthing configuration
- [docs/HARDWARE_SUPPORT.md](docs/HARDWARE_SUPPORT.md) - Adding hardware-specific configs
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues and solutions

## Repository Structure

```
omarchy-customization/
├── README.md              # This file
├── QUICKSTART.md          # Quick start guide
├── CHECKLIST.md           # Pre/post installation checklist
├── install.sh             # Master installer
├── config/
│   └── packages.conf      # Simple packages to install
├── scripts/               # Installation scripts
├── configs/               # Configuration files
├── apps/                  # App-specific documentation
├── hardware/              # Hardware-specific configs
└── docs/                  # Detailed documentation
```

## Safety Features

- **Automatic backups** - All modified files are backed up before changes
- **Idempotent** - Safe to run multiple times
- **Dry-run mode** - Preview all changes without applying
- **Comprehensive logging** - Complete log of all actions at `~/.local/share/omarchy-customization/logs/latest.log`
- **Error handling** - Continues on errors, reports summary at end

## Contributing

This is a personal customization repository shared for educational purposes. Feel free to fork and adapt for your own needs.

## License

MIT License - See LICENSE file for details.

## Support

For Omarchy-specific issues, refer to the [Omarchy documentation](https://manuals.omamix.org/).
For issues with these customization scripts, check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).
