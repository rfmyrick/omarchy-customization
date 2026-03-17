#!/bin/bash

# Omarchy Customization Master Installer
# This script orchestrates all customization scripts

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Parse arguments
DRY_RUN=false
for arg in "$@"; do
	case $arg in
	--dry-run)
		DRY_RUN=true
		shift
		;;
	esac
done

export DRY_RUN

# Source common functions
source scripts/lib/common.sh

# Initialize
init_logging

if [[ "$DRY_RUN" == true ]]; then
	print_header "Omarchy Customization Installer (DRY RUN)"
	print_info "No changes will be made to the system"
else
	print_header "Omarchy Customization Installer"
fi

log_info "Starting installation from $SCRIPT_DIR"

# Array of scripts to run (in order)
SCRIPTS=(
	"00-prerequisites.sh"
	"05-packages-simple.sh"
	"10-system-config.sh"
	"15-packages-complex.sh"
	"16-flatpak-setup.sh"
	"17-hidpi-config.sh"
	"20-apps-setup.sh"
	"30-webapps.sh"
	"40-hyprland-overrides.sh"
	"50-keybindings.sh"
	"55-starship.sh"
	"60-hardware-specific.sh"
	"61-thunderbolt-fix.sh"
	"70-themes.sh"
	"80-configs-only.sh"
	"90-terminals.sh"
	"99-finalize.sh"
)

# Run each script, continuing on error
for script in "${SCRIPTS[@]}"; do
	script_path="scripts/$script"

	if [[ -f "$script_path" ]]; then
		print_header "Running: $script"
		log_info "Executing $script"

		if source "$script_path"; then
			log_success "$script completed"
		else
			log_error "$script failed with exit code $?"
			record_failure "Script execution: $script"
			print_warning "Continuing despite error in $script"
		fi
	else
		log_warning "Script not found: $script_path"
	fi
done

# Print final summary
print_summary

if [[ "$DRY_RUN" == true ]]; then
	echo ""
	echo "To apply these changes, run without --dry-run:"
	echo "  ./install.sh"
fi

exit 0
