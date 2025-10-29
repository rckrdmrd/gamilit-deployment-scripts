#!/bin/bash
#
# Script de corrección de objetos faltantes post-instalación
# Ejecutar después de install-all.sh si hay problemas
#
# Uso:
#   DB_PASSWORD='tu_password' bash 99-fix-missing-objects.sh

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

export PGPASSWORD="${DB_PASSWORD:-mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-gamilit_user}"
DB_NAME="${DB_NAME:-gamilit_platform}"

echo "========================================="
echo "  Corrección de Objetos Faltantes"
echo "========================================="
echo ""

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para ejecutar SQL
run_sql() {
    local sql=$1
    local description=$2

    echo -n "$description... "
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$sql" > /dev/null 2>&1; then
        echo "✅"
        return 0
    else
        echo "❌"
        return 1
    fi
}

# 1. Verificar y crear tabla user_ranks si no existe
log_info "Verificando tabla gamification_system.user_ranks..."

if ! psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1 FROM gamification_system.user_ranks LIMIT 1" > /dev/null 2>&1; then
    log_warn "Tabla user_ranks no existe, creando..."

    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL'
CREATE TABLE IF NOT EXISTS gamification_system.user_ranks (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    user_id uuid NOT NULL,
    tenant_id uuid,
    current_rank maya_rank DEFAULT 'MERCENARIO'::maya_rank NOT NULL,
    previous_rank maya_rank,
    rank_progress_percentage integer DEFAULT 0,
    modules_required_for_next integer,
    modules_completed_for_rank integer DEFAULT 0,
    xp_required_for_next integer,
    xp_earned_for_rank integer DEFAULT 0,
    ml_coins_bonus integer DEFAULT 0,
    certificate_url text,
    badge_url text,
    achieved_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    previous_rank_achieved_at timestamp with time zone,
    is_current boolean DEFAULT true,
    rank_metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT user_ranks_rank_progress_percentage_check CHECK (((rank_progress_percentage >= 0) AND (rank_progress_percentage <= 100))),
    CONSTRAINT user_ranks_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE,
    CONSTRAINT user_ranks_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_ranks_user_id ON gamification_system.user_ranks(user_id);
CREATE INDEX IF NOT EXISTS idx_user_ranks_current_rank ON gamification_system.user_ranks(current_rank);
CREATE INDEX IF NOT EXISTS idx_user_ranks_is_current ON gamification_system.user_ranks(is_current) WHERE is_current = true;

COMMENT ON TABLE gamification_system.user_ranks IS 'Progresión de rangos maya: NACOM → BATAB → HOLCATTE → GUERRERO → MERCENARIO';
EOSQL

    log_info "Tabla user_ranks creada"
else
    log_info "Tabla user_ranks ya existe"
fi

# 2. Verificar que todos los usuarios tengan profiles
log_info "Verificando perfiles de usuarios..."

users_without_profile=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
SELECT COUNT(*) FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM auth_management.profiles p WHERE p.user_id = u.id)
  AND u.deleted_at IS NULL
")

if [ "$users_without_profile" -gt 0 ]; then
    log_warn "Encontrados $users_without_profile usuarios sin perfil, creando..."

    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL'
-- Deshabilitar trigger temporalmente
ALTER TABLE auth_management.profiles DISABLE TRIGGER trg_initialize_user_stats;

-- Crear perfiles faltantes
INSERT INTO auth_management.profiles (
    user_id,
    tenant_id,
    email,
    full_name,
    display_name,
    date_of_birth,
    role,
    status,
    email_verified,
    preferences
)
SELECT
    u.id,
    '00000000-0000-0000-0000-000000000001',
    u.email,
    COALESCE(INITCAP(SPLIT_PART(u.email, '@', 1)), 'User'),
    COALESCE(INITCAP(SPLIT_PART(u.email, '@', 1)), 'User'),
    '2010-01-01',
    u.role,
    'active',
    CASE WHEN u.email_confirmed_at IS NOT NULL THEN true ELSE false END,
    '{"theme": "detective", "language": "es", "timezone": "America/Mexico_City"}'::jsonb
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM auth_management.profiles p WHERE p.user_id = u.id)
  AND u.deleted_at IS NULL;

-- Reactivar trigger
ALTER TABLE auth_management.profiles ENABLE TRIGGER trg_initialize_user_stats;
EOSQL

    log_info "Perfiles creados"
else
    log_info "Todos los usuarios tienen perfil"
fi

# 3. Verificar user_stats
log_info "Verificando user_stats..."

profiles_without_stats=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
SELECT COUNT(*) FROM auth_management.profiles p
WHERE NOT EXISTS (SELECT 1 FROM gamification_system.user_stats us WHERE us.user_id = p.id)
")

if [ "$profiles_without_stats" -gt 0 ]; then
    log_warn "Encontrados $profiles_without_stats perfiles sin stats, creando..."

    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL'
INSERT INTO gamification_system.user_stats (
    user_id,
    tenant_id,
    level,
    total_xp,
    ml_coins
)
SELECT
    p.id,
    p.tenant_id,
    1,
    0,
    100
FROM auth_management.profiles p
WHERE NOT EXISTS (SELECT 1 FROM gamification_system.user_stats us WHERE us.user_id = p.id);
EOSQL

    log_info "user_stats creados"
else
    log_info "Todos los perfiles tienen stats"
fi

# 4. Verificar user_ranks
log_info "Verificando user_ranks..."

profiles_without_ranks=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
SELECT COUNT(*) FROM auth_management.profiles p
WHERE NOT EXISTS (SELECT 1 FROM gamification_system.user_ranks ur WHERE ur.user_id = p.id AND ur.is_current = true)
")

if [ "$profiles_without_ranks" -gt 0 ]; then
    log_warn "Encontrados $profiles_without_ranks perfiles sin ranks, creando..."

    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL'
INSERT INTO gamification_system.user_ranks (
    user_id,
    tenant_id,
    current_rank
)
SELECT
    p.id,
    p.tenant_id,
    'MERCENARIO'::maya_rank
FROM auth_management.profiles p
WHERE NOT EXISTS (SELECT 1 FROM gamification_system.user_ranks ur WHERE ur.user_id = p.id AND ur.is_current = true);
EOSQL

    log_info "user_ranks creados"
else
    log_info "Todos los perfiles tienen ranks"
fi

# 5. Verificar trigger initialize_user_stats
log_info "Verificando trigger initialize_user_stats..."

trigger_status=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
SELECT t.tgenabled
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'auth_management'
  AND c.relname = 'profiles'
  AND t.tgname = 'trg_initialize_user_stats'
")

if [ "$trigger_status" = "O" ]; then
    log_info "Trigger está habilitado"
elif [ "$trigger_status" = "D" ]; then
    log_warn "Trigger está deshabilitado, habilitando..."
    run_sql "ALTER TABLE auth_management.profiles ENABLE TRIGGER trg_initialize_user_stats" "Habilitando trigger"
else
    log_error "Trigger no encontrado"
fi

# Resumen final
echo ""
echo "========================================="
echo "  Verificación Final"
echo "========================================="

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL'
SELECT
    'Usuarios' as tipo,
    COUNT(*)::text as cantidad
FROM auth.users
WHERE deleted_at IS NULL

UNION ALL

SELECT
    'Perfiles',
    COUNT(*)::text
FROM auth_management.profiles

UNION ALL

SELECT
    'User Stats',
    COUNT(*)::text
FROM gamification_system.user_stats

UNION ALL

SELECT
    'User Ranks',
    COUNT(*)::text
FROM gamification_system.user_ranks
WHERE is_current = true;
EOSQL

echo ""
log_info "Correcciones completadas exitosamente"
echo ""
