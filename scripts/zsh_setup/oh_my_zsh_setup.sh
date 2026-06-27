#!/bin/bash
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_PATH/../utils.sh"

log_section "Setup Oh My Zsh"

check_connectivity

log_section "Dependências"

log_step "Verificando dependências..."
ensure_cmd "zsh"    "zsh"
ensure_cmd "curl"   "curl"
ensure_cmd "git"    "git"
ensure_cmd "zoxide" "zoxide"

log_section "Oh My Zsh"

if [ -d "$HOME/.oh-my-zsh" ]; then
    log_warning "Oh My Zsh já está instalado, pulando..."
else
    log_step "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh instalado"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

log_section "Plugins"

log_step "Verificando zsh-autosuggestions..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    log_info "Clonando zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    log_success "zsh-autosuggestions instalado"
else
    log_warning "zsh-autosuggestions já está instalado, pulando..."
fi

log_step "Verificando zsh-syntax-highlighting..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    log_info "Clonando zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting instalado"
else
    log_warning "zsh-syntax-highlighting já está instalado, pulando..."
fi

log_section "Configurações"

log_step "Aplicando configurações do zshrc..."
if [ -f "$SCRIPT_PATH/zshsetup.txt" ]; then
    rm -f ~/.zshrc
    cp "$SCRIPT_PATH/zshsetup.txt" ~/.zshrc
    log_success "zshrc configurado com sucesso"
else
    log_error "zshsetup.txt não encontrado em $SCRIPT_PATH — configurações não aplicadas"
fi

log_step "Definindo zsh como shell padrão..."
chsh -s "$(which zsh)"
log_success "Shell padrão alterado para zsh"

log_section "Concluído"
log_success "Setup finalizado! Reinicie o terminal (ou faça logout/login) para usar o zsh."