# 🚀 Guia para Enviar o Projeto para o GitHub

## 📋 Pré-requisitos

1. Conta no GitHub (se não tiver, crie em: https://github.com)
2. Git instalado (já está instalado ✅)
3. Repositório Git inicializado (já foi feito ✅)

## 🔧 Passo 1: Configurar Git (se ainda não configurou)

Execute os seguintes comandos no terminal, substituindo com seus dados:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"
```

**OU** configure apenas para este repositório:

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/kivicare-laravel/kivicare-laravel-web-v1.9.0
git config user.name "Seu Nome"
git config user.email "seu.email@exemplo.com"
```

## 📝 Passo 2: Adicionar Arquivos e Fazer Commit

Execute os seguintes comandos:

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/kivicare-laravel/kivicare-laravel-web-v1.9.0

# Adicionar todos os arquivos (exceto os ignorados pelo .gitignore)
git add .

# Verificar o que será commitado
git status

# Fazer o commit inicial
git commit -m "Initial commit: Projeto Metacare - Migração de Kivicare para Metacare"
```

## 🌐 Passo 3: Criar Repositório no GitHub

1. Acesse https://github.com e faça login
2. Clique no botão **"+"** no canto superior direito
3. Selecione **"New repository"**
4. Preencha:
   - **Repository name**: `metacare-laravel` (ou o nome que preferir)
   - **Description**: "Sistema de gestão de terapia psicológica - Metacare"
   - **Visibility**: Escolha **Private** (recomendado) ou **Public**
   - **NÃO marque** "Initialize this repository with a README" (já temos arquivos)
5. Clique em **"Create repository"**

## 🔗 Passo 4: Conectar ao Repositório Remoto

Após criar o repositório no GitHub, você verá uma página com instruções. Execute os comandos mostrados, que serão algo como:

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/kivicare-laravel/kivicare-laravel-web-v1.9.0

# Adicionar o repositório remoto (substitua SEU_USUARIO pelo seu usuário do GitHub)
git remote add origin https://github.com/SEU_USUARIO/metacare-laravel.git

# OU se preferir usar SSH (se tiver chave SSH configurada):
# git remote add origin git@github.com:SEU_USUARIO/metacare-laravel.git

# Verificar se foi adicionado corretamente
git remote -v
```

## 📤 Passo 5: Enviar para o GitHub

```bash
# Renomear branch para 'main' (padrão atual do GitHub)
git branch -M main

# Enviar para o GitHub
git push -u origin main
```

Se for a primeira vez, o GitHub pode pedir autenticação:
- **Username**: Seu usuário do GitHub
- **Password**: Use um **Personal Access Token** (não sua senha normal)

### Como criar Personal Access Token:

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token (classic)
3. Dê um nome (ex: "Metacare Project")
4. Selecione escopos: `repo` (acesso completo a repositórios)
5. Generate token
6. **COPIE O TOKEN** (você não verá novamente!)
7. Use este token como senha ao fazer push

## ✅ Verificação

Após o push, acesse seu repositório no GitHub e verifique se todos os arquivos foram enviados corretamente.

## 🔄 Comandos Úteis para o Futuro

```bash
# Ver status das alterações
git status

# Adicionar arquivos modificados
git add .

# Fazer commit
git commit -m "Descrição das alterações"

# Enviar para o GitHub
git push

# Ver histórico de commits
git log --oneline

# Ver branches
git branch
```

## ⚠️ Importante

- **NUNCA** faça commit do arquivo `.env` (já está no .gitignore)
- **NUNCA** faça commit de senhas ou chaves de API
- Sempre verifique com `git status` antes de fazer commit
- Use mensagens de commit descritivas

## 🆘 Problemas Comuns

### Erro: "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/SEU_USUARIO/metacare-laravel.git
```

### Erro: "failed to push some refs"
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### Esqueceu de configurar nome/email
```bash
git config user.name "Seu Nome"
git config user.email "seu.email@exemplo.com"
git commit --amend --reset-author
```

---

**Boa sorte! 🚀**

