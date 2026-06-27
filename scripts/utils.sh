#!/bin/bash

# =============================================================
#  utils.sh — Funções utilitárias para scripts de setup
#  Uso: source utils.sh
# =============================================================

UTILS_SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$UTILS_SCRIPT_PATH/log.sh"

# -------------------------------------------------------------
# ensure_cmd <binário> <pacote_apt>
#
# Checa se um comando existe. Se não, instala via apt.
# Exemplos:
#   ensure_cmd "curl" "curl"
#   ensure_cmd "docker" "docker-ce"
# -------------------------------------------------------------
ensure_cmd() {
    local cmd="$1"
    local pkg="${2:-$1}"

    if command -v "$cmd" > /dev/null 2>&1; then
        log_debug "'$cmd' já está instalado, pulando..."
    else
        log_info "'$cmd' não encontrado, instalando '$pkg'..."
        sudo apt install -y "$pkg"
        if command -v "$cmd" > /dev/null 2>&1; then
            log_success "'$cmd' instalado com sucesso"
        else
            log_error "Falha ao instalar '$pkg'"
            return 1
        fi
    fi
}

# -------------------------------------------------------------
# ensure_dir <diretório>
#
# Garante que um diretório existe, criando se necessário.
# -------------------------------------------------------------
ensure_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        log_debug "Diretório '$dir' já existe, pulando..."
    else
        mkdir -p "$dir"
        log_success "Diretório '$dir' criado"
    fi
}

# -------------------------------------------------------------
# require_root
#
# Encerra o script se não estiver rodando como root/sudo.
# -------------------------------------------------------------
require_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Este script precisa ser executado com sudo"
        exit 1
    fi
}

# -------------------------------------------------------------
# check_connectivity <host>
#
# Checa se há conectividade com um host. Default: google.com
# -------------------------------------------------------------
check_connectivity() {
    local host="${1:-google.com}"
    log_step "Verificando conectividade com '$host'..."
    if curl -sf --max-time 5 "https://$host" > /dev/null 2>&1; then
        log_success "Conectividade OK"
        return 0
    else
        log_error "Sem conexão com '$host' — verifique sua rede"
        return 1
    fi
}