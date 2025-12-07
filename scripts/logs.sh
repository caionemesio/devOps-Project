#!/bin/bash

# ========================================
# Script para visualizar logs
# ========================================

# Cores
YELLOW='\033[1;33m'
NC='\033[0m'

SERVICE=${1:-all}

case $SERVICE in
  backend)
    echo -e "${YELLOW}📋 Logs do Backend:${NC}"
    docker logs -f backend-production
    ;;
  frontend)
    echo -e "${YELLOW}📋 Logs do Frontend:${NC}"
    docker logs -f frontend-production
    ;;
  all)
    echo -e "${YELLOW}📋 Logs de todos os serviços:${NC}"
    docker compose -f docker-compose.prod.yml logs -f
    ;;
  *)
    echo "Uso: $0 [backend|frontend|all]"
    echo "Exemplo: $0 backend"
    exit 1
    ;;
esac





