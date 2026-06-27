#!/bin/bash
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_PATH/utils.sh"

log_section "Corrigindo Locale do Sistema"

log_step "Atualizando lista de pacotes..."
sudo apt update -y
log_success "Lista atualizada"

ensure_cmd "locale-gen" "locales"

log_step "Habilitando pt_BR.UTF-8 no locale.gen..."
sudo sed -i 's/^# *\(pt_BR.UTF-8 UTF-8\)/\1/' /etc/locale.gen
log_success "Locale pt_BR.UTF-8 habilitado"

log_step "Gerando locales..."
sudo locale-gen
log_success "Locales gerados"

log_step "Aplicando locale padrão do sistema..."
sudo update-locale LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8
log_success "Locale definido: LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8"

log_section "Concluído"
log_success "Locale corrigido com sucesso!"
log_warning "Desconecte e reconecte sua sessão SSH para aplicar as mudanças"