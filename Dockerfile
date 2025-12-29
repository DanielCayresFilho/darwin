# Dockerfile para Laravel no Coolify
# Coolify já gerencia o Nginx, então só precisamos do PHP-FPM

FROM php:8.2-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    wget \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo \
        pdo_mysql \
        zip \
        intl \
        mbstring \
        exif \
        pcntl \
        bcmath \
        opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar apenas arquivos necessários primeiro (otimização de cache)
COPY composer.json composer.lock ./
COPY package.json package-lock.json ./

# Instalar dependências do Composer (sem dev, sem scripts)
# Desabilitar completamente os scripts do composer durante o build
RUN COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_DISABLE_XDEBUG_WARN=1 \
    composer install --no-dev --no-interaction --optimize-autoloader --no-scripts --no-autoloader

# Copiar resto dos arquivos
COPY . .

# Criar .env básico para evitar erros durante build (será sobrescrito pelo Coolify)
RUN if [ ! -f .env ]; then \
        echo "APP_NAME=Laravel" > .env && \
        echo "APP_ENV=production" >> .env && \
        echo "APP_KEY=" >> .env && \
        echo "APP_DEBUG=false" >> .env && \
        echo "APP_URL=http://localhost" >> .env && \
        echo "DB_CONNECTION=mysql" >> .env; \
    fi

# Completar instalação do Composer (gerar autoloader, mas SEM scripts)
# Desabilitar descoberta automática de pacotes durante o build
RUN COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_DISABLE_XDEBUG_WARN=1 \
    LARAVEL_SKIP_PACKAGE_DISCOVERY=1 \
    composer dump-autoload --optimize --no-scripts --no-interaction

# Instalar dependências do NPM e compilar assets
RUN npm ci --production=false && \
    npm run production && \
    npm cache clean --force

# Configurar permissões
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 775 /var/www/html/storage && \
    chmod -R 775 /var/www/html/bootstrap/cache

# Copiar configuração customizada do PHP-FPM
COPY php-fpm-custom.conf /usr/local/etc/php-fpm.d/zzz-custom.conf

# Configurar PHP-FPM para trabalhar com Nginx do Coolify
RUN sed -i 's/listen = .*/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/;clear_env = no/clear_env = no/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/listen.allowed_clients = 127.0.0.1/;listen.allowed_clients = 0.0.0.0/' /usr/local/etc/php-fpm.d/www.conf || true

# Copiar script de inicialização
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expor porta do PHP-FPM
EXPOSE 9000

# Comando de inicialização
CMD ["/usr/local/bin/start.sh"]

