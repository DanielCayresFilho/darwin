# 🚀 Deploy no Coolify - Darwin (Laravel App)

Este guia explica como fazer deploy da aplicação Laravel no Coolify.

---

## 🎯 Método Recomendado: Nixpacks (Mais Fácil)

O Coolify tem suporte nativo para Laravel via **Nixpacks**. Este é o método **MAIS FÁCIL** e **RECOMENDADO**.

### Passo 1: Criar o Projeto no Coolify

1. Acesse seu painel do Coolify
2. Clique em **"+ New Resource"**
3. Escolha **"Application"**
4. Conecte seu repositório Git
5. Selecione o branch (ex: `main` ou `claude/fix-production-deployment-7YURT`)

### Passo 2: Configurar o Build Pack

Na configuração do projeto:

1. **Build Pack**: Selecione `nixpacks` (ou deixe em auto-detect)
2. **Port**: `80` (Nixpacks configura automaticamente o Nginx + PHP-FPM)
3. **Install Command**: Deixe vazio (Nixpacks detecta automaticamente)
4. **Build Command**: `npm run production` (para compilar assets)
5. **Start Command**: Deixe vazio (Nixpacks usa o padrão do Laravel)

### Passo 3: Configurar Variáveis de Ambiente

No Coolify, vá em **Environment Variables** e adicione:

```bash
# Essenciais
APP_NAME=Darwin
APP_ENV=production
APP_DEBUG=false
APP_KEY=                           # Gere com: php artisan key:generate
APP_URL=https://seu-dominio.com    # Seu domínio no Coolify

# Banco de Dados (use o banco que você criou no Coolify)
DB_CONNECTION=mysql
DB_HOST=                           # IP do serviço MySQL no Coolify
DB_PORT=3306
DB_DATABASE=darwin_prod
DB_USERNAME=darwin_user
DB_PASSWORD=                       # Senha do banco

# Cache e Sessão
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Assets
MIX_ASSET_URL=${APP_URL}
MIX_APP_URL=${APP_URL}
```

### Passo 4: Configurar Banco de Dados

**Opção A: Usar MySQL do Coolify (Recomendado)**

1. No Coolify, crie um **novo serviço MySQL**:
   - Vá em **"+ New Resource"** → **"Database"** → **"MySQL"**
   - Anote o **host interno** (algo como `mysql-xyz.coolify`)
   - Use esse host no `DB_HOST` do seu app

2. Crie o banco e usuário:
   ```bash
   # Conecte no MySQL do Coolify e execute:
   CREATE DATABASE darwin_prod;
   CREATE USER 'darwin_user'@'%' IDENTIFIED BY 'SENHA_FORTE_AQUI';
   GRANT ALL PRIVILEGES ON darwin_prod.* TO 'darwin_user'@'%';
   FLUSH PRIVILEGES;
   ```

**Opção B: Usar banco externo**
- Configure `DB_HOST` com o IP/domínio do seu banco externo

### Passo 5: Deploy Inicial

1. Clique em **"Deploy"** no Coolify
2. Aguarde o build completar (pode demorar 5-10 minutos na primeira vez)
3. Verifique os logs em **"Deployment Logs"**

### Passo 6: Executar Migrações

Após o deploy, você precisa rodar as migrações:

**Via Coolify UI:**
1. Vá em **"Execute Command"** no seu app
2. Execute: `php artisan migrate --force`
3. Execute: `php artisan storage:link`

**Via SSH:**
```bash
# Conecte no servidor do Coolify
ssh seu-servidor

# Entre no container
docker exec -it <container-name> bash

# Execute os comandos
php artisan migrate --force
php artisan storage:link
php artisan config:cache
```

### Passo 7: Configurar Domínio

1. No Coolify, vá em **"Domains"**
2. Adicione seu domínio
3. Ative **"Generate SSL"** para HTTPS automático
4. Aguarde o SSL ser gerado (1-2 minutos)

---

## 🔧 Método Alternativo: Dockerfile (Mais Controle)

Se você preferir usar o Dockerfile ao invés do Nixpacks:

### Passo 1: Configurar Build Pack

No Coolify:
- **Build Pack**: Selecione `dockerfile`
- **Dockerfile**: `Dockerfile`
- **Port**: `9000` (porta do PHP-FPM)

### Passo 2: Configurar Proxy Reverso

**IMPORTANTE**: O Coolify precisa saber como se comunicar com o PHP-FPM.

Adicione estas configurações no Coolify:

1. Vá em **"Advanced"** → **"Custom Nginx Configuration"**
2. Adicione:

```nginx
location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;

    fastcgi_read_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_connect_timeout 300;
}

location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

### Passo 3: Deploy

Siga os mesmos passos do método Nixpacks (variáveis de ambiente, banco, etc.)

---

## 🐛 Troubleshooting Coolify

### Erro: "502 Bad Gateway"

**Causa**: Coolify não está conseguindo se conectar ao PHP-FPM.

**Solução**:
1. Verifique se o container está rodando:
   ```bash
   docker ps | grep darwin
   ```

2. Verifique se PHP-FPM está escutando na porta 9000:
   ```bash
   docker exec -it <container> netstat -tlnp | grep 9000
   ```

3. Verifique a configuração do Nginx no Coolify (Custom Nginx Config)

### Erro: "Connection refused" ou "SQLSTATE"

**Causa**: Não consegue conectar ao banco de dados.

**Solução**:
1. Verifique se o MySQL está rodando no Coolify
2. Verifique as credenciais no `.env`:
   - `DB_HOST` (deve ser o host interno do Coolify)
   - `DB_USERNAME`
   - `DB_PASSWORD`
   - `DB_DATABASE`

3. Teste a conexão:
   ```bash
   docker exec -it <container> php artisan db:show
   ```

### Erro: "The page is not working" (500)

**Causa**: Erro interno do Laravel.

**Solução**:
1. Veja os logs:
   ```bash
   # No Coolify UI, vá em "Logs" → "Application Logs"

   # Ou via Docker:
   docker logs <container-name>

   # Ou veja o log do Laravel:
   docker exec -it <container> cat storage/logs/laravel.log
   ```

2. Verifique se `APP_KEY` está configurado
3. Verifique permissões:
   ```bash
   docker exec -it <container> chmod -R 775 storage bootstrap/cache
   ```

### Assets (CSS/JS) não carregam

**Causa**: Assets não foram compilados ou URL está errada.

**Solução**:
1. Certifique-se que `APP_URL` está correto no `.env`
2. Recompile os assets:
   ```bash
   docker exec -it <container> npm run production
   ```
3. Limpe o cache:
   ```bash
   docker exec -it <container> php artisan cache:clear
   docker exec -it <container> php artisan config:clear
   ```

---

## ⚡ Comandos Úteis para Coolify

### Ver logs em tempo real
```bash
# No servidor do Coolify
docker logs -f <container-name>
```

### Acessar shell do container
```bash
docker exec -it <container-name> bash
```

### Executar comandos Artisan
```bash
# Via Docker
docker exec -it <container-name> php artisan <comando>

# Exemplos:
docker exec -it <container-name> php artisan migrate --force
docker exec -it <container-name> php artisan cache:clear
docker exec -it <container-name> php artisan queue:work
```

### Reiniciar aplicação
No Coolify UI: Clique em **"Restart"**

### Ver uso de recursos
```bash
docker stats <container-name>
```

---

## 🎯 Configuração Recomendada para Produção

### Variáveis de Ambiente Completas

```bash
# App
APP_NAME=Darwin
APP_ENV=production
APP_KEY=base64:...                 # Gere com artisan
APP_DEBUG=false
APP_URL=https://seu-dominio.com

# Banco
DB_CONNECTION=mysql
DB_HOST=mysql-xyz.coolify          # Host interno do Coolify
DB_PORT=3306
DB_DATABASE=darwin_prod
DB_USERNAME=darwin_user
DB_PASSWORD=senha-segura-aqui

# Cache (use Redis se disponível)
CACHE_DRIVER=redis                 # ou 'file' se não tiver Redis
SESSION_DRIVER=redis               # ou 'file' se não tiver Redis
QUEUE_CONNECTION=redis             # ou 'database' se não tiver Redis

# Redis (se usar)
REDIS_HOST=redis-xyz.coolify       # Host interno do Redis no Coolify
REDIS_PORT=6379

# Assets
MIX_ASSET_URL=${APP_URL}
MIX_APP_URL=${APP_URL}

# Mail (configure seu SMTP)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=senha-app
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@seu-dominio.com
MAIL_FROM_NAME="${APP_NAME}"
```

### Otimizações para Produção

Após deploy, execute:

```bash
docker exec -it <container> bash -c "
php artisan config:cache &&
php artisan route:cache &&
php artisan view:cache &&
php artisan event:cache
"
```

---

## 📊 Checklist de Deploy no Coolify

- [ ] Projeto criado no Coolify
- [ ] Repositório Git conectado
- [ ] Build Pack configurado (Nixpacks recomendado)
- [ ] Variáveis de ambiente configuradas
- [ ] `APP_KEY` gerado
- [ ] Banco de dados MySQL criado no Coolify
- [ ] Credenciais do banco configuradas
- [ ] Deploy realizado com sucesso
- [ ] Migrações executadas
- [ ] Storage link criado
- [ ] Domínio configurado
- [ ] SSL gerado e funcionando
- [ ] Aplicação acessível via HTTPS
- [ ] Logs verificados (sem erros)
- [ ] Caches otimizados

---

## 🆘 Ainda com problemas?

1. **Verifique os logs** no Coolify UI
2. **Teste comandos** via `docker exec`
3. **Verifique a conectividade** entre app e banco
4. **Use o método Nixpacks** se o Dockerfile não funcionar

**Dica**: O Nixpacks é mais fácil e geralmente "just works" com Laravel!

---

✅ **Pronto! Sua aplicação estará rodando no Coolify com HTTPS automático!** 🎉
