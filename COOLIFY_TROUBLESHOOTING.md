# Troubleshooting - Coolify + Laravel

## Problema: Bad Gateway (502)

### O que foi configurado:

1. **PHP-FPM escutando em TCP**: Configurado para escutar em `0.0.0.0:9000` (todas as interfaces)
2. **Permissões de conexão**: Configurado para aceitar conexões de qualquer IP
3. **Configuração customizada**: Arquivo `php-fpm-custom.conf` com configurações otimizadas

### Como verificar no Coolify:

1. **Verificar logs do container**:
   ```bash
   # No Coolify, vá em Logs do container
   # Procure por: "PHP-FPM configurado para escutar em 0.0.0.0:9000"
   ```

2. **Verificar se o PHP-FPM está rodando**:
   ```bash
   # Dentro do container
   ps aux | grep php-fpm
   netstat -tlnp | grep 9000
   ```

3. **Verificar configuração do Nginx no Coolify**:
   - O Coolify deve estar configurado para fazer `fastcgi_pass` para `app:9000` ou o nome do serviço
   - Verifique nas configurações do serviço no Coolify se a porta está correta

### Configurações importantes no Coolify:

1. **Porta do serviço**: `9000`
2. **Tipo de aplicação**: PHP (não precisa de Nginx separado, o Coolify gerencia)
3. **Domínio**: `darwin.taticamarketing.com.br`

### Se ainda não funcionar:

1. Verifique se o Coolify está usando o nome correto do serviço para conectar ao PHP-FPM
2. Verifique os logs do Nginx no Coolify
3. Teste a conexão manualmente:
   ```bash
   # Dentro do container do PHP-FPM
   php -v
   php-fpm -t  # Testa configuração
   ```

### Nota sobre Laravel:

O Laravel serve **tudo junto**:
- ✅ Frontend (Blade templates + Vue.js)
- ✅ Backend (API/Controllers)
- ✅ Assets estáticos (CSS/JS compilados)

Não são aplicações separadas. Tudo roda através do PHP-FPM.

