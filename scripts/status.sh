#!/bin/bash

# ========================================
# Script para verificar status da aplicação
# ========================================

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}📊 Status da Aplicação${NC}"
echo "======================================"
echo ""

# Status dos containers
echo "🐳 Containers:"
docker compose -f docker-compose.prod.yml ps
echo ""

# Health check
echo "💚 Health Status:"
BACKEND_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' backend-production 2>/dev/null || echo "not running")
FRONTEND_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' frontend-production 2>/dev/null || echo "not running")

if [ "$BACKEND_HEALTH" = "healthy" ]; then
    echo -e "  Backend:  ${GREEN}✓ ${BACKEND_HEALTH}${NC}"
else
    echo -e "  Backend:  ${RED}✗ ${BACKEND_HEALTH}${NC}"
fi

if [ "$FRONTEND_HEALTH" = "healthy" ]; then
    echo -e "  Frontend: ${GREEN}✓ ${FRONTEND_HEALTH}${NC}"
else
    echo -e "  Frontend: ${RED}✗ ${FRONTEND_HEALTH}${NC}"
fi

echo ""

# Uso de recursos
echo "💻 Uso de Recursos:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
echo ""

# Volumes
echo "💾 Volumes:"
docker volume ls | grep devops-project
echo ""

# Portas
echo "🌐 Portas Expostas:"
docker compose -f docker-compose.prod.yml ps --format json | grep -o '"PublishedPort":[^,}]*' || echo "  Nenhuma porta exposta"
echo ""


