#!/bin/bash

# Install all extra Omarchy themes using omarchy-theme-install command
# Uses sequential installation to avoid conflicts with omarchy-theme-set

print_step "Installing all extra Omarchy themes..."

# All extra themes from the Omarchy manual
# Note: Removed broken themes (404 or moved):
# - https://github.com/somerocketeer/omarchy-bauhaus-theme (returns 301, likely moved)
# - https://github.com/mishonki3/omarchy-bliss-theme (returns 404, deleted)
THEMES=(
	"https://github.com/JJDizz1L/aetheria"
	"https://github.com/tahfizhabib/omarchy-amberbyte-theme"
	"https://github.com/vale-c/omarchy-arc-blueberry"
	"https://github.com/davidguttman/archwave"
	"https://github.com/bjarneo/omarchy-ash-theme"
	"https://github.com/tahfizhabib/omarchy-artzen-theme"
	"https://github.com/bjarneo/omarchy-aura-theme"
	"https://github.com/guilhermetk/omarchy-all-hallows-eve-theme"
	"https://github.com/abhijeet-swami/omarchy-ayaka-theme"
	"https://github.com/Hydradevx/omarchy-azure-glow-theme"
	"https://github.com/HANCORE-linux/omarchy-batou-theme"
	"https://github.com/ankur311sudo/black_arch"
	"https://github.com/HANCORE-linux/omarchy-blackgold-theme"
	"https://github.com/HANCORE-linux/omarchy-blackturq-theme"
	"https://github.com/dotsilva/omarchy-bluedotrb-theme"
	"https://github.com/hipsterusername/omarchy-blueridge-dark-theme"
	"https://github.com/Luquatic/omarchy-catppuccin-dark"
	"https://github.com/Grey-007/citrus-cynapse"
	"https://github.com/hoblin/omarchy-cobalt2-theme"
	"https://github.com/noahljungberg/omarchy-darcula-theme"
	"https://github.com/HANCORE-linux/omarchy-demon-theme"
	"https://github.com/dotsilva/omarchy-dotrb-theme"
)

# Install a single theme using omarchy-theme-install
install_single_theme() {
	local theme_url="$1"
	local theme_name=$(basename "$theme_url" .git | sed -E 's/^omarchy-//; s/-theme$//')

	# Check if already installed
	if [[ -d "$HOME/.config/omarchy/themes/$theme_name" ]]; then
		log_info "Theme already installed: $theme_name"
		return 0
	fi

	log_info "Installing theme: $theme_name"

	if [[ "${DRY_RUN:-false}" == true ]]; then
		echo "[DRY-RUN] Would install theme: $theme_name from $theme_url"
		return 0
	fi

	# Use omarchy-theme-install command (installs and temporarily sets theme)
	if omarchy-theme-install "$theme_url" 2>/dev/null; then
		log_success "Installed theme: $theme_name"
		return 0
	else
		log_error "Failed to install theme: $theme_name"
		return 1
	fi
}

# Set Ethereal theme as default
set_ethereal_theme() {
	print_step "Setting Ethereal theme as default..."

	local current_theme=$(omarchy-theme-current 2>/dev/null || echo "unknown")

	if [[ "$current_theme" == "Ethereal" ]]; then
		print_success "Ethereal theme is already active"
		return 0
	fi

	if [[ "${DRY_RUN:-false}" == true ]]; then
		echo "[DRY-RUN] Would set theme to Ethereal"
		return 0
	fi

	if run_cmd "omarchy-theme-set 'Ethereal'" "Set Ethereal theme"; then
		print_success "Ethereal theme activated"
	else
		print_warning "Failed to set Ethereal theme"
		record_failure "Set Ethereal theme"
	fi
}

# Install all themes sequentially (not parallel, to avoid omarchy-theme-set conflicts)
install_all_themes() {
	local installed=0
	local failed=0

	print_info "Installing ${#THEMES[@]} themes sequentially using omarchy-theme-install..."

	for theme_url in "${THEMES[@]}"; do
		if install_single_theme "$theme_url"; then
			((installed++))
		else
			((failed++))
		fi
	done

	if [[ "${DRY_RUN:-false}" != true ]]; then
		print_success "Theme installation complete ($installed installed, $failed failed)"
	else
		print_success "Theme installation dry-run complete (${#THEMES[@]} themes would be installed)"
	fi

	if [[ "${DRY_RUN:-false}" != true && $failed -gt 0 ]]; then
		print_warning "Some themes failed to install. Check log for details: $LATEST_LINK"
	fi
}

# Run theme installation and set default
install_all_themes
set_ethereal_theme

print_success "Theme setup complete"
