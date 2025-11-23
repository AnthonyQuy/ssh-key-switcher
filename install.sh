#!/bin/sh

# SSH Key Switcher Installation Script
# This script installs the skw command-line tool

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

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    print_warning "Running as root. Will install to /usr/local/bin"
    INSTALL_DIR="/usr/local/bin"
    USE_SUDO=""
else
    # Try to write to /usr/local/bin
    if [ -w "/usr/local/bin" ]; then
        INSTALL_DIR="/usr/local/bin"
        USE_SUDO=""
    else
        # Check if user has sudo
        if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
            INSTALL_DIR="/usr/local/bin"
            USE_SUDO="sudo"
        else
            # Fall back to user's local bin
            INSTALL_DIR="$HOME/.local/bin"
            USE_SUDO=""
            
            # Create directory if it doesn't exist
            mkdir -p "$INSTALL_DIR"
            
            # Check if it's in PATH
            if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
                NEEDS_PATH_UPDATE=1
            else
                NEEDS_PATH_UPDATE=0
            fi
        fi
    fi
fi

echo ""
print_info "SSH Key Switcher (skw) Installation"
print_info "===================================="
echo ""

# Check for required commands
print_info "Checking dependencies..."

MISSING_DEPS=""

if ! command -v ssh-keygen >/dev/null 2>&1; then
    MISSING_DEPS="$MISSING_DEPS ssh-keygen"
fi

if ! command -v ssh-add >/dev/null 2>&1; then
    MISSING_DEPS="$MISSING_DEPS ssh-add"
fi

if [ -n "$MISSING_DEPS" ]; then
    print_error "Missing required dependencies:$MISSING_DEPS"
    echo ""
    echo "Please install OpenSSH client tools:"
    echo "  macOS:   (should be pre-installed)"
    echo "  Ubuntu:  sudo apt-get install openssh-client"
    echo "  CentOS:  sudo yum install openssh-clients"
    echo "  Fedora:  sudo dnf install openssh-clients"
    exit 1
fi

print_success "All dependencies found"
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if skw script exists
if [ ! -f "$SCRIPT_DIR/skw" ]; then
    print_error "skw script not found in $SCRIPT_DIR"
    echo "Make sure you're running this script from the ssh-key-switcher directory"
    exit 1
fi

# Install the script
print_info "Installing skw to $INSTALL_DIR..."

if [ -n "$USE_SUDO" ]; then
    $USE_SUDO cp "$SCRIPT_DIR/skw" "$INSTALL_DIR/skw"
    $USE_SUDO chmod +x "$INSTALL_DIR/skw"
else
    cp "$SCRIPT_DIR/skw" "$INSTALL_DIR/skw"
    chmod +x "$INSTALL_DIR/skw"
fi

if [ $? -eq 0 ]; then
    print_success "skw installed successfully to $INSTALL_DIR/skw"
else
    print_error "Installation failed"
    exit 1
fi

echo ""

# Handle PATH configuration if needed
if [ "${NEEDS_PATH_UPDATE:-0}" -eq 1 ]; then
    # Detect shell and config file
    SHELL_CONFIG=""
    SHELL_NAME=""
    
    if [ -n "$BASH_VERSION" ]; then
        SHELL_NAME="bash"
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_NAME="zsh"
        SHELL_CONFIG="$HOME/.zshrc"
    else
        # Try to detect from SHELL variable
        case "$SHELL" in
            */zsh)
                SHELL_NAME="zsh"
                SHELL_CONFIG="$HOME/.zshrc"
                ;;
            */bash)
                SHELL_NAME="bash"
                if [ -f "$HOME/.bashrc" ]; then
                    SHELL_CONFIG="$HOME/.bashrc"
                elif [ -f "$HOME/.bash_profile" ]; then
                    SHELL_CONFIG="$HOME/.bash_profile"
                fi
                ;;
        esac
    fi
    
    print_warning "$INSTALL_DIR is not in your PATH"
    echo ""
    
    if [ -n "$SHELL_CONFIG" ]; then
        printf "Would you like to add it to $SHELL_CONFIG automatically? (Y/n): "
        read -r response
        
        response=${response:-Y}
        
        if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
            # Check if PATH is already configured
            if grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$SHELL_CONFIG" 2>/dev/null || \
               grep -q "export PATH=\$HOME/.local/bin:\$PATH" "$SHELL_CONFIG" 2>/dev/null; then
                print_info "PATH already configured in $SHELL_CONFIG"
            else
                # Add PATH to config file
                echo "" >> "$SHELL_CONFIG"
                echo "# Added by SSH Key Switcher installer" >> "$SHELL_CONFIG"
                echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_CONFIG"
                print_success "Added PATH to $SHELL_CONFIG"
            fi
            
            echo ""
            print_info "To activate skw immediately, run:"
            echo "  source $SHELL_CONFIG"
            echo ""
            print_info "Or simply restart your terminal."
        else
            echo ""
            print_info "You can add this line to your $SHELL_CONFIG manually:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
            echo ""
            print_info "Then reload: source $SHELL_CONFIG"
        fi
    else
        print_info "Add this line to your shell config (~/.bashrc, ~/.zshrc, etc.):"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        print_info "Then reload your shell."
    fi
    
    echo ""
fi

# Verify installation
if command -v skw >/dev/null 2>&1; then
    print_success "Installation verified! skw is now available."
    
    # Show version
    skw version
    echo ""
    
    # Ask if user wants to initialize
    printf "Would you like to initialize SSH Key Switcher now? (Y/n): "
    read -r response
    
    response=${response:-Y}
    
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        echo ""
        skw init
    else
        echo ""
        print_info "You can initialize later by running: skw init"
    fi
else
    # If PATH wasn't updated automatically, show manual instructions
    if [ "${NEEDS_PATH_UPDATE:-0}" -eq 0 ]; then
        print_warning "skw is not available in PATH"
        echo ""
        echo "Add $INSTALL_DIR to your PATH by adding this line to your shell config:"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        echo ""
        echo "Then reload your shell or run: source ~/.bashrc (or ~/.zshrc)"
    fi
fi

echo ""
print_success "Installation complete!"
echo ""
print_info "Quick Start:"
echo "  skw init              # Initialize the tool"
echo "  skw add work          # Create a work profile"
echo "  skw add personal      # Create a personal profile"
echo "  skw use work          # Switch to work profile"
echo "  skw list              # List all profiles"
echo "  skw help              # Show all commands"
echo ""
print_info "For more information, visit:"
echo "  https://github.com/AnthonyQuy/ssh-key-switcher"
echo ""
