#!/bin/bash
set -e

echo "🚀 Script de Deploy para VPS - Laravel Darwin"
echo "=============================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis (ajuste conforme necessário)
APP_NAME="darwin"
APP_DIR="/var/www/html"
APP_USER="www-data"
PHP_VERSION="8.2"
DOMAIN="darwin.taticamarketing.com.br"

echo -e "${GREEN}📋 Configurações:${NC}"
echo "  - Diretório: $APP_DIR"
echo "  - Usuário: $APP_USER"
echo "  - PHP: $PHP_VERSION"
echo "  - Domínio: $DOMAIN"
echo ""

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Por favor, execute como root ou com sudo${NC}"
    exit 1
fi

# 1. Atualizar sistema
echo -e "${YELLOW}📦 Atualizando sistema...${NC}"
apt update && apt upgrade -y

# 2. Instalar dependências
echo -e "${YELLOW}📦 Instalando dependências...${NC}"
apt install -y \
    software-properties-common \
    curl \
    git \
    unzip \
    nginx \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-opcache \
    certbot \
    python3-certbot-nginx

# 3. Instalar Composer
echo -e "${YELLOW}📦 Instalando Composer...${NC}"
if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

# 4. Instalar Node.js 18.x
echo -e "${YELLOW}📦 Instalando Node.js...${NC}"
if [ ! -f /usr/bin/node ]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
fi

# 5. Criar diretório da aplicação
echo -e "${YELLOW}📁 Criando diretório da aplicação...${NC}"
mkdir -p $APP_DIR
cd $APP_DIR

# 6. Clonar ou atualizar repositório (ajuste a URL do seu repositório)
echo -e "${YELLOW}📥 Clonando/Atualizando repositório...${NC}"
if [ -d "$APP_DIR/.git" ]; then
    echo "  Repositório já existe, fazendo pull..."
    git pull
else
    echo "  Clonando repositório..."
    # Ajuste a URL do seu repositório Git
    read -p "Digite a URL do repositório Git: " REPO_URL
    git clone $REPO_URL $APP_DIR
fi

# 7. Instalar dependências do Composer
echo -e "${YELLOW}📦 Instalando dependências do Composer...${NC}"
cd $APP_DIR
composer install --no-dev --optimize-autoloader --no-interaction

# 8. Instalar dependências do NPM e compilar assets
echo -e "${YELLOW}📦 Instalando dependências do NPM e compilando assets...${NC}"
npm ci --production=false
npm run production

# 9. Configurar permissões
echo -e "${YELLOW}🔐 Configurando permissões...${NC}"
chown -R $APP_USER:$APP_USER $APP_DIR
chmod -R 755 $APP_DIR
chmod -R 775 $APP_DIR/storage
chmod -R 775 $APP_DIR/bootstrap/cache

# 10. Configurar arquivo .env
echo -e "${YELLOW}⚙️  Configurando arquivo .env...${NC}"
if [ ! -f $APP_DIR/.env ]; then
    cp $APP_DIR/.env.example $APP_DIR/.env
    echo -e "${YELLOW}⚠️  Arquivo .env criado. Configure as variáveis de ambiente antes de continuar!${NC}"
    echo "  Pressione Enter após configurar o .env..."
    read
fi

# Gerar APP_KEY se não existir
php artisan key:generate --force || true

# 11. Executar migrações
echo -e "${YELLOW}📦 Executando migrações...${NC}"
php artisan migrate --force --no-interaction

# 12. Criar link simbólico para storage
echo -e "${YELLOW}🔗 Criando link simbólico para storage...${NC}"
php artisan storage:link || true

# 13. Otimizar Laravel
echo -e "${YELLOW}⚡ Otimizando Laravel...${NC}"
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# 14. Configurar Nginx
echo -e "${YELLOW}🌐 Configurando Nginx...${NC}"
cp $APP_DIR/nginx.conf /etc/nginx/sites-available/$APP_NAME
ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/

# Remover configuração padrão se existir
rm -f /etc/nginx/sites-enabled/default

# Testar configuração do Nginx
nginx -t

# 15. Configurar SSL com Let's Encrypt
echo -e "${YELLOW}🔒 Configurando SSL...${NC}"
read -p "Deseja configurar SSL com Let's Encrypt? (s/n): " SETUP_SSL
if [ "$SETUP_SSL" = "s" ] || [ "$SETUP_SSL" = "S" ]; then
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN || echo "⚠️  Erro ao configurar SSL. Configure manualmente depois."
fi

# 16. Reiniciar serviços
echo -e "${YELLOW}🔄 Reiniciando serviços...${NC}"
systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx
systemctl enable php${PHP_VERSION}-fpm
systemctl enable nginx

# 17. Configurar firewall (se necessário)
echo -e "${YELLOW}🔥 Configurando firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow 'Nginx Full'
    ufw allow OpenSSH
    echo "  Firewall configurado"
fi

echo ""
echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
echo ""
echo -e "${GREEN}📋 Próximos passos:${NC}"
echo "  1. Configure o arquivo .env com as variáveis corretas"
echo "  2. Verifique se o SSL está funcionando: https://$DOMAIN"
echo "  3. Verifique os logs em caso de problemas:"
echo "     - Nginx: /var/log/nginx/darwin-error.log"
echo "     - PHP-FPM: /var/log/php${PHP_VERSION}-fpm.log"
echo "     - Laravel: $APP_DIR/storage/logs/laravel.log"
echo ""

