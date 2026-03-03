#!/bin/bash

# Hardware detection and configuration router
# This script detects hardware and applies appropriate configurations

# Source the hardware detection library
source scripts/lib/hardware-detect.sh

# Main detection and routing function
run_hardware_detection() {
    print_step "Detecting hardware configuration..."
    
    local vendor=$(get_system_vendor)
    local product=$(get_product_name)
    local gpu=$(detect_gpu)
    local model_dir=$(get_model_directory)
    
    print_info "Detected hardware:"
    print_info "  Vendor: $vendor"
    print_info "  Model: $product"
    print_info "  GPU: $gpu"
    
    local config_applied=false
    
    # Apply GPU-specific configs
    if [[ -f "hardware/$gpu/suspend-fix.sh" ]]; then
        print_info "Applying $gpu-specific configurations..."
        source "hardware/$gpu/suspend-fix.sh"
        config_applied=true
    fi
    
    # Apply model-specific configs
    if [[ -d "hardware/$model_dir" ]]; then
        print_info "Applying model-specific configurations..."
        for script in hardware/$model_dir/*.sh; do
            if [[ -f "$script" ]]; then
                source "$script"
                config_applied=true
            fi
        done
    fi
    
    if [[ "$config_applied" == false ]]; then
        print_info "No hardware-specific configurations needed for this system"
    fi
    
    print_success "Hardware detection complete"
}

# Run detection
run_hardware_detection
