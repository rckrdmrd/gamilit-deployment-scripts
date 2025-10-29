# 🗄️ GAMILIT - Scripts de Base de Datos

Directorio de scripts para gestión de la base de datos GAMILIT.

---

## 🎯 Scripts Principales

### ⭐ `00-init-database-from-scratch.sh` - RECOMENDADO

**Para:** Primera instalación en servidor nuevo (sin BD ni usuario)

```bash
# Interactivo
./00-init-database-from-scratch.sh

# Desarrollo
./00-init-database-from-scratch.sh --env dev

# Producción
./00-init-database-from-scratch.sh --env prod
```

**Hace:**
- ✅ Crea usuario PostgreSQL
- ✅ Crea base de datos
- ✅ Ejecuta 354 archivos SQL
- ✅ Carga datos iniciales
- ✅ Genera credenciales seguras
- ✅ Actualiza .env
- ✅ Valida instalación

---

### `setup-and-recreate-db.sh`

**Para:** Recrear base de datos cuando ya existe el usuario

```bash
./setup-and-recreate-db.sh
./setup-and-recreate-db.sh --env prod
```

---

### `sync-ddl-from-docs.sh`

**Para:** Sincronizar DDL desde el directorio docs

```bash
# Ver qué se sincronizaría
./sync-ddl-from-docs.sh --dry-run

# Sincronizar
./sync-ddl-from-docs.sh
```

---

### `generate-jwt-secrets.sh`

**Para:** Generar nuevos JWT secrets

```bash
# Solo mostrar
./generate-jwt-secrets.sh

# Actualizar .env.prod
./generate-jwt-secrets.sh --update-env
```

---

## 📚 Documentación

| Archivo | Descripción |
|---------|-------------|
| **[README-DEPLOYMENT.md](README-DEPLOYMENT.md)** | Guía completa de deployment |
| **[README-RECREATE.md](README-RECREATE.md)** | Guía de recreación de BD |
| **[../../PRODUCTION-READY.md](../../PRODUCTION-READY.md)** | Configuración de producción lista |
| **[../../QUICKSTART.md](../../QUICKSTART.md)** | Inicio rápido 5 min |

---

## 🚀 Quick Start

```bash
# 1. Ir al directorio
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database

# 2. Ejecutar script principal
./00-init-database-from-scratch.sh

# 3. Seguir instrucciones interactivas

# 4. Ver credenciales
cat ../../.env.prod
cat ../../database-credentials-prod.txt

# 5. Copiar .env al backend
cp ../../.env.prod ../../../backend/.env
```

---

## 🔧 Otros Scripts

| Script | Propósito |
|--------|-----------|
| `full-recreate-database.sh` | Recrear con permisos sudo |
| `full-recreate-as-owner.sh` | Recrear como owner de BD |
| `db-validate.sh` | Validar instalación |
| `db-setup.sh` | Setup básico de BD |
| `execute_all_seeds.sh` | Cargar solo seeds |

---

## 📝 Credenciales de Producción

Ya están guardadas en:

```bash
../../.env.prod
../../database-credentials-prod.txt
```

**Ver credenciales:**
```bash
cat ../../database-credentials-prod.txt
```

---

## 🔐 Usuarios de Prueba

| Email | Password | Rol |
|-------|----------|-----|
| student@gamilit.com | Test1234 | student |
| teacher@gamilit.com | Test1234 | admin_teacher |
| admin@gamilit.com | Test1234 | super_admin |

---

## ✅ Verificación Rápida

```bash
# Conectar a BD
export PGPASSWORD='mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj'
psql -h localhost -U gamilit_user -d gamilit_platform

# Listar esquemas
\dn

# Contar usuarios
SELECT COUNT(*) FROM auth.users;

# Salir
\q
```

---

## 📚 Más Información

Ver documentación completa en:
- [../../INDEX.md](../../INDEX.md) - Índice general
- [../../PRODUCTION-READY.md](../../PRODUCTION-READY.md) - Guía de producción
- [README-DEPLOYMENT.md](README-DEPLOYMENT.md) - Deployment detallado

---

**Ubicación:** `/home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database`
