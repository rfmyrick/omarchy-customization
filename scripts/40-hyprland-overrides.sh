#!/bin/bash

# Configure Hyprland to source custom overrides
# This is the KEY pattern that makes customizations survive Omarchy updates

print_step "Configuring Hyprland overrides..."

# Add source line to hyprland.conf
add_override_source() {
    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    local override_line='source = ~/.config/hypr/custom-overrides.conf'
    
    if [[ ! -f "$hypr_conf" ]]; then
        print_warning "Hyprland config not found: $hypr_conf"
        record_failure "Hyprland config not found"
        return 1
    fi
    
    if grep -qF "$override_line" "$hypr_conf"; then
        print_success "Custom overrides already sourced in hyprland.conf"
        return 0
    fi
    
    print_info "Adding custom overrides source to hyprland.conf..."
    
    if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "[DRY-RUN] Would add: $override_line"
        return 0
    fi
    
    backup_file "$hypr_conf"
    echo "$override_line" >> "$hypr_conf"
    print_success "Added custom overrides source to hyprland.conf"
}

# Copy custom override configs
copy_override_configs() {
    print_info "Installing custom override configurations..."
    
    # Copy custom-overrides.conf
    if [[ -f "configs/hypr/custom-overrides.conf" ]]; then
        if [[ ! -f "$HOME/.config/hypr/custom-overrides.conf" ]] || \
           ! diff -q "configs/hypr/custom-overrides.conf" "$HOME/.config/hypr/custom-overrides.conf" >/dev/null 2>&1; then
            
            if [[ "${DRY_RUN:-false}" != true ]]; then
                backup_file "$HOME/.config/hypr/custom-overrides.conf"
                cp configs/hypr/custom-overrides.conf "$HOME/.config/hypr/"
            fi
            print_success "Installed custom-overrides.conf"
        else
            print_success "custom-overrides.conf is up to date"
        fi
    else
        print_warning "configs/hypr/custom-overrides.conf not found"
    fi
    
    # Copy window-rules.conf
    if [[ -f "configs/hypr/window-rules.conf" ]]; then
        if [[ ! -f "$HOME/.config/hypr/window-rules.conf" ]] || \
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
add_override_source
copy_override_configs

print_success "Hyprland overrides configured"
print_info "Customizations will now survive Omarchy updates!"
