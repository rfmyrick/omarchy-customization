#!/bin/bash

# Install applications that require manual setup or special handling

print_step "Installing applications..."

# Install Cider
install_cider() {
	print_step "Installing Cider (Apple Music client)..."

	if package_installed cider; then
		print_success "Cider is already installed"
		return 0
	fi

	# Look for any cider package in Downloads
	local cider_package=$(find "$HOME/Downloads" -name "cider-*-linux-x64.pkg.tar.zst" -type f 2>/dev/null | head -1)

	if [[ -z "$cider_package" ]]; then
		print_warning "Cider package not found in ~/Downloads/"
		print_info ""
		print_info "To install Cider:"
		print_info "  1. Visit: https://cider.sh/ or https://cidercollective.itch.io/cider"
		print_info "  2. Purchase and download Cider (supports the developers!)"
		print_info "  3. Download the .pkg.tar.zst file"
		print_info "  4. Place it in ~/Downloads/"
		print_info "  5. Run this script again"
		print_info ""
		record_failure "Cider installation - package not found"
		return 1
	fi

	print_info "Found Cider package: $(basename "$cider_package")"
	print_info "Installing..."

	if run_cmd "sudo pacman -U '$cider_package'" "Install Cider from $cider_package"; then
		print_success "Cider installed successfully"
		return 0
	else
		print_error "Failed to install Cider"
		record_failure "Cider installation"
		return 1
	fi
}

# Install PIA VPN
install_pia_vpn() {
	print_step "Installing Private Internet Access VPN..."

	# Check if PIA is already installed (command exists and service is active)
	if command_exists piavpn && systemctl is-active --quiet piavpn 2>/dev/null; then
		print_success "PIA VPN is already installed and running"
		return 0
	fi

	# Check if command exists but service is not running (needs setup)
	if command_exists piavpn; then
		print_warning "PIA VPN command exists but service is not active"
		print_info "Attempting to enable PIA VPN service..."

		if run_cmd "sudo systemctl enable --now piavpn" "Enable PIA VPN daemon"; then
			print_success "PIA VPN service enabled and started"
		else
			print_warning "Could not enable PIA VPN service automatically"
			print_info "You may need to run: sudo systemctl enable --now piavpn"
		fi

		return 0
	fi

	# Look for PIA installer in Downloads
	local pia_installer=$(find "$HOME/Downloads" -name "pia-linux-*.run" -type f 2>/dev/null | head -1)

	if [[ -z "$pia_installer" ]]; then
		print_warning "PIA VPN installer not found in ~/Downloads/"
		print_info ""
		print_info "To install PIA VPN:"
		print_info "  1. Visit: https://www.privateinternetaccess.com/download/linux-vpn"
		print_info "  2. Download the Linux installer (.run file)"
		print_info "  3. Place it in ~/Downloads/"
		print_info "  4. Run this script again"
		print_info ""
		record_failure "PIA VPN installation - installer not found"
		return 1
	fi

	print_info "Found PIA VPN installer: $(basename "$pia_installer")"
	print_info "Installing..."
	print_info "Note: PIA installer will prompt for elevated privileges when needed"

	# Make installer executable and run it (NOT as sudo - installer handles it)
	if [[ "${DRY_RUN:-false}" != true ]]; then
		chmod +x "$pia_installer"
	fi

	if run_cmd "'$pia_installer'" "Install PIA VPN from $pia_installer"; then
		print_success "PIA VPN installed successfully"

		# Enable and start the daemon
		print_info "Enabling PIA VPN daemon..."
		run_cmd "sudo systemctl enable --now piavpn" "Enable PIA VPN daemon"

		print_info "Launch with: piavpn or find it in the app launcher"
		print_info "Note: You'll need to log in with your PIA credentials on first launch"
		print_info "See docs/VPN_SETUP.md for configuration instructions"
	else
		print_error "Failed to install PIA VPN"
		record_failure "PIA VPN installation"
	fi
}

# Run installations
install_cider
install_pia_vpn
