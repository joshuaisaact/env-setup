#!/bin/bash
set -e  # Exit on error

echo "Setting up Arch Linux development environment..."

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo "Error: This script is designed for Arch Linux (pacman not found)"
    exit 1
fi

echo "Using pacman package manager"

# Update package database
echo "Updating package database..."
sudo pacman -Sy

# Install basic requirements
echo "Installing basic tools..."
sudo pacman -S --needed --noconfirm zsh curl git fzf ripgrep fd bat eza github-cli micro

# Install Zed editor
if ! command -v zed &> /dev/null; then
    echo "Installing Zed editor..."
    # Check if AUR helper is available (yay or paru)
    if command -v yay &> /dev/null; then
        echo "Using yay to install Zed from AUR..."
        yay -S --needed --noconfirm zed
    elif command -v paru &> /dev/null; then
        echo "Using paru to install Zed from AUR..."
        paru -S --needed --noconfirm zed
    else
        echo "No AUR helper found. Installing Zed manually..."
        curl -f https://zed.dev/install.sh | sh
        echo "Zed installed to ~/.local/bin/zed"
    fi
fi

# Install Oh My Posh
if ! command -v oh-my-posh &> /dev/null; then
    echo "Installing Oh My Posh..."

    # Check if AUR helper is available (yay or paru)
    if command -v yay &> /dev/null; then
        echo "Using yay to install Oh My Posh from AUR..."
        yay -S --needed --noconfirm oh-my-posh-bin
    elif command -v paru &> /dev/null; then
        echo "Using paru to install Oh My Posh from AUR..."
        paru -S --needed --noconfirm oh-my-posh-bin
    else
        echo "No AUR helper found. Installing Oh My Posh manually..."
        curl -s https://ohmyposh.dev/install.sh | bash -s

        # Find the Oh My Posh binary
        echo "Locating Oh My Posh binary..."
        OH_MY_POSH_PATH=$(find $HOME -name "oh-my-posh" 2>/dev/null | head -n 1)

        if [ -z "$OH_MY_POSH_PATH" ]; then
            # Try a broader search if not found in home directory
            echo "Searching system-wide for Oh My Posh..."
            OH_MY_POSH_PATH=$(sudo find / -name "oh-my-posh" 2>/dev/null | grep -v "Permission denied" | head -n 1)
        fi

        if [ -n "$OH_MY_POSH_PATH" ]; then
            echo "Found Oh My Posh at: $OH_MY_POSH_PATH"

            # Create symlink to ensure it's in PATH
            echo "Creating symlink in /usr/local/bin..."
            sudo ln -sf "$OH_MY_POSH_PATH" /usr/local/bin/oh-my-posh

            # Make sure it's executable
            sudo chmod +x /usr/local/bin/oh-my-posh

            # Verify the symlink
            echo "Verifying Oh My Posh installation..."
            ls -la /usr/local/bin/oh-my-posh
            which oh-my-posh
            oh-my-posh --version
        else
            echo "Could not find Oh My Posh binary after installation."
            echo "Please install manually or install an AUR helper (yay/paru) and re-run."
        fi
    fi
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Create directories if they don't exist
mkdir -p ~/.config/ohmyposh
mkdir -p ~/.config/micro

# Backup existing config files
if [ -f ~/.zshrc ]; then
    echo "Backing up existing .zshrc to .zshrc.backup"
    cp ~/.zshrc ~/.zshrc.backup
fi

# Copy configuration files (only if they exist in current directory)
echo "Copying configuration files..."
if [ -f .zshrc.linux ]; then
    cp .zshrc.linux ~/.zshrc
    echo "Copied .zshrc.linux to ~/.zshrc"
elif [ -f .zshrc ]; then
    cp .zshrc ~/.zshrc
    echo "Copied .zshrc to ~/.zshrc"
else
    echo "Warning: .zshrc.linux or .zshrc not found in current directory, skipping..."
fi

if [ -f .config/ohmyposh/zen.toml ]; then
    cp .config/ohmyposh/zen.toml ~/.config/ohmyposh/
    echo "Copied Oh My Posh theme"
else
    echo "Warning: zen.toml not found, skipping..."
fi

if [ -d .config/micro ]; then
    cp .config/micro/* ~/.config/micro/ 2>/dev/null || true
    echo "Copied micro configuration"
else
    echo "Warning: micro config directory not found, skipping..."
fi

# Copy ghostty config if available
if [ -f .config/ghostty/config ]; then
    mkdir -p ~/.config/ghostty
    cp .config/ghostty/config ~/.config/ghostty/
    echo "Copied ghostty configuration"
fi

# Install Oh My Zsh plugins if needed
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "zsh-autosuggestions already installed, skipping..."
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "zsh-syntax-highlighting already installed, skipping..."
fi

# Set zsh as default shell if it's not already
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

echo ""
echo "============================================"
echo "Installation complete!"
echo "============================================"
echo ""
echo "All tools installed:"
echo "  - zsh (shell)"
echo "  - Oh My Zsh (framework)"
echo "  - Oh My Posh (prompt)"
echo "  - micro (editor)"
echo "  - zed (editor)"
echo "  - fzf (fuzzy finder)"
echo "  - ripgrep (rg)"
echo "  - fd (find alternative)"
echo "  - bat (cat with syntax highlighting)"
echo "  - eza (modern ls)"
echo "  - github-cli (gh)"
echo ""
echo "Please run 'source ~/.zshrc' or restart your terminal to apply changes."
echo ""
