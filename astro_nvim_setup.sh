sudo apt update && sudo apt upgrade -y

# Instalar Nerd Fonts
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
cd ~/.local/share/fonts 
unzip JetBrainsMono.zip 
rm JetBrainsMono.zip 
fc-cache -fv

# Instalar Nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

# Backup das configs antigas
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

# Baixar minhas configs
git clone https://github.com/Thgm01/AstroNvim_user ~/.config/nvim

# Inicializa o AstroNvim
nvim --headless +q
