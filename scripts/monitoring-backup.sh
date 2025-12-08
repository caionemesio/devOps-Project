#!/bin/bash

# ========================================
# Script de Backup - Monitoramento
# Faz backup dos dados do Zabbix e Grafana
# ========================================

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}💾 BACKUP DO SISTEMA DE MONITORAMENTO${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Criar diretório de backup
BACKUP_DIR="./backups/monitoring"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/${TIMESTAMP}"

echo -e "${YELLOW}📁 Criando diretório de backup...${NC}"
mkdir -p "${BACKUP_PATH}"

# Backup Grafana
echo -e "${YELLOW}📊 Fazendo backup do Grafana...${NC}"
docker run --rm \
    -v devops-project_grafana-data:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    alpine \
    tar czf /backup/grafana-data.tar.gz -C /data .

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Grafana data backup concluído"
else
    echo -e "  ${RED}✗${NC} Erro no backup do Grafana"
fi

# Backup Grafana Config
docker run --rm \
    -v devops-project_grafana-config:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    alpine \
    tar czf /backup/grafana-config.tar.gz -C /data .

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Grafana config backup concluído"
else
    echo -e "  ${RED}✗${NC} Erro no backup do Grafana config"
fi

# Backup Zabbix PostgreSQL
echo -e "${YELLOW}🗄️  Fazendo backup do Zabbix Database...${NC}"
docker exec zabbix-postgres pg_dump -U zabbix zabbix > "${BACKUP_PATH}/zabbix-db.sql"

if [ $? -eq 0 ]; then
    gzip "${BACKUP_PATH}/zabbix-db.sql"
    echo -e "  ${GREEN}✓${NC} Zabbix database backup concluído"
else
    echo -e "  ${RED}✗${NC} Erro no backup do Zabbix database"
fi

# Backup Zabbix Server Data
echo -e "${YELLOW}📦 Fazendo backup dos dados do Zabbix Server...${NC}"
docker run --rm \
    -v devops-project_zabbix-server-data:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    alpine \
    tar czf /backup/zabbix-server-data.tar.gz -C /data .

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Zabbix server data backup concluído"
else
    echo -e "  ${RED}✗${NC} Erro no backup do Zabbix server data"
fi

# Backup Prometheus
echo -e "${YELLOW}📈 Fazendo backup do Prometheus...${NC}"
docker run --rm \
    -v devops-project_prometheus-data:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    alpine \
    tar czf /backup/prometheus-data.tar.gz -C /data .

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Prometheus backup concluído"
else
    echo -e "  ${RED}✗${NC} Erro no backup do Prometheus"
fi

# Backup dos arquivos de configuração
echo -e "${YELLOW}⚙️  Fazendo backup das configurações...${NC}"
tar czf "${BACKUP_PATH}/monitoring-configs.tar.gz" monitoring/ docker-compose.monitoring.yml

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Configurações backup concluído"
else
    echo -e "  ${RED}✗${NC} Erro no backup das configurações"
fi

# Calcular tamanho do backup
BACKUP_SIZE=$(du -sh "${BACKUP_PATH}" | cut -f1)

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Backup concluído!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}Localização:${NC} ${BACKUP_PATH}"
echo -e "  ${YELLOW}Tamanho:${NC} ${BACKUP_SIZE}"
echo ""

# Listar arquivos do backup
echo -e "${YELLOW}📋 Arquivos no backup:${NC}"
ls -lh "${BACKUP_PATH}" | tail -n +2 | awk '{printf "  %s  %s\n", $9, $5}'
echo ""

# Manter apenas os últimos 7 backups
echo -e "${YELLOW}🧹 Limpando backups antigos (mantendo últimos 7)...${NC}"
cd "${BACKUP_DIR}"
ls -t | tail -n +8 | xargs -r rm -rf
cd - > /dev/null

echo -e "${GREEN}💡 Dica:${NC} Faça upload deste backup para S3 ou outro local seguro!"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

