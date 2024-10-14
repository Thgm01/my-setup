#Instalar Oh my zsh (TERMINAR)
    sudo apt update -y
    sudo apt install zsh -y
    sudo apt install curl -y

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    sudo apt install zoxide

    sudo rm ~/.zshrc
    cp zshsetup.txt ~/.zshrc


