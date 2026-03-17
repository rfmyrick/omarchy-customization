#!/bin/bash

# Dock Hotplug Handler
# Comprehensive fix for Thunderbolt dock connection/disconnection
# Prevents windows from closing and handles workspace migration

print_step "Configuring dock hotplug handling..."

# Fix 1: Remove the dangerous display-manager restart from udev rules
fix_udev_rules() {
	print_info "Fixing udev rules (removing display-manager restart)..."

	local udev_rule="/etc/udev/rules.d/99-thunderbolt-dock.rules"

	if [[ -f "$udev_rule" ]]; then
		# Check if the dangerous line exists
		if grep -q "restart display-manager" "$udev_rule"; then
			if [[ "${DRY_RUN:-false}" == true ]]; then
				print_info "[DRY-RUN] Would remove display-manager restart from $udev_rule"
			else
				backup_file "$udev_rule"

				# Rewrite the rule without the display-manager restart
				cat <<'EOF' | sudo tee "$udev_rule" >/dev/null
# Disable USB autosuspend for input devices and Thunderbolt
# Prevents dock connection/disconnection issues on HP ZBook

# Disable autosuspend for all input devices (keyboard, mouse, trackpad)
ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", ATTR{power/control}="on"

# Disable autosuspend for Thunderbolt devices
ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{power/control}="on"

# Disable autosuspend for USB hubs (often in docks)
ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/control}="on"

# Note: Display reloading is handled by user service dock-hotplug.service
# Do NOT add display-manager restart here - it kills all windows!
EOF
				sudo udevadm control --reload-rules
				print_success "Fixed udev rules (removed window-killing display-manager restart)"
			fi
		else
			print_success "Udev rules already correct (no display-manager restart)"
		fi
	else
		print_warning "Udev rule not found - may need to run 61-thunderbolt-fix.sh first"
	fi
}

# Fix 2: Create dock handler script
create_dock_handler() {
	print_info "Creating dock handler script..."

	local handler_script="$HOME/.local/bin/dock-handler"

	if [[ -f "$handler_script" ]]; then
		print_success "Dock handler script already exists"
		return 0
	fi

	if [[ "${DRY_RUN:-false}" == true ]]; then
		print_info "[DRY-RUN] Would create dock handler script at $handler_script"
		return 0
	fi

	mkdir -p "$(dirname "$handler_script")"

	cat >"$handler_script" <<'SCRIPT_EOF'
#!/bin/bash

# Dock Hotplug Handler
# Monitors Thunderbolt connection state and manages workspace migration
# Runs as user service - has access to Wayland session

LAST_STATE="unknown"
LOG_FILE="$HOME/.local/share/omarchy-customization/logs/dock-handler.log"

# Logging function
log_msg() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Initialize log
log_msg "Dock handler started"

while true; do
	# Check if Thunderbolt devices are connected (count domains that have devices)
	CURRENT_STATE=0
	if [[ -d /sys/bus/thunderbolt/devices ]]; then
		# Count active thunderbolt domains with connected devices
		for domain in /sys/bus/thunderbolt/devices/domain*; do
			if [[ -d "$domain" ]]; then
				# Check if this domain has any device connected (not just the domain itself)
				device_count=$(find "$domain" -maxdepth 1 -name "[0-9]-*" 2>/dev/null | wc -l)
				if [[ $device_count -gt 0 ]]; then
					CURRENT_STATE=$((CURRENT_STATE + 1))
				fi
			fi
		done
	fi
	
	if [[ "$CURRENT_STATE" != "$LAST_STATE" ]]; then
		if [[ "$CURRENT_STATE" -gt 0 ]]; then
			# DOCK CONNECTED
			log_msg "Dock connected (state: $CURRENT_STATE), waiting for devices..."
			sleep 3  # Wait for USB/display enumeration
			
			# Check if external display appeared (DP-6 for Dell U4025QW)
			if hyprctl monitors 2>/dev/null | grep -q "DP-6"; then
				log_msg "External display DP-6 detected, moving workspaces 1-5..."
				
				# Move workspaces 1-5 to external display
				for ws in 1 2 3 4 5; do
					hyprctl dispatch moveworkspacetomonitor "$ws" "DP-6" 2>/dev/null || true
					sleep 0.1
				done
				
				# Set workspace 1 as active on external
				hyprctl dispatch workspace 1
				log_msg "Workspaces moved to external display"
			else
				log_msg "No external display detected after dock connect"
			fi
		else
			# DOCK DISCONNECTED
			log_msg "Dock disconnected, moving workspaces to laptop..."
			sleep 1
			
			# Move all workspaces back to laptop display (eDP-1)
			for ws in 1 2 3 4 5 6 7 8 9 10; do
				hyprctl dispatch moveworkspacetomonitor "$ws" "eDP-1" 2>/dev/null || true
				sleep 0.1
			done
			
			# Ensure internal display is focused
			hyprctl dispatch focusmonitor "eDP-1"
			log_msg "Workspaces moved to laptop display"
		fi
		
		LAST_STATE="$CURRENT_STATE"
	fi
	
	# Check every 2 seconds
	sleep 2
done
SCRIPT_EOF

	chmod +x "$handler_script"
	print_success "Created dock handler script"
}

# Fix 3: Create systemd user service
create_systemd_service() {
	print_info "Creating systemd user service..."

	local service_file="$HOME/.config/systemd/user/dock-hotplug.service"

	if [[ -f "$service_file" ]]; then
		print_success "Systemd service already exists"
		return 0
	fi

	if [[ "${DRY_RUN:-false}" == true ]]; then
		print_info "[DRY-RUN] Would create systemd service at $service_file"
		return 0
	fi

	mkdir -p "$(dirname "$service_file")"

	cat >"$service_file" <<'EOF'
[Unit]
Description=Dock Hotplug Handler
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/dock-handler
Restart=always
RestartSec=5
StandardOutput=append:%h/.local/share/omarchy-customization/logs/dock-handler.log
StandardError=append:%h/.local/share/omarchy-customization/logs/dock-handler.log

[Install]
WantedBy=default.target
EOF

	print_success "Created systemd user service"
}

# Fix 4: Enable and start the service
enable_service() {
	print_info "Enabling dock hotplug service..."

	if [[ "${DRY_RUN:-false}" == true ]]; then
		print_info "[DRY-RUN] Would enable and start dock-hotplug.service"
		return 0
	fi

	# Reload systemd user daemon
	systemctl --user daemon-reload

	# Enable service to start on login
	if systemctl --user enable dock-hotplug.service 2>/dev/null; then
		print_success "Service enabled"
	fi

	# Start service immediately if graphical session is running
	if [[ -n "$WAYLAND_DISPLAY" ]] || [[ -n "$DISPLAY" ]]; then
		if systemctl --user start dock-hotplug.service 2>/dev/null; then
			print_success "Service started"
		else
			print_warning "Could not start service immediately (will start on next login)"
		fi
	else
		print_info "No graphical session detected - service will start on next login"
	fi
}

# Fix 5: Create emergency recovery script
create_recovery_script() {
	print_info "Creating emergency dock recovery script..."

	local recovery_script="$HOME/.local/bin/dock-recovery"

	if [[ -f "$recovery_script" ]]; then
		print_success "Recovery script already exists"
		return 0
	fi

	if [[ "${DRY_RUN:-false}" == true ]]; then
		print_info "[DRY-RUN] Would create recovery script at $recovery_script"
		return 0
	fi

	mkdir -p "$(dirname "$recovery_script")"

	cat >"$recovery_script" <<'EOF'
#!/bin/bash

# Emergency Dock Recovery
# Use this when dock connection causes display/input issues

notify-send "🔄 Dock Recovery" "Attempting to recover display and input..." --urgency=critical --expire-time=5000

# Method 1: Gentle Hyprland reload
echo "Method 1: Reloading Hyprland..."
hyprctl reload 2>/dev/null

sleep 2

# Method 2: If displays are still wrong, force re-detection
if ! hyprctl monitors 2>/dev/null | grep -q "eDP-1"; then
	echo "Method 2: Forcing display re-detection..."
	# Trigger display rescan
	hyprctl dispatch exec "sleep 1 && hyprctl reload" 2>/dev/null
fi

sleep 2

# Method 3: Move all workspaces to laptop display as fallback
echo "Method 3: Moving workspaces to laptop display..."
for ws in 1 2 3 4 5 6 7 8 9 10; do
	hyprctl dispatch moveworkspacetomonitor "$ws" "eDP-1" 2>/dev/null || true
	sleep 0.1
done

# Focus laptop display
hyprctl dispatch focusmonitor "eDP-1" 2>/dev/null

notify-send "✅ Recovery Complete" "Display and workspaces restored. Check your windows." --expire-time=5000

echo "Recovery complete. If issues persist, unplug and replug the dock."
EOF

	chmod +x "$recovery_script"
	print_success "Created emergency recovery script"
	print_info "Usage: dock-recovery (or SUPER+SHIFT+D if keybinding is configured)"
}

# Fix 6: Add emergency keybinding to Hyprland config
add_emergency_keybinding() {
	print_info "Adding emergency recovery keybinding..."

	local bindings_file="$HOME/.config/hypr/bindings.conf"
	local recovery_line='bindd = SUPER SHIFT, D, Emergency Dock Recovery, exec, ~/.local/bin/dock-recovery'

	if [[ ! -f "$bindings_file" ]]; then
		print_warning "bindings.conf not found - skipping keybinding"
		return 0
	fi

	if grep -q "Emergency Dock Recovery" "$bindings_file"; then
		print_success "Emergency keybinding already configured"
		return 0
	fi

	if [[ "${DRY_RUN:-false}" == true ]]; then
		print_info "[DRY-RUN] Would add emergency keybinding to $bindings_file"
		return 0
	fi

	backup_file "$bindings_file"
	echo "" >>"$bindings_file"
	echo "# Emergency dock recovery keybinding" >>"$bindings_file"
	echo "$recovery_line" >>"$bindings_file"

	print_success "Added emergency recovery keybinding (SUPER+SHIFT+D)"
}

# Run all fixes
fix_udev_rules
create_dock_handler
create_systemd_service
enable_service
create_recovery_script
add_emergency_keybinding

print_success "Dock hotplug configuration complete"
print_info "The dock handler service will:"
print_info "  - Monitor Thunderbolt connections every 2 seconds"
print_info "  - Move workspaces 1-5 to external display when dock connects"
print_info "  - Move all workspaces back to laptop when dock disconnects"
print_info "  - Preserve all windows (no more closing!)"
print_info ""
print_info "Emergency recovery:"
print_info "  - Run: dock-recovery (in terminal)"
print_info "  - Or press: SUPER+SHIFT+D"
print_info ""
print_info "Note: You may need to log out and back in for all changes to take effect"
