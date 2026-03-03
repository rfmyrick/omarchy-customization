#!/bin/bash

# Hardware detection library
# Provides functions to detect system hardware for applying specific configurations

# Get system vendor
get_system_vendor() {
    cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "Unknown"
}

# Get product name
get_product_name() {
    cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown"
}

# Get product version
get_product_version() {
    cat /sys/class/dmi/id/product_version 2>/dev/null || echo "Unknown"
}

# Get full model identifier
get_full_model() {
    local vendor=$(get_system_vendor)
    local product=$(get_product_name)
    echo "${vendor}:${product}"
}

# Detect GPU type
detect_gpu() {
    if lspci 2>/dev/null | grep -qi "nvidia"; then
        echo "nvidia"
    elif lspci 2>/dev/null | grep -qi "amd.*vga\|amd.*radeon\|amd.*graphics"; then
        echo "amd"
    elif lspci 2>/dev/null | grep -qi "intel.*vga\|intel.*graphics"; then
        echo "intel"
    else
        echo "unknown"
    fi
}

# Detect CPU type
detect_cpu() {
    if grep -q "Intel" /proc/cpuinfo 2>/dev/null; then
        echo "intel"
    elif grep -q "AMD" /proc/cpuinfo 2>/dev/null; then
        echo "amd"
    else
        echo "unknown"
    fi
}

# Get sanitized model name for directory lookup
get_model_directory() {
    local vendor=$(get_system_vendor)
    local product=$(get_product_name)
    # Convert to lowercase, replace spaces with hyphens
    local model_dir=$(echo "${vendor}-${product}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    echo "$model_dir"
}

# Check if specific hardware config exists
has_hardware_config() {
    local model_dir=$(get_model_directory)
    local gpu=$(detect_gpu)
    
    # Check for exact model match
    if [[ -d "hardware/$model_dir" ]]; then
        return 0
    fi
    
    # Check for GPU-specific configs
    if [[ -f "hardware/$gpu/suspend-fix.sh" ]]; then
        return 0
    fi
    
    return 1
}

# Check if NVIDIA-specific suspend fix is needed
needs_nvidia_suspend_fix() {
    [[ "$(detect_gpu)" == "nvidia" ]]
}

# Apply hardware-specific configurations
apply_hardware_configs() {
    local model_dir=$(get_model_directory)
    local gpu=$(detect_gpu)
    local vendor=$(get_system_vendor)
    local product=$(get_product_name)
    
    print_info "Detected hardware:"
    print_info "  Vendor: $vendor"
    print_info "  Model: $product"
    print_info "  GPU: $gpu"
    
    # Apply GPU-specific configs
    if [[ -f "hardware/$gpu/suspend-fix.sh" ]]; then
        print_step "Applying $gpu-specific configurations..."
        source "hardware/$gpu/suspend-fix.sh"
    fi
    
    # Apply model-specific configs
    if [[ -d "hardware/$model_dir" ]]; then
        print_step "Applying model-specific configurations for $vendor $product..."
        for script in hardware/$model_dir/*.sh; do
            if [[ -f "$script" ]]; then
                source "$script"
            fi
        done
    fi
    
    # If no specific configs, just note it
    if ! has_hardware_config; then
        print_info "No hardware-specific configurations needed for this system"
    fi
}

# Print hardware information (for debugging)
print_hardware_info() {
    echo "Hardware Information:"
    echo "  Vendor: $(get_system_vendor)"
    echo "  Product: $(get_product_name)"
    echo "  Version: $(get_product_version)"
    echo "  GPU: $(detect_gpu)"
    echo "  CPU: $(detect_cpu)"
    echo "  Model Dir: $(get_model_directory)"
}
