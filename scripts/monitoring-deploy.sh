#!/bin/bash

# ========================================
# Script de Deploy - Monitoramento
# Deploy Zabbix + Grafana
# ========================================

set -e

echo "📊 Iniciando deploy do sistema de monitoramento..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verifica se está na raiz do projeto
if [ ! -f "docker-compose.monitoring.yml" ]; then
    echo -e "${RED}❌ Erro: docker-compose.monitoring.yml não encontrado!${NC}"
    echo "Execute este script da raiz do projeto."
    exit 1
fi

# Criar diretórios necessários
echo -e "${YELLOW}📁 Criando estrutura de diretórios...${NC}"
mkdir -p monitoring/grafana/provisioning/{dashboards,datasources}

# Verificar se o arquivo .env existe
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Arquivo .env não encontrado. Criando com valores padrão...${NC}"
    cat > .env << EOF
# Zabbix Database
ZABBIX_DB_USER=zabbix
ZABBIX_DB_PASSWORD=zabbix_password_change_me
ZABBIX_DB_NAME=zabbix

# Grafana
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin_change_me
EOF
    echo -e "${YELLOW}⚠️  IMPORTANTE: Edite o arquivo .env e altere as senhas padrão!${NC}"
    read -p "Pressione ENTER para continuar..."
fi

# Parar containers de monitoramento existentes
echo -e "${YELLOW}🛑 Parando containers de monitoramento existentes...${NC}"
docker compose -f docker-compose.monitoring.yml down 2>/dev/null || true

# Limpar volumes órfãos (opcional)
echo -e "${YELLOW}🧹 Limpando volumes órfãos...${NC}"
docker volume prune -f

# Build e start dos containers de monitoramento
echo -e "${YELLOW}🏗️  Construindo e iniciando containers de monitoramento...${NC}"
docker compose -f docker-compose.monitoring.yml up -d

# Aguardar containers ficarem prontos
echo -e "${YELLOW}⏳ Aguardando containers iniciarem (pode levar até 2 minutos)...${NC}"
sleep 30

# Verificar status
echo -e "${BLUE}📊 Verificando status dos containers...${NC}"
docker compose -f docker-compose.monitoring.yml ps

# Verificar health dos containers
echo ""
echo -e "${BLUE}🏥 Verificando saúde dos serviços...${NC}"
ZABBIX_SERVER_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' zabbix-server 2>/dev/null || echo "unknown")
ZABBIX_WEB_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' zabbix-web 2>/dev/null || echo "unknown")
GRAFANA_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' grafana 2>/dev/null || echo "unknown")

echo "  Zabbix Server: ${ZABBIX_SERVER_HEALTH}"
echo "  Zabbix Web:    ${ZABBIX_WEB_HEALTH}"
echo "  Grafana:       ${GRAFANA_HEALTH}"

# Obter IP público da instância EC2 (se estiver na AWS)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")

echo ""
echo -e "${GREEN}✅ Deploy do monitoramento concluído!${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🌐 URLs de Acesso:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}Zabbix Frontend:${NC}"
echo -e "    http://${PUBLIC_IP}:8080"
echo -e "    Usuário: ${GREEN}Admin${NC}"
echo -e "    Senha: ${GREEN}zabbix${NC}"
echo ""
echo -e "  ${YELLOW}Grafana:${NC}"
echo -e "    http://${PUBLIC_IP}:3001"
echo -e "    Usuário: ${GREEN}${GRAFANA_USER:-admin}${NC}"
echo -e "    Senha: ${GREEN}${GRAFANA_PASSWORD:-admin}${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Próximos Passos:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  1. Configure o Security Group na AWS para permitir:"
echo "     - Porta 8080 (Zabbix)"
echo "     - Porta 3001 (Grafana)"
echo "     - Porta 10051 (Zabbix Server)"
echo ""
echo "  2. Faça login no Zabbix e configure:"
echo "     - Hosts para monitorar"
echo "     - Triggers de alerta"
echo "     - Notificações"
echo ""
echo "  3. No Grafana:"
echo "     - Ative o plugin Zabbix: Configuration → Plugins → Zabbix"
echo "     - Configure dashboards com dados do Zabbix"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Para ver os logs:"
echo "  ./scripts/monitoring-logs.sh"
echo ""
echo "Para verificar status:"
echo "  ./scripts/monitoring-status.sh"
echo ""
echo "Para parar o monitoramento:"
echo "  docker compose -f docker-compose.monitoring.yml down"
echo ""

