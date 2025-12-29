# Guia de Deploy na VPS

## Pré-requisitos

- VPS com Ubuntu/Debian
- Acesso root ou sudo
- Domínio apontando para o IP da VPS

## Passo a Passo

### 1. Preparar o Servidor

```bash
# Conectar na VPS
ssh root@seu-ip

# Executar o script de deploy
chmod +x deploy-vps.sh
sudo ./deploy-vps.sh
```

### 2. Configurar Variáveis de Ambiente

Edite o arquivo `.env`:

```bash
nano /var/www/html/.env
```

Configure as seguintes variáveis:

```env
APP_NAME=Darwin
APP_ENV=production
APP_KEY=base64:SUA_CHAVE_AQUI
APP_DEBUG=false
APP_URL=https://darwin.taticamarketing.com.br

# Banco de Dados MySQL
DB_CONNECTION=mysql
DB_HOST=ucg084w44sw84kssgs00sg0g
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=mysql
DB_PASSWORD=9ifRaRf16HTxrxdwEtB1vTnU78QAQ2kZOfDUscmKObbBp4VXwL9VIYMn28FsJ4A7

# Sessão e Cache
SESSION_DRIVER=file
CACHE_DRIVER=file
QUEUE_CONNECTION=sync

# Mail (configure conforme seu provedor)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=noreply@darwin.taticamarketing.com.br
MAIL_FROM_NAME="${APP_NAME}"
```

### 3. Gerar APP_KEY

```bash
cd /var/www/html
php artisan key:generate
```

### 4. Executar Migrações

```bash
php artisan migrate --force
```

### 5. Configurar SSL (Let's Encrypt)

Se não configurou durante o script:

```bash
certbot --nginx -d darwin.taticamarketing.com.br
```

### 6. Verificar Status dos Serviços

```bash
# Verificar Nginx
systemctl status nginx

# Verificar PHP-FPM
systemctl status php8.2-fpm

# Verificar se está escutando nas portas corretas
netstat -tlnp | grep -E ':(80|443|9000)'
```

## Comandos Úteis

### Reiniciar Serviços

```bash
systemctl restart nginx
systemctl restart php8.2-fpm
```

### Ver Logs

```bash
# Logs do Nginx
tail -f /var/log/nginx/darwin-error.log

# Logs do PHP-FPM
tail -f /var/log/php8.2-fpm.log

# Logs do Laravel
tail -f /var/www/html/storage/logs/laravel.log
```

### Atualizar Aplicação

```bash
cd /var/www/html
git pull
composer install --no-dev --optimize-autoloader
npm ci --production=false
npm run production
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
systemctl restart php8.2-fpm
```

### Limpar Cache

```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Troubleshooting

### 502 Bad Gateway

1. Verificar se PHP-FPM está rodando:
   ```bash
   systemctl status php8.2-fpm
   ```

2. Verificar socket do PHP-FPM:
   ```bash
   ls -la /var/run/php/php8.2-fpm.sock
   ```

3. Verificar configuração do Nginx:
   ```bash
   nginx -t
   ```

### Permissões

```bash
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache
```

### Testar PHP-FPM

```bash
# Testar se PHP está funcionando
php -v

# Testar se PHP-FPM está respondendo
curl http://localhost:9000
```

## Segurança

1. **Firewall**: Configure o UFW para permitir apenas portas necessárias
2. **SSL**: Sempre use HTTPS em produção
3. **Permissões**: Mantenha permissões corretas nos arquivos
4. **Backup**: Configure backups regulares do banco de dados

## Backup do Banco de Dados

```bash
# Criar backup
mysqldump -u mysql -p default > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
mysql -u mysql -p default < backup.sql
```

