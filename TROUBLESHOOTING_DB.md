# Troubleshooting - Conexão com Banco de Dados

## Erro: "Temporary failure in name resolution"

O hostname `ucg084w44sw84kssgs00sg0g` não está sendo resolvido pelo DNS.

### Possíveis causas:

1. **Banco de dados em rede privada do Coolify** - Não acessível externamente
2. **Hostname incorreto** - Pode ser um hostname interno do Coolify
3. **DNS não configurado** - A VPS não consegue resolver o hostname

### Soluções:

#### 1. Verificar o hostname correto no Coolify

No painel do Coolify, verifique:
- O hostname/IP real do banco de dados MySQL
- Se o banco aceita conexões externas
- Se há um IP público ou hostname diferente

#### 2. Testar resolução DNS

```bash
# Tentar resolver o hostname
nslookup ucg084w44sw84kssgs00sg0g
# ou
dig ucg084w44sw84kssgs00sg0g

# Tentar ping (pode não responder, mas mostra se resolve)
ping -c 3 ucg084w44sw84kssgs00sg0g
```

#### 3. Usar IP ao invés de hostname

Se você souber o IP do banco de dados, use no `.env`:

```env
DB_HOST=IP_DO_BANCO_AQUI
```

#### 4. Verificar se o banco aceita conexões externas

O MySQL do Coolify pode estar configurado apenas para aceitar conexões da rede interna do Coolify. Nesse caso:

**Opção A:** Instalar MySQL local na VPS
**Opção B:** Usar túnel SSH para conectar ao banco do Coolify
**Opção C:** Configurar o banco do Coolify para aceitar conexões externas

#### 5. Instalar MySQL local (solução rápida)

Se o banco do Coolify não for acessível, você pode instalar MySQL local:

```bash
apt update
apt install -y mysql-server

# Configurar MySQL
mysql_secure_installation

# Criar banco e usuário
mysql -u root -p
```

```sql
CREATE DATABASE default CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'mysql'@'localhost' IDENTIFIED BY '9ifRaRf16HTxrxdwEtB1vTnU78QAQ2kZOfDUscmKObbBp4VXwL9VIYMn28FsJ4A7';
GRANT ALL PRIVILEGES ON default.* TO 'mysql'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Depois atualizar o `.env`:

```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=mysql
DB_PASSWORD=9ifRaRf16HTxrxdwEtB1vTnU78QAQ2kZOfDUscmKObbBp4VXwL9VIYMn28FsJ4A7
```

#### 6. Verificar no Coolify

No painel do Coolify:
1. Vá até o serviço MySQL
2. Verifique o "Public URL" ou "Connection String"
3. Pode haver um hostname diferente ou IP público
4. Verifique se há opção para "Allow External Connections"

