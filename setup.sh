# Remove a senha do sudo
    username=$(whoami)
    echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

#Instalar Oh my zsh (TERMINAR)
    sudo apt update -y
    sudo apt install zsh -y
    sudo apt install curl -y

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    sudo apt install zoxide

    sudo rm ~/.zshrc
    cp zshsetup.txt ~/.zshrc

# Instalar Nvim
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo mv nvim.appimage /usr/local/bin/nvim
