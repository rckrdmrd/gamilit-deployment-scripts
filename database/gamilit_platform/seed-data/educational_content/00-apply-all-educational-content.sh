#!/bin/bash
#
# Script consolidado para aplicar todo el contenido educativo
#
# Uso:
#   bash 00-apply-all-educational-content.sh
#
# Variables de entorno necesarias:
#   DB_HOST (default: localhost)
#   DB_PORT (default: 5432)
#   DB_NAME (default: gamilit_platform)
#   DB_USER (default: gamilit_user)
#   DB_PASSWORD (requerido)

set -e

# Configuración
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-gamilit_platform}
DB_USER=${DB_USER:-gamilit_user}

if [ -z "$DB_PASSWORD" ]; then
    echo "❌ Error: DB_PASSWORD no está configurado"
    echo "Uso: DB_PASSWORD='tu_password' bash $0"
    exit 1
fi

export PGPASSWORD="$DB_PASSWORD"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "  Aplicando Contenido Educativo - Gamilit Platform"
echo "=================================================="
echo "Host: $DB_HOST:$DB_PORT"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo ""

# Función para ejecutar SQL
run_sql() {
    local file=$1
    local description=$2

    echo -n "📝 $description... "
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$file" > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
        echo "Error ejecutando: $file"
        exit 1
    fi
}

# Paso 1: Módulos
echo "=== Paso 1: Cargando Módulos ==="
run_sql "$SCRIPT_DIR/01-seed-modules.sql" "Creando 4 módulos educativos"

# Paso 2: Rúbricas de evaluación
echo ""
echo "=== Paso 2: Cargando Rúbricas ==="
run_sql "$SCRIPT_DIR/02-seed-assessment_rubrics.sql" "Creando rúbricas de evaluación"

# Paso 3: Ejercicios completos del Módulo 1
echo ""
echo "=== Paso 3: Cargando Ejercicios del Módulo 1 ==="
run_sql "$SCRIPT_DIR/05-seed-module1-complete.sql" "Creando 5 ejercicios completos (Marie Curie)"

echo ""
echo "=================================================="
echo "✅ Contenido educativo aplicado exitosamente"
echo "=================================================="
echo ""
echo "Resumen:"
echo "  - 4 módulos creados"
echo "  - Módulo 1: 5 ejercicios completos"
echo "  - Módulos 2-4: Pendientes de ejercicios"
echo ""

# Verificación
echo "Verificando datos cargados..."
echo ""

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL'
SELECT
    '📚 Módulos' as tipo,
    COUNT(*)::text as cantidad
FROM educational_content.modules
WHERE is_published = true

UNION ALL

SELECT
    '📝 Ejercicios' as tipo,
    COUNT(*)::text as cantidad
FROM educational_content.exercises
WHERE is_active = true

UNION ALL

SELECT
    '✏️ Ejercicios Módulo 1' as tipo,
    COUNT(*)::text as cantidad
FROM educational_content.exercises
WHERE module_id = '11111111-1111-1111-1111-111111111111'
  AND is_active = true;
EOSQL

echo ""
echo "Para verificar el contenido en detalle:"
echo "  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"
echo ""
echo "Para probar desde el backend:"
echo "  bash /tmp/test_all_exercises.sh"
echo ""
