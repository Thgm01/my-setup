#!/bin/bash

# =============================================================
#  log.sh — Funções de log coloridas com timestamp
#  Uso: source log.sh
# =============================================================

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Ícones por nível
ICON_INFO="ℹ"
ICON_SUCCESS="✔"
ICON_WARNING="⚠"
ICON_ERROR="✖"
ICON_DEBUG="⚙"
ICON_STEP="→"

# Nível mínimo de log (DEBUG=0, INFO=1, WARNING=2, ERROR=3)
LOG_LEVEL=${LOG_LEVEL:-0}

# Arquivo de log opcional (deixe vazio para não salvar)
LOG_FILE=${LOG_FILE:-""}

# -------------------------------------------------------------
# Função interna de escrita
# -------------------------------------------------------------
_log_write() {
    local level="$1"
    local level_num="$2"
    local color="$3"
    local icon="$4"
    local message="$5"

    # Filtra pelo nível mínimo
    if [ "$level_num" -lt "$LOG_LEVEL" ]; then
        return
    fi

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local formatted="${color}[${timestamp}] [${icon} ${level}]${RESET} ${WHITE}${message}${RESET}"
    local plain="[${timestamp}] [${level}] ${message}"

    # Erros vão para stderr, o resto para stdout
    if [ "$level" = "ERROR" ]; then
        echo -e "$formatted" >&2
    else
        echo -e "$formatted"
    fi

    # Salva no arquivo sem cores
    if [ -n "$LOG_FILE" ]; then
        echo "$plain" >> "$LOG_FILE"
    fi
}

# -------------------------------------------------------------
# Funções públicas
# -------------------------------------------------------------

log_info() {
    _log_write "INFO" 1 "$BLUE" "$ICON_INFO" "$*"
}

log_success() {
    _log_write "SUCCESS" 1 "$GREEN" "$ICON_SUCCESS" "$*"
}

log_warning() {
    _log_write "WARNING" 2 "$YELLOW" "$ICON_WARNING" "$*"
}

log_error() {
    _log_write "ERROR" 3 "$RED" "$ICON_ERROR" "$*"
}

log_debug() {
    _log_write "DEBUG" 0 "$MAGENTA" "$ICON_DEBUG" "$*"
}

log_step() {
    _log_write "STEP" 1 "$CYAN" "$ICON_STEP" "$*"
}

# Separador visual para agrupar etapas
log_section() {
    local title="$*"
    local line="──────────────────────────────────────────"
    echo -e "${CYAN}${line}${RESET}"
    echo -e "${WHITE}  ${title}${RESET}"
    echo -e "${CYAN}${line}${RESET}"
}