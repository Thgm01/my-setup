# Instalar o ROS Humble
    sudo apt install software-properties-common -y
    sudo add-apt-repository universe -y
    sudo apt update && sudo apt install curl -y
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
    sudo apt update && sudo apt upgrade -y
    sudo apt install ros-humble-desktop -y
    sudo apt install ros-dev-tools -y

# Instalar o TurtleSim
    sudo apt update -y
    sudo apt install ros-humble-turtlesim -y

# Instalar rqt
    sudo apt install '~nros-humble-rqt*' -y

# Colcon Setup
    sudo apt install python3-colcon-common-extensions -y

# Instalar Gazebo
    sudo apt update && sudo apt upgrade -y
    sudo apt install '~nros-humble-gazebo-*' -y

# Instalar outros pacotes
    sudo apt install ros-humble-joint-state-publisher
    sudo apt install ros-humble-joint-state-publisher-gui

# Source
if [[ "$SHELL" == *"zsh"* ]]; then
    source /opt/ros/humble/setup.zsh
else
	source /opt/ros/humble/setup.bash
fi

