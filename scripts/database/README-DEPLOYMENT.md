# GAMILIT Platform - Guía de Despliegue de Base de Datos

Esta guía explica cómo inicializar y desplegar la base de datos GAMILIT desde cero en cualquier servidor (desarrollo o producción).

## 📁 Estructura del Proyecto

```
gamilit-deployment-scripts/
├── .env.dev.example           # Template para desarrollo
├── .env.prod.example          # Template para producción
├── database/                  # DDL y SQL copiados desde docs
│   ├── gamilit_platform/
│   │   ├── schemas/          # Esquemas y tablas
│   │   └── seed-data/        # Datos iniciales
│   └── setup/                # Scripts de instalación
└── scripts/
    └── database/
        ├── 00-init-database-from-scratch.sh    # ⭐ NUEVO: Setup inicial
        └── setup-and-recreate-db.sh            # Recrear BD existente
```

## 🚀 Escenarios de Uso

### Escenario 1: Servidor Nuevo (Sin Base de Datos)

**Caso de Uso:** Primer despliegue en servidor productivo o desarrollo donde NO existe el usuario ni la base de datos.

**Script:** `00-init-database-from-scratch.sh`

#### Características:
- ✅ Crea usuario PostgreSQL desde cero
- ✅ Crea base de datos
- ✅ Ejecuta todos los DDL
- ✅ Carga datos iniciales (seeds)
- ✅ Genera credenciales seguras automáticamente
- ✅ Actualiza archivo `.env.dev` o `.env.prod`
- ✅ Guarda credenciales en archivo seguro

#### Uso:

```bash
# Modo interactivo (recomendado)
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database
./00-init-database-from-scratch.sh

# Modo desarrollo (no interactivo)
./00-init-database-from-scratch.sh --env dev

# Modo producción (no interactivo)
./00-init-database-from-scratch.sh --env prod

# Con host personalizado
./00-init-database-from-scratch.sh --env prod --db-host 192.168.1.100 --db-port 5432

# Saltar actualización de .env (útil para testing)
./00-init-database-from-scratch.sh --env dev --skip-env-update
```

#### Requisitos Previos:

1. **PostgreSQL instalado y corriendo:**
   ```bash
   sudo systemctl status postgresql
   # Si no está corriendo:
   sudo systemctl start postgresql
   ```

2. **Acceso como superusuario `postgres`:**
   - Vía sudo: `sudo -u postgres psql`
   - Vía peer authentication: `psql -U postgres`

3. **Cliente PostgreSQL (psql):**
   ```bash
   psql --version
   # Si no está instalado:
   sudo apt-get install postgresql-client
   ```

4. **OpenSSL para generar credenciales:**
   ```bash
   openssl version
   ```

---

### Escenario 2: Base de Datos Existente (Recrear)

**Caso de Uso:** Ya tienes una base de datos y usuario, pero quieres recrearla completamente (útil para desarrollo).

**Script:** `setup-and-recreate-db.sh`

#### Uso:

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database
./setup-and-recreate-db.sh

# Con parámetros
./setup-and-recreate-db.sh --env dev
./setup-and-recreate-db.sh --env prod --skip-env-update
```

---

## 📋 Proceso Detallado

### Paso 1: Preparación

```bash
# 1. Clonar/actualizar el repositorio
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# 2. Verificar estructura
ls -la database/
ls -la database/setup/
ls -la database/gamilit_platform/seed-data/

# 3. Verificar PostgreSQL
pg_isready -h localhost -p 5432
sudo systemctl status postgresql
```

### Paso 2: Ejecutar Script de Inicialización

```bash
cd scripts/database
./00-init-database-from-scratch.sh
```

**El script preguntará:**
1. ¿Ambiente? (dev/prod)
2. ¿Eliminar BD existente? (si aplica)

**Ejecutará automáticamente:**
1. ✅ Genera credenciales seguras (password 32 chars, JWT secrets)
2. ✅ Verifica prerequisitos (psql, openssl, PostgreSQL)
3. ✅ Crea usuario `gamilit_user` con CREATEDB
4. ✅ Crea base de datos `gamilit_platform`
5. ✅ Ejecuta DDL (esquemas, tablas, funciones, triggers, RLS)
6. ✅ Carga seeds (usuarios test, módulos, ejercicios, gamificación)
7. ✅ Valida instalación (conteo de tablas, datos)
8. ✅ Actualiza `.env.dev` o `.env.prod`
9. ✅ Guarda credenciales en archivo seguro

### Paso 3: Verificar Instalación

```bash
# Ver archivo de credenciales
cat ../../../database-credentials-dev.txt
# O para producción:
cat ../../../database-credentials-prod.txt

# Verificar .env
cat ../../../.env.dev
# O:
cat ../../../.env.prod

# Conectar a la base de datos
PGPASSWORD='<tu_password>' psql -h localhost -p 5432 -U gamilit_user -d gamilit_platform

# Verificar esquemas
\dn

# Verificar tablas
\dt auth.*
\dt gamification_system.*
\dt educational_content.*

# Verificar usuarios de prueba
SELECT user_id, email, role FROM auth.users;

# Salir
\q
```

### Paso 4: Configurar Backend

El script ya actualizó el archivo `.env`, ahora solo necesitas:

#### Opción A: Backend en la misma máquina

```bash
# Copiar .env al backend
cp ../../.env.dev ../../backend/.env
# O para producción:
cp ../../.env.prod ../../backend/.env

# Iniciar backend
cd ../../backend
npm install
npm run dev
```

#### Opción B: Backend en otra máquina

```bash
# Copiar contenido del .env
cat ../../.env.dev

# Copiar manualmente o vía scp
scp ../../.env.dev usuario@servidor-backend:/ruta/backend/.env
```

### Paso 5: Probar Conexión

```bash
# Health check
curl http://localhost:3006/api/health

# Login con usuario de prueba
curl -X POST http://localhost:3006/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"student@gamilit.com","password":"Test1234"}'
```

---

## 🔐 Usuarios de Prueba

El script carga automáticamente estos usuarios:

| Email | Password | Rol | Descripción |
|-------|----------|-----|-------------|
| `student@gamilit.com` | `Test1234` | `student` | Estudiante regular |
| `teacher@gamilit.com` | `Test1234` | `admin_teacher` | Profesor/Admin |
| `admin@gamilit.com` | `Test1234` | `super_admin` | Super Administrador |

**⚠️ IMPORTANTE:** En producción, cambiar estas contraseñas inmediatamente.

---

## 📝 Archivos Generados

### `.env.dev` o `.env.prod`

Contiene todas las variables de entorno necesarias:

```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=<generado automáticamente>
JWT_SECRET=<generado automáticamente>
JWT_REFRESH_SECRET=<generado automáticamente>
NODE_ENV=development|production
# ... más variables
```

### `database-credentials-{env}.txt`

Archivo seguro con todas las credenciales, connection strings y comandos útiles.

**Permisos:** `600` (solo lectura para el usuario)

---

## 🔧 Solución de Problemas

### Error: "PostgreSQL no está respondiendo"

```bash
# Verificar servicio
sudo systemctl status postgresql

# Iniciar servicio
sudo systemctl start postgresql

# Verificar puerto
pg_isready -h localhost -p 5432

# Ver logs
sudo journalctl -u postgresql -n 50
```

### Error: "No se puede conectar como usuario postgres"

**Opción 1:** Configurar sudo sin password

```bash
sudo visudo
# Agregar:
tu_usuario ALL=(postgres) NOPASSWD: /usr/bin/psql
```

**Opción 2:** Ejecutar como postgres

```bash
sudo -u postgres ./00-init-database-from-scratch.sh
```

**Opción 3:** Configurar peer authentication en `pg_hba.conf`

### Error: "Base de datos ya existe"

El script preguntará si quieres recrearla. Responde `yes` para continuar.

### Error en DDL: "Faltan archivos SQL"

Verifica que copiaste correctamente los archivos:

```bash
find ../../../database -name "*.sql" | wc -l
# Debe mostrar ~350+ archivos
```

Si faltan, copia nuevamente desde docs:

```bash
cd ../../..
rsync -av /home/isem/workspace/workspace-gamilit/docs/03-desarrollo/base-de-datos/backup-ddl/ ./database/ --exclude='*.md'
```

### Error: "openssl no encontrado"

```bash
sudo apt-get update
sudo apt-get install openssl
```

---

## 🌍 Despliegue en Servidor Remoto

### Preparar el Servidor

```bash
# Conectar al servidor
ssh usuario@servidor-produccion

# Instalar PostgreSQL
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib

# Instalar OpenSSL (si no está)
sudo apt-get install openssl

# Iniciar PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Subir Scripts y DDL

```bash
# Desde tu máquina local
cd /home/isem/workspace/workspace-gamilit/projects

# Comprimir
tar -czf gamilit-deployment.tar.gz gamilit-deployment-scripts/

# Subir al servidor
scp gamilit-deployment.tar.gz usuario@servidor:/tmp/

# En el servidor
ssh usuario@servidor
cd /opt  # o donde quieras instalar
sudo tar -xzf /tmp/gamilit-deployment.tar.gz
cd gamilit-deployment-scripts/scripts/database

# Dar permisos
chmod +x *.sh

# Ejecutar
sudo ./00-init-database-from-scratch.sh --env prod
```

### Configurar Firewall (si es necesario)

```bash
# Permitir PostgreSQL solo localmente (más seguro)
sudo ufw allow from 127.0.0.1 to any port 5432

# O permitir desde IP específica
sudo ufw allow from 192.168.1.0/24 to any port 5432
```

---

## 🔄 Actualizar Base de Datos Existente

Si solo necesitas actualizar la estructura sin recrear todo:

```bash
cd scripts/database

# Opción 1: Ejecutar DDL manualmente
cd ../../database/setup
export PGPASSWORD='tu_password'
bash install-all.sh

# Opción 2: Ejecutar scripts específicos
cd ../gamilit_platform/schemas/auth/functions
psql -h localhost -U gamilit_user -d gamilit_platform -f 01-generate_jwt_token.sql
```

---

## 📊 Validación Post-Instalación

```bash
# Script de validación incluido
export PGPASSWORD='tu_password'
psql -h localhost -U gamilit_user -d gamilit_platform -f ../../database/99-VALIDATE-DATABASE.sql

# Manualmente
psql -h localhost -U gamilit_user -d gamilit_platform << 'EOF'
-- Contar esquemas
SELECT COUNT(*) as esquemas FROM information_schema.schemata
WHERE schema_name IN ('auth', 'auth_management', 'gamification_system',
                       'educational_content', 'progress_tracking',
                       'content_management', 'social_features',
                       'system_configuration', 'audit_logging');

-- Contar usuarios
SELECT COUNT(*) as usuarios FROM auth.users WHERE deleted_at IS NULL;

-- Contar módulos
SELECT COUNT(*) as modulos FROM educational_content.modules;

-- Contar ejercicios
SELECT COUNT(*) as ejercicios FROM educational_content.exercises;

-- Contar stats de gamificación
SELECT COUNT(*) as user_stats FROM gamification_system.user_stats;
EOF
```

**Resultados esperados:**
- Esquemas: 9
- Usuarios: 3+
- Módulos: 4+
- Ejercicios: 20+
- User stats: 3+

---

## 🔒 Seguridad en Producción

### Checklist de Seguridad

- [ ] Cambiar contraseñas de usuarios de prueba
- [ ] Usar contraseñas fuertes (32+ caracteres)
- [ ] Configurar SSL/TLS para PostgreSQL
- [ ] Configurar firewall (solo IPs permitidas)
- [ ] No exponer PostgreSQL a internet público
- [ ] Usar `.env.prod` en producción (no `.env.dev`)
- [ ] No commitear archivos `.env` a git
- [ ] Rotar JWT secrets regularmente
- [ ] Configurar backups automáticos
- [ ] Configurar monitoreo y alertas
- [ ] Revisar logs regularmente

### Cambiar Contraseñas de Usuarios de Prueba

```sql
-- Conectar a la base de datos
psql -h localhost -U gamilit_user -d gamilit_platform

-- Cambiar contraseña de estudiante
UPDATE auth.users
SET password_hash = crypt('NuevaPasswordSegura123!', gen_salt('bf', 10))
WHERE email = 'student@gamilit.com';

-- Repetir para otros usuarios
```

### Configurar Backups Automáticos

```bash
# Crear script de backup
cat > /opt/gamilit-deployment-scripts/scripts/database/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups/gamilit"
mkdir -p "$BACKUP_DIR"
PGPASSWORD='tu_password' pg_dump -h localhost -U gamilit_user gamilit_platform | gzip > "$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql.gz"
# Mantener solo últimos 7 días
find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +7 -delete
EOF

chmod +x /opt/gamilit-deployment-scripts/scripts/database/backup-db.sh

# Configurar cron (diario a las 2 AM)
crontab -e
# Agregar:
0 2 * * * /opt/gamilit-deployment-scripts/scripts/database/backup-db.sh
```

---

## 📚 Referencias

- **Script principal:** `00-init-database-from-scratch.sh`
- **Script recreación:** `setup-and-recreate-db.sh`
- **DDL completo:** `database/setup/install-all.sh`
- **Validación:** `database/99-VALIDATE-DATABASE.sql`
- **Documentación completa:** `DEPLOYMENT-GUIDE.md`

---

## 🆘 Soporte

Si encuentras problemas:

1. Revisa los logs: `/tmp/gamilit_ddl_install.log`
2. Verifica PostgreSQL: `sudo systemctl status postgresql`
3. Revisa el README: `scripts/database/README-DEPLOYMENT.md`
4. Consulta la documentación del proyecto

---

## ✅ Resumen

**Para servidor nuevo (producción o desarrollo):**
```bash
cd scripts/database
./00-init-database-from-scratch.sh --env prod  # o --env dev
```

**Para recrear base de datos existente:**
```bash
cd scripts/database
./setup-and-recreate-db.sh
```

**Verificar:**
```bash
cat ../../.env.prod  # o .env.dev
cat ../../database-credentials-prod.txt
psql -h localhost -U gamilit_user -d gamilit_platform
```

¡Listo! 🚀
