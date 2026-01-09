#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "===== STARTING INSTALLATION ====="

# 1. Update System & Install Official Packages
echo "--> Updating system and installing Pacman packages..."
sudo pacman -Syu --noconfirm --needed \
    alacritty zsh polybar rofi dunst feh unzip usbutils btop \
    thunar thunar-archive-plugin file-roller gvfs mousepad viewnior \
    abiword gnumeric fastfetch papirus-icon-theme redshift brightnessctl \
    git base-devel

# 2. Install Yay (AUR Helper)
if ! command -v yay &> /dev/null; then
    echo "--> Yay not found. Installing..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
else
    echo "--> Yay is already installed."
fi

# 3. Install AUR Packages
echo "--> Installing AUR packages..."
yay -S --noconfirm nwg-look gruvbox-dark-gtk ttf-iosevka-nerd xcursor-skyrim

# 4. Copy Dotfiles (From current folder)
echo "--> Deploying configuration files..."

# Ensure .config exists
mkdir -p ~/.config

# List of folders to copy
folders=(bspwm sxhkd polybar alacritty rofi dunst nvim nwg-look gtk-3.0 gtk-4.0 xsettingsd)

for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        # Backup existing config if it exists
        if [ -d "$HOME/.config/$folder" ]; then
            echo "    Backing up existing $folder to $folder.bak"
            mv "$HOME/.config/$folder" "$HOME/.config/$folder.bak"
        fi
        
        echo "    Copying $folder..."
        cp -r "$folder" ~/.config/
    else
        echo "    WARNING: $folder not found in current directory. Skipping."
    fi
done

# Copy specific files
echo "--> Copying standalone files..."
[ -f .zshrc ] && cp .zshrc ~/ || echo "    .zshrc not found"

if [ -f .gtkrc-2.0 ]; then
    echo "    Copying .gtkrc-2.0..."
    cp .gtkrc-2.0 ~/
fi

# 5. Post-Installation Configuration
echo "--> Finalizing setup..."

# Make scripts executable
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/polybar/launch.sh

echo "===== INSTALLATION COMPLETE ====="
echo "Please restart your computer to apply all changes."
