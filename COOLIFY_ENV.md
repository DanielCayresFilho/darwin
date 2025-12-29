# Variáveis de Ambiente para Coolify

Configure as seguintes variáveis de ambiente no Coolify:

## Variáveis Obrigatórias

```bash
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

# Sessão e Cache (Redis opcional, mas recomendado)
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

## Como Gerar APP_KEY

Execute no terminal local:
```bash
php artisan key:generate --show
```

Ou no Coolify, após o primeiro deploy, execute:
```bash
php artisan key:generate
```

## Configuração do Coolify

1. **Porta**: O PHP-FPM está configurado para rodar na porta `9000`
2. **Nginx**: O Coolify já gerencia o Nginx automaticamente
3. **Domínio**: Configure o domínio `darwin.taticamarketing.com.br` no Coolify
4. **Build**: O Dockerfile já compila os assets automaticamente durante o build

## Notas Importantes

- O script `start.sh` executa migrações automaticamente no primeiro deploy
- Os assets são compilados durante o build da imagem Docker
- As permissões de storage são configuradas automaticamente
- O cache é otimizado para produção automaticamente

