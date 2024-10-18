#!/bin/bash

clear

# Definindo cores
VERMELHO='\033[31m'
VERDE='\033[32m'
AMARELO='\033[33m'
RESET='\033[0m'

folder_path=$(find ~/ -name "my-setup")

# Flags para a instalação
git_plugins_flag=false

ros2_install_flag=false
ros2_plugin_flag=false

kicad_install=false

cancel=false

for arg in "$@"; do
    case $arg in
        -g|--git_plugins)
            git_plugins_flag=true

            # Se não encontrar o arquivo cancela as operações
            if [ -z "$(find "$folder_path" -name git_plugins.sh 2>/dev/null)" ]; then
                echo -e "${VERMELHO}git_plugins.sh não encontrado!${RESET}"
                cancel=true
                break
            fi
            ;;
        
        -ri| --ros_install)
            ros2_install_flag=true
            ros2_plugin_flag=true
            ;;

        -rp| --ros_plugins)
            ros2_plugin_flag=true
            ;;

        -k| --kicad_install)
            kicad_install=true
            ;;
        *)
            echo -e "${VERMELHO}Opção inválida: $arg${RESET}"
            cancel=true
            break
            ;;
    esac
done

# Cancela imprimindo uma mensagem na tela
if [ "$cancel" = true ]; then
    echo -e "${VERMELHO}Todas as alterações foram descartadas!${RESET}"
    echo -e "${VERMELHO}Encerrando o programa!${RESET}"
    exit 1
fi


# Instalas tudo relacionado ao git
if [ "$git_plugins_flag" = true ]; then
    echo -e "${AMARELO}Atualizando/Instalando plugins do git${RESET}"

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
    echo -e "${VERDE}Plugins do git atualizado/instalado com sucesso${RESET}"
fi

# Instalar as dependencias do ros2
if [ "$ros2_install_flag" = true ]; then
    if [ "$ROS_DISTRO" != "humble" ]; then
        echo -e "${AMARELO}Instalando ROS2 Humble${RESET}"
        "$folder_path"/ros2_setup/ros2_humble_install.sh
    else
        echo -e "${VERDE}ROS2 já está instalado${RESET}"
    fi
fi

if [ "$ros2_plugin_flag" = true ]; then
    echo -e "${AMARELO}Atualizando/Instalando plugins do ROS2${RESET}"
    
    if [ "$ROS_DISTRO" != "humble" ]; then
        echo -e "${VERMELHO}ROS2 Humble não instalado${RESET}"
    else
        if [ -n "$(ls -a ~/ | grep .ros2_plugins)" ]; then
            rm -f ~/.ros2_plugins
        fi

        cp "$folder_path"/ros2_setup/ros2_plugins.sh ~/.ros2_plugins

        # Caso não tenha o comando de source no .bashrc adiciona ele
        if ! grep -q "source ~/.ros2_plugins" ~/.bashrc; then
            echo "source ~/.ros2_plugins" >> ~/.bashrc
        fi

        # Caso tenha o terminal zsh verificar se possui o source no .zshrc
        # Caso não tenha o source adiciona ele
        if [ -n "$(ls -a ~/ | grep .zshrc)" ]; then
            if ! grep -q "source ~/.ros2_plugins" ~/.zshrc; then
                echo "source ~/.ros2_plugins" >> ~/.zshrc
            fi
        fi
    fi
    echo -e "${VERDE}Plugins do ROS atualizado/instalado com sucesso${RESET}"
fi

# Instalação do kicad 8.0
if [ "$kicad_install" = true ]; then
    echo -e "${AMARELO}Instalando Kicad 8.0${RESET}"
    "$folder_path"/kicad_install.sh
    echo -e "${VERDE}Kicad 8.0 instalado com sucesso${RESET}"
fi


# diferencia os terminais para aplicar as alterações
if [[ "$SHELL" == *"zsh"* ]]; then
    zsh
else
    source ~/.bashrc
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
