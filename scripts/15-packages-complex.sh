#!/bin/bash

# Install and configure complex packages
# These packages require additional configuration beyond simple installation

print_step "Installing complex packages..."

# Install Syncthing
install_syncthing() {
    print_step "Installing and configuring Syncthing..."
    
    # Install syncthing package
    if ! package_installed syncthing; then
        log_info "Installing syncthing package"
        if ! run_cmd "sudo pacman -S --needed --noconfirm syncthing" "Install syncthing"; then
            record_failure "Syncthing package installation"
            return 1
        fi
    else
        print_success "Syncthing package already installed"
    fi
    
    # Enable user service
    if ! systemctl --user is-enabled syncthing.service &>/dev/null; then
        log_info "Enabling syncthing user service"
        if run_cmd "systemctl --user enable syncthing.service" "Enable syncthing service"; then
            print_success "Syncthing service enabled"
        else
            record_failure "Syncthing service enable"
            return 1
        fi
    else
        print_success "Syncthing service already enabled"
    fi
    
    # Start service
    if ! systemctl --user is-active syncthing.service &>/dev/null; then
        log_info "Starting syncthing service"
        if run_cmd "systemctl --user start syncthing.service" "Start syncthing service"; then
            print_success "Syncthing service started"
        else
            record_failure "Syncthing service start"
            return 1
        fi
    else
        print_success "Syncthing service already running"
    fi
    
    # Configure firewall
    local firewall=$(detect_firewall)
    
    case "$firewall" in
        ufw)
            log_info "Configuring ufw for Syncthing"
            run_cmd "sudo ufw allow 22000/tcp comment 'Syncthing'" "Allow Syncthing TCP"
            run_cmd "sudo ufw allow 22000/udp comment 'Syncthing'" "Allow Syncthing UDP"
            run_cmd "sudo ufw allow 21027/udp comment 'Syncthing discovery'" "Allow Syncthing discovery"
            print_success "Firewall configured for Syncthing"
            mark_restart_needed
            ;;
        firewalld)
            log_info "Configuring firewalld for Syncthing"
            run_cmd "sudo firewall-cmd --permanent --add-port=22000/tcp" "Allow Syncthing TCP"
            run_cmd "sudo firewall-cmd --permanent --add-port=22000/udp" "Allow Syncthing UDP"
            run_cmd "sudo firewall-cmd --permanent --add-port=21027/udp" "Allow Syncthing discovery"
            run_cmd "sudo firewall-cmd --reload" "Reload firewalld"
            print_success "Firewall configured for Syncthing"
            mark_restart_needed
            ;;
        iptables)
            print_warning "iptables detected but not configured automatically"
            print_info "Please manually configure ports 22000/tcp, 22000/udp, 21027/udp"
            ;;
        none)
            print_warning "No firewall detected"
            ;;
    esac
    
    print_success "Syncthing installed and configured"
    print_info "Access Syncthing at: http://localhost:8384"
    print_info "See docs/SYNCTHING_SETUP.md for pairing devices"
}

# Run installations
install_syncthing
