#!/bin/bash

# Script para preparar o projeto para o GitHub
# Execute: bash preparar-github.sh

echo "🚀 Preparando projeto Metacare para GitHub..."
echo ""

# Verificar se está no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto Laravel"
    exit 1
fi

# Verificar configuração do Git
echo "📋 Verificando configuração do Git..."
if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
    echo "⚠️  Git não está configurado!"
    echo ""
    read -p "Digite seu nome: " GIT_NAME
    read -p "Digite seu email: " GIT_EMAIL
    
    git config user.name "$GIT_NAME"
    git config user.email "$GIT_EMAIL"
    echo "✅ Git configurado!"
else
    echo "✅ Git já está configurado:"
    echo "   Nome: $(git config user.name)"
    echo "   Email: $(git config user.email)"
fi

echo ""
echo "📦 Adicionando arquivos ao Git..."
git add .

echo ""
echo "📊 Status dos arquivos:"
git status --short | head -30

echo ""
read -p "Deseja fazer o commit inicial? (s/n): " CONFIRM

if [ "$CONFIRM" = "s" ] || [ "$CONFIRM" = "S" ]; then
    git commit -m "Initial commit: Projeto Metacare - Migração de Kivicare para Metacare
    
- Substituição completa de branding Kivicare → Metacare
- Atualização de logos e assets
- Atualização de emails, URLs e textos
- Configuração para terapia psicológica e metaverso"
    
    echo ""
    echo "✅ Commit realizado com sucesso!"
    echo ""
    echo "📝 Próximos passos:"
    echo "1. Crie um repositório no GitHub (https://github.com/new)"
    echo "2. Execute os seguintes comandos:"
    echo ""
    echo "   git remote add origin https://github.com/SEU_USUARIO/metacare-laravel.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    echo "📖 Para mais detalhes, consulte o arquivo GUIA_GITHUB.md"
else
    echo "⏭️  Commit cancelado. Execute manualmente quando estiver pronto."
fi

