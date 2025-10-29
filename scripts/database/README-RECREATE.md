# Scripts de Recreación de Base de Datos - GAMILIT

Este directorio contiene scripts para recrear la base de datos completa de GAMILIT desde cero.

## 📋 Descripción

Estos scripts permiten:
- ✅ Eliminar y recrear la base de datos completa
- ✅ Cargar todos los esquemas, tablas, funciones, triggers, RLS
- ✅ Cargar datos iniciales (seeds)
- ✅ Usar paths relativos (funcionan desde cualquier ubicación)
- ✅ Configuración desde .env del backend
- ✅ Generar credenciales seguras automáticamente
- ✅ Actualizar .env según ambiente (dev/prod)

## 🚀 Scripts Disponibles

### 1. `setup-and-recreate-db.sh` ⭐ (RECOMENDADO)

Script completo y automatizado que:
- Pregunta el ambiente (dev o prod)
- Genera credenciales seguras automáticamente
- Crea usuario y base de datos
- Ejecuta todos los DDL
- Carga todos los seeds
- Actualiza el .env correspondiente

**Uso:**
```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# Modo interactivo (pregunta ambiente)
./scripts/database/setup-and-recreate-db.sh

# Especificar ambiente directamente
./scripts/database/setup-and-recreate-db.sh --env dev
./scripts/database/setup-and-recreate-db.sh --env prod

# Sin actualizar .env
./scripts/database/setup-and-recreate-db.sh --skip-env-update
```

**Ventajas:**
- ✅ Todo en un solo comando
- ✅ Genera contraseñas seguras automáticamente
- ✅ Actualiza .env automáticamente
- ✅ Copia .env.example si no existe .env
- ✅ Crea backup del .env anterior
- ✅ Simula deployment real

---

### 2. `full-recreate-database.sh` (Requiere permisos de superusuario)

Script completo que:
- Elimina la base de datos existente
- Crea usuario y base de datos desde cero
- Ejecuta todos los DDL
- Carga todos los seeds

**Requiere**: Acceso como usuario `postgres` (vía sudo o contraseña)

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# Con confirmación
./scripts/database/full-recreate-database.sh

# Sin confirmación
./scripts/database/full-recreate-database.sh --no-confirm
```

### 2. `full-recreate-as-owner.sh` (Recomendado)

Script que recrea la base de datos usando el usuario dueño (`gamilit_user`):
- Limpia todos los datos existentes (TRUNCATE)
- Verifica estructura DDL
- Carga todos los seeds

**No requiere**: Permisos de superusuario

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# Ejecutar (pedirá confirmación)
./scripts/database/full-recreate-as-owner.sh
```

**Ventajas**:
- ✅ No requiere sudo
- ✅ Más rápido (no elimina/crea la BD)
- ✅ Mantiene la estructura existente
- ✅ Ideal para desarrollo

## 📁 Estructura de Archivos

Los scripts usan paths relativos y encuentran automáticamente:

```
workspace-gamilit/
├── projects/
│   ├── gamilit-deployment-scripts/
│   │   └── scripts/
│   │       └── database/
│   │           ├── full-recreate-database.sh       ← Script completo
│   │           └── full-recreate-as-owner.sh       ← Script como owner (recomendado)
│   └── gamilit-platform-backend/
│       └── .env                                     ← Configuración de BD
└── docs/
    └── 03-desarrollo/
        └── base-de-datos/
            └── backup-ddl/
                ├── setup/
                │   └── install-all.sh               ← Script de DDL
                └── gamilit_platform/
                    └── seed-data/                   ← Datos iniciales
```

## ⚙️ Configuración

Los scripts leen la configuración desde:
`/home/isem/workspace/workspace-gamilit/projects/gamilit-platform-backend/.env`

Variables importantes:
```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj
```

## 🧪 Datos de Prueba

Después de ejecutar los scripts, tendrás estos usuarios:

| Email | Password | Rol |
|-------|----------|-----|
| student@gamilit.com | Test1234 | student |
| teacher@gamilit.com | Test1234 | admin_teacher |
| admin@gamilit.com | Test1234 | super_admin |

**Contenido Cargado**:
- ✅ 4 módulos educativos
- ✅ 11 ejercicios (5 en módulo 1, 2 en módulos 2-4)
- ✅ Categorías de logros
- ✅ Logros configurados
- ✅ Rangos Maya
- ✅ Gamificación inicializada para todos los usuarios

## 🔄 Proceso de Recreación Completo

### Opción 1: Usando `setup-and-recreate-db.sh` ⭐ (MÁS RECOMENDADO)

```bash
# 1. Ir al directorio de scripts
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# 2. Ejecutar script (preguntará ambiente)
./scripts/database/setup-and-recreate-db.sh

# 3. Seleccionar ambiente:
#    1) Desarrollo (actualiza .env o .env.local)
#    2) Producción (actualiza .env.production)

# 4. Esperar a que termine (2-3 minutos)

# 5. ¡Listo! El .env ya está actualizado con las nuevas credenciales

# 6. Iniciar backend
cd ../gamilit-platform-backend
npm run dev
```

### Opción 2: Usando `full-recreate-as-owner.sh`

```bash
# 1. Ir al directorio de scripts
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# 2. Ejecutar script
./scripts/database/full-recreate-as-owner.sh

# 3. Confirmar con 'yes'

# 4. Esperar a que termine (1-2 minutos)

# 5. Iniciar backend
cd ../gamilit-platform-backend
npm run dev

# 6. Verificar
curl http://localhost:3006/api/health
```

### Opción 3: Usando `full-recreate-database.sh`

```bash
# 1. Asegurarse de tener acceso como postgres
# (requiere sudo o POSTGRES_PASSWORD en .env)

# 2. Ejecutar
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts
./scripts/database/full-recreate-database.sh --no-confirm

# 3. Esperar a que termine (2-3 minutos)

# 4. Iniciar backend
cd ../gamilit-platform-backend
npm run dev
```

## 🧪 Verificación Post-Instalación

```bash
# 1. Health check
curl http://localhost:3006/api/health

# 2. Login
curl -X POST http://localhost:3006/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"student@gamilit.com","password":"Test1234"}'

# 3. Verificar módulos (usar el token del paso 2)
TOKEN="<token-from-login>"
curl http://localhost:3006/api/educational/modules/user/10000000-0000-0000-0000-000000000001 \
  -H "Authorization: Bearer $TOKEN"

# 4. Verificar en la base de datos
PGPASSWORD='mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj' psql -h localhost -U gamilit_user -d gamilit_platform -c "
SELECT
  (SELECT COUNT(*) FROM auth.users WHERE deleted_at IS NULL) as usuarios,
  (SELECT COUNT(*) FROM educational_content.modules) as modulos,
  (SELECT COUNT(*) FROM educational_content.exercises) as ejercicios,
  (SELECT COUNT(*) FROM gamification_system.user_stats) as stats,
  (SELECT COUNT(*) FROM gamification_system.user_ranks WHERE is_current = true) as ranks;
"
```

**Resultado esperado**:
```
 usuarios | modulos | ejercicios | stats | ranks
----------+---------+------------+-------+-------
        3 |       4 |         11 |     3 |     3
```

## 🐛 Troubleshooting

### Error: "permission denied to set parameter session_replication_role"
**Solución**: Este es un warning que puede ignorarse. No afecta la funcionalidad.

### Error: "cannot connect to PostgreSQL"
**Solución**:
```bash
# Verificar que PostgreSQL está corriendo
pg_isready -h localhost -p 5432

# Si no está corriendo, iniciarlo
sudo systemctl start postgresql
```

### Error: "relation does not exist"
**Solución**: Algunas tablas pueden no existir aún (es normal). El script continúa con las que sí existen.

### No se crearon usuarios
**Solución**: Verificar que existe el archivo:
```bash
ls -la /home/isem/workspace/workspace-gamilit/docs/03-desarrollo/base-de-datos/backup-ddl/gamilit_platform/seed-data/auth_management/01-seed-test-users.sql
```

## 📝 Notas Importantes

1. **Backup**: Estos scripts eliminan TODOS los datos. Hacer backup si es necesario.

2. **Ambiente de Desarrollo**: Estos scripts están diseñados para desarrollo local.

3. **Producción**: Para producción, usar procesos de migración apropiados.

4. **Paths Relativos**: Los scripts funcionan desde cualquier ubicación gracias a paths relativos.

5. **PostgreSQL**: Debe estar corriendo antes de ejecutar los scripts.

## 🎯 Casos de Uso

### Desarrollo Local - Reset Completo
```bash
./scripts/database/full-recreate-as-owner.sh
```

### Simular Deployment a Servidor
```bash
./scripts/database/full-recreate-database.sh --no-confirm
```

### Probar Cambios en DDL
```bash
# 1. Modificar archivos en backup-ddl/
# 2. Ejecutar
./scripts/database/full-recreate-as-owner.sh
# 3. Verificar cambios
```

## 📚 Referencias

- Documentación DDL: `../../../docs/03-desarrollo/base-de-datos/backup-ddl/README.md`
- Seeds: `../../../docs/03-desarrollo/base-de-datos/backup-ddl/gamilit_platform/seed-data/`
- Backend .env: `../../gamilit-platform-backend/.env`

## ✅ Checklist de Éxito

Después de ejecutar el script, deberías tener:

- [ ] Base de datos `gamilit_platform` creada
- [ ] 3 usuarios de prueba (student, teacher, admin)
- [ ] 4 módulos educativos
- [ ] 11 ejercicios distribuidos en los módulos
- [ ] Gamificación inicializada (stats y ranks)
- [ ] Backend conectándose exitosamente
- [ ] Login funcionando con student@gamilit.com
- [ ] Endpoints de módulos retornando datos

---

**Fecha de creación**: 2025-10-28
**Última actualización**: 2025-10-28
**Autor**: Claude Code (Anthropic)
