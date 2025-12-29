#!/bin/bash

# Script para verificar o status do push para GitHub

echo "═══════════════════════════════════════════════════════════"
echo "           📤 STATUS DO PUSH PARA GITHUB"
echo "═══════════════════════════════════════════════════════════"
echo ""

cd /Applications/XAMPP/xamppfiles/htdocs/kivicare-laravel/kivicare-laravel-web-v1.9.0

# Informações do repositório local
echo "📊 REPOSITÓRIO LOCAL:"
echo "   Branch: $(git branch --show-current)"
echo "   Commits locais: $(git log --oneline | wc -l | tr -d ' ')"
echo "   Objetos: $(git count-objects | awk '{print $1}')"
echo "   Tamanho: $(git count-objects -vH | grep '^size:' | awk '{print $2, $3}')"
echo ""

# Verificar processos de push
PUSH_PROCESSES=$(ps aux | grep "git push" | grep -v grep | wc -l | tr -d ' ')
if [ "$PUSH_PROCESSES" -gt 0 ]; then
    echo "🔄 PUSH EM ANDAMENTO:"
    echo "   ⏳ Processos ativos: $PUSH_PROCESSES"
    echo "   Status: Compressão e envio em progresso..."
    echo ""
    echo "   Processos:"
    ps aux | grep "git push" | grep -v grep | awk '{print "   - PID:", $2, "| Iniciado:", $9}'
else
    echo "✅ PUSH:"
    echo "   Nenhum processo ativo"
    echo ""
fi

# Verificar repositório remoto
echo "🌐 REPOSITÓRIO REMOTO:"
echo "   URL: $(git remote get-url origin)"
echo ""

# Tentar verificar se o push foi concluído
echo "🔍 VERIFICANDO STATUS REMOTO..."
git fetch origin 2>&1 | head -3

# Verificar se há commits não enviados
UNPUSHED=$(git log origin/main..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
if [ "$UNPUSHED" = "0" ] 2>/dev/null; then
    echo ""
    echo "✅ SUCESSO: Todos os commits foram enviados!"
    echo "   Acesse: https://github.com/guilhermebertolaccini/darwin-laravel"
elif [ "$UNPUSHED" -gt 0 ] 2>/dev/null; then
    echo ""
    echo "⏳ AGUARDANDO: $UNPUSHED commit(s) ainda não enviado(s)"
    echo "   O push pode estar em andamento ou ter falhado"
else
    echo ""
    echo "⚠️  Não foi possível verificar o status remoto"
    echo "   O repositório remoto pode estar vazio ou o push ainda está em progresso"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "💡 DICAS:"
echo "   - Se o push estiver travado, pressione Ctrl+C e execute:"
echo "     bash push-github.sh"
echo "   - Verifique manualmente em:"
echo "     https://github.com/guilhermebertolaccini/darwin-laravel"
echo ""



