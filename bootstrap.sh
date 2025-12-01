#!/bin/sh

# SSH Key Switcher Bootstrap Script
# This script downloads and runs the installer from GitHub

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

# Configuration
GITHUB_USER="${GITHUB_USER:-AnthonyQuy}"
GITHUB_REPO="${GITHUB_REPO:-ssh-key-switcher}"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Create temporary directory
TEMP_DIR=$(mktemp -d -t skw-install.XXXXXX)

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Ensure cleanup on exit
trap cleanup EXIT INT TERM

echo ""
print_info "SSH Key Switcher Bootstrap Installer"
print_info "====================================="
echo ""

# Check for download tool
DOWNLOAD_CMD=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -fsSL"
    print_info "Using curl for downloads"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget -qO-"
    print_info "Using wget for downloads"
else
    print_error "Neither curl nor wget found. Please install one of them."
    exit 1
fi

echo ""

# Download install.sh
print_info "Downloading install.sh..."
if ! $DOWNLOAD_CMD "${BASE_URL}/install.sh" > "$TEMP_DIR/install.sh"; then
    print_error "Failed to download install.sh"
    echo ""
    echo "Please check:"
    echo "  - Your internet connection"
    echo "  - The repository URL: https://github.com/${GITHUB_USER}/${GITHUB_REPO}"
    echo "  - The branch exists: ${GITHUB_BRANCH}"
    exit 1
fi

# Download skw
print_info "Downloading skw..."
if ! $DOWNLOAD_CMD "${BASE_URL}/skw" > "$TEMP_DIR/skw"; then
    print_error "Failed to download skw"
    exit 1
fi

# Make scripts executable
chmod +x "$TEMP_DIR/install.sh"
chmod +x "$TEMP_DIR/skw"

print_success "Files downloaded successfully"
echo ""

# Run the installer from temp directory
print_info "Running installer..."
echo ""

cd "$TEMP_DIR"
if ./install.sh "$@"; then
    echo ""
    print_success "Bootstrap installation completed successfully!"
else
    exit_code=$?
    echo ""
    print_error "Installation failed with exit code $exit_code"
    exit $exit_code
fi

# Cleanup will happen automatically via trap
