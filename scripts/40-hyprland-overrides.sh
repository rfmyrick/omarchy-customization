#!/bin/bash

# Configure Hyprland window rules
# Window rules are maintained directly in ~/.config/hypr/ files

print_step "Configuring Hyprland window rules..."

# Copy window-rules.conf if needed
copy_window_rules() {
	print_info "Installing window rules configuration..."

	if [[ -f "configs/hypr/window-rules.conf" ]]; then
		if [[ ! -f "$HOME/.config/hypr/window-rules.conf" ]] ||
			! diff -q "configs/hypr/window-rules.conf" "$HOME/.config/hypr/window-rules.conf" >/dev/null 2>&1; then

			if [[ "${DRY_RUN:-false}" != true ]]; then
				backup_file "$HOME/.config/hypr/window-rules.conf"
				cp configs/hypr/window-rules.conf "$HOME/.config/hypr/"
			fi
			print_success "Installed window-rules.conf"
		else
			print_success "window-rules.conf is up to date"
		fi
	fi
}

# Run configuration
copy_window_rules

print_success "Hyprland window rules configured"
print_info "Window rules are maintained in ~/.config/hypr/window-rules.conf"
