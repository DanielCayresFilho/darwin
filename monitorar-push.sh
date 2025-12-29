#!/bin/bash

# Script para monitorar o progresso do push

echo "═══════════════════════════════════════════════════════════"
echo "           📊 MONITORAMENTO DO PUSH"
echo "═══════════════════════════════════════════════════════════"
echo ""

cd /Applications/XAMPP/xamppfiles/htdocs/kivicare-laravel/kivicare-laravel-web-v1.9.0

# Verificar processos
PUSH_PROCESSES=$(ps aux | grep "git push" | grep -v grep | wc -l | tr -d ' ')
if [ "$PUSH_PROCESSES" -gt 0 ]; then
    echo "✅ Push em andamento!"
    echo "   Processos ativos: $PUSH_PROCESSES"
    echo ""
    ps aux | grep "git push" | grep -v grep | awk '{print "   PID:", $2, "| Iniciado:", $9, $10}'
    echo ""
    echo "⏳ Aguarde... O push pode levar 10-30 minutos devido ao tamanho."
    echo ""
    echo "💡 Para verificar o progresso, execute:"
    echo "   bash verificar-push.sh"
else
    echo "⚠️  Nenhum processo de push encontrado."
    echo ""
    echo "Verificando se o push foi concluído..."
    git fetch origin 2>&1 | head -3
    
    UNPUSHED=$(git log origin/main..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
    if [ "$UNPUSHED" = "0" ] 2>/dev/null; then
        echo ""
        echo "✅ SUCESSO! Push concluído!"
        echo "   Acesse: https://github.com/guilhermebertolaccini/darwin-laravel"
    else
        echo ""
        echo "❌ Push não concluído ou falhou."
        echo "   Commits não enviados: $UNPUSHED"
        echo ""
        echo "💡 Tente novamente:"
        echo "   git push -u origin main --progress"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"


