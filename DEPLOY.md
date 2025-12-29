# 🚀 Guia de Deploy - Darwin (Laravel App)

⚠️ **ATENÇÃO**: Este repositório foi otimizado para deploy via **Coolify**.

Para deploy no Coolify, use o arquivo **QUICKSTART-COOLIFY.md** (muito mais fácil!)

Este guia (DEPLOY.md) é para deploy standalone/manual, que requer configuração adicional.

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado na sua VPS:

- **Docker** (versão 20.10 ou superior)
- **Docker Compose** (versão 2.0 ou superior)
- **Git**
- Porta 80 e 443 disponíveis (ou altere as portas no .env)

### Instalação rápida do Docker (Ubuntu/Debian)

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Docker Compose
sudo apt install docker-compose-plugin -y

# Adicionar seu usuário ao grupo docker (para não usar sudo)
sudo usermod -aG docker $USER

# Aplicar mudanças (ou faça logout/login)
newgrp docker

# Verificar instalação
docker --version
docker compose version
```

---

## 🎯 Método 1: Deploy Simples com Docker Compose (RECOMENDADO)

Este é o método mais fácil e rápido para rodar a aplicação em produção.

### Passo 1: Clonar o repositório

```bash
# Clone o projeto
git clone <URL_DO_SEU_REPOSITORIO> darwin
cd darwin
```

### Passo 2: Configurar variáveis de ambiente

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar arquivo .env
nano .env
```

Configure as seguintes variáveis **OBRIGATÓRIAS**:

```env
APP_NAME='Darwin'
APP_ENV=production
APP_KEY=                          # Vamos gerar isso depois
APP_DEBUG=false
APP_URL=http://seu-dominio.com    # ⚠️ IMPORTANTE: Altere para seu domínio

# Banco de Dados
DB_CONNECTION=mysql
DB_HOST=mysql                      # Nome do serviço no docker-compose
DB_PORT=3306
DB_DATABASE=darwin_prod
DB_USERNAME=darwin_user
DB_PASSWORD=SENHA_SUPER_SEGURA_AQUI    # ⚠️ Altere para senha forte!

# Portas (opcional)
APP_PORT=80
APP_PORT_SSL=443

# Cache e Sessão
CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=redis                   # Nome do serviço no docker-compose
REDIS_PORT=6379
```

### Passo 3: Gerar APP_KEY

```bash
# Método 1: Se você já tem PHP instalado localmente
php artisan key:generate

# Método 2: Gerar manualmente (copie o resultado e adicione ao .env)
echo "base64:$(openssl rand -base64 32)"
```

Adicione o resultado no arquivo `.env` na linha `APP_KEY=`

### Passo 4: Subir a aplicação

```bash
# Build e start dos containers
docker compose -f docker-compose.prod.yml up -d --build

# Acompanhar logs (Ctrl+C para sair)
docker compose -f docker-compose.prod.yml logs -f

# Verificar se todos os serviços estão rodando
docker compose -f docker-compose.prod.yml ps
```

### Passo 5: Executar migrações e configurações iniciais

```bash
# Acessar o container da aplicação
docker compose -f docker-compose.prod.yml exec app bash

# Dentro do container:
php artisan migrate --force
php artisan db:seed --force          # Se quiser dados de exemplo
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Sair do container
exit
```

### Passo 6: Testar a aplicação

Abra seu navegador e acesse: `http://seu-dominio.com` ou `http://IP_DA_VPS`

---

## 🔒 Método 2: Configurar SSL/HTTPS com Let's Encrypt

### Passo 1: Instalar Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

### Passo 2: Obter certificado SSL

```bash
# Parar o Nginx do Docker temporariamente
docker compose -f docker-compose.prod.yml stop nginx

# Obter certificado
sudo certbot certonly --standalone -d seu-dominio.com -d www.seu-dominio.com

# Reiniciar Nginx
docker compose -f docker-compose.prod.yml start nginx
```

### Passo 3: Configurar Nginx para usar SSL

Edite o arquivo `nginx.conf` e descomente as linhas de SSL (linhas 18-25), ajustando o caminho dos certificados.

Depois, descomente a linha no `docker-compose.prod.yml` para montar o volume do Let's Encrypt:

```yaml
# - /etc/letsencrypt:/etc/letsencrypt:ro  # ← Remova o # desta linha
```

Reinicie o Nginx:

```bash
docker compose -f docker-compose.prod.yml restart nginx
```

---

## 📝 Nota Importante

**Arquivos removidos para compatibilidade com Coolify:**
- `nginx.conf` / `nginx.conf.example` - Causavam conflito
- `Dockerfile` - Nixpacks detecta automaticamente
- `php-fpm-custom.conf` - Não necessário
- `start.sh` - Nixpacks gerencia inicialização

**Para deploy standalone:** Você precisará recriar esses arquivos ou usar outra estratégia.
**Para Coolify:** Use o QUICKSTART-COOLIFY.md (recomendado!)

---

## 🛠️ Comandos Úteis

### Gerenciar containers

```bash
# Parar todos os serviços
docker compose -f docker-compose.prod.yml down

# Parar e remover volumes (⚠️ isso apaga o banco de dados!)
docker compose -f docker-compose.prod.yml down -v

# Reiniciar um serviço específico
docker compose -f docker-compose.prod.yml restart app
docker compose -f docker-compose.prod.yml restart nginx

# Ver logs de um serviço específico
docker compose -f docker-compose.prod.yml logs -f app
docker compose -f docker-compose.prod.yml logs -f nginx
docker compose -f docker-compose.prod.yml logs -f mysql

# Acessar shell do container
docker compose -f docker-compose.prod.yml exec app bash
docker compose -f docker-compose.prod.yml exec mysql bash
```

### Atualizar aplicação

```bash
# Pull do código novo
git pull origin main

# Rebuild e restart
docker compose -f docker-compose.prod.yml up -d --build

# Executar migrações se houver
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force

# Limpar caches
docker compose -f docker-compose.prod.yml exec app php artisan config:cache
docker compose -f docker-compose.prod.yml exec app php artisan route:cache
docker compose -f docker-compose.prod.yml exec app php artisan view:cache
```

### Backup do banco de dados

```bash
# Criar backup
docker compose -f docker-compose.prod.yml exec mysql mysqldump -u root -p darwin_prod > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
docker compose -f docker-compose.prod.yml exec -T mysql mysql -u root -p darwin_prod < backup_20240101_120000.sql
```

---

## 🐛 Troubleshooting

### Problema: Containers não iniciam

```bash
# Ver logs detalhados
docker compose -f docker-compose.prod.yml logs

# Verificar se as portas estão ocupadas
sudo netstat -tulpn | grep -E ':(80|443|3306|6379)'

# Se estiverem, mude as portas no .env ou pare o serviço conflitante
```

### Problema: Erro de conexão com banco de dados

```bash
# Verificar se o MySQL está rodando
docker compose -f docker-compose.prod.yml ps mysql

# Ver logs do MySQL
docker compose -f docker-compose.prod.yml logs mysql

# Testar conexão manualmente
docker compose -f docker-compose.prod.yml exec mysql mysql -u root -p
```

### Problema: Página em branco / Erro 500

```bash
# Ver logs do Laravel
docker compose -f docker-compose.prod.yml logs app

# Verificar permissões
docker compose -f docker-compose.prod.yml exec app chown -R www-data:www-data storage bootstrap/cache
docker compose -f docker-compose.prod.yml exec app chmod -R 775 storage bootstrap/cache

# Limpar caches
docker compose -f docker-compose.prod.yml exec app php artisan cache:clear
docker compose -f docker-compose.prod.yml exec app php artisan config:clear
docker compose -f docker-compose.prod.yml exec app php artisan view:clear
```

### Problema: Assets (CSS/JS) não carregam

```bash
# Reconstruir assets dentro do container
docker compose -f docker-compose.prod.yml exec app npm run production

# Ou reconstruir a imagem completamente
docker compose -f docker-compose.prod.yml build --no-cache app
docker compose -f docker-compose.prod.yml up -d app
```

### Problema: PHP-FPM não responde

```bash
# Verificar se PHP-FPM está escutando
docker compose -f docker-compose.prod.yml exec app netstat -tlnp | grep 9000

# Reiniciar o serviço
docker compose -f docker-compose.prod.yml restart app

# Verificar configuração do Nginx
docker compose -f docker-compose.prod.yml exec nginx nginx -t
```

---

## 📊 Monitoramento

### Ver uso de recursos

```bash
# Ver uso de CPU/Memória dos containers
docker stats

# Ver espaço em disco
docker system df

# Limpar recursos não utilizados
docker system prune -a
```

---

## 🔐 Segurança

### Recomendações importantes:

1. **Altere todas as senhas padrão** no arquivo `.env`
2. **Configure firewall** (UFW no Ubuntu):
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp  # SSH
   sudo ufw enable
   ```
3. **Use HTTPS** em produção (configure Let's Encrypt)
4. **Faça backups regulares** do banco de dados
5. **Mantenha o sistema atualizado**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## 📞 Suporte

Se você encontrou algum problema que não está listado aqui, verifique:

1. Logs dos containers: `docker compose -f docker-compose.prod.yml logs`
2. Logs do Laravel: `storage/logs/laravel.log`
3. Logs do Nginx: Container `darwin_nginx` em `/var/log/nginx/`

---

## ✅ Checklist de Deploy

- [ ] Docker e Docker Compose instalados
- [ ] Repositório clonado
- [ ] Arquivo `.env` configurado corretamente
- [ ] `APP_KEY` gerado
- [ ] Senhas alteradas para valores seguros
- [ ] Containers iniciados: `docker compose -f docker-compose.prod.yml up -d`
- [ ] Migrações executadas: `php artisan migrate --force`
- [ ] Storage link criado: `php artisan storage:link`
- [ ] Caches otimizados para produção
- [ ] SSL configurado (opcional, mas recomendado)
- [ ] Firewall configurado
- [ ] Backup do banco de dados configurado

---

**Pronto! Sua aplicação deve estar rodando em produção! 🎉**
