#!/bin/bash

# ========================================
# Script de Deploy - Produção
# ========================================

set -e  # Para em caso de erro

echo "🚀 Iniciando deploy em produção..."

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

# Aguardar containers ficarem saudáveis
echo -e "${YELLOW}⏳ Aguardando containers iniciarem...${NC}"
sleep 10

# Verificar status
echo -e "${YELLOW}📊 Verificando status dos containers...${NC}"
docker compose -f docker-compose.prod.yml ps

# Verificar health
BACKEND_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' backend-production 2>/dev/null || echo "unknown")
FRONTEND_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' frontend-production 2>/dev/null || echo "unknown")

echo ""
echo -e "${GREEN}✅ Deploy concluído!${NC}"
echo ""
echo "Status dos serviços:"
echo "  Backend:  ${BACKEND_HEALTH}"
echo "  Frontend: ${FRONTEND_HEALTH}"
echo ""
echo "Para ver os logs:"
echo "  docker compose -f docker-compose.prod.yml logs -f"
echo ""


