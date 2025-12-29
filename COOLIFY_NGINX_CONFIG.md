# Configuração do Nginx no Coolify

## Problema: Bad Gateway (502)

Se o PHP-FPM está rodando mas ainda dá Bad Gateway, o problema está na configuração do Nginx no Coolify.

## Verificações no Coolify:

### 1. Tipo de Aplicação
- Certifique-se de que o tipo está configurado como **PHP** ou **Laravel**
- NÃO use "Static Site" ou "Node.js"

### 2. Porta do Serviço
- A porta interna do serviço deve ser: **9000**
- O PHP-FPM está configurado para escutar em `0.0.0.0:9000`

### 3. Configuração do Nginx (se tiver acesso)

O Coolify deve estar configurado para fazer `fastcgi_pass` assim:

```nginx
location ~ \.php$ {
    include fastcgi_params;
    fastcgi_pass <nome-do-servico>:9000;
    # ou
    # fastcgi_pass 127.0.0.1:9000;  # Se estiver no mesmo container
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
}
```

### 4. Nome do Serviço

No Coolify, verifique:
- O nome do serviço/container onde o PHP-FPM está rodando
- O Nginx deve usar esse nome para conectar (ex: `app:9000` ou `laravel:9000`)

### 5. Variáveis de Ambiente

Certifique-se de que estas variáveis estão configuradas:
- `APP_ENV=production`
- `APP_KEY=...` (gerado)
- `APP_URL=https://darwin.taticamarketing.com.br`
- Todas as variáveis de banco de dados

### 6. Teste de Conexão

Se tiver acesso ao container do Nginx no Coolify, teste:

```bash
# Testar se consegue conectar ao PHP-FPM
telnet <nome-do-servico-php-fpm> 9000
# ou
nc -zv <nome-do-servico-php-fpm> 9000
```

### 7. Logs do Nginx

Verifique os logs do Nginx no Coolify para ver erros específicos:
- Procure por erros de `fastcgi_pass`
- Verifique se há timeouts
- Veja se há erros de conexão

## Solução Alternativa: Socket Unix

Se o TCP não funcionar, o Coolify pode precisar de socket Unix. Nesse caso, precisaríamos ajustar o Dockerfile para usar socket ao invés de TCP.

## Verificação Final

Após fazer o deploy, verifique nos logs:
1. ✅ PHP-FPM está rodando: `ready to handle connections`
2. ✅ Está escutando em `0.0.0.0:9000`
3. ✅ Nenhum erro de configuração

Se tudo isso estiver OK mas ainda der Bad Gateway, o problema está na configuração do Nginx no Coolify.

