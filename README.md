# my-setup

## Observações
Para o funcionamento de autocompletar os comandos de ROS2 é necessário remover as linhas `autoload -U +x compinit && compinit` e `autoload -U +x bashcompinit && bashcompinit` dos arquivos abaixo:
- `/usr/share/colcon_argcomplete/hook/colcon-argcomplete.zsh`
- `/opt/ros/humble/share/ros2cli/environment/ros2-argcomplete.zsh`
- `/opt/ros/humble/share/ament_index_python/environment/ament_index-argcomplete.zsh`
- `/opt/ros/humble/share/rosidl_cli/environment/rosidl-argcomplete.zsh`
