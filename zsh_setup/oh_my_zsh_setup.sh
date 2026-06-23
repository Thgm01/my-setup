#!/bin/bash
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Instala dependências
if ! command -v zsh > /dev/null 2>&1 ; then
    sudo apt install zsh -y
fi

if ! command -v curl > /dev/null 2>&1 ; then
    sudo apt install curl -y
fi

if ! command -v zoxide > /dev/null 2>&1 ; then
    sudo apt install zoxide -y
fi

# Instala o Oh My Zsh se ainda não existir
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "OH-MY-ZSH já está instalado"
else
    echo "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Plugin: zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions já está instalado"
fi

# Plugin: zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting já está instalado"
fi

# Aplica suas configurações do zsh
if [ -f "$SCRIPT_PATH/zshsetup.txt" ]; then
    rm -f ~/.zshrc
    cp "$SCRIPT_PATH/zshsetup.txt" ~/.zshrc
else
    echo "Aviso: zshsetup.txt não encontrado em $SCRIPT_PATH"
fi

# Define o zsh como shell padrão
chsh -s "$(which zsh)"

echo "Concluído! Reinicie o terminal (ou faça logout/login) para usar o zsh."