#!/bin/bash

# Apply hardware-specific configurations

print_step "Checking for hardware-specific configurations..."

# Source hardware detection library
source scripts/lib/hardware-detect.sh

# Apply hardware configs
apply_hardware_configs

print_success "Hardware-specific configuration complete"
