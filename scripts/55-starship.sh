#!/bin/bash

# Configure Starship prompt
# This script ensures Starship is enabled in the shell

print_step "Configuring Starship prompt..."

# Check if already done
if is_done "starship-configured"; then
    print_success "Starship configuration already applied"
    return 0
fi

# Check if Starship is already configured in .bashrc
if grep -q "starship init bash" ~/.bashrc 2>/dev/null; then
    print_success "Starship is already enabled in .bashrc"
    mark_done "starship-configured"
    return 0
fi

# Verify .bashrc exists
if [[ ! -f ~/.bashrc ]]; then
    print_warning ".bashrc not found - skipping Starship configuration"
    record_failure "Starship configuration - .bashrc not found"
    return 1
fi

print_info "Adding Starship to .bashrc..."

if [[ "${DRY_RUN:-false}" == true ]]; then
    echo "[DRY-RUN] Would add Starship initialization to ~/.bashrc"
else
    backup_file ~/.bashrc
    echo '' >> ~/.bashrc
    echo '# Initialize Starship prompt' >> ~/.bashrc
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    print_success "Starship enabled in .bashrc"
    print_info "Restart your terminal or run: source ~/.bashrc"
    mark_done "starship-configured"
fi

print_success "Starship configuration complete"
