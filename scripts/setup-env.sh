#!/bin/bash

# ========================================
# Script de Setup - Arquivo .env
# Cria .env com senhas fortes automaticamente
# ========================================

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔐 Configuração de Variáveis de Ambiente${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Verificar se .env já existe
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Arquivo .env já existe!${NC}"
    read -p "Deseja sobrescrever? (s/N): " CONFIRM
    if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
        echo -e "${GREEN}✅ Operação cancelada. Arquivo .env mantido.${NC}"
        exit 0
    fi
    # Fazer backup do .env existente
    BACKUP_FILE=".env.backup.$(date +%Y%m%d_%H%M%S)"
    cp .env "$BACKUP_FILE"
    echo -e "${GREEN}📦 Backup criado: ${BACKUP_FILE}${NC}"
    echo ""
fi

# Função para gerar senha forte
generate_password() {
    openssl rand -base64 24 | tr -d "=+/" | cut -c1-24
}

echo -e "${YELLOW}🔑 Gerando senhas fortes automaticamente...${NC}"
echo ""

# Gerar senhas
POSTGRES_PASS=$(generate_password)
ZABBIX_PASS=$(generate_password)
GRAFANA_PASS=$(generate_password)

# Perguntar dados personalizados (opcional)
echo -e "${BLUE}Configurações da Aplicação:${NC}"
echo -e "${YELLOW}Pressione ENTER para usar valores padrão${NC}"
echo ""

read -p "Nome do banco de dados [tasks_db]: " POSTGRES_DB
POSTGRES_DB=${POSTGRES_DB:-tasks_db}

read -p "Usuário do banco de dados [app_user]: " POSTGRES_USER
POSTGRES_USER=${POSTGRES_USER:-app_user}

read -p "Usuário do Grafana [admin]: " GRAFANA_USER
GRAFANA_USER=${GRAFANA_USER:-admin}

echo ""
echo -e "${YELLOW}⚙️  Criando arquivo .env...${NC}"

# Criar arquivo .env
cat > .env << EOF
# ========================================
# APLICAÇÃO PRINCIPAL
# ========================================
NODE_ENV=production
BACKEND_PORT=3000
PORT=3000
VITE_API_URL=/api

# ========================================
# PostgreSQL - APLICAÇÃO
# ========================================
POSTGRES_DB=${POSTGRES_DB}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASS}

# ========================================
# ZABBIX DATABASE
# ========================================
ZABBIX_DB_USER=zabbix
ZABBIX_DB_PASSWORD=${ZABBIX_PASS}
ZABBIX_DB_NAME=zabbix

# ========================================
# GRAFANA
# ========================================
GRAFANA_USER=${GRAFANA_USER}
GRAFANA_PASSWORD=${GRAFANA_PASS}
EOF

# Ajustar permissões
chmod 600 .env

echo ""
echo -e "${GREEN}✅ Arquivo .env criado com sucesso!${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 CREDENCIAIS GERADAS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}PostgreSQL (Aplicação):${NC}"
echo -e "  Database: ${GREEN}${POSTGRES_DB}${NC}"
echo -e "  User:     ${GREEN}${POSTGRES_USER}${NC}"
echo -e "  Password: ${GREEN}${POSTGRES_PASS}${NC}"
echo ""
echo -e "${YELLOW}Zabbix:${NC}"
echo -e "  URL:      ${GREEN}http://<IP-EC2>:8080${NC}"
echo -e "  User:     ${GREEN}Admin${NC}"
echo -e "  Password: ${GREEN}zabbix${NC} ${RED}(altere no primeiro acesso!)${NC}"
echo -e "  DB Pass:  ${GREEN}${ZABBIX_PASS}${NC}"
echo ""
echo -e "${YELLOW}Grafana:${NC}"
echo -e "  URL:      ${GREEN}http://<IP-EC2>:3001${NC}"
echo -e "  User:     ${GREEN}${GRAFANA_USER}${NC}"
echo -e "  Password: ${GREEN}${GRAFANA_PASS}${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${RED}⚠️  IMPORTANTE:${NC}"
echo -e "  ${YELLOW}1.${NC} Copie e salve estas credenciais em local seguro!"
echo -e "  ${YELLOW}2.${NC} Nunca commite o arquivo .env no Git"
echo -e "  ${YELLOW}3.${NC} Altere a senha do Zabbix no primeiro acesso"
echo -e "  ${YELLOW}4.${NC} Faça backup regular das credenciais"
echo ""
echo -e "${GREEN}💡 Próximo passo:${NC}"
echo -e "  Execute o deploy: ${BLUE}./scripts/deploy.sh${NC}"
echo -e "  Depois execute:   ${BLUE}./scripts/monitoring-deploy.sh${NC}"
echo ""

# Perguntar se quer salvar credenciais em arquivo
read -p "Deseja salvar as credenciais em arquivo texto? (s/N): " SAVE_CREDS
if [ "$SAVE_CREDS" = "s" ] || [ "$SAVE_CREDS" = "S" ]; then
    CREDS_FILE="CREDENTIALS_$(date +%Y%m%d_%H%M%S).txt"
    cat > "$CREDS_FILE" << EOF
CREDENCIAIS DO PROJETO - $(date)
====================================

PostgreSQL (Aplicação):
  Database: ${POSTGRES_DB}
  User:     ${POSTGRES_USER}
  Password: ${POSTGRES_PASS}

Zabbix:
  URL:      http://<IP-EC2>:8080
  User:     Admin
  Password: zabbix (ALTERE NO PRIMEIRO ACESSO!)
  DB Pass:  ${ZABBIX_PASS}

Grafana:
  URL:      http://<IP-EC2>:3001
  User:     ${GRAFANA_USER}
  Password: ${GRAFANA_PASS}

====================================
⚠️  ATENÇÃO:
- Guarde este arquivo em local seguro
- Não compartilhe por email ou chat
- Delete após salvar em gerenciador de senhas
- Nunca commite no Git
====================================
EOF
    chmod 600 "$CREDS_FILE"
    echo ""
    echo -e "${GREEN}✅ Credenciais salvas em: ${CREDS_FILE}${NC}"
    echo -e "${RED}⚠️  Lembre-se de mover para local seguro e deletar depois!${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

