#!/bin/bash

##############################################################################
# GAMILIT Platform - Generate JWT Secrets
#
# Este script genera JWT secrets seguros y los agrega al .env.prod
# Útil después de configurar las credenciales de base de datos
#
# Uso:
#   ./generate-jwt-secrets.sh
#   ./generate-jwt-secrets.sh --update-env
##############################################################################

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_PROD="$PROJECT_ROOT/.env.prod"

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "  $1"
}

UPDATE_ENV=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --update-env)
            UPDATE_ENV=true
            shift
            ;;
        --help)
            cat << EOF
GAMILIT Platform - Generate JWT Secrets

Uso: $0 [OPCIONES]

Opciones:
  --update-env    Actualizar automáticamente .env.prod
  --help          Mostrar esta ayuda

Descripción:
  Genera JWT secrets seguros usando OpenSSL y opcionalmente
  los actualiza en el archivo .env.prod

EOF
            exit 0
            ;;
        *)
            echo "Opción desconocida: $1"
            exit 1
            ;;
    esac
done

print_header "🔐 GAMILIT - Generador de JWT Secrets"

# Verificar openssl
if ! command -v openssl &> /dev/null; then
    print_error "OpenSSL no encontrado"
    exit 1
fi

# Generar secrets
print_info "Generando JWT secrets seguros..."
echo ""

JWT_SECRET=$(openssl rand -base64 32)
JWT_REFRESH_SECRET=$(openssl rand -base64 32)

print_success "Secrets generados"
echo ""

echo -e "${CYAN}JWT_SECRET:${NC}"
echo "$JWT_SECRET"
echo ""

echo -e "${CYAN}JWT_REFRESH_SECRET:${NC}"
echo "$JWT_REFRESH_SECRET"
echo ""

echo -e "${CYAN}VITE_JWT_SECRET (igual que JWT_SECRET):${NC}"
echo "$JWT_SECRET"
echo ""

if [ "$UPDATE_ENV" = true ]; then
    if [ ! -f "$ENV_PROD" ]; then
        print_warning "Archivo .env.prod no encontrado: $ENV_PROD"
        print_info "Crea el archivo primero o usa los valores manualmente"
        exit 1
    fi

    print_info "Actualizando $ENV_PROD..."

    # Crear backup
    cp "$ENV_PROD" "${ENV_PROD}.backup.$(date +%Y%m%d_%H%M%S)"

    # Actualizar secrets
    sed -i "s|^JWT_SECRET=.*|JWT_SECRET=${JWT_SECRET}|" "$ENV_PROD"
    sed -i "s|^JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=${JWT_REFRESH_SECRET}|" "$ENV_PROD"
    sed -i "s|^VITE_JWT_SECRET=.*|VITE_JWT_SECRET=${JWT_SECRET}|" "$ENV_PROD"

    print_success "Archivo .env.prod actualizado"
    echo ""
else
    print_info "Para actualizar .env.prod, ejecuta:"
    echo ""
    echo -e "  ${YELLOW}sed -i \"s|^JWT_SECRET=.*|JWT_SECRET=${JWT_SECRET}|\" $ENV_PROD${NC}"
    echo -e "  ${YELLOW}sed -i \"s|^JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=${JWT_REFRESH_SECRET}|\" $ENV_PROD${NC}"
    echo -e "  ${YELLOW}sed -i \"s|^VITE_JWT_SECRET=.*|VITE_JWT_SECRET=${JWT_SECRET}|\" $ENV_PROD${NC}"
    echo ""
    print_info "O ejecuta este script con --update-env"
    echo ""
fi

print_header "✅ COMPLETADO"

if [ "$UPDATE_ENV" = true ]; then
    print_info "JWT secrets configurados en .env.prod"
else
    print_info "Copia los secrets anteriores a tu archivo .env"
fi

echo ""
