#!/bin/bash
set -e  # Exit on error

echo "Setting up Linux development environment..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    echo "Using apt package manager"
    
    # Update package lists
    sudo apt-get update
    
    # Install basic requirements
    sudo apt-get install -y zsh curl git fzf ripgrep
    
    # Install micro editor
    if ! command -v micro &> /dev/null; then
        echo "Installing micro editor..."
        curl https://getmic.ro | bash
        sudo mv micro /usr/local/bin/
    fi
    
    # Install eza (modern ls replacement)
    if ! command -v eza &> /dev/null; then
        echo "Installing eza..."
        sudo apt-get install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/eza.gpg
        echo "deb [signed-by=/etc/apt/keyrings/eza.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/eza.list
        sudo apt-get update
        sudo apt-get install -y eza
    fi

# Install bat (syntax highlighting cat replacement)
if ! command -v bat &> /dev/null; then
    echo "Installing bat..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        # For Ubuntu/Debian
        sudo apt-get install -y bat
        # Ubuntu/Debian usually name the binary 'batcat' to avoid name conflicts
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            echo "Creating bat symlink..."
            mkdir -p ~/.local/bin
            ln -sf /usr/bin/batcat ~/.local/bin/bat
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        fi
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        # For Fedora/RHEL
        sudo dnf install -y bat
    fi
fi
    
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    echo "Using dnf package manager"
    
    # Update package lists
    sudo dnf check-update
    
    # Install basic requirements
    sudo dnf install -y zsh curl git fzf ripgrep
    
    # Install micro editor
    if ! command -v micro &> /dev/null; then
        echo "Installing micro editor..."
        curl https://getmic.ro | bash
        sudo mv micro /usr/local/bin/
    fi
    
    # Install eza (modern ls replacement)
    if ! command -v eza &> /dev/null; then
        echo "Installing eza..."
        sudo dnf install -y eza
    fi
    
else
    echo "Unsupported Linux distribution. Please install packages manually."
    exit 1
fi

# Install fd (fast find alternative)
if ! command -v fd &> /dev/null; then
    echo "Installing fd-find..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt-get install -y fd-find
        # Ubuntu/Debian usually name the binary 'fdfind'
        if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
            echo "Creating fd symlink..."
            mkdir -p ~/.local/bin
            ln -sf $(which fdfind) ~/.local/bin/fd
        fi
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y fd-find
    fi
fi

# Install Oh My Posh for Linux
if ! command -v oh-my-posh &> /dev/null; then
    echo "Installing Oh My Posh..."
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
        echo "Could not find Oh My Posh binary. Trying alternative installation method..."
        
        # Try alternative installation method using the Debian package
        wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64.deb
        sudo dpkg -i posh-linux-amd64.deb
        rm posh-linux-amd64.deb
        
        # Verify again
        echo "Verifying Oh My Posh installation after alternative method..."
        which oh-my-posh || echo "Oh My Posh installation failed. Please install manually."
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

# Set zsh as default shell if it's not already
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# Source the new config
echo "Installation complete!"
echo "Please run 'source ~/.zshrc' or restart your terminal to apply changes."
