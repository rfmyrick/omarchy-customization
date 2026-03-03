#!/bin/bash

# Prerequisites check and setup
# This script verifies Omarchy is installed and sets up the environment

print_step "Checking prerequisites..."

# Check if running on Omarchy
if [[ ! -d "$HOME/.local/share/omarchy" ]]; then
    print_error "Omarchy installation not detected!"
    print_info "This customization is designed for Omarchy Linux systems."
    print_info "Please install Omarchy first: https://omarchy.org/"
    record_failure "Omarchy not detected"
    exit 1
fi

print_success "Omarchy installation detected"

# Check if running as root (should NOT be root)
if [[ $EUID -eq 0 ]]; then
    print_error "Do not run this script as root!"
    print_info "The script will prompt for sudo when needed."
    record_failure "Running as root"
    exit 1
fi

print_success "Running as regular user (good)"

# Check for required commands
print_info "Checking required commands..."

required_commands=("pacman" "yay" "git")
missing_commands=()

for cmd in "${required_commands[@]}"; do
    if ! command_exists "$cmd"; then
        missing_commands+=("$cmd")
    fi
done

if [[ ${#missing_commands[@]} -gt 0 ]]; then
    print_warning "Missing commands: ${missing_commands[*]}"
    print_info "Some features may not work properly"
fi

# Create necessary directories
if [[ "${DRY_RUN:-false}" != true ]]; then
    print_info "Creating necessary directories..."
    mkdir -p "$HOME/.local/share/omarchy-customization"/{backups,logs,markers}
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/omarchy/themes"
fi

print_success "Prerequisites check complete"
