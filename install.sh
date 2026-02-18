#!/bin/bash

#############################################################################
# XpreSS ::::8ootstrap Install Script
# Downloads the latest version from GitHub and runs the setup
# 
# Usage (no root needed for download!):
#   curl -SL  | bash
#   
#   Or download and run:
#   wget https://github.com/CorbanPendrak/XpreSS/archive/refs/heads/main.zip
#   unzip main.zip
#   bash main/install.sh
#
# Root will only be requested when needed for system setup!
#############################################################################

set -e  # Exit on error

# ::::) Vriska-themed Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[38;5;33m'      # Vriska's signature blue
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
GITHUB_ZIP_URL="https://github.com/CorbanPendrak/XpreSS/archive/refs/heads/main.zip"
TEMP_DIR="/tmp/xpress-install-$$"
EXTRACT_DIR="XpreSS-main"

# Spinning web animation frames ::::)
SPIDER_FRAMES=("🕷️ " "🕸️ " "🕷️ " "🕸️ ")
FRAME_IDX=0

# ::::8 Function to print Vriska-themed messages
print_vriska() {
    echo -e "${BOLD}${BLUE}::::::::\)${NC} ${CYAN}$1${NC}"
}

print_info() {
    echo -e "${BLUE}[::::INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS ✓✓✓✓✓✓✓✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[W8RN::::NG!]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR ::::((((]${NC} $1"
}

print_step() {
    echo -e "${BOLD}${MAGENTA}======== Step $1 ========${NC}"
}

print_spider() {
    echo -e "${CYAN}${SPIDER_FRAMES[$FRAME_IDX]}${NC} $1"
    FRAME_IDX=$(( (FRAME_IDX + 1) % ${#SPIDER_FRAMES[@]} ))
}

# Function to cleanup on exit
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_info "Cleaning up the web of temporary files..."
        print_spider "Sweeping away the evidence..."
        rm -rf "$TEMP_DIR"
        print_success "All clean! No traces left ::::)"
    fi
}

trap cleanup EXIT

# Detect the operating system and package manager
detect_os() {
    print_step "1/8"
    print_vriska "Detecting your oper8ing system..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_ID=$ID
        print_success "Found: $OS_NAME"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_NAME="macOS"
        OS_ID="macos"
        print_success "Found: macOS (the 8est OS for cool kids)"
    else
        OS_NAME="Unknown"
        OS_ID="unknown"
        print_warning "Could not detect OS. Will do our 8est anyway!"
    fi
    
    print_info "OS Identific8ion: $OS_ID"
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
        PKG_UPDATE="apt-get update -qq"
        PKG_INSTALL="apt-get install -y"
        print_info "Package manager detected: APT (De8ian/U8untu style)"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="dnf check-update || true"
        PKG_INSTALL="dnf install -y"
        print_info "Package manager detected: DNF (Fedora style)"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        PKG_UPDATE="yum check-update || true"
        PKG_INSTALL="yum install -y"
        print_info "Package manager detected: YUM (RHEL style)"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        PKG_UPDATE="pacman -Sy"
        PKG_INSTALL="pacman -S --noconfirm"
        print_info "Package manager detected: Pacman (Arch style - nice choice 8t8w)"
    elif command -v apk &> /dev/null; then
        PKG_MANAGER="apk"
        PKG_UPDATE="apk update"
        PKG_INSTALL="apk add"
        print_info "Package manager detected: APK (Alpine style)"
    elif command -v brew &> /dev/null; then
        PKG_MANAGER="brew"
        PKG_UPDATE="brew update"
        PKG_INSTALL="brew install"
        print_info "Package manager detected: Homebrew (macOS style)"
    else
        PKG_MANAGER="none"
        print_warning "No package manager detected! You'll need to install dependencies manually."
    fi
}

# ::::) Check if we have sudo access (only when needed)
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        print_info "Running as root - you've got all the power! ::::8"
        return 0
    fi
    
    if sudo -n true 2>/dev/null; then
        print_info "Passwordless sudo detected - convenient!"
        return 0
    fi
    
    print_info "Not running as root, but that's OK for now!"
    print_info "We'll only ask for sudo when we really need it :::;)"
    return 1
}

# Banner!
print_banner() {
    echo -e "${BOLD}${BLUE}"
    echo "████████████████████████████████████████████████████████"
    echo "████ ✱----✱----✱ XpreSS Install8ion ✱----✱----✱ ████"
    echo "████████████████████████████████████████████████████████"
    echo -e "${NC}"
    print_vriska "Welc8me to the XpreSS installer!"
    print_vriska "This script is going to spin a web of awesome for you ::::)"
    echo ""
}

print_banner

# Detect OS
detect_os
echo ""

# Print current status
print_step "2/8"
print_vriska "Checking the situ8ion..."
check_sudo
echo ""

# Check for required commands
print_step "3/8"
print_vriska "Checking for required tools in your arsenal..."
MISSING_DEPS=""
NEEDS_INSTALL=false

print_spider "Scanning for curl or wget..."
if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    print_warning "Neither curl nor wget found!"
    MISSING_DEPS="$MISSING_DEPS curl"
    NEEDS_INSTALL=true
else
    if command -v curl &> /dev/null; then
        print_success "curl is ready to go!"
    else
        print_success "wget is standing by!"
    fi
fi

print_spider "Scanning for unzip..."
if ! command -v unzip &> /dev/null; then
    print_warning "unzip not found!"
    MISSING_DEPS="$MISSING_DEPS unzip"
    NEEDS_INSTALL=true
else
    print_success "unzip is at your service!"
fi

if [ "$NEEDS_INSTALL" = true ]; then
    echo ""
    print_warning "Some dependencies are missing:$MISSING_DEPS"
    
    if [ "$PKG_MANAGER" = "none" ]; then
        print_error "No package manager detected!"
        print_info "Please install these manually:$MISSING_DEPS"
        exit 1
    fi
    
    print_vriska "No worries! I'll install them for you ::::)"
    print_info "This requires elevated privileges..."
    
    if [ "$EUID" -ne 0 ]; then
        print_spider "Requesting sudo access for package install8ion..."
        sudo -v || {
            print_error "Cannot get sudo access!"
            print_info "Please install these packages manually:$MISSING_DEPS"
            exit 1
        }
        print_success "Got the keys to the kingdom! ::::8"
    fi
    
    print_spider "Updating package lists..."
    sudo $PKG_UPDATE
    
    print_spider "Installing dependencies..."
    sudo $PKG_INSTALL $MISSING_DEPS
    
    print_success "All dependencies installed! ::::) ::::) :::;) ::::) ::::) ::::) ::::) :::;)"
else
    print_success "All required tools are already installed! You're well-prepared ::::8"
fi
echo ""

# Create temporary directory (no root needed!)
print_step "4/8"
print_vriska "Setting up a temporary workspace..."
print_spider "Creating directory: $TEMP_DIR"
mkdir -p "$TEMP_DIR"
print_success "Temporary lair cre8ted!"
echo ""

print_step "5/8"
print_vriska "Traveling to the temporary directory..."
cd "$TEMP_DIR"
print_info "Now operating from: $(pwd)"
echo ""

# Download the repository (no root needed!)
print_step "6/8"
print_vriska "Time to c8tch the XpreSS repository from GitHub!"
print_info "Source: $GITHUB_ZIP_URL"
echo ""

if command -v curl &> /dev/null; then
    print_spider "Using curl to snatch the files..."
    curl -L --progress-bar -o xpress.zip "$GITHUB_ZIP_URL"
else
    print_spider "Using wget to snatch the files..."
    wget --show-progress -O xpress.zip "$GITHUB_ZIP_URL"
fi

echo ""
print_success "Downloaded $(du -h xpress.zip | cut -f1) of awesome! ::::8"
echo ""

# Extract the archive
print_step "7/8"
print_vriska "Unraveling the web archive..."
print_spider "Extracting all files..."

unzip -q xpress.zip

# Check if extraction was successful
if [ ! -d "$EXTRACT_DIR" ]; then
    print_error "Failed to extract archive or directory structure unexpected :::;("
    print_info "Expected to find: $EXTRACT_DIR"
    print_info "Actually found: $(ls -1)"
    exit 1
fi

print_success "Extracted successfully!"
print_info "Contents ready in: $EXTRACT_DIR"
echo ""

# Change to extracted directory
print_vriska "Descending into the extracted directory..."
cd "$EXTRACT_DIR"
print_info "Current location: $(pwd)"
print_info "Files available: $(ls -1 | wc -l | tr -d ' ') items"
echo ""

# Make setup script executable
print_spider "Making setup.sh executable..."
chmod +x setup.sh
print_success "setup.sh is now ready to run! ::::)"
echo ""

# Run the setup script
print_step "8/8"
print_vriska "Now for the REAL magic - running the setup script!"
print_info "This is where we actually configure your system..."
print_warning "setup.sh will need root privileges for Apache/MySQL/PHP setup"
echo ""

if [ "$EUID" -ne 0 ]; then
    print_spider "Preparing to escalate privileges..."
    print_info "You may be prompted for your password..."
    echo ""
    sudo ./setup.sh
else
    ./setup.sh
fi

echo ""
echo -e "${BOLD}${BLUE}"
echo "████████████████████████████████████████████████████████"
echo "████████████████████████████████████████████████████████"
print_success "XpreSS install8ion complete! ::::8 ::::8 ::::8"
echo -e "${BLUE}████████████████████████████████████████████████████████"
echo "████████████████████████████████████████████████████████"
echo -e "${NC}"
print_vriska "You're all set! The web is spun and your XpreSS app is ready!"
print_vriska "Thanks for using this installer - may your exploits be fruitful! :::;)"
print_info "The temporary files will be cleaned up automatically."
echo ""
