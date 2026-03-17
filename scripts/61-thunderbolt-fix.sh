#!/bin/bash

# Thunderbolt/Dock Connection Fix
# Resolves issues with HP ZBook Ultra G1a locking up when connecting/disconnecting Thunderbolt dock

print_step "Applying Thunderbolt dock connection fixes..."

# Fix 1: Remove conflicting logind configuration
fix_logind_conflict() {
	print_info "Checking for conflicting logind configurations..."

	if [[ -f /etc/systemd/logind.conf.d/lid.conf ]]; then
		if [[ "${DRY_RUN:-false}" == true ]]; then
			print_info "[DRY-RUN] Would remove conflicting /etc/systemd/logind.conf.d/lid.conf"
		else
			backup_file /etc/systemd/logind.conf.d/lid.conf
			sudo rm -f /etc/systemd/logind.conf.d/lid.conf
			print_success "Removed conflicting lid.conf"
			mark_restart_needed
		fi
	else
		print_success "No conflicting logind configuration found"
	fi
}

# Fix 2: Disable USB autosuspend for input devices
fix_usb_autosuspend() {
	print_info "Configuring USB autosuspend for dock stability..."

	local udev_rule="/etc/udev/rules.d/99-thunderbolt-dock.rules"

	if [[ ! -f "$udev_rule" ]]; then
		if [[ "${DRY_RUN:-false}" == true ]]; then
			print_info "[DRY-RUN] Would create $udev_rule to disable USB autosuspend for input devices"
		else
			backup_file "$udev_rule"
			cat <<'EOF' | sudo tee "$udev_rule" >/dev/null
# Disable USB autosuspend for input devices and Thunderbolt
# Prevents dock connection/disconnection issues on HP ZBook

# Disable autosuspend for all input devices (keyboard, mouse, trackpad)
ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", ATTR{power/control}="on"

# Disable autosuspend for Thunderbolt devices
ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{power/control}="on"

# Disable autosuspend for USB hubs (often in docks)
ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/control}="on"

# Reload displays on Thunderbolt connection/disconnection
ACTION=="add|remove", SUBSYSTEM=="thunderbolt", RUN+="/usr/bin/systemctl --no-block restart display-manager"
EOF
			sudo udevadm control --reload-rules
			print_success "Created USB/Thunderbolt autosuspend rules"
			mark_restart_needed
		fi
	else
		print_success "USB/Thunderbolt rules already configured"
	fi
}

# Fix 3: Add Hyprland monitor reload on display changes
fix_hyprland_hotplug() {
	print_info "Configuring Hyprland hotplug handling..."

	# Create a script to reload Hyprland on display changes
	local reload_script="$HOME/.local/bin/hyprland-reload-hotplug"
	local desktop_file="$HOME/.config/autostart/hyprland-hotplug.desktop"

	if [[ ! -f "$reload_script" ]]; then
		if [[ "${DRY_RUN:-false}" == true ]]; then
			print_info "[DRY-RUN] Would create hotplug reload script"
		else
			mkdir -p "$(dirname "$reload_script")"
			cat >"$reload_script" <<'EOF'
#!/bin/bash
# Auto-reload Hyprland when displays change (for dock hotplug)
# Runs as a background process

while true; do
    # Listen for display changes via dbus
    dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/freedesktop/UPower/devices/battery_BAT0'" 2>/dev/null | while read -r line; do
        if echo "$line" | grep -q "OnBattery"; then
            # Power state changed, likely dock event
            sleep 2
            # Only reload if hyprland is running
            if command -v hyprctl &>/dev/null && hyprctl monitors &>/dev/null; then
                hyprctl reload 2>/dev/null
            fi
        fi
    done
    sleep 5
done
EOF
			chmod +x "$reload_script"

			# Create autostart entry
			mkdir -p "$(dirname "$desktop_file")"
			cat >"$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=Hyprland Hotplug Handler
Exec=$reload_script
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Comment=Auto-reload Hyprland on display changes
EOF
			print_success "Created Hyprland hotplug reload script"
		fi
	else
		print_success "Hyprland hotplug script already exists"
	fi
}

# Fix 4: Add input device configuration to prevent sleep
fix_input_devices() {
	print_info "Configuring input device power management..."

	local modprobe_file="/etc/modprobe.d/thunderbolt-dock.conf"

	if [[ ! -f "$modprobe_file" ]]; then
		if [[ "${DRY_RUN:-false}" == true ]]; then
			print_info "[DRY-RUN] Would create $modprobe_file for Thunderbolt power settings"
		else
			cat <<'EOF' | sudo tee "$modprobe_file" >/dev/null
# Thunderbolt and USB power management for dock stability
# Prevents input device disconnections on HP ZBook

# Disable USB autosuspend globally for better dock compatibility
options usbcore autosuspend=-1

# Thunderbolt driver options for better hotplug support
options thunderbolt auto_suspend=0
EOF
			print_success "Created Thunderbolt kernel module configuration"
			mark_restart_needed
		fi
	else
		print_success "Thunderbolt kernel configuration already exists"
	fi
}

# Run all fixes
fix_logind_conflict
fix_usb_autosuspend
fix_hyprland_hotplug
fix_input_devices

print_success "Thunderbolt dock connection fixes applied"
print_info "Note: A restart is required for all changes to take effect"
