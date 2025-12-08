#!/bin/bash

# ========================================
# Script de Deploy - Produção Completa
# Aplicação + Monitoramento (Zabbix + Grafana)
# ========================================

set -e  # Para em caso de erro

echo "🚀 Iniciando deploy completo em produção..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verifica se está na raiz do projeto
if [ ! -f "docker-compose.prod.yml" ]; then
    echo -e "${RED}❌ Erro: docker-compose.prod.yml não encontrado!${NC}"
    echo "Execute este script da raiz do projeto."
    exit 1
fi

# Parar containers existentes
echo -e "${YELLOW}📦 Parando containers existentes...${NC}"
docker compose -f docker-compose.prod.yml down

# Limpar imagens antigas (opcional)
echo -e "${YELLOW}🧹 Limpando imagens antigas...${NC}"
docker image prune -f

# Build e start dos containers
echo -e "${YELLOW}🏗️  Construindo e iniciando containers...${NC}"
docker compose -f docker-compose.prod.yml up -d --build

# Criar diretórios necessários para Grafana
echo -e "${YELLOW}📁 Criando estrutura de diretórios do monitoramento...${NC}"
mkdir -p monitoring/grafana/provisioning/{dashboards,datasources}

# Aguardar containers ficarem saudáveis
echo -e "${YELLOW}⏳ Aguardando containers iniciarem (pode levar até 2 minutos)...${NC}"
sleep 30

# Verificar status
echo -e "${YELLOW}📊 Verificando status dos containers...${NC}"
docker compose -f docker-compose.prod.yml ps

# Verificar health - Aplicação
BACKEND_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' backend-production 2>/dev/null || echo "unknown")
FRONTEND_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' frontend-production 2>/dev/null || echo "unknown")

# Verificar health - Monitoramento
ZABBIX_SERVER_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' zabbix-server 2>/dev/null || echo "unknown")
ZABBIX_WEB_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' zabbix-web 2>/dev/null || echo "unknown")
GRAFANA_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' grafana 2>/dev/null || echo "unknown")

# Obter IP público da instância EC2 (se estiver na AWS)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")

echo ""
echo -e "${GREEN}✅ Deploy completo concluído!${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📊 STATUS DOS SERVIÇOS${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Aplicação:${NC}"
echo "  Backend:       ${BACKEND_HEALTH}"
echo "  Frontend:      ${FRONTEND_HEALTH}"
echo ""
echo -e "${YELLOW}Monitoramento:${NC}"
echo "  Zabbix Server: ${ZABBIX_SERVER_HEALTH}"
echo "  Zabbix Web:    ${ZABBIX_WEB_HEALTH}"
echo "  Grafana:       ${GRAFANA_HEALTH}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🌐 URLs DE ACESSO${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Aplicação:${NC}"
echo "  http://${PUBLIC_IP}"
echo ""
echo -e "${YELLOW}Zabbix:${NC}"
echo "  http://${PUBLIC_IP}:8080"
echo "  Usuário: Admin"
echo "  Senha: zabbix ${RED}(altere no primeiro acesso!)${NC}"
echo ""
echo -e "${YELLOW}Grafana:${NC}"
echo "  http://${PUBLIC_IP}:3001"
echo "  Usuário: admin (ou valor do .env)"
echo "  Senha: (valor do .env)"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}💡 Comandos úteis:${NC}"
echo "  Ver logs:   docker compose -f docker-compose.prod.yml logs -f"
echo "  Ver status: ./scripts/status.sh"
echo "  Parar tudo: docker compose -f docker-compose.prod.yml down"
echo ""





