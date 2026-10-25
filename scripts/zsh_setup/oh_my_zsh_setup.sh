#!/bin/bash
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_PATH/../utils.sh"

# Uso: ./oh_my_zsh_setup.sh [texto_do_banner]
# Ex.: ./oh_my_zsh_setup.sh jetson
# Em Raspberry Pi / Jetson a placa é detectada: aplica a paleta dela, instala o
# resumo do sistema no login e, sem texto informado, usa o nome da placa no banner.
BANNER_TEXT="${1:-}"
DEVICE="$(detect_device)"
[ -z "$BANNER_TEXT" ] && BANNER_TEXT="$DEVICE"

log_section "Setup Oh My Zsh"

if [ -n "$DEVICE" ]; then
    log_info "Placa detectada: $DEVICE"
else
    log_info "Nenhuma placa conhecida detectada (raspberry/jetson) — sem paleta e sem resumo do sistema"
fi

check_connectivity

log_section "Dependências"

log_step "Verificando dependências..."
ensure_cmd "zsh"    "zsh"
ensure_cmd "curl"   "curl"
ensure_cmd "git"    "git"
ensure_cmd "zoxide" "zoxide"
[ -n "$BANNER_TEXT" ] && ensure_cmd "figlet" "figlet"

log_section "Oh My Zsh"

if [ -d "$HOME/.oh-my-zsh" ]; then
    log_warning "Oh My Zsh já está instalado, pulando..."
else
    log_step "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh instalado"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

log_section "Tema Powerlevel10k"

log_step "Verificando powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    log_info "Clonando powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    log_success "powerlevel10k instalado"
else
    log_warning "powerlevel10k já está instalado, pulando..."
fi

log_step "Aplicando configuração do p10k..."
if [ -f "$SCRIPT_PATH/p10k.zsh" ]; then
    cp "$SCRIPT_PATH/p10k.zsh" ~/.p10k.zsh
    log_success "~/.p10k.zsh copiado de $SCRIPT_PATH/p10k.zsh"
else
    log_warning "p10k.zsh não encontrado em $SCRIPT_PATH — rode 'p10k configure' no primeiro login e salve o ~/.p10k.zsh nesse caminho"
fi

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

if [ -n "$DEVICE" ]; then
    log_step "Instalando resumo do sistema no login..."
    if [ -f "$SCRIPT_PATH/sysinfo.zsh" ]; then
        cp "$SCRIPT_PATH/sysinfo.zsh" ~/.zsh_sysinfo.zsh
        log_success "Resumo copiado para ~/.zsh_sysinfo.zsh"
    else
        log_error "sysinfo.zsh não encontrado em $SCRIPT_PATH — resumo não instalado"
    fi

    # Silencia o MOTD do Ubuntu/Jetson e o "Last login" no SSH.
    touch ~/.hushlogin
    log_success "MOTD e 'Last login' desativados (~/.hushlogin)"
else
    rm -f ~/.zsh_sysinfo.zsh
fi

# Paleta dark da placa detectada (cores 256 do p10k):
#   DARK   = fundo escuro tingido do segmento do diretório
#   MUTED  = texto do diretório e diretórios encurtados
#   ACCENT = diretório âncora (o atual), contexto e prompt char
# BANNER_RGB = cor do banner, mais escura que a cor oficial da marca.
case "$DEVICE" in
    jetson)    DARK=22; MUTED=70;  ACCENT=118; BANNER_RGB="94;148;0" ;;   # NVIDIA green #76B900
    raspberry) DARK=52; MUTED=168; ACCENT=211; BANNER_RGB="160;21;59" ;;  # Raspberry red #C51A4A
    *)         DARK=""; MUTED=""; ACCENT=""; BANNER_RGB="" ;;
esac

if [ -n "$BANNER_TEXT" ]; then
    log_step "Gerando banner '$BANNER_TEXT'..."
    if [ -n "$BANNER_RGB" ]; then
        { printf '\033[38;2;%sm' "$BANNER_RGB"; figlet "$BANNER_TEXT"; printf '\033[0m'; } > ~/.zsh_banner
    else
        figlet "$BANNER_TEXT" > ~/.zsh_banner
    fi
    log_success "Banner salvo em ~/.zsh_banner"
else
    log_debug "Nenhum banner informado, mantendo ~/.zsh_banner atual (se existir)"
fi

if [ -n "$ACCENT" ]; then
    echo "$MUTED" > ~/.zsh_sysinfo_color
    log_step "Aplicando paleta de '$DEVICE' no prompt..."
    cat > ~/.zsh_theme.zsh <<EOF
# Gerado por oh_my_zsh_setup.sh (paleta: $DEVICE). Carregado depois do ~/.p10k.zsh.
# Estilo rainbow (POWERLEVEL9K_BACKGROUND definido) tinge o fundo do diretório; lean só colore o texto.
[[ -n \$POWERLEVEL9K_BACKGROUND ]] && typeset -g POWERLEVEL9K_DIR_BACKGROUND=$DARK
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$MUTED
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$MUTED
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$ACCENT
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO,REMOTE,REMOTE_SUDO,ROOT}_FOREGROUND=$MUTED
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$ACCENT
(( \$+functions[p10k] )) && p10k reload
EOF
    log_success "Paleta salva em ~/.zsh_theme.zsh"
else
    rm -f ~/.zsh_theme.zsh ~/.zsh_sysinfo_color
    log_debug "Sem paleta de placa — usando cores do p10k.zsh"
fi

log_step "Definindo zsh como shell padrão..."
chsh -s "$(which zsh)"
log_success "Shell padrão alterado para zsh"

log_section "Concluído"
log_success "Setup finalizado! Reinicie o terminal (ou faça logout/login) para usar o zsh."