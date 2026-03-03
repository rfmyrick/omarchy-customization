# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-03-03

### Added
- Initial release of Omarchy customization scripts
- Comprehensive documentation suite (README, guides, troubleshooting)
- Starship prompt configuration script (55-starship.sh) with full idempotency
- CHANGELOG.md using Keep a Changelog format
- .gitignore for repository hygiene
- Full idempotency across all scripts with marker files, pattern checks, and backups

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
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Technical architecture
- [docs/CUSTOMIZATION_GUIDE.md](docs/CUSTOMIZATION_GUIDE.md) - Customization instructions
- [docs/POWER_MANAGEMENT.md](docs/POWER_MANAGEMENT.md) - Power settings
- [docs/VPN_SETUP.md](docs/VPN_SETUP.md) - VPN configuration
- [docs/SYNCTHING_SETUP.md](docs/SYNCTHING_SETUP.md) - Syncthing setup
- [docs/HARDWARE_SUPPORT.md](docs/HARDWARE_SUPPORT.md) - Hardware-specific configs
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues

## System Requirements

- **Omarchy**: Version 3.4.1 or later
- **Bootloader**: Limine (Omarchy default)
- **Shell**: Bash
- **Init System**: systemd
- **Architecture**: x86_64

## Known Limitations

- NVIDIA kernel parameters require manual configuration when using Limine bootloader
  (Omarchy 3.4.1 uses Limine instead of GRUB)
- Some hardware-specific configurations may require manual adjustments
- Theme installation requires internet connection and may take several minutes
