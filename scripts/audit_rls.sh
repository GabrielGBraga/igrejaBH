#!/bin/bash
# scripts/audit_rls.sh

SQL_FILE=$1
EXIT_CODE=0

echo "🔍 Auditando RLS em $SQL_FILE..."

# Captura tabelas criadas (com ou sem aspas, ignorando case)
TABLES=$(grep -Ei "CREATE TABLE[[:space:]]+(public\.)?\"?([a-zA-Z0-9_]+)\"?" "$SQL_FILE" | sed -E 's/.*TABLE[[:space:]]+(public\.)?"?([^"[:space:](]+)"?.*/\2/I')

for table in $TABLES; do
    # Verifica se existe ENABLE ROW LEVEL SECURITY para esta tabela
    # Procura por variações: ALTER TABLE x ENABLE..., ALTER TABLE public.x ENABLE...
    if ! grep -Ei "ALTER TABLE[[:space:]]+(public\.)?\"?$table\"?[[:space:]]+ENABLE[[:space:]]+ROW[[:space:]]+LEVEL[[:space:]]+SECURITY" "$SQL_FILE" > /dev/null; then
        echo "❌ ERRO: Tabela '$table' detectada no diff sem ENABLE ROW LEVEL SECURITY!"
        EXIT_CODE=1
    else
        echo "✅ Tabela '$table' possui política de RLS habilitada."
    fi
done

exit $EXIT_CODE
