#!/bin/bash

# Install all extra Omarchy themes in parallel

print_step "Installing all extra Omarchy themes (parallel mode)..."

# All extra themes from the Omarchy manual
THEMES=(
    "https://github.com/JJDizz1L/aetheria"
    "https://github.com/tahfizhabib/omarchy-amberbyte-theme"
    "https://github.com/vale-c/omarchy-arc-blueberry"
    "https://github.com/davidguttman/archwave"
    "https://github.com/bjarneo/omarchy-ash-theme"
    "https://github.com/tahfizhabib/omarchy-artzen-theme"
    "https://github.com/bjarneo/omarchy-aura-theme"
    "https://github.com/guilhermetk/omarchy-all-hallows-eve-theme"
    "https://github.com/abhijeet-swami/omarchy-ayaka-theme"
    "https://github.com/Hydradevx/omarchy-azure-glow-theme"
    "https://github.com/HANCORE-linux/omarchy-batou-theme"
    "https://github.com/somerocketeer/omarchy-bauhaus-theme"
    "https://github.com/ankur311sudo/black_arch"
    "https://github.com/HANCORE-linux/omarchy-blackgold-theme"
    "https://github.com/HANCORE-linux/omarchy-blackturq-theme"
    "https://github.com/mishonki3/omarchy-bliss-theme"
    "https://github.com/dotsilva/omarchy-bluedotrb-theme"
    "https://github.com/hipsterusername/omarchy-blueridge-dark-theme"
    "https://github.com/Luquatic/omarchy-catppuccin-dark"
    "https://github.com/Grey-007/citrus-cynapse"
    "https://github.com/hoblin/omarchy-cobalt2-theme"
    "https://github.com/noahljungberg/omarchy-darcula-theme"
    "https://github.com/HANCORE-linux/omarchy-demon-theme"
    "https://github.com/dotsilva/omarchy-dotrb-theme"
)

install_single_theme() {
    local theme_url="$1"
    local theme_name=$(basename "$theme_url" .git | sed -E 's/^omarchy-//; s/-theme$//')
    
    if [[ -d "$HOME/.config/omarchy/themes/$theme_name" ]]; then
        log_info "Theme already installed: $theme_name"
        return 0
    fi
    
    log_info "Installing theme: $theme_name"
    
    if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "[DRY-RUN] Would install theme: $theme_name"
        return 0
    fi
    
    # Use timeout to prevent hanging (60 seconds per theme)
    if timeout 60 omarchy-theme-install "$theme_url" 2>/dev/null; then
        log_success "Installed theme: $theme_name"
        return 0
    else
        log_error "Failed or timed out: $theme_name"
        return 1
    fi
}

# Set Ethereal theme as default
set_ethereal_theme() {
    print_step "Setting Ethereal theme as default..."
    
    local current_theme=$(omarchy-theme-current 2>/dev/null || echo "unknown")
    
    if [[ "$current_theme" == "Ethereal" ]]; then
        print_success "Ethereal theme is already active"
        return 0
    fi
    
    if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "[DRY-RUN] Would set theme to Ethereal"
        return 0
    fi
    
    if run_cmd "omarchy-theme-set 'Ethereal'" "Set Ethereal theme"; then
        print_success "Ethereal theme activated"
    else
        print_warning "Failed to set Ethereal theme"
        record_failure "Set Ethereal theme"
    fi
}

# Install themes in parallel with max 5 concurrent
install_all_themes() {
    local installed=0
    local failed=0
    local max_parallel=5
    local running=0
    local pids=()
    
    print_info "Installing ${#THEMES[@]} themes with max $max_parallel concurrent connections..."
    print_info "Timeout: 60 seconds per theme"
    
    for theme_url in "${THEMES[@]}"; do
        # Wait if we've hit the concurrency limit
        while [[ $running -ge $max_parallel ]]; do
            wait -n 2>/dev/null || true
            running=$((running - 1))
        done
        
        # Start theme installation in background
        install_single_theme "$theme_url" &
        pids+=($!)
        running=$((running + 1))
    done
    
    # Wait for all background jobs
    wait
    
    # Count results (skip in dry-run mode)
    if [[ "${DRY_RUN:-false}" != true ]]; then
        for theme_url in "${THEMES[@]}"; do
            local theme_name=$(basename "$theme_url" .git | sed -E 's/^omarchy-//; s/-theme$//')
            if [[ -d "$HOME/.config/omarchy/themes/$theme_name" ]]; then
                ((installed++))
            else
                ((failed++))
            fi
        done
        print_success "Theme installation complete ($installed installed, $failed failed)"
    else
        print_success "Theme installation dry-run complete (${#THEMES[@]} themes would be installed)"
    fi
    
    if [[ "${DRY_RUN:-false}" != true && $failed -gt 0 ]]; then
        print_warning "Some themes failed to install. Check log for details: $LATEST_LINK"
    fi
}

# Run theme installation and set default
install_all_themes
set_ethereal_theme

print_success "Theme setup complete"
