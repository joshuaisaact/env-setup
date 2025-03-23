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
brew install zsh oh-my-zsh micro fzf jandedobbeleer/oh-my-posh/oh-my-posh

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
cp .zshrc ~/
cp .config/ohmyposh/zen.toml ~/.config/ohmyposh/
cp .config/micro/* ~/.config/micro/ 2>/dev/null || true

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
