#!/bin/bash

# Flatpak setup and application installation
# This script installs flatpak, adds Flathub repository, and installs Plex Media Server client

print_step "Setting up Flatpak and installing applications..."

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

# Install Plex Media Server client via Flatpak
install_plex() {
	print_step "Installing Plex Media Server client..."

	# Check if Plex is already installed via flatpak
	if flatpak list --app 2>/dev/null | grep -q "tv.plex.PlexDesktop"; then
		print_success "Plex is already installed"
		return 0
	fi

	print_info "Installing Plex Desktop from Flathub..."
	print_info "Note: Plex will require authentication on first launch"

	if run_cmd "flatpak install -y flathub tv.plex.PlexDesktop" "Install Plex Desktop"; then
		print_success "Plex Desktop installed successfully"
		print_info "Launch Plex from the app menu or with: flatpak run tv.plex.PlexDesktop"
		print_info "Note: You'll need to sign in with your Plex account on first launch"
	else
		print_error "Failed to install Plex Desktop"
		record_failure "Plex Desktop installation"
		return 1
	fi
}

# Run setup functions
setup_flatpak
install_plex

print_success "Flatpak and Plex setup complete"
