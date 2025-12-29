#!/bin/bash

# Script para fazer push do projeto para GitHub com otimizações para projetos grandes
# Execute: bash push-github.sh

echo "🚀 Iniciando push para GitHub com otimizações..."
echo ""

cd /Applications/XAMPP/xamppfiles/htdocs/kivicare-laravel/kivicare-laravel-web-v1.9.0

# Configurações otimizadas para projetos grandes
echo "⚙️  Configurando Git para projetos grandes..."
git config http.postBuffer 1048576000
git config http.maxRequestBuffer 100M
git config http.version HTTP/1.1
git config core.compression 0
git config pack.windowMemory "256m"
git config pack.packSizeLimit "2g"

# Verificar se há commits para enviar
COMMITS_AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")
if [ "$COMMITS_AHEAD" = "0" ]; then
    echo "⚠️  Nenhum commit novo para enviar."
    echo "Verificando se há arquivos não commitados..."
    if [ -n "$(git status --porcelain)" ]; then
        echo "📦 Há arquivos não commitados. Deseja fazer commit? (s/n)"
        read -r CONFIRM
        if [ "$CONFIRM" = "s" ] || [ "$CONFIRM" = "S" ]; then
            git add .
            git commit -m "Update: Adicionar arquivos do projeto Metacare"
        fi
    fi
fi

echo ""
echo "📤 Iniciando push para GitHub..."
echo "⏳ Isso pode levar vários minutos devido ao tamanho do projeto..."
echo ""

# Tentar push com progresso
if git push -u origin main --progress; then
    echo ""
    echo "✅ Push concluído com sucesso!"
    echo "🌐 Acesse: https://github.com/guilhermebertolaccini/darwin-laravel"
else
    echo ""
    echo "❌ Push falhou. Tentando estratégia alternativa..."
    echo ""
    echo "💡 Opções:"
    echo "1. Tente novamente em alguns minutos"
    echo "2. Use GitHub Desktop ou outra ferramenta GUI"
    echo "3. Faça push em partes menores usando branches"
    echo ""
    echo "Para fazer push em partes, você pode:"
    echo "  git push origin main:feature-branch"
    echo "  # Depois faça merge no GitHub"
fi



