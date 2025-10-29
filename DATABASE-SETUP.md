# 🗄️ GAMILIT Platform - Database Setup Guide

Guía completa para configurar la base de datos GAMILIT desde cero en cualquier ambiente (desarrollo o producción).

## 📋 Tabla de Contenidos

- [Vista General](#-vista-general)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Quick Start](#-quick-start)
- [Scripts Disponibles](#-scripts-disponibles)
- [Guías Detalladas](#-guías-detalladas)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Vista General

Este proyecto contiene todo lo necesario para desplegar la base de datos GAMILIT:

- ✅ **Scripts automatizados** para inicialización completa
- ✅ **DDL completo** (esquemas, tablas, funciones, triggers, RLS)
- ✅ **Datos iniciales** (seeds con usuarios, módulos, ejercicios)
- ✅ **Configuración de ambientes** (dev y prod)
- ✅ **Generación automática de credenciales seguras**
- ✅ **Validación post-instalación**

---

## 📁 Estructura del Proyecto

```
gamilit-deployment-scripts/
│
├── 📄 .env.dev.example              # Template configuración desarrollo
├── 📄 .env.prod.example             # Template configuración producción
├── 📄 .env.dev                      # Generado por scripts (gitignored)
├── 📄 .env.prod                     # Generado por scripts (gitignored)
├── 📄 database-credentials-dev.txt  # Generado por scripts (gitignored)
├── 📄 database-credentials-prod.txt # Generado por scripts (gitignored)
│
├── 📂 database/                     # DDL y SQL (copiado desde docs)
│   ├── 00-INIT-DATABASE.sql
│   ├── 99-VALIDATE-DATABASE.sql
│   │
│   ├── 📂 gamilit_platform/
│   │   ├── 📂 schemas/
│   │   │   ├── auth/
│   │   │   ├── auth_management/
│   │   │   ├── gamification_system/
│   │   │   ├── educational_content/
│   │   │   ├── progress_tracking/
│   │   │   ├── content_management/
│   │   │   ├── social_features/
│   │   │   ├── system_configuration/
│   │   │   └── audit_logging/
│   │   │
│   │   └── 📂 seed-data/
│   │       ├── auth_management/
│   │       ├── educational_content/
│   │       ├── gamification_system/
│   │       └── system_configuration/
│   │
│   └── 📂 setup/
│       ├── install-all.sh           # Ejecuta todos los DDL
│       └── db-setup.sh
│
└── 📂 scripts/
    └── 📂 database/
        ├── 00-init-database-from-scratch.sh  # ⭐ Inicialización completa
        ├── setup-and-recreate-db.sh          # Recrear BD existente
        ├── sync-ddl-from-docs.sh             # Sincronizar DDL desde docs
        └── README-DEPLOYMENT.md              # Guía detallada
```

---

## 🚀 Quick Start

### Para Servidor NUEVO (Primera vez)

```bash
# 1. Ir al directorio de scripts
cd /path/to/gamilit-deployment-scripts/scripts/database

# 2. Ejecutar script de inicialización
./00-init-database-from-scratch.sh

# 3. Seguir las instrucciones interactivas
#    - Seleccionar ambiente (dev/prod)
#    - Confirmar recreación si BD existe

# 4. ¡Listo! El script:
#    ✅ Crea usuario y base de datos
#    ✅ Ejecuta todos los DDL
#    ✅ Carga datos iniciales
#    ✅ Genera credenciales seguras
#    ✅ Actualiza .env
#    ✅ Valida instalación
```

### Para BASE DE DATOS Existente

```bash
cd /path/to/gamilit-deployment-scripts/scripts/database
./setup-and-recreate-db.sh
```

---

## 📜 Scripts Disponibles

### 1. `00-init-database-from-scratch.sh` ⭐ **RECOMENDADO**

**Uso:** Primera instalación en servidor nuevo

**Características:**
- Crea usuario PostgreSQL desde cero
- Crea base de datos
- Ejecuta todos los DDL
- Carga seeds
- Genera credenciales automáticamente
- Actualiza .env

**Ejemplos:**
```bash
# Modo interactivo
./00-init-database-from-scratch.sh

# Desarrollo
./00-init-database-from-scratch.sh --env dev

# Producción
./00-init-database-from-scratch.sh --env prod

# Con host personalizado
./00-init-database-from-scratch.sh --env prod --db-host 192.168.1.100

# Sin actualizar .env (testing)
./00-init-database-from-scratch.sh --env dev --skip-env-update
```

### 2. `setup-and-recreate-db.sh`

**Uso:** Recrear base de datos existente

**Características:**
- Requiere usuario existente
- Elimina y recrea BD
- Ejecuta DDL y seeds
- Actualiza .env

**Ejemplos:**
```bash
./setup-and-recreate-db.sh
./setup-and-recreate-db.sh --env prod
```

### 3. `sync-ddl-from-docs.sh`

**Uso:** Actualizar DDL desde el repositorio de docs

**Características:**
- Sincroniza archivos SQL desde `docs/03-desarrollo/base-de-datos/backup-ddl`
- Útil cuando se actualizan esquemas

**Ejemplos:**
```bash
# Ver qué se sincronizaría
./sync-ddl-from-docs.sh --dry-run

# Sincronizar
./sync-ddl-from-docs.sh
```

---

## 📖 Guías Detalladas

### Instalación Completa Paso a Paso

Ver: [scripts/database/README-DEPLOYMENT.md](scripts/database/README-DEPLOYMENT.md)

Incluye:
- ✅ Requisitos previos detallados
- ✅ Solución de problemas comunes
- ✅ Despliegue en servidor remoto
- ✅ Configuración de seguridad
- ✅ Backups automáticos
- ✅ Validación post-instalación

---

## 🔑 Credenciales y Configuración

### Archivos Generados

Después de ejecutar el script de inicialización, se generan:

#### 1. `.env.dev` o `.env.prod`

Contiene todas las variables de entorno:

```bash
# Base de datos
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=<32 caracteres generados>

# JWT
JWT_SECRET=<generado>
JWT_REFRESH_SECRET=<generado>

# Node
NODE_ENV=development|production

# ... más variables
```

**Uso:**
```bash
# Ver contenido
cat .env.dev
# o
cat .env.prod

# Copiar al backend
cp .env.dev ../backend/.env
```

#### 2. `database-credentials-{env}.txt`

Archivo seguro (permisos 600) con:
- Todas las credenciales
- Connection strings
- Comandos útiles
- Usuarios de prueba

**Uso:**
```bash
cat database-credentials-dev.txt
```

### Usuarios de Prueba

| Email | Password | Rol |
|-------|----------|-----|
| `student@gamilit.com` | `Test1234` | `student` |
| `teacher@gamilit.com` | `Test1234` | `admin_teacher` |
| `admin@gamilit.com` | `Test1234` | `super_admin` |

**⚠️ En producción: Cambiar estas contraseñas inmediatamente**

---

## 🧪 Validación

### Verificar Base de Datos

```bash
# Conectar a la BD
PGPASSWORD='tu_password' psql -h localhost -U gamilit_user -d gamilit_platform

# Listar esquemas
\dn

# Listar tablas
\dt auth.*
\dt gamification_system.*
\dt educational_content.*

# Contar usuarios
SELECT COUNT(*) FROM auth.users;

# Salir
\q
```

### Probar Backend

```bash
# Health check
curl http://localhost:3006/api/health

# Login
curl -X POST http://localhost:3006/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"student@gamilit.com","password":"Test1234"}'
```

---

## 🔧 Troubleshooting

### PostgreSQL no está corriendo

```bash
sudo systemctl status postgresql
sudo systemctl start postgresql
pg_isready -h localhost -p 5432
```

### No puedo conectar como postgres

```bash
# Opción 1: Configurar sudo
sudo visudo
# Agregar: tu_usuario ALL=(postgres) NOPASSWD: /usr/bin/psql

# Opción 2: Ejecutar como postgres
sudo -u postgres ./00-init-database-from-scratch.sh
```

### Faltan archivos DDL

```bash
cd scripts/database
./sync-ddl-from-docs.sh
```

### Ver logs de instalación

```bash
tail -50 /tmp/gamilit_ddl_install.log
```

### Base de datos existe pero está corrupta

```bash
# Recrear completamente
./00-init-database-from-scratch.sh --force --env dev
```

---

## 🔒 Seguridad en Producción

### Checklist

- [ ] Ejecutar con `--env prod`
- [ ] Cambiar passwords de usuarios de prueba
- [ ] Configurar SSL/TLS para PostgreSQL
- [ ] Configurar firewall
- [ ] No exponer PostgreSQL a internet
- [ ] No commitear `.env` a git
- [ ] Rotar JWT secrets regularmente
- [ ] Configurar backups automáticos
- [ ] Configurar monitoreo

### Cambiar Passwords

```sql
psql -h localhost -U gamilit_user -d gamilit_platform

UPDATE auth.users
SET password_hash = crypt('NuevaPasswordSegura!', gen_salt('bf', 10))
WHERE email = 'student@gamilit.com';
```

### Configurar Backups

```bash
# Crear script
cat > backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups/gamilit"
mkdir -p "$BACKUP_DIR"
PGPASSWORD='tu_password' pg_dump -h localhost -U gamilit_user gamilit_platform \
  | gzip > "$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql.gz"
find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +7 -delete
EOF

chmod +x backup-db.sh

# Agregar a cron (diario 2 AM)
crontab -e
# Agregar: 0 2 * * * /path/to/backup-db.sh
```

---

## 📚 Más Información

- **Guía detallada:** [scripts/database/README-DEPLOYMENT.md](scripts/database/README-DEPLOYMENT.md)
- **Documentación general:** [README.md](README.md)
- **Guía de deployment:** [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)

---

## 🆘 Soporte

Si encuentras problemas:

1. ✅ Revisa logs: `/tmp/gamilit_ddl_install.log`
2. ✅ Verifica PostgreSQL: `sudo systemctl status postgresql`
3. ✅ Lee troubleshooting: `scripts/database/README-DEPLOYMENT.md`
4. ✅ Verifica estructura: `find database -name "*.sql" | wc -l` (debe ser ~350+)

---

## ✅ Resumen Rápido

**Instalación completa en 3 comandos:**

```bash
# 1. Ir a scripts
cd scripts/database

# 2. Ejecutar inicialización
./00-init-database-from-scratch.sh

# 3. Verificar
cat ../../.env.dev
psql -h localhost -U gamilit_user -d gamilit_platform
```

**Para actualizar DDL:**

```bash
cd scripts/database
./sync-ddl-from-docs.sh
./00-init-database-from-scratch.sh --force
```

¡Listo para usar! 🚀
