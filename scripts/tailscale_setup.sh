#!/bin/bash
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_PATH/utils.sh"

log_section "Setup Tailscale"

check_connectivity

ensure_cmd "curl" "curl"

log_step "Verificando instalação do Tailscale..."
if ! command -v tailscale > /dev/null 2>&1; then
    log_info "Tailscale não encontrado, instalando..."
    curl -fsSL https://tailscale.com/install.sh | sh
    if command -v tailscale > /dev/null 2>&1; then
        log_success "Tailscale instalado com sucesso"
    else
        log_error "Falha ao instalar o Tailscale"
        exit 1
    fi
else
    log_debug "Tailscale já está instalado, pulando..."
fi

log_section "Configurando Tailscale"

log_step "Verificando status da conexão..."
if sudo tailscale status > /dev/null 2>&1; then
    log_warning "Tailscale já está conectado, pulando autenticação..."
    sudo tailscale status
else
    log_info "Iniciando autenticação com Tailscale..."
    sudo tailscale up
    if sudo tailscale status > /dev/null 2>&1; then
        log_success "Tailscale conectado com sucesso"
    else
        log_error "Falha ao conectar ao Tailscale"
        exit 1
    fi
fi

log_section "Concluído"
log_success "Tailscale configurado e ativo!"