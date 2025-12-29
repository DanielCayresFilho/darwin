#!/bin/bash
set -e

echo "🚀 Iniciando aplicação Laravel no Coolify..."

# Aguardar conexão com o banco de dados (se necessário)
echo "⏳ Verificando conexão com o banco de dados..."
max_attempts=30
attempt=0
until php artisan db:show --quiet 2>/dev/null || [ $attempt -ge $max_attempts ]; do
    attempt=$((attempt + 1))
    echo "⏳ Aguardando banco de dados... (tentativa $attempt/$max_attempts)"
    sleep 2
done

if [ $attempt -ge $max_attempts ]; then
    echo "⚠️  Não foi possível conectar ao banco de dados após $max_attempts tentativas"
    echo "⚠️  Continuando mesmo assim..."
else
    echo "✅ Banco de dados conectado!"
fi

# Limpar caches
echo "🧹 Limpando caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Executar migrações (apenas se não estiver em modo de manutenção)
if [ "$APP_ENV" != "local" ]; then
    echo "📦 Executando migrações..."
    php artisan migrate --force --no-interaction || echo "⚠️  Aviso: Erro ao executar migrações"
fi

# Otimizar aplicação para produção
if [ "$APP_ENV" = "production" ]; then
    echo "⚡ Otimizando aplicação para produção..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan event:cache
fi

# Garantir permissões corretas
echo "🔐 Configurando permissões..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Criar link simbólico para storage se não existir
if [ ! -L /var/www/html/public/storage ]; then
    echo "🔗 Criando link simbólico para storage..."
    php artisan storage:link || echo "⚠️  Link de storage já existe ou não foi possível criar"
fi

echo "✅ Inicialização concluída!"

# Verificar e corrigir configuração do PHP-FPM
echo "🔍 Verificando configuração do PHP-FPM..."
echo "📋 Configurações ativas antes da correção:"
grep -E "^(listen|listen.allowed_clients|clear_env)" /usr/local/etc/php-fpm.d/*.conf 2>/dev/null || echo "⚠️  Não foi possível ler configurações"

# Garantir que TODAS as configurações de listen apontem para 0.0.0.0:9000
echo "🔧 Corrigindo todas as configurações de listen..."
sed -i 's/listen = .*/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/*.conf 2>/dev/null || true
sed -i 's/listen = 9000/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/*.conf 2>/dev/null || true
sed -i 's/listen = \/run\/php\/php.*\.sock/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/*.conf 2>/dev/null || true

# Comentar listen.allowed_clients em todos os arquivos para permitir qualquer IP
sed -i 's/^listen.allowed_clients =.*/;listen.allowed_clients = /' /usr/local/etc/php-fpm.d/*.conf 2>/dev/null || true

echo "📋 Configurações ativas após correção:"
grep -E "^(listen|listen.allowed_clients|clear_env)" /usr/local/etc/php-fpm.d/*.conf 2>/dev/null || echo "⚠️  Não foi possível ler configurações"

# Verificar se está escutando na porta correta
echo "🔍 Verificando se PHP-FPM está configurado corretamente..."
if netstat -tlnp 2>/dev/null | grep -q ":9000" || ss -tlnp 2>/dev/null | grep -q ":9000"; then
    echo "✅ Porta 9000 já está em uso (pode ser de uma execução anterior)"
fi

echo "🌐 Iniciando PHP-FPM na porta 9000..."

# Iniciar PHP-FPM em foreground
exec php-fpm -F

