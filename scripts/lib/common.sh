#!/bin/bash

# Common functions for Omarchy customization scripts
# Source this file at the beginning of each script

# Color codes for consistent output
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'

# Logging configuration
readonly LOG_BASE_DIR="$HOME/.local/share/omarchy-customization/logs"
readonly LOG_FILE="$LOG_BASE_DIR/install-$(date +%Y%m%d_%H%M%S).log"
readonly LATEST_LINK="$LOG_BASE_DIR/latest.log"

# Error tracking
declare -a FAILED_STEPS=()

# Restart tracking
RESTART_NEEDED=false

# Initialize logging
init_logging() {
    mkdir -p "$LOG_BASE_DIR"
    touch "$LOG_FILE"
    
    # Update symlink to point to latest log
    ln -sf "$LOG_FILE" "$LATEST_LINK"
    
    # Cleanup old logs (keep 1 year)
    find "$LOG_BASE_DIR" -name "install-*.log" -type f -mtime +365 -delete 2>/dev/null || true
    
    {
        echo "=== Omarchy Customization Install Log ==="
        echo "Started: $(date)"
        echo "Dry-run: ${DRY_RUN:-false}"
        echo ""
    } >> "$LOG_FILE"
}

# Log functions
log_info() {
    echo "[INFO] $1" >> "$LOG_FILE"
}

log_success() {
    echo "[SUCCESS] $1" >> "$LOG_FILE"
}

log_warning() {
    echo "[WARNING] $1" >> "$LOG_FILE"
}

log_error() {
    echo "[ERROR] $1" >> "$LOG_FILE"
}

log_aur() {
    echo "[AUR] $1" >> "$LOG_FILE"
}

# Error tracking
record_failure() {
    FAILED_STEPS+=("$1")
    log_error "Step failed: $1"
}

# Restart tracking
mark_restart_needed() {
    RESTART_NEEDED=true
    log_info "Restart marked as needed"
}

# Display functions (also log)
print_header() {
    local msg="$1"
    echo ""
    echo "══════════════════════════════════════════════════════════"
    echo "  $msg"
    echo "══════════════════════════════════════════════════════════"
    log_info "HEADER: $msg"
}

print_step() {
    local msg="$1"
    echo ""
    echo "[*] $msg"
    log_info "STEP: $msg"
}

print_success() {
    local msg="$1"
    echo "✓ $msg"
    log_success "$msg"
}

print_warning() {
    local msg="$1"
    echo "⚠ $msg"
    log_warning "$msg"
}

print_error() {
    local msg="$1"
    echo "✗ $msg"
    log_error "$msg"
}

print_info() {
    local msg="$1"
    echo "ℹ $msg"
    log_info "$msg"
}

print_aur_notice() {
    local pkg="$1"
    echo "📦 Installing from AUR: $pkg"
    log_aur "Installing $pkg from AUR"
}

# Execute or simulate command
run_cmd() {
    local cmd="$1"
    local description="${2:-$cmd}"
    
    if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "[DRY-RUN] Would execute: $description"
        log_info "[DRY-RUN] Would execute: $cmd"
        return 0
    else
        log_info "Executing: $cmd"
        eval "$cmd"
    fi
}

# Backup file (always happens, even in dry-run for safety)
backup_file() {
    local file="$1"
    local backup_dir="$HOME/.local/share/omarchy-customization/backups/$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$file" ]]; then
        if [[ "${DRY_RUN:-false}" == true ]]; then
            echo "[DRY-RUN] Would backup: $file → $backup_dir/"
            log_info "[DRY-RUN] Would backup: $file"
        else
            mkdir -p "$backup_dir"
            cp "$file" "$backup_dir/$(basename "$file")"
            log_info "Backed up: $file → $backup_dir/"
        fi
    fi
}

# Copy file with dry-run support
copy_file() {
    local src="$1"
    local dest="$2"
    
    if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "[DRY-RUN] Would copy: $src → $dest"
        log_info "[DRY-RUN] Would copy: $src → $dest"
    else
        cp "$src" "$dest"
    fi
}

# Idempotency helpers
mark_done() {
    local marker_file="$HOME/.local/share/omarchy-customization/$1"
    if [[ "${DRY_RUN:-false}" != true ]]; then
        mkdir -p "$(dirname "$marker_file")"
        touch "$marker_file"
    fi
}

is_done() {
    [[ -f "$HOME/.local/share/omarchy-customization/$1" ]]
}

# Final summary
print_summary() {
    echo ""
    echo "══════════════════════════════════════════════════════════"
    echo "  INSTALLATION SUMMARY"
    echo "══════════════════════════════════════════════════════════"
    
    if [[ ${#FAILED_STEPS[@]} -eq 0 ]]; then
        echo ""
        echo "✓ All steps completed successfully!"
        log_success "All steps completed successfully"
    else
        echo ""
        echo "✗ Some steps failed:"
        for step in "${FAILED_STEPS[@]}"; do
            echo "  - $step"
        done
        echo ""
        echo "See log file for details: $LOG_FILE"
    fi
    
    # Check if restart is needed
    if [[ "$RESTART_NEEDED" == true ]]; then
        echo ""
        echo "⚠ RESTART REQUIRED"
        echo "Some changes require a system restart to take effect."
        echo "Please restart your computer when convenient."
        log_info "Restart required"
    fi
    
    echo ""
    echo "Log file: $LOG_FILE"
    echo "══════════════════════════════════════════════════════════"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if package is installed
package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Detect firewall
detect_firewall() {
    if systemctl is-active --quiet ufw 2>/dev/null || command -v ufw >/dev/null 2>&1; then
        echo "ufw"
    elif systemctl is-active --quiet firewalld 2>/dev/null || command -v firewall-cmd >/dev/null 2>&1; then
        echo "firewalld"
    elif command -v iptables >/dev/null 2>&1; then
        echo "iptables"
    else
        echo "none"
    fi
}
