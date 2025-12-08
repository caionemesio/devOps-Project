#!/bin/bash

# ========================================
# Script de Restore - Monitoramento
# Restaura backup do Zabbix e Grafana
# ========================================

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}♻️  RESTORE DO SISTEMA DE MONITORAMENTO${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Listar backups disponíveis
BACKUP_DIR="./backups/monitoring"

if [ ! -d "${BACKUP_DIR}" ]; then
    echo -e "${RED}❌ Nenhum backup encontrado!${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Backups disponíveis:${NC}"
echo ""
ls -lt "${BACKUP_DIR}" | grep ^d | awk '{print NR". "$9" ("$6" "$7" "$8")"}'
echo ""

read -p "Selecione o número do backup para restaurar: " BACKUP_NUM

BACKUP_NAME=$(ls -t "${BACKUP_DIR}" | sed -n "${BACKUP_NUM}p")
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

if [ ! -d "${BACKUP_PATH}" ]; then
    echo -e "${RED}❌ Backup inválido!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}⚠️  AVISO: Este processo irá:${NC}"
echo "  1. Parar todos os containers de monitoramento"
echo "  2. Remover os volumes existentes"
echo "  3. Restaurar os dados do backup"
echo "  4. Reiniciar os containers"
echo ""
read -p "Deseja continuar? (s/N): " CONFIRM

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
    echo -e "${YELLOW}Operação cancelada.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}🛑 Parando containers...${NC}"
docker compose -f docker-compose.monitoring.yml down

echo -e "${YELLOW}🗑️  Removendo volumes existentes...${NC}"
docker volume rm devops-project_grafana-data 2>/dev/null || true
docker volume rm devops-project_grafana-config 2>/dev/null || true
docker volume rm devops-project_zabbix-postgres-data 2>/dev/null || true
docker volume rm devops-project_zabbix-server-data 2>/dev/null || true
docker volume rm devops-project_prometheus-data 2>/dev/null || true

echo -e "${YELLOW}📦 Criando novos volumes...${NC}"
docker volume create devops-project_grafana-data
docker volume create devops-project_grafana-config
docker volume create devops-project_zabbix-postgres-data
docker volume create devops-project_zabbix-server-data
docker volume create devops-project_prometheus-data

# Restore Grafana
echo -e "${YELLOW}📊 Restaurando Grafana...${NC}"
docker run --rm \
    -v devops-project_grafana-data:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    alpine \
    tar xzf /backup/grafana-data.tar.gz -C /data

docker run --rm \
    -v devops-project_grafana-config:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    alpine \
    tar xzf /backup/grafana-config.tar.gz -C /data

echo -e "  ${GREEN}✓${NC} Grafana restaurado"

# Restore Zabbix Server Data
echo -e "${YELLOW}📦 Restaurando Zabbix Server...${NC}"
docker run --rm \
    -v devops-project_zabbix-server-data:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    alpine \
    tar xzf /backup/zabbix-server-data.tar.gz -C /data

echo -e "  ${GREEN}✓${NC} Zabbix server restaurado"

# Restore Prometheus
echo -e "${YELLOW}📈 Restaurando Prometheus...${NC}"
docker run --rm \
    -v devops-project_prometheus-data:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    alpine \
    tar xzf /backup/prometheus-data.tar.gz -C /data

echo -e "  ${GREEN}✓${NC} Prometheus restaurado"

# Iniciar containers novamente
echo -e "${YELLOW}🚀 Iniciando containers...${NC}"
docker compose -f docker-compose.monitoring.yml up -d

echo -e "${YELLOW}⏳ Aguardando inicialização...${NC}"
sleep 20

# Restore Zabbix Database
echo -e "${YELLOW}🗄️  Restaurando Zabbix Database...${NC}"
gunzip -c "${BACKUP_PATH}/zabbix-db.sql.gz" | docker exec -i zabbix-postgres psql -U zabbix -d zabbix

echo -e "  ${GREEN}✓${NC} Zabbix database restaurado"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Restore concluído com sucesso!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Aguarde alguns minutos para os serviços estabilizarem."
echo ""
echo "Verifique o status com:"
echo "  ./scripts/monitoring-status.sh"
echo ""

