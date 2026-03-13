#!/bin/bash

# Configure custom keybindings in bindings.conf
# These bindings override Omarchy's defaults

print_step "Configuring custom keybindings..."

print_info "Custom keybindings are defined in ~/.config/hypr/bindings.conf"
print_info "Key bindings are personal and should be maintained in your Hyprland config files."

if [[ "${DRY_RUN:-false}" == true ]]; then
	echo "[DRY-RUN] Would verify keybindings are configured in bindings.conf"
fi

print_success "Keybindings configuration complete"
print_info "Edit ~/.config/hypr/bindings.conf to customize your keybindings"
