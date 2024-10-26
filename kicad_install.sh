# Instalação do Kicad 8.0
if [ -z "$(grep -r ^deb /etc/apt/sources.list* | grep kicad)" ]; then
  sudo add-apt-repository ppa:kicad/kicad-8.0-releases
else
  printf "\nJá está posuí  o repositorio no apt!\n\n"
fi

sudo apt update -y
sudo apt install kicad -y
