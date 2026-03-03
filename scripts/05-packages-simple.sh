#!/bin/bash

# Install simple packages
# These are packages that require no special configuration

print_step "Installing simple packages..."

# Source the package list
if [[ -f "config/packages.conf" ]]; then
    source config/packages.conf
else
    print_warning "config/packages.conf not found, using default package list"
    PACMAN_PACKAGES=(cmatrix powertop rsync yt-dlp htop btop neofetch tree fzf ripgrep fd bat eza zoxide stow jq yq unzip p7zip wget curl git-delta shellcheck shfmt tldr httpie)
    AUR_PACKAGES=()
fi

failed_packages=()

# Verify yay is installed for AUR packages
if [[ ${#AUR_PACKAGES[@]} -gt 0 ]] && ! command_exists yay; then
    print_step "Installing yay (AUR helper)..."
    if run_cmd "sudo pacman -S --needed --noconfirm yay" "Install yay"; then
        print_success "yay installed"
    else
        print_warning "Failed to install yay - AUR packages will be skipped"
        record_failure "yay installation"
        AUR_PACKAGES=()  # Empty the array to skip AUR installs
    fi
fi

# Install pacman packages
for pkg in "${PACMAN_PACKAGES[@]}"; do
    if package_installed "$pkg"; then
        print_success "$pkg already installed"
    else
        log_info "Installing $pkg via pacman"
        if run_cmd "sudo pacman -S --needed --noconfirm $pkg" "Install $pkg via pacman"; then
            print_success "Installed $pkg"
        else
            print_error "Failed to install $pkg"
            failed_packages+=("$pkg")
            record_failure "Package installation: $pkg"
        fi
    fi
done

# Install AUR packages (with notice)
for pkg in "${AUR_PACKAGES[@]}"; do
    if package_installed "$pkg"; then
        print_success "$pkg already installed"
    else
        print_aur_notice "$pkg"
        if run_cmd "yay -S --needed --noconfirm $pkg" "Install $pkg from AUR"; then
            print_success "Installed $pkg from AUR"
        else
            print_error "Failed to install $pkg from AUR"
            failed_packages+=("$pkg (AUR)")
            record_failure "AUR package installation: $pkg"
        fi
    fi
done

if [[ ${#failed_packages[@]} -gt 0 ]]; then
    print_warning "Some packages failed to install: ${failed_packages[*]}"
fi
