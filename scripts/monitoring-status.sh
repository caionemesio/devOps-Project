#!/bin/bash

# ========================================
# Script de Status - Monitoramento
# Verifica status dos serviços de monitoramento
# ========================================

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📊 STATUS DO SISTEMA DE MONITORAMENTO${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Verificar se os containers estão rodando
echo -e "${YELLOW}📦 Containers Rodando:${NC}"
docker compose -f docker-compose.monitoring.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Health check dos containers
echo -e "${YELLOW}🏥 Health Check:${NC}"
CONTAINERS=("zabbix-server" "zabbix-web" "grafana" "zabbix-agent")

for container in "${CONTAINERS[@]}"; do
    if docker ps --filter "name=${container}" --format "{{.Names}}" | grep -q "${container}"; then
        STATUS=$(docker inspect --format='{{.State.Status}}' ${container} 2>/dev/null)
        HEALTH=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no healthcheck{{end}}' ${container} 2>/dev/null)
        
        if [ "$STATUS" = "running" ]; then
            if [ "$HEALTH" = "healthy" ] || [ "$HEALTH" = "no healthcheck" ]; then
                echo -e "  ${GREEN}✓${NC} ${container}: ${GREEN}${STATUS}${NC} (${HEALTH})"
            elif [ "$HEALTH" = "starting" ]; then
                echo -e "  ${YELLOW}⟳${NC} ${container}: ${YELLOW}${STATUS}${NC} (${HEALTH})"
            else
                echo -e "  ${RED}✗${NC} ${container}: ${RED}${STATUS}${NC} (${HEALTH})"
            fi
        else
            echo -e "  ${RED}✗${NC} ${container}: ${RED}${STATUS}${NC}"
        fi
    else
        echo -e "  ${RED}✗${NC} ${container}: ${RED}não rodando${NC}"
    fi
done
echo ""

# Uso de recursos
echo -e "${YELLOW}💻 Uso de Recursos:${NC}"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" \
    $(docker compose -f docker-compose.monitoring.yml ps -q) 2>/dev/null
echo ""

# Obter IP público
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")

# URLs de acesso
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🌐 URLs de Acesso:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}Zabbix:${NC}     http://${PUBLIC_IP}:8080"
echo -e "  ${YELLOW}Grafana:${NC}    http://${PUBLIC_IP}:3001"
echo ""

# Verificar se as portas estão acessíveis
echo -e "${YELLOW}🔌 Teste de Conectividade:${NC}"
for port in 8080 3001; do
    if curl -s --max-time 2 http://localhost:${port} >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Porta ${port}: ${GREEN}acessível${NC}"
    else
        echo -e "  ${RED}✗${NC} Porta ${port}: ${RED}não acessível${NC}"
    fi
done
echo ""

# Volumes
echo -e "${YELLOW}💾 Volumes:${NC}"
docker volume ls --filter "name=devops-project" | grep -E "(zabbix|grafana|prometheus)" || echo "  Nenhum volume encontrado"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

