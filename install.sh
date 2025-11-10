#!/bin/bash

# Windsurf VIP Installation Script
# Usage: bash <(curl -Lk https://raw.githubusercontent.com/Xcloud-hub1/coding/main/install.sh)

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing Windsurf VIP...${NC}"

# Get promotion code from argument
PROMOTION_CODE="${1:-}"

# Detect OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    i386|i686)
        ARCH="386"
        ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${YELLOW}Go is not installed. Installing Go...${NC}"
    
    if [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y golang-go
        elif command -v yum &> /dev/null; then
            sudo yum install -y golang
        else
            echo -e "${RED}Please install Go manually: https://golang.org/doc/install${NC}"
            exit 1
        fi
    elif [[ "$OS" == "darwin" ]]; then
        if command -v brew &> /dev/null; then
            brew install go
        else
            echo -e "${RED}Please install Go manually: https://golang.org/doc/install${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Please install Go manually: https://golang.org/doc/install${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}Go version: $(go version)${NC}"

# Create temp directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo -e "${GREEN}Downloading source code...${NC}"
git clone https://github.com/Xcloud-hub1/coding.git
cd coding

# Fix go.mod version if needed
if grep -q "go 1.22" go.mod; then
    sed -i.bak 's/go 1.22.*/go 1.18/' go.mod
fi

echo -e "${GREEN}Building windsurf-vip...${NC}"
go build -ldflags "-w -s" -o windsurf-vip

# Install to system
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="windsurf-vip"

if [[ "$OS" == "linux" ]] || [[ "$OS" == "darwin" ]]; then
    echo -e "${GREEN}Installing to $INSTALL_DIR...${NC}"
    sudo mv windsurf-vip "$INSTALL_DIR/$BINARY_NAME"
    sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
    
    # Save promotion code if provided
    if [[ -n "$PROMOTION_CODE" ]]; then
        echo "$PROMOTION_CODE" > "$HOME/.windsurf-viprc"
        echo -e "${GREEN}Promotion code saved: $PROMOTION_CODE${NC}"
    fi
    
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${YELLOW}Run the following command to start:${NC}"
    echo -e "${GREEN}windsurf-vip${NC}"
    
    # Clean up
    cd /
    rm -rf "$TMP_DIR"
    
    # Ask if user wants to run now
    read -p "Do you want to run windsurf-vip now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        windsurf-vip
    fi
else
    echo -e "${RED}Unsupported OS: $OS${NC}"
    exit 1
fi
