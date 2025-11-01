#!/bin/bash
set -e  # Exit on error

echo "Setting up development environment..."

# Check for and install Homebrew if needed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install required tools
echo "Installing required tools..."
brew install zsh oh-my-zsh micro fzf jandedobbeleer/oh-my-posh/oh-my-posh eza ripgrep

# Create directories if they don't exist
mkdir -p ~/.config/ohmyposh
mkdir -p ~/.config/micro

# Backup existing config files
if [ -f ~/.zshrc ]; then
    echo "Backing up existing .zshrc to .zshrc.backup"
    cp ~/.zshrc ~/.zshrc.backup
fi

# Copy configuration files
echo "Copying configuration files..."

# Copy zshrc (prefer .zshrc.mac if available)
if [ -f .zshrc.mac ]; then
    cp .zshrc.mac ~/.zshrc
    echo "Copied .zshrc.mac to ~/.zshrc"
elif [ -f .zshrc ]; then
    cp .zshrc ~/.zshrc
    echo "Copied .zshrc to ~/.zshrc"
else
    echo "Warning: .zshrc.mac or .zshrc not found in current directory, skipping..."
fi

# Copy Oh My Posh theme
if [ -f .config/ohmyposh/zen.toml ]; then
    cp .config/ohmyposh/zen.toml ~/.config/ohmyposh/
    echo "Copied Oh My Posh theme"
else
    echo "Warning: zen.toml not found, skipping..."
fi

# Copy micro editor config
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

# Copy yabai config if available
if [ -f .config/yabai/yabairc ]; then
    mkdir -p ~/.config/yabai
    cp .config/yabai/yabairc ~/.config/yabai/
    chmod +x ~/.config/yabai/yabairc
    echo "Copied yabai configuration"
fi

# Install Oh My Zsh plugins if needed
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Source the new config
echo "Installation complete!"
echo "Please run 'source ~/.zshrc' or restart your terminal to apply changes."
