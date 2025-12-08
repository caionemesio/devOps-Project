#!/bin/bash

# ========================================
# Script de Logs - Monitoramento
# Visualiza logs dos serviços de monitoramento
# ========================================

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 LOGS DO SISTEMA DE MONITORAMENTO${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Selecione o serviço para ver os logs:"
echo ""
echo "  1) Zabbix Server"
echo "  2) Zabbix Web"
echo "  3) Grafana"
echo "  4) Zabbix Agent"
echo "  5) Todos os serviços"
echo "  6) Sair"
echo ""
read -p "Opção: " option

case $option in
    1)
        echo -e "${YELLOW}📋 Logs do Zabbix Server (Ctrl+C para sair)${NC}"
        docker compose -f docker-compose.monitoring.yml logs -f zabbix-server
        ;;
    2)
        echo -e "${YELLOW}📋 Logs do Zabbix Web (Ctrl+C para sair)${NC}"
        docker compose -f docker-compose.monitoring.yml logs -f zabbix-web
        ;;
    3)
        echo -e "${YELLOW}📋 Logs do Grafana (Ctrl+C para sair)${NC}"
        docker compose -f docker-compose.monitoring.yml logs -f grafana
        ;;
    4)
        echo -e "${YELLOW}📋 Logs do Zabbix Agent (Ctrl+C para sair)${NC}"
        docker compose -f docker-compose.monitoring.yml logs -f zabbix-agent
        ;;
    5)
        echo -e "${YELLOW}📋 Logs de Todos os Serviços (Ctrl+C para sair)${NC}"
        docker compose -f docker-compose.monitoring.yml logs -f
        ;;
    6)
        echo -e "${GREEN}👋 Até logo!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Opção inválida!${NC}"
        exit 1
        ;;
esac

