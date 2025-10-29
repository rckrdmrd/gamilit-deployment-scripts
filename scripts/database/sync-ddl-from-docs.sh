#!/bin/bash

##############################################################################
# GAMILIT Platform - Sync DDL from Docs
#
# Este script sincroniza los archivos DDL desde el directorio de documentación
# hacia el proyecto de deployment. Útil cuando se actualizan los esquemas.
#
# Uso:
#   ./sync-ddl-from-docs.sh
#   ./sync-ddl-from-docs.sh --dry-run
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
WORKSPACE_ROOT="$(cd "$PROJECT_ROOT/../.." && pwd)"

# Buscar docs en múltiples ubicaciones posibles
if [ -d "$WORKSPACE_ROOT/gamilit-docs/03-desarrollo/base-de-datos/backup-ddl" ]; then
    DOCS_SOURCE="$WORKSPACE_ROOT/gamilit-docs/03-desarrollo/base-de-datos/backup-ddl"
elif [ -d "$WORKSPACE_ROOT/docs/03-desarrollo/base-de-datos/backup-ddl" ]; then
    DOCS_SOURCE="$WORKSPACE_ROOT/docs/03-desarrollo/base-de-datos/backup-ddl"
elif [ -d "$PROJECT_ROOT/../gamilit-docs/03-desarrollo/base-de-datos/backup-ddl" ]; then
    DOCS_SOURCE="$PROJECT_ROOT/../gamilit-docs/03-desarrollo/base-de-datos/backup-ddl"
else
    DOCS_SOURCE="$WORKSPACE_ROOT/docs/03-desarrollo/base-de-datos/backup-ddl"
fi

DATABASE_DEST="$PROJECT_ROOT/database"

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "  $1"
}

show_help() {
    cat << EOF
GAMILIT Platform - Sincronización de DDL desde Docs

Uso: $0 [OPCIONES]

Opciones:
  --dry-run    Mostrar lo que se haría sin ejecutar cambios
  --help       Mostrar esta ayuda

Descripción:
  Sincroniza los archivos DDL y SQL desde:
    $DOCS_SOURCE

  Hacia:
    $DATABASE_DEST

  Solo copia archivos .sql y directorios, excluye archivos .md

EOF
}

# Variables
DRY_RUN=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

print_header "🔄 GAMILIT - Sincronización de DDL"

# Verificar que existe el directorio fuente
if [ ! -d "$DOCS_SOURCE" ]; then
    print_error "Directorio fuente no encontrado: $DOCS_SOURCE"
    exit 1
fi

print_success "Directorio fuente encontrado"
print_info "Fuente: $DOCS_SOURCE"
print_info "Destino: $DATABASE_DEST"

# Crear directorio destino si no existe
if [ ! -d "$DATABASE_DEST" ]; then
    print_step "Creando directorio destino..."
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$DATABASE_DEST"
        print_success "Directorio creado"
    else
        print_info "[DRY-RUN] mkdir -p $DATABASE_DEST"
    fi
fi

# Contar archivos antes
if [ -d "$DATABASE_DEST" ]; then
    files_before=$(find "$DATABASE_DEST" -name "*.sql" 2>/dev/null | wc -l)
    print_info "Archivos SQL actuales: $files_before"
fi

# Sincronizar
print_step "Sincronizando archivos..."

if [ "$DRY_RUN" = true ]; then
    print_warning "MODO DRY-RUN: No se realizarán cambios"
    rsync -av --dry-run --progress "$DOCS_SOURCE/" "$DATABASE_DEST/" --exclude='*.md' 2>&1 | tail -20
else
    if rsync -av --progress "$DOCS_SOURCE/" "$DATABASE_DEST/" --exclude='*.md' 2>&1 | tee /tmp/gamilit_sync.log | tail -20; then
        print_success "Sincronización completada"
    else
        print_error "Error durante la sincronización"
        print_info "Ver detalles en: /tmp/gamilit_sync.log"
        exit 1
    fi
fi

# Contar archivos después
files_after=$(find "$DATABASE_DEST" -name "*.sql" 2>/dev/null | wc -l)
print_info "Archivos SQL después: $files_after"

if [ "$DRY_RUN" = false ]; then
    # Verificar estructura
    print_step "Verificando estructura..."

    required_dirs=(
        "gamilit_platform"
        "gamilit_platform/schemas"
        "gamilit_platform/seed-data"
        "setup"
    )

    all_ok=true
    for dir in "${required_dirs[@]}"; do
        if [ -d "$DATABASE_DEST/$dir" ]; then
            print_success "$dir"
        else
            print_error "$dir - NO ENCONTRADO"
            all_ok=false
        fi
    done

    if [ "$all_ok" = true ]; then
        echo ""
        print_success "Estructura verificada correctamente"
    else
        echo ""
        print_error "Faltan directorios requeridos"
        exit 1
    fi

    # Resumen
    echo ""
    print_header "✅ SINCRONIZACIÓN COMPLETADA"
    echo -e "${CYAN}Archivos SQL:${NC} $files_after"
    echo -e "${CYAN}Ubicación:${NC} $DATABASE_DEST"
    echo ""
    print_info "Ahora puedes ejecutar:"
    echo -e "  ${YELLOW}cd $SCRIPT_DIR${NC}"
    echo -e "  ${YELLOW}./00-init-database-from-scratch.sh${NC}"
    echo ""
else
    echo ""
    print_warning "Modo dry-run: No se realizaron cambios"
    print_info "Ejecuta sin --dry-run para sincronizar"
fi
