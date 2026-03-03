#!/bin/bash

# System configuration
# Sets up power profiles, suspend/hibernate, lid behavior

print_step "Configuring system settings..."

# Setup hibernation
setup_hibernation() {
	# Check if hibernation is already set up
	if [[ -f /etc/mkinitcpio.conf.d/omarchy_resume.conf ]]; then
		print_success "Hibernation is already configured"
	else
		print_info "Setting up hibernation (this requires sudo)..."
		if run_cmd "omarchy-hibernation-setup --force" "Setup hibernation"; then
			print_success "Hibernation setup initiated"
		else
			print_warning "Hibernation setup may have failed"
			record_failure "Hibernation setup"
		fi
	fi

	# Modify hibernate delay from 30min to 90min
	local sleep_conf="/etc/systemd/sleep.conf.d/99-custom-sleep.conf"
	if [[ ! -f "$sleep_conf" ]] || ! grep -q "HibernateDelaySec=90min" "$sleep_conf" 2>/dev/null; then
		print_info "Setting hibernate delay to 90 minutes..."

		if [[ "${DRY_RUN:-false}" == true ]]; then
			echo "[DRY-RUN] Would create $sleep_conf with 90min hibernate delay"
		else
			backup_file "$sleep_conf"
			sudo mkdir -p "$(dirname "$sleep_conf")"
			cat <<'EOF' | sudo tee "$sleep_conf" >/dev/null
[Sleep]
# Extend suspend-then-hibernate delay from 30min to 90min
HibernateDelaySec=90min
# Never hibernate when on AC power
HibernateOnACPower=no
EOF
			print_success "Hibernate delay configured"
			mark_restart_needed
		fi
	else
		print_success "Hibernate delay already configured"
	fi
}

# Setup lid switch behavior
setup_lid_switch() {
	local logind_conf="/etc/systemd/logind.conf.d/99-custom-lid.conf"

	if [[ ! -f "$logind_conf" ]]; then
		print_info "Setting up lid switch behavior..."

		if [[ "${DRY_RUN:-false}" == true ]]; then
			echo "[DRY-RUN] Would create $logind_conf with custom lid behavior"
		else
			backup_file "$logind_conf"
			sudo mkdir -p "$(dirname "$logind_conf")"
			cat <<'EOF' | sudo tee "$logind_conf" >/dev/null
[Login]
# Suspend when lid is closed on battery power
HandleLidSwitch=suspend
# Do NOT suspend when lid is closed on AC power (for docked/external monitor use)
HandleLidSwitchExternalPower=ignore
# Ignore lid when docked
HandleLidSwitchDocked=ignore
EOF
			print_success "Lid switch behavior configured"
			mark_restart_needed
		fi
	else
		print_success "Lid switch behavior already configured"
	fi
}

# Setup power profiles
setup_power_profiles() {
	local omarchy_rule="/etc/udev/rules.d/99-power-profile.rules"
	local old_custom_rule="/etc/udev/rules.d/99-power-profile-custom.rules"

	# Clean up old custom rule file (it sorts before Omarchy's and gets overridden anyway)
	if [[ -f "$old_custom_rule" ]]; then
		print_info "Removing old custom power profile rule..."
		if [[ "${DRY_RUN:-false}" == true ]]; then
			echo "[DRY-RUN] Would remove: $old_custom_rule"
		else
			backup_file "$old_custom_rule"
			sudo rm -f "$old_custom_rule"
			print_success "Removed old custom rule"
		fi
	fi

	# Check if Omarchy's rule needs to be modified (should have power-saver on battery)
	if [[ ! -f "$omarchy_rule" ]]; then
		print_warning "Omarchy power profile rule not found at $omarchy_rule"
		record_failure "Power profile setup - rule not found"
	elif grep -q 'ATTR{online}=="0".*powerprofilesctl set balanced' "$omarchy_rule" 2>/dev/null; then
		print_info "Updating Omarchy power profile to use power-saver on battery..."

		if [[ "${DRY_RUN:-false}" == true ]]; then
			echo "[DRY-RUN] Would modify $omarchy_rule to use power-saver on battery"
		else
			backup_file "$omarchy_rule"
			# Use sed to replace balanced with power-saver on the battery line only
			sudo sed -i 's/powerprofilesctl set balanced/powerprofilesctl set power-saver/' "$omarchy_rule"
			# Reload udev rules
			sudo udevadm control --reload-rules
			print_success "Updated power profile: power-saver on battery, performance on AC"
		fi
	elif grep -q 'ATTR{online}=="0".*powerprofilesctl set power-saver' "$omarchy_rule" 2>/dev/null; then
		print_success "Power profiles already configured correctly (power-saver on battery)"
	else
		print_warning "Could not determine power profile configuration state"
		record_failure "Power profile setup - unknown state"
	fi
}

# Enable suspend in system menu
enable_suspend_menu() {
	local toggle_file="$HOME/.local/state/omarchy/toggles/suspend-on"

	if [[ -f "$toggle_file" ]]; then
		print_success "Suspend is already enabled in system menu"
	else
		print_info "Enabling suspend in system menu..."
		if run_cmd "omarchy-toggle-suspend" "Enable suspend in menu"; then
			print_success "Suspend enabled in system menu"
		else
			record_failure "Enable suspend menu"
		fi
	fi
}

# Run setup functions
setup_hibernation
setup_lid_switch
setup_power_profiles
enable_suspend_menu

print_success "System configuration complete"
