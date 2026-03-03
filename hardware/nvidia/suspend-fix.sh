#!/bin/bash

# NVIDIA GPU suspend/hibernation fixes
# NVIDIA graphics cards often require special configuration for proper suspend/resume

# Only run on NVIDIA systems
if [[ "$(detect_gpu)" != "nvidia" ]]; then
    print_info "No NVIDIA GPU detected - skipping NVIDIA-specific configuration"
    return 0
fi

print_step "Applying NVIDIA-specific suspend fixes..."

print_info "NVIDIA GPU detected - applying suspend/hibernation workarounds"

# Configure NVIDIA persistence mode
# This keeps the GPU initialized, improving suspend/resume reliability
configure_nvidia_persistence() {
    print_info "Enabling NVIDIA persistence mode..."
    
    if command -v nvidia-smi &>/dev/null; then
        if [[ "${DRY_RUN:-false}" != true ]]; then
            sudo nvidia-smi -pm 1
            print_success "NVIDIA persistence mode enabled"
        else
            echo "[DRY-RUN] Would enable NVIDIA persistence mode"
        fi
    fi
}

# Configure systemd service for NVIDIA
# Ensures proper initialization on boot
configure_nvidia_systemd() {
    local nvidia_service="/etc/systemd/system/nvidia-suspend.service"
    
    if [[ ! -f "$nvidia_service" ]]; then
        print_info "Setting up NVIDIA systemd services..."
        
        if [[ "${DRY_RUN:-false}" != true ]]; then
            # Enable nvidia-suspend and nvidia-resume services
            sudo systemctl enable nvidia-suspend.service 2>/dev/null || true
            sudo systemctl enable nvidia-resume.service 2>/dev/null || true
            sudo systemctl enable nvidia-hibernate.service 2>/dev/null || true
            
            print_success "NVIDIA systemd services configured"
        else
            echo "[DRY-RUN] Would enable NVIDIA systemd services"
        fi
    else
        print_success "NVIDIA systemd services already configured"
    fi
}

# Run configurations
configure_nvidia_persistence
configure_nvidia_systemd

print_success "NVIDIA-specific configurations applied"
print_info "Note: NVIDIA systems using Limine bootloader may require manual kernel parameter configuration"
print_info "Parameters: nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"
