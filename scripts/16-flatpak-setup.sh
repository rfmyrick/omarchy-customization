#!/bin/bash

# Flatpak setup and application installation
# This script installs flatpak, adds Flathub repository, and installs configured Flatpak apps

print_step "Setting up Flatpak and installing applications..."

# Configuration file for Flatpak packages
FLATPAK_CONFIG="$SCRIPT_DIR/config/flatpaks.conf"

# Install flatpak package and add Flathub repository
setup_flatpak() {
	if ! package_installed flatpak; then
		print_info "Installing Flatpak package manager..."
		if run_cmd "sudo pacman -S --needed --noconfirm flatpak" "Install flatpak package"; then
			print_success "Flatpak installed"
		else
			record_failure "Flatpak package installation"
			return 1
		fi
	else
		print_success "Flatpak is already installed"
	fi

	# Check if Flathub repository is configured
	if ! flatpak remotes 2>/dev/null | grep -q "flathub"; then
		print_info "Adding Flathub repository..."
		if run_cmd "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" "Add Flathub repository"; then
			print_success "Flathub repository added"
			mark_restart_needed
		else
			record_failure "Flathub repository setup"
			return 1
		fi
	else
		print_success "Flathub repository already configured"
	fi
}

# Install configured Flatpak applications
install_flatpaks() {
	# Check if config file exists
	if [[ ! -f "$FLATPAK_CONFIG" ]]; then
		print_warning "Flatpak config file not found: $FLATPAK_CONFIG"
		print_info "Skipping Flatpak application installation"
		return 0
	fi

	# Source the config file to get FLATPAK_PACKAGES array
	source "$FLATPAK_CONFIG"

	# Check if there are any packages to install
	if [[ ${#FLATPAK_PACKAGES[@]} -eq 0 ]]; then
		print_info "No Flatpak packages configured"
		return 0
	fi

	print_step "Installing Flatpak applications..."

	for app_id in "${FLATPAK_PACKAGES[@]}"; do
		# Skip comments and empty lines
		[[ "$app_id" =~ ^#.*$ ]] && continue
		[[ -z "$app_id" ]] && continue

		# Check if already installed
		if flatpak list --app 2>/dev/null | grep -q "${app_id}$"; then
			print_success "$app_id is already installed"
			continue
		fi

		print_info "Installing $app_id..."
		if run_cmd "flatpak install -y flathub $app_id" "Install $app_id"; then
			print_success "$app_id installed successfully"

			# Special handling for known apps
			case "$app_id" in
			tv.plex.PlexDesktop)
				print_info "Note: Plex requires authentication on first launch"
				print_info "Launch with: flatpak run $app_id"
				;;
			esac
		else
			print_error "Failed to install $app_id"
			record_failure "Flatpak installation: $app_id"
		fi
	done
}

# Run setup functions
setup_flatpak
install_flatpaks

print_success "Flatpak setup complete"
