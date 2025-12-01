#!/bin/bash

# ========================================
# Script de Backup - PostgreSQL
# ========================================

set -e

# Configurações
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="postgres-backup-${DATE}.sql"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}💾 Iniciando backup do PostgreSQL...${NC}"

# Criar diretório de backups se não existir
mkdir -p ${BACKUP_DIR}

# Verificar se o container está rodando
if ! docker ps | grep -q postgres-production; then
    echo -e "${RED}❌ Erro: Container postgres-production não está rodando!${NC}"
    exit 1
fi

# Fazer backup do PostgreSQL
echo "📦 Exportando banco de dados..."
docker exec postgres-production pg_dump -U app_user tasks_db > ${BACKUP_DIR}/${BACKUP_FILE}

# Comprimir backup
echo "🗜️  Comprimindo backup..."
gzip ${BACKUP_DIR}/${BACKUP_FILE}

echo -e "${GREEN}✅ Backup criado com sucesso!${NC}"
echo "Arquivo: ${BACKUP_DIR}/${BACKUP_FILE}.gz"

# Calcular tamanho do backup
SIZE=$(du -h ${BACKUP_DIR}/${BACKUP_FILE}.gz | cut -f1)
echo "Tamanho: ${SIZE}"

# Listar backups existentes
echo ""
echo "📂 Backups existentes:"
ls -lh ${BACKUP_DIR}/ | grep postgres-backup || echo "Nenhum backup encontrado"

# Remover backups com mais de 30 dias (opcional)
echo ""
echo "🧹 Limpando backups antigos (>30 dias)..."
DELETED=$(find ${BACKUP_DIR} -name "postgres-backup-*.sql.gz" -mtime +30 -delete -print 2>/dev/null | wc -l)
if [ "$DELETED" -gt 0 ]; then
    echo "Removidos: $DELETED backup(s) antigo(s)"
else
    echo "Nenhum backup antigo para remover"
fi

echo ""
echo -e "${GREEN}✅ Processo de backup concluído!${NC}"

