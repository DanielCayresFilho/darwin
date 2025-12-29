# ⚡ DEPLOY RÁPIDO NO COOLIFY - 5 MINUTOS

## ✅ IMPORTANTE: Auto-Detecção do Laravel

Este repositório **NÃO tem** arquivo `nixpacks.toml`.
O Coolify vai **detectar automaticamente** que é Laravel e configurar tudo!

Você não precisa fazer nada além de seguir os passos abaixo. 🚀

---

## 🎯 Método MAIS FÁCIL (Recomendado)

### 1️⃣ No Coolify, crie o App (2 min)

1. **+ New Resource** → **Application**
2. Conecte seu repositório Git
3. Selecione o branch: `claude/fix-production-deployment-7YURT`
4. Clique em **Continue**

### 2️⃣ Configure o Build (1 min)

Na tela de configuração:

- **Build Pack**: `nixpacks` (deve detectar automaticamente)
- **Port**: `8000`
- **Base Directory**: `/` (deixe vazio ou root)
- Clique em **Save**

### 3️⃣ Adicione Variáveis de Ambiente (1 min)

Vá em **Environment** e cole isso (⚠️ ALTERE OS VALORES):

```bash
APP_NAME=Darwin
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
APP_URL=https://SEU-DOMINIO.coolify.io

DB_CONNECTION=mysql
DB_HOST=SEU-MYSQL-HOST.coolify
DB_PORT=3306
DB_DATABASE=darwin_prod
DB_USERNAME=darwin_user
DB_PASSWORD=SENHA-DO-BANCO

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
```

**Para gerar APP_KEY**, copie e cole no terminal:
```bash
echo "base64:$(openssl rand -base64 32)"
```

### 4️⃣ Crie o Banco de Dados no Coolify (1 min)

**Opção Fácil:**

1. **+ New Resource** → **Database** → **MySQL 8.0**
2. Anote o **host** (algo como `mysql-abc123.coolify`)
3. Anote a **senha** que o Coolify gerou
4. Use esses valores no `DB_HOST` e `DB_PASSWORD` do app

**Depois**, conecte no MySQL e crie o banco:

```bash
# Via Coolify UI, em "Execute Command" no MySQL:
CREATE DATABASE darwin_prod;
CREATE USER 'darwin_user'@'%' IDENTIFIED BY 'SENHA-DO-BANCO';
GRANT ALL PRIVILEGES ON darwin_prod.* TO 'darwin_user'@'%';
FLUSH PRIVILEGES;
```

### 5️⃣ Deploy! (30 seg)

1. Clique em **Deploy** no Coolify
2. Aguarde o build (3-5 minutos na primeira vez)
3. Acompanhe os logs

### 6️⃣ Rode as Migrações (30 seg)

Após o deploy completar:

**Via Coolify UI:**
- Vá em **Execute Command**
- Execute:
  ```bash
  php artisan migrate --force && php artisan storage:link
  ```

**Pronto! Acesse seu domínio! 🎉**

---

## 🔥 MÉTODO SUPER RÁPIDO (Se tiver banco externo)

Se você já tem um MySQL rodando em algum lugar:

1. Crie o app no Coolify (passos 1 e 2 acima)
2. Cole as variáveis de ambiente apontando para seu banco existente
3. Deploy
4. Rode migrações
5. **DONE!** ✅

---

## 🐛 Problemas Comuns

### Build falhou?

**Erro de memória:**
- No Coolify, aumente a memória do container para pelo menos 2GB

**Erro de npm:**
```bash
# No Execute Command, rode:
npm install && npm run production
```

### 502 Bad Gateway?

1. Verifique se a porta está configurada como `8000`
2. Verifique os logs do deployment
3. Teste se o PHP está respondendo:
   ```bash
   curl http://localhost:8000
   ```

### Página em branco?

1. **APP_KEY não foi gerado** - Gere e adicione no Environment
2. **Banco não conecta** - Verifique credenciais
3. **Permissões** - Execute:
   ```bash
   chmod -R 775 storage bootstrap/cache
   ```

---

## 📋 Checklist Rápido

- [ ] App criado no Coolify (Nixpacks, porta 8000)
- [ ] Variáveis de ambiente configuradas (APP_KEY, DB_*, etc)
- [ ] MySQL criado no Coolify (ou use externo)
- [ ] Deploy rodando
- [ ] Migrações executadas
- [ ] Domínio configurado
- [ ] FUNCIONANDO! 🚀

---

## 💡 Dicas Importantes

⚡ **Use Nixpacks** - É automático e funciona de primeira
🔑 **Não esqueça o APP_KEY** - Gere com o comando acima
🗄️ **Banco de dados** - Use o MySQL do Coolify, é mais fácil
🌐 **Domínio** - Coolify gera SSL automático, só adicionar

---

**TEMPO TOTAL: ~5-7 minutos** ⏱️

**Se não funcionar na primeira, respire, veja os logs e tente de novo! Você consegue! 💪**
