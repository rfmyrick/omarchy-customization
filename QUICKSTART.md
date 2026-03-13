# Quick Start Guide

Get your Omarchy system customized quickly with this guide.

## Prerequisites

Before you begin, ensure you have:
1. A working Omarchy installation
2. Cider purchased and downloaded (see [CHECKLIST.md](CHECKLIST.md))
3. Internet connection
4. Sudo access

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/YOURUSER/omarchy-customization.git
cd omarchy-customization
```

### 2. Review Configuration Files

Take a moment to review the configuration files in the `configs/` directory:

```bash
# List all config files
ls -la configs/

# Review window rules template
cat configs/hypr/window-rules.conf

# Review system configurations
cat configs/systemd/sleep.conf.d/99-custom-sleep.conf
```

Note: Hyprland configurations (bindings, window rules, etc.) are maintained directly in `~/.config/hypr/` after installation.

Make any desired changes before running the installer.

### 3. Run Dry-Run Mode (Recommended)

Always run in dry-run mode first to see what changes will be made:

```bash
./install.sh --dry-run
```

This will:
- Show all packages that would be installed
- Display all configuration changes
- Indicate which files would be backed up
- Report any missing prerequisites (like Cider)

**No changes will be made to your system.**

### 4. Review the Output

Check the dry-run output for:
- Any warnings about missing prerequisites
- List of packages to be installed
- Configuration files that will be modified
- Hardware that was detected

### 5. Apply Changes

When you're ready to apply the customizations:

```bash
./install.sh
```

The installer will:
1. Check prerequisites
2. Create backups of existing files
3. Install packages
4. Apply configurations
5. Show a summary of what was done

### 6. Post-Installation

After installation completes:

1. **Review the summary** - Check for any failures or warnings
2. **Check if restart is needed** - The script will indicate this
3. **Complete the checklist** - Follow [CHECKLIST.md](CHECKLIST.md) for authentication steps
4. **Verify customizations** - Test keybindings, themes, etc.

## Troubleshooting

### Installation fails

Check the log file for details:
```bash
cat ~/.local/share/omarchy-customization/logs/latest.log
```

### Cider not found

Ensure you've:
1. Purchased Cider from [cider.sh](https://cider.sh/)
2. Downloaded the `.pkg.tar.zst` file
3. Placed it in `~/Downloads/`

### Permission denied

Make sure the install script is executable:
```bash
chmod +x install.sh
```

## Next Steps

- Review [CHECKLIST.md](CHECKLIST.md) for post-installation tasks
- Read [docs/CUSTOMIZATION_GUIDE.md](docs/CUSTOMIZATION_GUIDE.md) to learn how to customize further
- Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) if you encounter issues

## Getting Help

- **Omarchy issues**: https://manuals.omamix.org/
- **Customization issues**: Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Logs**: `~/.local/share/omarchy-customization/logs/latest.log`
