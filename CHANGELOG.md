# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-03-17

### Added
- Thunderbolt dock hotplug fix for HP ZBook Ultra G1a (61-thunderbolt-fix.sh)
  - Resolves lockups when connecting/disconnecting Thunderbolt docks
  - Fixes input device issues (trackpad/keyboard stops working)
  - Auto-reloads Hyprland on dock connect/disconnect
  - Disables USB/Thunderbolt autosuspend
- Dedicated HiDPI configuration script (17-hidpi-config.sh)
  - Separated from Flatpak setup for better organization
  - Configures Plex and other apps for HiDPI displays
  - Uses explicit 2x scaling for optimal display quality
- Comprehensive Thunderbolt troubleshooting documentation (docs/THUNDERBOLT_FIX.md)
- Starship prompt configuration script (55-starship.sh)

### Changed
- Separated HiDPI configuration from Flatpak installation script
  - Flatpak script now focuses only on app installation
  - HiDPI configuration moved to dedicated script (17-hidpi-config.sh)
  - Better single-responsibility principle adherence
- Updated PIA VPN installation to not use sudo
  - Installer handles privilege escalation internally
  - Better compatibility with PIA's installer requirements
- Removed llmfit from package list (AUR build errors)

### Fixed
- Hyprland config concatenation issue (missing newline before source directive)
- PIA VPN installation failures due to incorrect sudo usage
- Added missing 55-starship.sh and 61-thunderbolt-fix.sh to install.sh

## [1.0.0] - 2025-03-03

### Added
- Initial release of Omarchy customization scripts
- Comprehensive documentation suite (README, guides, troubleshooting)
- Starship prompt configuration script (55-starship.sh) with full idempotency
- CHANGELOG.md using Keep a Changelog format
- .gitignore for repository hygiene
- Full idempotency across all scripts with marker files, pattern checks, and backups
- **Flatpak package manager support** (`scripts/16-flatpak-setup.sh`) with Flathub repository
- **Plex Media Server client** installation via Flatpak (`tv.plex.PlexDesktop`)

### Changed
- Updated hibernate delay from 60min to 90min (consistent across all configs)
- Changed power profile on battery from `balanced` to `power-saver` (configs already updated)
- Modernized NVIDIA script for Limine bootloader compatibility (Omarchy default)
  - Removed GRUB kernel parameter configuration
  - Added conditional GPU execution (only runs on NVIDIA systems)
  - Added informational messages about manual Limine configuration
- Added yay verification before AUR package installation (with fallback)

### Fixed
- Fixed hardware detection typo (`$GPU` -> `$gpu`) in hardware-detect.sh
- **Fixed power profile configuration bug**: Modified Omarchy's rules directly instead of creating conflicting custom file that was being overridden by alphabetical ordering
- **Fixed idempotency in suspend toggle** (`10-system-config.sh`): Script was checking for wrong state file (`suspend-on` instead of `suspend-off`), causing toggle to flip on every run
- **Fixed idempotency in PIA VPN** (`20-apps-setup.sh`): Now checks for `/usr/local/bin/piactl` to determine if installed, preventing installer from launching GUI on repeated runs

### Compatibility
- **Tested and validated against Omarchy 3.4.1**
- Compatible with Limine bootloader (Omarchy default in 3.4.1+)
- All scripts maintain full idempotency and dry-run support

## Idempotency Features

All scripts in this release implement comprehensive idempotency:

- **Marker Files**: Use `is_done()` and `mark_done()` for complex operations
- **Pattern Checks**: Use `grep` to detect if changes are already applied
- **File Existence**: Check `[[ -f ]]` before modifying
- **Backups**: Use `backup_file()` before any file modifications
- **Dry-Run Support**: All scripts check `$DRY_RUN` before making changes
- **Safe Re-execution**: Scripts can be run multiple times without side effects

## Documentation

Comprehensive documentation is available:
- [README.md](README.md) - Overview and quick start
- [AGENTS.md](AGENTS.md) - Guidelines for AI agents
- [CHECKLIST.md](CHECKLIST.md) - Pre/post installation tasks
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Technical architecture
- [docs/CUSTOMIZATION_GUIDE.md](docs/CUSTOMIZATION_GUIDE.md) - Customization instructions
- [docs/POWER_MANAGEMENT.md](docs/POWER_MANAGEMENT.md) - Power settings
- [docs/VPN_SETUP.md](docs/VPN_SETUP.md) - VPN configuration
- [docs/SYNCTHING_SETUP.md](docs/SYNCTHING_SETUP.md) - Syncthing setup
- [docs/HARDWARE_SUPPORT.md](docs/HARDWARE_SUPPORT.md) - Hardware-specific configs
- [docs/THUNDERBOLT_FIX.md](docs/THUNDERBOLT_FIX.md) - Thunderbolt dock troubleshooting
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues

## System Requirements

- **Omarchy**: Version 3.4.1 or later
- **Bootloader**: Limine (Omarchy default)
- **Shell**: Bash
- **Init System**: systemd
- **Architecture**: x86_64

## Known Limitations

- HP ZBook Ultra G1a may experience Thunderbolt dock lockups without the fix applied
  (See scripts/61-thunderbolt-fix.sh and docs/THUNDERBOLT_FIX.md)
- NVIDIA kernel parameters require manual configuration when using Limine bootloader
  (Omarchy 3.4.1 uses Limine instead of GRUB)
- Some hardware-specific configurations may require manual adjustments
- Theme installation requires internet connection and may take several minutes
