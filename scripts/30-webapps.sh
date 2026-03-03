#!/bin/bash

# Install web applications

print_step "Installing web applications..."

# Install t3.chat
install_t3_chat() {
    local desktop_file="$HOME/.local/share/applications/T3 Chat.desktop"
    
    if [[ -f "$desktop_file" ]]; then
        print_success "T3 Chat web app is already installed"
        return 0
    fi
    
    print_info "Installing T3 Chat web app..."
    
    if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "[DRY-RUN] Would install T3 Chat web app"
        return 0
    fi
    
    # Use omarchy-webapp-install command
    if run_cmd "omarchy-webapp-install 'T3 Chat' 'https://www.t3.chat' 'https://www.t3.chat/favicon.ico'" "Install t3.chat web app"; then
        print_success "T3 Chat web app installed"
    else
        print_error "Failed to install T3 Chat"
        record_failure "T3 Chat web app installation"
    fi
}

# Run installations
install_t3_chat
