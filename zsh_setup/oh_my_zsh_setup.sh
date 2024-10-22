#Instalar Oh my zsh
    folder_path="$(find ~/ -name "my-setup")"/zsh_setup

    # Pré Requisitos
    sudo apt update -y
    sudo apt install zsh curl -y

    # Caso já exista não instala o Oh my zsh
    if [ -n "$(ls -a ~/ | grep .oh-my-zsh)" ]; then
        echo "OH-MY-ZSH Já está instalado"
    else
        # Download e instalação
        wget -P "$folder_path" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
        # Comentar a linha de inicialização automática para não travar o resto da instalação
        sed -i '/exec zsh -l/s/^/#/' "$folder_path"/install.sh
        sh "$folder_path"/install.sh
        rm -f "$folder_path"/install.sh
    fi
    
    # Configuração de plugins do zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sudo apt install zoxide
    
    # Passando minhas configurações do zsh
    sudo rm ~/.zshrc
    cp "$folder_path"/zshsetup.txt ~/.zshrc

    # Definindo o zsh como padrão
    chsh -s $(which zsh)
    eval"$(zoxide init zsh)"
