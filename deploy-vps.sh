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

# 2. Adicionar repositório do PHP (Ondrej PPA)
echo -e "${YELLOW}📦 Adicionando repositório do PHP...${NC}"
apt install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
apt update

# 3. Instalar dependências básicas
echo -e "${YELLOW}📦 Instalando dependências básicas...${NC}"
apt install -y \
    curl \
    git \
    unzip \
    nginx \
    certbot \
    python3-certbot-nginx

# 4. Instalar PHP e extensões
echo -e "${YELLOW}📦 Instalando PHP ${PHP_VERSION} e extensões...${NC}"
apt install -y \
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
    php${PHP_VERSION}-opcache

# 5. Instalar Composer
echo -e "${YELLOW}📦 Instalando Composer...${NC}"
if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

# 6. Instalar Node.js 18.x
echo -e "${YELLOW}📦 Instalando Node.js...${NC}"
if [ ! -f /usr/bin/node ]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
fi

# 7. Criar diretório da aplicação
echo -e "${YELLOW}📁 Preparando diretório da aplicação...${NC}"

# Verificar se o diretório já existe
if [ -d "$APP_DIR" ]; then
    if [ -d "$APP_DIR/.git" ]; then
        echo "  ✅ Diretório já existe e é um repositório Git"
        cd $APP_DIR
        echo "  📥 Fazendo pull para atualizar..."
        git pull || echo "  ⚠️  Erro ao fazer pull, continuando..."
    else
        echo -e "${YELLOW}  ⚠️  Diretório $APP_DIR já existe mas não é um repositório Git${NC}"
        read -p "  Deseja limpar o diretório e clonar novamente? (s/n): " CLEAN_DIR
        if [ "$CLEAN_DIR" = "s" ] || [ "$CLEAN_DIR" = "S" ]; then
            echo "  🗑️  Limpando diretório..."
            rm -rf $APP_DIR/*
            rm -rf $APP_DIR/.* 2>/dev/null || true
            read -p "  Digite a URL do repositório Git: " REPO_URL
            git clone $REPO_URL $APP_DIR
            cd $APP_DIR
        else
            echo "  ℹ️  Usando diretório existente. Certifique-se de que os arquivos estão corretos."
            cd $APP_DIR
        fi
    fi
else
    echo "  📁 Criando diretório..."
    mkdir -p $APP_DIR
    cd $APP_DIR
    echo "  📥 Clonando repositório..."
    read -p "  Digite a URL do repositório Git: " REPO_URL
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
fi

# 9. Configurar arquivo .env ANTES de instalar dependências
echo -e "${YELLOW}⚙️  Configurando arquivo .env...${NC}"
if [ ! -f $APP_DIR/.env ]; then
    if [ -f $APP_DIR/.env.example ]; then
        cp $APP_DIR/.env.example $APP_DIR/.env
    else
        # Criar .env básico se não existir .env.example
        cat > $APP_DIR/.env << EOF
APP_NAME=Darwin
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://${DOMAIN}

DB_CONNECTION=mysql
DB_HOST=ucg084w44sw84kssgs00sg0g
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=mysql
DB_PASSWORD=9ifRaRf16HTxrxdwEtB1vTnU78QAQ2kZOfDUscmKObbBp4VXwL9VIYMn28FsJ4A7

SESSION_DRIVER=file
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
EOF
    fi
    echo -e "${YELLOW}⚠️  Arquivo .env criado. Verifique as configurações!${NC}"
fi

# Gerar APP_KEY se não existir
if ! grep -q "APP_KEY=base64:" $APP_DIR/.env 2>/dev/null; then
    echo -e "${YELLOW}🔑 Gerando APP_KEY...${NC}"
    cd $APP_DIR
    php artisan key:generate --force || echo "⚠️  Erro ao gerar APP_KEY"
fi

# 10. Instalar dependências do Composer (sem scripts para evitar erro de conexão)
echo -e "${YELLOW}📦 Instalando dependências do Composer...${NC}"
cd $APP_DIR
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Agora gerar autoloader e executar scripts (com .env configurado)
echo -e "${YELLOW}📦 Gerando autoloader e executando scripts...${NC}"
# Executar package:discover manualmente e ignorar erros do Telescope
php artisan package:discover --ansi || echo "⚠️  Aviso: Alguns pacotes não puderam ser descobertos (normal se Telescope não estiver instalado)"
composer dump-autoload --optimize --no-interaction --no-scripts || composer dump-autoload --optimize --no-interaction

# 11. Instalar dependências do NPM e compilar assets
echo -e "${YELLOW}📦 Instalando dependências do NPM e compilando assets...${NC}"
npm ci --production=false
npm run production

# 12. Configurar permissões
echo -e "${YELLOW}🔐 Configurando permissões...${NC}"
chown -R $APP_USER:$APP_USER $APP_DIR
chmod -R 755 $APP_DIR
chmod -R 775 $APP_DIR/storage
chmod -R 775 $APP_DIR/bootstrap/cache

# 13. Testar conexão com banco de dados
echo -e "${YELLOW}🔍 Testando conexão com banco de dados...${NC}"
php artisan db:show --quiet 2>/dev/null && echo "✅ Conexão com banco OK" || echo -e "${YELLOW}⚠️  Não foi possível conectar ao banco. Verifique as credenciais no .env${NC}"

# 13. Executar migrações
echo -e "${YELLOW}📦 Executando migrações...${NC}"
php artisan migrate --force --no-interaction || echo "⚠️  Erro ao executar migrações. Verifique a conexão com o banco de dados."

# 14. Criar link simbólico para storage
echo -e "${YELLOW}🔗 Criando link simbólico para storage...${NC}"
php artisan storage:link || true

# 15. Otimizar Laravel
echo -e "${YELLOW}⚡ Otimizando Laravel...${NC}"
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# 16. Configurar Nginx
echo -e "${YELLOW}🌐 Configurando Nginx...${NC}"
cp $APP_DIR/nginx.conf /etc/nginx/sites-available/$APP_NAME
ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/

# Remover configuração padrão se existir
rm -f /etc/nginx/sites-enabled/default

# Testar configuração do Nginx
nginx -t

# 17. Configurar SSL com Let's Encrypt
echo -e "${YELLOW}🔒 Configurando SSL...${NC}"
read -p "Deseja configurar SSL com Let's Encrypt? (s/n): " SETUP_SSL
if [ "$SETUP_SSL" = "s" ] || [ "$SETUP_SSL" = "S" ]; then
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN || echo "⚠️  Erro ao configurar SSL. Configure manualmente depois."
fi

# 18. Reiniciar serviços
echo -e "${YELLOW}🔄 Reiniciando serviços...${NC}"
systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx
systemctl enable php${PHP_VERSION}-fpm
systemctl enable nginx

# 19. Configurar firewall (se necessário)
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

