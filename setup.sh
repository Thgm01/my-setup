#!/bin/bash

folder_path=$(find ~/ -name "my-setup")

git_plugins_flag=false

cancel=false

for arg in "$@"; do
    case $arg in
        -g|--git_plugins)
        git_plugins_flag=true

        # Se não encontrar o arquivo cancela as operações
        if [ -z "$(find "$folder_path" -name git_plugins.sh 2>/dev/null)" ]; then
            echo "git_plugins.sh não encontrado"
            cancel=true
            break
        fi
        ;;
    *)
        echo "Opção inválida: $arg"
        cancel=true
        break
        ;;
    esac
done

if [ "$cancel" = true ]; then
    echo "Todas as alterações foram descartadas!"
    echo "Encerrando o programa!"
    exit 1
fi


# Instalas tudo relacionado ao git
if [ "$git_plugins_flag" = true ]; then
    # Caso ja tenha o arquivo .git_plugins, apaga ele
    if [ -n "$(ls -a ~/ | grep .git_plugins)" ]; then 
        rm ~/.git_plugins
    fi
    
    # Copia o novo arquivo .git_plugins
    cp "$folder_path"/git_plugins.sh ~/.git_plugins
    
    # Caso não tenha o comando de source no .bashrc adiciona ele
    if ! grep -q "source ~/.git_plugins" ~/.bashrc; then
        echo "source ~/.git_plugins" >> ~/.bashrc
    fi

    # Caso tenha o terminal zsh verificar se possui o source no .zshrc
    # Caso não tenha o source adiciona ele
    if [ -n "$(ls -a ~/ | grep .zshrc)" ]; then
        if ! grep -q "source ~/.git_plugins" ~/.zshrc; then
            echo "source ~/.git_plugins" >> ~/.zshrc
        fi
    fi
    
    # diferencia os terminais para aplicar as alterações
    if [[ "$SHELL" == *"zsh"* ]]; then
        zsh
    else
        echo "DEBUG 2"
        source ~/.bashrc
    fi
fi

# # Verifica se a flag foi ativada
# if [ "$git_plugins_flag" = true ]; then
#   echo "A flag -g ou --git_plugins foi usada"
# else
#   echo "Nenhuma flag de plugin foi usada"
# fi

# #Remove a senha do sudo
#     username=$(whoami)
#     echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo
#
# #Instalar Oh my zsh (TERMINAR)
#     sudo apt update -y
#     sudo apt install zsh -y
#     sudo apt install curl -y
#
#     sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
#     git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
#     sudo apt install zoxide
#
#     sudo rm ~/.zshrc
#     cp zshsetup.txt ~/.zshrc
#
# # Instalar Nvim
#     curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
#     chmod u+x nvim.appimage
#     sudo mv nvim.appimage /usr/local/bin/nvim
