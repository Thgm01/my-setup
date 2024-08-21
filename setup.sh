# Remove a senha do sudo
    username=$(whoami)
    echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

# Instalar ROS Humble
    sudo apt update && sudo apt install locales -y
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8

    sudo apt install software-properties-common -y
    sudo add-apt-repository universe 

    sudo apt update && sudo apt install curl -y
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

    sudo apt update && sudo apt upgrade -y
    sudo apt install ros-humble-desktop -y
    sudo apt install ros-dev-tools -y

    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

    sudo apt install python3-colcon-common-extensions -y
    sudo apt-get install ros-humble-vision-msgs -y

    echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
    echo "export _colcon_cd_root=/opt/ros/humble/" >> ~/.bashrc
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

#Install rqt and plugins 
    sudo apt update 
    sudo apt install ros-humble-rqt* -y

#install ros2 dynamixel
    sudo apt-get install ros-humble-dynamixel-sdk -y

#Instalar Oh my zsh (TERMINAR)
    sudo apt update -y
    sudo apt install zsh -y
    sudo apt install curl -y

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    sudo apt install zoxide

    sudo rm ~/.zshrc
    cp zshsetup.txt ~/.zshrc

#Install VsCode
    sudo apt update && sudo apt upgrade && sudo apt install snapd -y
    sudo snap install --classic code -y

# Instalar Nvim
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo mv nvim.appimage /usr/local/bin/nvim

# Instalar SSH
    sudo apt-get update -y
    sudo apt-get install openssh-server -y
