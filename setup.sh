#!/bin/bash

set -e

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${GREEN}[*] Universal AIO Password Recovery - Setup${NC}"
echo ""

detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

PKG=$(detect_pkg_manager)
echo -e "${GREEN}[*] Detected package manager: $PKG${NC}"

install_apt_packages() {
    echo -e "${GREEN}[*] Installing system packages via apt...${NC}"
    sudo apt-get update -qq
    sudo apt install -y -qq \
        p7zip-full \
        unrar \
        openssl \
        gnupg \
        python3 \
        python3-pip \
        libreoffice \
        sqlite3 \
        2>/dev/null || true
}

install_dnf_packages() {
    echo -e "${GREEN}[*] Installing system packages via dnf...${NC}"
    sudo dnf install -y \
        p7zip \
        unrar \
        openssl \
        gnupg2 \
        python3 \
        python3-pip \
        libreoffice \
        sqlite \
        2>/dev/null || true
}

install_yum_packages() {
    echo -e "${GREEN}[*] Installing system packages via yum...${NC}"
    sudo yum install -y \
        p7zip \
        unrar \
        openssl \
        gnupg2 \
        python3 \
        python3-pip \
        libreoffice \
        sqlite \
        2>/dev/null || true
}

install_pacman_packages() {
    echo -e "${GREEN}[*] Installing system packages via pacman...${NC}"
    sudo pacman -S --noconfirm \
        p7zip \
        unrar \
        openssl \
        gnupg \
        python \
        python-pip \
        libreoffice-fresh \
        sqlite \
        2>/dev/null || true
}

install_zypper_packages() {
    echo -e "${GREEN}[*] Installing system packages via zypper...${NC}"
    sudo zypper install -y \
        p7zip \
        unrar \
        openssl \
        gpg2 \
        python3 \
        python3-pip \
        libreoffice \
        sqlite3 \
        2>/dev/null || true
}

case "$PKG" in
    apt)    install_apt_packages ;;
    dnf)    install_dnf_packages ;;
    yum)    install_yum_packages ;;
    pacman) install_pacman_packages ;;
    zypper) install_zypper_packages ;;
    *)
        echo -e "${RED}[!] Unknown package manager. Please install manually:${NC}"
        echo "    - p7zip-full / p7zip"
        echo "    - unrar"
        echo "    - openssl"
        echo "    - gnupg / gnupg2"
        echo "    - python3 + python3-pip"
        echo "    - libreoffice"
        echo "    - sqlite3"
        ;;
esac

echo ""
echo -e "${GREEN}[*] Installing Python packages...${NC}"
pip3 install --user --break-system-packages \
    pikepdf \
    msoffcrypto \
    pykeepass \
    2>/dev/null || pip3 install --user --break-system-packages \
        pikepdf \
        msoffcrypto \
        pykeepass \
        2>/dev/null || true

echo ""
echo -e "${GREEN}[*] Setup complete!${NC}"
echo -e "${GREEN}[*] Run: ./password-recovery.sh${NC}"
