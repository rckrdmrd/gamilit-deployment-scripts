# GAMILIT Platform - Database Version 2.0 Changelog

**Fecha:** 2025-10-28
**Versión:** 2.0.0
**Responsable:** Claude Code Agent

---

## Resumen Ejecutivo

Se ha completado la actualización de los scripts de inicialización de la base de datos, incorporando:

- 5 tablas nuevas
- Script maestro de inicialización completa
- Script de validación automatizada
- Documentación de dependencias
- Tipos enumerados centralizados
- Seed data ampliado

## Nuevos Archivos Creados

### Scripts Maestros

1. **`00-INIT-DATABASE.sql`**
   - Ubicación: `/docs/03-desarrollo/base-de-datos/backup-ddl/`
   - Propósito: Inicialización completa de la BD en un solo comando
   - Contenido: Crea database, schemas, tablas, funciones, triggers, índices, RLS, seed data
   - Tiempo de ejecución: ~5-10 minutos

2. **`99-VALIDATE-DATABASE.sql`**
   - Ubicación: `/docs/03-desarrollo/base-de-datos/backup-ddl/`
   - Propósito: Validación automatizada de la instalación
   - Validaciones: 12 categorías de objetos (schemas, tablas, funciones, etc.)
   - Output: Tabla resumen con PASS/WARNING/FAIL

3. **`DEPENDENCIES.md`**
   - Ubicación: `/docs/03-desarrollo/base-de-datos/backup-ddl/`
   - Propósito: Documentación completa de dependencias
   - Contenido: Orden de creación, diagramas, notas de implementación

### Scripts de Schema

4. **`02-create-enums.sql`**
   - Ubicación: `/docs/03-desarrollo/base-de-datos/backup-ddl/gamilit_platform/`
   - Propósito: Tipos enumerados centralizados
   - Tipos: 4 enums (theme_type, language_type, boost_type, inventory_transaction_type)

5. **Scripts de inicialización por schema:**
   - `schemas/auth_management/00-init-auth_management.sql`
   - `schemas/gamification_system/00-init-gamification_system.sql`
   - `schemas/progress_tracking/00-init-progress_tracking.sql`
   - Propósito: Inicialización modular por schema

### Seed Data

6. **`seed-data/gamification_system/00-seed-achievement_categories.sql`**
   - 5 categorías de logros: Explorador, Guerrero, Sabio, Constructor, Social

7. **`seed-data/gamification_system/03-seed-maya-ranks.sql`**
   - 5 rangos Maya: Ajaw, Nacom, Ah K'in, Halach Uinic, K'uk'ulkan

8. **`seed-data/README.md`**
   - Documentación completa del seed data
   - Orden de ejecución
   - Validación

## Tablas Nuevas Integradas

### 1. gamification_system.achievement_categories

**Propósito:** Clasificación de logros en categorías temáticas

**Campos clave:**
- `id` (VARCHAR): Identificador único de categoría
- `name` (VARCHAR): Nombre de la categoría
- `description` (TEXT): Descripción
- `icon` (VARCHAR): Icono/emoji
- `sort_order` (INTEGER): Orden de presentación

**Relaciones:**
- FK hacia `achievements.category_id`

**Seed data:** 5 categorías predefinidas

### 2. gamification_system.active_boosts

**Propósito:** Gestión de bonificadores temporales activos

**Campos clave:**
- `id` (UUID): Identificador único
- `user_id` (UUID): Usuario que tiene el boost
- `boost_type` (VARCHAR): Tipo de boost (XP, COINS, LUCK, DROP_RATE)
- `multiplier` (NUMERIC): Multiplicador del boost
- `expires_at` (TIMESTAMPTZ): Fecha de expiración

**Relaciones:**
- FK hacia `profiles.user_id`

**Índices:**
- `idx_active_boosts_user_id`
- `idx_active_boosts_expires_at`

### 3. gamification_system.inventory_transactions

**Propósito:** Historial detallado de transacciones de inventario

**Campos clave:**
- `id` (UUID): Identificador único
- `user_id` (UUID): Usuario
- `item_id` (UUID): Item involucrado
- `transaction_type` (VARCHAR): PURCHASE, USE, REWARD, EXPIRE, ADMIN_GRANT
- `quantity` (INTEGER): Cantidad
- `metadata` (JSONB): Datos adicionales

**Relaciones:**
- FK hacia `profiles.user_id`
- FK hacia `comodines_inventory.id`

**Índices:**
- `idx_inventory_transactions_user_id`
- `idx_inventory_transactions_type`

### 4. auth_management.user_preferences

**Propósito:** Preferencias personalizadas de usuario

**Campos clave:**
- `user_id` (UUID): Usuario (PK)
- `theme` (VARCHAR): light, dark, auto
- `language` (VARCHAR): es, en
- `notifications_enabled` (BOOLEAN)
- `email_notifications` (BOOLEAN)
- `preferences` (JSONB): Preferencias adicionales

**Relaciones:**
- FK hacia `profiles.user_id`

**RLS:** Usuarios solo acceden a sus propias preferencias

### 5. progress_tracking.scheduled_missions

**Propósito:** Misiones programadas para aulas y grupos

**Campos clave:**
- `id` (UUID): Identificador único
- `classroom_id` (UUID): Aula asignada
- `mission_id` (UUID): Misión a realizar
- `scheduled_for` (TIMESTAMPTZ): Fecha programada
- `status` (VARCHAR): pending, active, completed, expired, cancelled
- `metadata` (JSONB): Configuración adicional

**Relaciones:**
- FK hacia `classrooms.id`
- FK hacia `missions.id`

**Índices:**
- `idx_scheduled_missions_classroom`
- `idx_scheduled_missions_status`

## Mejoras en Documentación

### README.md Principal

**Actualizaciones:**
- Sección de Novedades v2.0
- Sección de Scripts Maestros
- Método de instalación mejorado (Script Maestro)
- Validación automatizada
- Estadísticas actualizadas
- Changelog v2.0

### Nuevas Secciones:

1. **Scripts Maestros**
   - 00-INIT-DATABASE.sql
   - 99-VALIDATE-DATABASE.sql
   - DEPENDENCIES.md

2. **Instalación Desde Cero**
   - Método 1: Script Maestro (RECOMENDADO)
   - Método 2: Scripts Automatizados (Legacy)

3. **Validación de la Instalación**
   - Método Automático (RECOMENDADO)
   - Validación Manual

4. **Estadísticas del Sistema**
   - Resumen General v2.0
   - Nuevas Tablas v2.0
   - Por Schema (actualizado)
   - Seed Data Incluido

## Orden de Ejecución Actualizado

### Para Instalación Desde Cero

```bash
# Opción Simple (RECOMENDADA)
psql -U postgres -f 00-INIT-DATABASE.sql
psql -U gamilit_user -d gamilit_platform -f 99-VALIDATE-DATABASE.sql
```

### Para Instalación Manual

Orden correcto de dependencias documentado en `DEPENDENCIES.md`:

1. Database y usuario
2. Extensiones
3. Schemas
4. ENUMs
5. Tablas (orden específico)
6. Funciones (gamilit schema primero)
7. Triggers
8. Índices
9. Vistas
10. RLS Policies
11. Grants
12. Seed data

## Dependencias Críticas Documentadas

### 1. auth.users → profiles
- `auth.users` DEBE existir antes de `profiles`
- Todas las demás tablas dependen de `profiles`

### 2. get_current_user_id() → RLS Policies
- Función crítica usada en TODAS las políticas RLS
- Debe crearse antes de las políticas

### 3. calculate_level_from_xp() → Triggers
- Función crítica para recálculo de niveles
- Debe existir antes del trigger de XP

### 4. Orden de tablas gamification_system
```
user_stats → user_ranks
achievements → user_achievements
achievement_categories → achievements
```

## Validaciones Implementadas

### Script 99-VALIDATE-DATABASE.sql

Valida automáticamente:

1. **Schemas** (esperado: 10)
2. **Extensiones** (esperado: 4)
3. **Tablas** (esperado: 35+)
4. **Funciones** (esperado: 30+)
5. **Triggers** (esperado: 26+)
6. **Índices** (esperado: 100+)
7. **Políticas RLS** (esperado: 60+)
8. **Vistas Materializadas** (esperado: 4)
9. **ENUMs** (esperado: 4+)
10. **Foreign Keys** (esperado: 40+)
11. **Funciones Críticas** (get_current_user_id, etc.)
12. **Seed Data** (achievement_categories: 5, maya_ranks: 5)

**Output:** Tabla resumen con estado PASS/WARNING/FAIL

## Impacto en Deployment

### Scripts de Deployment Actualizados

- **db-validate.sh**: Ya funciona correctamente
- Compatible con nueva estructura
- Sin cambios necesarios

### Recomendaciones

1. **Usar script maestro** para instalaciones nuevas
2. **Ejecutar validación** después de cada deployment
3. **Consultar DEPENDENCIES.md** antes de modificar esquema
4. **Mantener seed data actualizado** en producción

## Testing Recomendado

### Pre-Deployment

```bash
# 1. Test en ambiente local
psql -U postgres -f 00-INIT-DATABASE.sql

# 2. Validar instalación
psql -U gamilit_user -d gamilit_platform -f 99-VALIDATE-DATABASE.sql

# 3. Verificar seed data
psql -U gamilit_user -d gamilit_platform -c "
SELECT 'achievement_categories' as tabla, COUNT(*) FROM gamification_system.achievement_categories
UNION ALL
SELECT 'maya_ranks', COUNT(*) FROM gamification_system.user_ranks
UNION ALL
SELECT 'active_boosts (columnas)', COUNT(*) FROM information_schema.columns WHERE table_name = 'active_boosts'
UNION ALL
SELECT 'inventory_transactions (columnas)', COUNT(*) FROM information_schema.columns WHERE table_name = 'inventory_transactions'
UNION ALL
SELECT 'user_preferences (columnas)', COUNT(*) FROM information_schema.columns WHERE table_name = 'user_preferences'
UNION ALL
SELECT 'scheduled_missions (columnas)', COUNT(*) FROM information_schema.columns WHERE table_name = 'scheduled_missions';
"
```

### Post-Deployment

```bash
# 1. Ejecutar script de validación del proyecto
./scripts/database/db-validate.sh --detailed

# 2. Verificar RLS
psql -U gamilit_user -d gamilit_platform -c "
SELECT schemaname, tablename, 
       CASE WHEN rowsecurity THEN 'ENABLED' ELSE 'DISABLED' END as rls_status
FROM pg_tables 
WHERE schemaname IN ('auth_management', 'gamification_system', 'progress_tracking')
ORDER BY schemaname, tablename;
"

# 3. Test de funciones críticas
psql -U gamilit_user -d gamilit_platform -c "
SELECT proname, nspname 
FROM pg_proc p 
JOIN pg_namespace n ON p.pronamespace = n.oid 
WHERE proname IN ('get_current_user_id', 'calculate_level_from_xp')
ORDER BY proname;
"
```

## Próximos Pasos

### Inmediatos

1. ✅ Scripts creados y documentados
2. ⏳ Testing en ambiente de desarrollo
3. ⏳ Validación con backend
4. ⏳ Deployment en staging

### Futuro

1. Automatizar refresh de materialized views
2. Implementar monitoreo de performance
3. Crear scripts de migración incremental
4. Documentar procedimientos de rollback

## Archivos Modificados/Creados

### Nuevos

```
backup-ddl/
├── 00-INIT-DATABASE.sql                    [NUEVO]
├── 99-VALIDATE-DATABASE.sql                [NUEVO]
├── DEPENDENCIES.md                         [NUEVO]
└── gamilit_platform/
    ├── 02-create-enums.sql                 [NUEVO]
    ├── schemas/
    │   ├── auth_management/
    │   │   ├── 00-init-auth_management.sql  [NUEVO]
    │   │   └── tables/
    │   │       └── 10-user_preferences.sql  [NUEVO]
    │   ├── gamification_system/
    │   │   ├── 00-init-gamification_system.sql [NUEVO]
    │   │   └── tables/
    │   │       ├── 10-achievement_categories.sql [NUEVO]
    │   │       ├── 11-active_boosts.sql         [NUEVO]
    │   │       └── 12-inventory_transactions.sql [NUEVO]
    │   └── progress_tracking/
    │       ├── 00-init-progress_tracking.sql    [NUEVO]
    │       └── tables/
    │           └── 05-scheduled_missions.sql    [NUEVO]
    └── seed-data/
        ├── README.md                        [NUEVO]
        └── gamification_system/
            ├── 00-seed-achievement_categories.sql [NUEVO]
            └── 03-seed-maya-ranks.sql           [NUEVO]
```

### Modificados

```
backup-ddl/
└── README.md                                [ACTUALIZADO]
```

## Contacto y Soporte

Para preguntas o problemas relacionados con esta actualización:

- Revisar `DEPENDENCIES.md` para orden de ejecución
- Ejecutar `99-VALIDATE-DATABASE.sql` para diagnóstico
- Consultar `backup-ddl/README.md` para troubleshooting

---

**Documento generado:** 2025-10-28
**Versión:** 2.0.0
**Estado:** Completado
