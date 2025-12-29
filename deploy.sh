#!/bin/bash

# Script de Deploy Rápido para Darwin (Laravel App)
# Autor: Claude
# Descrição: Automatiza o processo de deploy da aplicação

set -e  # Parar se houver erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║         🚀 Deploy Darwin (Laravel App)               ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Função para exibir mensagens
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    error "Docker não está instalado!"
    echo ""
    echo "Instale o Docker primeiro:"
    echo "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker compose &> /dev/null; then
    error "Docker Compose não está instalado!"
    echo ""
    echo "Instale o Docker Compose:"
    echo "sudo apt install docker-compose-plugin -y"
    exit 1
fi

success "Docker e Docker Compose encontrados!"

# Verificar se arquivo .env existe
if [ ! -f .env ]; then
    warning "Arquivo .env não encontrado!"

    if [ -f .env.production.example ]; then
        info "Copiando .env.production.example para .env..."
        cp .env.production.example .env
        warning "⚠️  IMPORTANTE: Edite o arquivo .env e configure as variáveis antes de continuar!"
        warning "⚠️  Principalmente: APP_URL, DB_PASSWORD, MAIL_* etc."
        echo ""
        read -p "Pressione ENTER depois de configurar o .env..."
    elif [ -f .env.example ]; then
        info "Copiando .env.example para .env..."
        cp .env.example .env
        warning "⚠️  IMPORTANTE: Edite o arquivo .env e configure as variáveis antes de continuar!"
        echo ""
        read -p "Pressione ENTER depois de configurar o .env..."
    else
        error "Nenhum arquivo .env.example encontrado!"
        exit 1
    fi
fi

success "Arquivo .env encontrado!"

# Verificar se APP_KEY está configurado
source .env
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "" ]; then
    warning "APP_KEY não está configurado!"
    info "Gerando APP_KEY..."

    # Gerar chave
    NEW_KEY="base64:$(openssl rand -base64 32)"

    # Atualizar .env
    if grep -q "APP_KEY=" .env; then
        sed -i "s|APP_KEY=.*|APP_KEY=$NEW_KEY|g" .env
    else
        echo "APP_KEY=$NEW_KEY" >> .env
    fi

    success "APP_KEY gerado: $NEW_KEY"
fi

# Menu de opções
echo ""
info "Escolha uma opção:"
echo "1) Deploy completo (build + up + migrate)"
echo "2) Apenas build"
echo "3) Apenas start/up"
echo "4) Parar aplicação"
echo "5) Ver logs"
echo "6) Executar migrações"
echo "7) Limpar caches"
echo "8) Backup do banco de dados"
echo "9) Sair"
echo ""
read -p "Digite o número da opção: " option

case $option in
    1)
        info "Iniciando deploy completo..."

        # Build
        info "Building containers..."
        docker compose -f docker-compose.prod.yml build --no-cache

        # Up
        info "Iniciando containers..."
        docker compose -f docker-compose.prod.yml up -d

        # Aguardar MySQL ficar pronto
        info "Aguardando MySQL ficar pronto..."
        sleep 10

        # Migrações
        info "Executando migrações..."
        docker compose -f docker-compose.prod.yml exec -T app php artisan migrate --force

        # Storage link
        info "Criando link simbólico do storage..."
        docker compose -f docker-compose.prod.yml exec -T app php artisan storage:link || true

        # Caches
        info "Otimizando caches..."
        docker compose -f docker-compose.prod.yml exec -T app php artisan config:cache
        docker compose -f docker-compose.prod.yml exec -T app php artisan route:cache
        docker compose -f docker-compose.prod.yml exec -T app php artisan view:cache

        success "Deploy completo finalizado!"

        echo ""
        info "Aplicação rodando em:"
        echo "  → http://localhost (ou seu domínio)"
        echo ""
        info "Para ver logs:"
        echo "  → docker compose -f docker-compose.prod.yml logs -f"
        ;;

    2)
        info "Building containers..."
        docker compose -f docker-compose.prod.yml build
        success "Build finalizado!"
        ;;

    3)
        info "Iniciando containers..."
        docker compose -f docker-compose.prod.yml up -d
        success "Containers iniciados!"
        docker compose -f docker-compose.prod.yml ps
        ;;

    4)
        info "Parando containers..."
        docker compose -f docker-compose.prod.yml down
        success "Containers parados!"
        ;;

    5)
        info "Exibindo logs (Ctrl+C para sair)..."
        docker compose -f docker-compose.prod.yml logs -f
        ;;

    6)
        info "Executando migrações..."
        docker compose -f docker-compose.prod.yml exec app php artisan migrate --force
        success "Migrações executadas!"
        ;;

    7)
        info "Limpando caches..."
        docker compose -f docker-compose.prod.yml exec app php artisan config:clear
        docker compose -f docker-compose.prod.yml exec app php artisan cache:clear
        docker compose -f docker-compose.prod.yml exec app php artisan route:clear
        docker compose -f docker-compose.prod.yml exec app php artisan view:clear
        success "Caches limpos!"
        ;;

    8)
        BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
        info "Criando backup: $BACKUP_FILE"
        docker compose -f docker-compose.prod.yml exec mysql mysqldump -u root -p${DB_PASSWORD} ${DB_DATABASE} > "$BACKUP_FILE"
        success "Backup criado: $BACKUP_FILE"
        ;;

    9)
        info "Saindo..."
        exit 0
        ;;

    *)
        error "Opção inválida!"
        exit 1
        ;;
esac

echo ""
success "Operação concluída! 🎉"
