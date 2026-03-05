#!/bin/bash

# HiDPI Display Configuration
# Configures applications for high-DPI displays (2880x1800, 4K, etc.)
# This ensures crisp, properly scaled UI on modern laptops

print_step "Configuring HiDPI display support..."

# Detect if we have a HiDPI display
# Omarchy sets GDK_SCALE=2 for HiDPI displays
detect_hidpi() {
	# Check Omarchy's GDK_SCALE setting
	if [[ "${GDK_SCALE:-1}" == "2" ]]; then
		return 0 # HiDPI detected
	fi

	# Also check display DPI via xrandr
	if command -v xrandr &>/dev/null; then
		# Look for displays with DPI > 150 (HiDPI threshold)
		local dpi=$(xrandr --listmonitors 2>/dev/null | grep -oE "[0-9]+/[0-9]+x[0-9]+/[0-9]+" | head -1 | cut -d'/' -f2)
		if [[ -n "$dpi" && "$dpi" -gt 150 ]]; then
			return 0 # HiDPI detected
		fi
	fi

	return 1 # Standard DPI
}

# Configure Flatpak apps for HiDPI
configure_flatpak_hidpi() {
	print_step "Configuring Flatpak applications for HiDPI..."

	# Check if Flatpak is installed
	if ! command -v flatpak &>/dev/null; then
		print_info "Flatpak not installed, skipping Flatpak HiDPI configuration"
		return 0
	fi

	# Configure Plex Media Server
	if flatpak list --app 2>/dev/null | grep -q "tv.plex.PlexDesktop"; then
		print_info "Configuring Plex for HiDPI display..."

		# Check current configuration
		local current_config=$(flatpak override --user tv.plex.PlexDesktop --show 2>/dev/null)

		if echo "$current_config" | grep -q "QT_SCALE_FACTOR=2"; then
			print_success "Plex already configured for HiDPI (2x scaling)"
		else
			if [[ "${DRY_RUN:-false}" == true ]]; then
				print_info "[DRY-RUN] Would configure Plex with 2x scaling and Fusion theme"
			else
				# Apply HiDPI configuration
				flatpak override --user tv.plex.PlexDesktop \
					--env=QT_SCALE_FACTOR=2 \
					--env=QT_STYLE_OVERRIDE=Fusion
				print_success "Plex configured for HiDPI (2x scaling, Fusion theme)"
			fi
		fi
	fi

	# Add more Flatpak HiDPI configurations here as needed
	# Example: Spotify, Discord, etc.
}

# Configure native Qt apps for HiDPI
configure_qt_hidpi() {
	print_step "Configuring native applications for HiDPI..."

	# Qt5/6 applications
	if [[ "${DRY_RUN:-false}" != true ]]; then
		# Set Qt environment variables for user
		local qt_config_file="$HOME/.config/environment.d/qt-hidpi.conf"

		if [[ ! -f "$qt_config_file" ]]; then
			mkdir -p "$(dirname "$qt_config_file")"
			cat >"$qt_config_file" <<'EOF'
# Qt HiDPI Configuration
QT_AUTO_SCREEN_SCALE_FACTOR=1
QT_SCALE_FACTOR=2
EOF
			print_success "Qt environment configured for HiDPI"
		else
			print_success "Qt HiDPI configuration already exists"
		fi
	else
		print_info "[DRY-RUN] Would create Qt HiDPI environment configuration"
	fi
}

# Main configuration logic
if detect_hidpi; then
	print_info "HiDPI display detected (GDK_SCALE=2 or high DPI detected)"
	print_info "Configuring applications for optimal display quality..."

	configure_flatpak_hidpi
	configure_qt_hidpi

	print_success "HiDPI configuration complete"
else
	print_info "Standard DPI display detected, skipping HiDPI configuration"
fi
