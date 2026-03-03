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
            cat << 'EOF' | sudo tee "$sleep_conf" >/dev/null
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
            cat << 'EOF' | sudo tee "$logind_conf" >/dev/null
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
    local udev_rule="/etc/udev/rules.d/99-power-profile-custom.rules"
    
    if [[ ! -f "$udev_rule" ]] || grep -q "balanced" "$udev_rule" 2>/dev/null; then
        print_info "Setting up power profile switching..."
        print_info "  - On battery: power-saver mode"
        print_info "  - On AC: performance mode"
        
        if [[ "${DRY_RUN:-false}" == true ]]; then
            echo "[DRY-RUN] Would create $udev_rule with power-saver on battery"
        else
            backup_file "$udev_rule"
            cat << 'EOF' | sudo tee "$udev_rule" >/dev/null
# Custom power profile switching
# On battery (unplugged): use power-saver instead of balanced
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
# On AC (plugged in): use performance
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set performance"
EOF
            # Reload udev rules
            sudo udevadm control --reload-rules
            print_success "Power profile switching configured"
        fi
    else
        print_success "Power profiles already configured"
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
