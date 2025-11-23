#!/bin/sh

# SSH Key Switcher Uninstallation Script
# This script removes the skw command-line tool

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_error() {
    printf "${RED}Error: %s${NC}\n" "$1" >&2
}

print_success() {
    printf "${GREEN}%s${NC}\n" "$1"
}

print_info() {
    printf "${BLUE}%s${NC}\n" "$1"
}

print_warning() {
    printf "${YELLOW}%s${NC}\n" "$1"
}

echo ""
print_info "SSH Key Switcher (skw) Uninstallation"
print_info "======================================"
echo ""

# Find skw installation
SKW_PATH=""

if [ -f "/usr/local/bin/skw" ]; then
    SKW_PATH="/usr/local/bin/skw"
elif [ -f "$HOME/.local/bin/skw" ]; then
    SKW_PATH="$HOME/.local/bin/skw"
elif command -v skw >/dev/null 2>&1; then
    SKW_PATH=$(command -v skw)
else
    print_error "skw is not installed"
    exit 1
fi

print_info "Found skw at: $SKW_PATH"
echo ""

# Ask for confirmation
print_warning "This will remove the skw executable"
printf "Do you want to continue? (y/N): "
read -r response

if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
    print_info "Uninstallation cancelled"
    exit 0
fi

# Check if we need sudo
if [ -w "$SKW_PATH" ]; then
    rm "$SKW_PATH"
else
    if command -v sudo >/dev/null 2>&1; then
        sudo rm "$SKW_PATH"
    else
        print_error "Cannot remove $SKW_PATH (permission denied)"
        exit 1
    fi
fi

if [ $? -eq 0 ]; then
    print_success "skw has been uninstalled"
else
    print_error "Failed to uninstall skw"
    exit 1
fi

echo ""

# Check if PATH was added to shell config
SHELL_CONFIG=""
PATH_REMOVED=0

# Detect shell config file
case "$SHELL" in
    */zsh)
        SHELL_CONFIG="$HOME/.zshrc"
        ;;
    */bash)
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
        ;;
esac

# Check if PATH was added by installer
if [ -n "$SHELL_CONFIG" ] && [ -f "$SHELL_CONFIG" ]; then
    if grep -q "# Added by SSH Key Switcher installer" "$SHELL_CONFIG" 2>/dev/null; then
        echo ""
        print_warning "Found PATH configuration in $SHELL_CONFIG"
        printf "Would you like to remove it? (Y/n): "
        read -r response
        
        response=${response:-Y}
        
        if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
            # Create a backup
            cp "$SHELL_CONFIG" "$SHELL_CONFIG.skw-backup"
            
            # Remove the lines added by installer
            # Remove the comment line, the export line, and any blank line before it
            sed -i.tmp '/# Added by SSH Key Switcher installer/,/export PATH=.*\.local\/bin/d' "$SHELL_CONFIG"
            rm -f "$SHELL_CONFIG.tmp"
            
            print_success "Removed PATH configuration from $SHELL_CONFIG"
            print_info "Backup saved as: $SHELL_CONFIG.skw-backup"
            PATH_REMOVED=1
            
            echo ""
            print_info "To apply changes, run:"
            echo "  source $SHELL_CONFIG"
        else
            print_info "PATH configuration kept in $SHELL_CONFIG"
        fi
    fi
fi

# Ask about data removal
echo ""
print_warning "Your SSH key profiles and backups are still in:"
echo "  ~/.ssh-profiles/"
echo "  ~/.ssh-backup/"
echo ""
printf "Do you want to remove these directories? (y/N): "
read -r response

if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
    print_warning "This will permanently delete all your saved SSH key profiles and backups!"
    printf "Are you absolutely sure? (yes/N): "
    read -r confirm
    
    if [ "$confirm" = "yes" ]; then
        rm -rf "$HOME/.ssh-profiles"
        rm -rf "$HOME/.ssh-backup"
        print_success "Removed all SSH Key Switcher data"
    else
        print_info "Data directories kept"
    fi
else
    print_info "Data directories kept"
    print_info "You can manually remove them later if needed:"
    echo "  rm -rf ~/.ssh-profiles"
    echo "  rm -rf ~/.ssh-backup"
fi

echo ""
print_success "Uninstallation complete!"

if [ $PATH_REMOVED -eq 1 ]; then
    echo ""
    print_info "Note: Restart your terminal or run 'source $SHELL_CONFIG' to apply PATH changes."
fi
echo ""
