#!/bin/bash

# Configure custom keybindings
# These bindings override Omarchy's defaults

print_step "Configuring custom keybindings..."

print_info "Custom keybindings are defined in configs/hypr/custom-overrides.conf"
print_info "Current overrides:"
print_info "  - SUPER+SHIFT+M: Cider (Apple Music) instead of Spotify"
print_info "  - SUPER+SHIFT+A: t3.chat instead of ChatGPT"

if [[ "${DRY_RUN:-false}" == true ]]; then
    print_info "[DRY-RUN] Keybindings would be applied via custom-overrides.conf"
fi

print_success "Keybindings configured (see custom-overrides.conf for details)"
