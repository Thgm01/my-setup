#!/bin/bash
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_PATH/utils.sh"

log_section "Removendo versões antigas do Docker"

log_step "Verificando pacotes antigos instalados..."
OLD_PACKAGES=$(dpkg --get-selections \
    docker.io docker-compose docker-compose-v2 \
    docker-doc podman-docker containerd runc \
    2>/dev/null | cut -f1)

if [ -n "$OLD_PACKAGES" ]; then
    log_info "Pacotes encontrados para remover: $OLD_PACKAGES"
    sudo apt remove -y $OLD_PACKAGES
    log_success "Pacotes antigos removidos"
else
    log_debug "Nenhum pacote antigo encontrado, pulando..."
fi

log_section "Dependências"

check_connectivity

log_step "Atualizando lista de pacotes..."
sudo apt update -y
log_success "Lista atualizada"

ensure_cmd "curl"          "curl"
ensure_cmd "gnupg"         "gnupg"
ensure_cmd "lsb_release"   "lsb-release"

log_section "Configurando repositório oficial do Docker"

log_step "Adicionando chave GPG oficial do Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
log_success "Chave GPG adicionada"

log_step "Adicionando repositório do Docker ao apt..."
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
log_success "Repositório adicionado"

log_step "Atualizando lista de pacotes com novo repositório..."
sudo apt update -y
log_success "Lista de pacotes atualizada"

log_section "Instalando Docker Engine e Compose"

log_step "Instalando pacotes do Docker..."
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

if [ $? -ne 0 ]; then
    log_error "Falha ao instalar o Docker — verifique os logs acima"
    exit 1
fi

log_success "Docker Engine e Compose instalados"

log_section "Pós-instalação"

log_step "Habilitando Docker para iniciar com o sistema..."
sudo systemctl enable docker
sudo systemctl start docker
log_success "Serviço Docker ativo"

log_step "Adicionando usuário '$USER' ao grupo docker..."
sudo usermod -aG docker "$USER"
log_success "Usuário '$USER' adicionado ao grupo docker"

log_step "Verificando instalação..."
DOCKER_VERSION=$(docker --version 2>/dev/null)
COMPOSE_VERSION=$(docker compose version 2>/dev/null)

if [ -n "$DOCKER_VERSION" ]; then
    log_success "Docker:  $DOCKER_VERSION"
else
    log_error "Docker não encontrado após instalação"
    exit 1
fi

if [ -n "$COMPOSE_VERSION" ]; then
    log_success "Compose: $COMPOSE_VERSION"
else
    log_warning "Docker Compose plugin não encontrado"
fi

log_section "Concluído"
log_success "Docker instalado com sucesso!"
log_warning "Faça logout/login para usar o Docker sem sudo"