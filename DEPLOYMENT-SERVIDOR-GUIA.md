# 🚀 GAMILIT - Guía de Deployment en Servidor

## ✅ Scripts Actualizados con Rutas Relativas

Todos los scripts ahora usan **rutas relativas** y funcionan tanto en:
- **Local:** `/home/isem/workspace/workspace-gamilit/projects/`
- **Servidor:** `/home/gamilit/`

---

## 📋 Prerequisitos en el Servidor

Asegúrate de que el servidor tenga instalado:

```bash
# PostgreSQL
sudo systemctl status postgresql

# Cliente psql
psql --version

# OpenSSL
openssl version

# rsync (para sincronización)
rsync --version
```

---

## 📁 Estructura Esperada en el Servidor

```
/home/gamilit/
├── gamilit-docs/                    # Repositorio de documentación
│   └── 03-desarrollo/
│       └── base-de-datos/
│           └── backup-ddl/          # DDL completos (354 archivos)
│
├── gamilit-deployment-scripts/      # Scripts de deployment
│   ├── database/                    # DDL sincronizados (se genera)
│   └── scripts/
│       └── database/                # Scripts de BD
│           ├── sync-ddl-from-docs.sh
│           ├── setup-and-recreate-db.sh
│           ├── 00-init-database-from-scratch.sh
│           └── test-setup-verification.sh
│
├── gamilit-platform-backend/        # Backend
│   └── .env                         # Se genera automáticamente
│
└── gamilit-platform-web/            # Frontend
```

---

## 🔄 Proceso Completo en el Servidor

### 1. Hacer Pull de los Repositorios

```bash
cd /home/gamilit/gamilit-docs
git pull

cd /home/gamilit/gamilit-deployment-scripts
git pull

cd /home/gamilit/gamilit-platform-backend
git pull

cd /home/gamilit/gamilit-platform-web
git pull
```

### 2. Sincronizar DDL desde Docs

```bash
cd /home/gamilit/gamilit-deployment-scripts/scripts/database

# Verificar que encontrará los archivos (dry-run)
./sync-ddl-from-docs.sh --dry-run

# Si todo está OK, sincronizar
./sync-ddl-from-docs.sh
```

**Salida esperada:**
```
✓ Directorio fuente encontrado
  Fuente: /home/gamilit/gamilit-docs/03-desarrollo/base-de-datos/backup-ddl
  Archivos SQL: 354
✓ Sincronización completada
```

### 3. Verificar Setup (Opcional pero Recomendado)

```bash
./test-setup-verification.sh
```

**Debe mostrar:**
- ✓ 354 archivos SQL
- ✓ 10 esquemas encontrados
- ✓ Todos los directorios presentes

### 4. Recrear Base de Datos

**Opción A: Si la BD ya existe (recrear)**

```bash
./setup-and-recreate-db.sh --env prod
```

**Opción B: Si es primera vez (desde cero)**

```bash
./00-init-database-from-scratch.sh --env prod
```

El script hará:
1. ✅ Preguntará si eliminar BD existente (si aplica)
2. ✅ Creará usuario `gamilit_user` con password seguro
3. ✅ Creará base de datos `gamilit_platform`
4. ✅ Ejecutará 354 archivos SQL
5. ✅ Cargará datos iniciales (seeds)
6. ✅ Creará 3 usuarios de prueba
7. ✅ Actualizará `.env.prod`
8. ✅ Validará instalación

### 5. Verificar Credenciales Generadas

```bash
# Ver archivo .env generado
cat /home/gamilit/gamilit-deployment-scripts/.env.prod

# Ver credenciales completas
cat /home/gamilit/gamilit-deployment-scripts/database-credentials-prod.txt
```

### 6. Copiar .env al Backend

```bash
cp /home/gamilit/gamilit-deployment-scripts/.env.prod \
   /home/gamilit/gamilit-platform-backend/.env
```

### 7. Desplegar Backend con PM2

```bash
cd /home/gamilit/gamilit-platform-backend

# Instalar dependencias (si es necesario)
npm install

# Compilar TypeScript
npm run build

# Desplegar con PM2
pm2 restart gamilit-backend
# O si es primera vez:
pm2 start npm --name "gamilit-backend" -- start

# Verificar
pm2 status
pm2 logs gamilit-backend --lines 50
```

### 8. Desplegar Frontend con PM2

```bash
cd /home/gamilit/gamilit-platform-web

# Instalar dependencias
npm install

# Build de producción
npm run build

# Desplegar con PM2
pm2 restart gamilit-frontend
# O si es primera vez:
pm2 serve dist 3005 --name "gamilit-frontend" --spa

# Verificar
pm2 status
```

### 9. Verificar Deployment

```bash
# Health check backend
curl http://localhost:3006/api/health

# Probar login
curl -X POST http://localhost:3006/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"student@gamilit.com","password":"Test1234"}'

# Verificar frontend
curl http://localhost:3005
```

---

## 🔐 Usuarios de Prueba Creados

Los scripts crean automáticamente estos usuarios:

| Email | Password | Rol |
|-------|----------|-----|
| `student@gamilit.com` | `Test1234` | student |
| `teacher@gamilit.com` | `Test1234` | admin_teacher |
| `admin@gamilit.com` | `Test1234` | super_admin |

⚠️ **IMPORTANTE:** Cambiar estas contraseñas después del primer login en producción.

---

## 🔧 Troubleshooting

### Error: "Directorio fuente no encontrado"

```bash
# Verificar que gamilit-docs existe
ls -la /home/gamilit/gamilit-docs/

# Si no existe, clonar:
cd /home/gamilit
git clone <url-repo-docs> gamilit-docs
```

### Error: "PostgreSQL no responde"

```bash
sudo systemctl status postgresql
sudo systemctl start postgresql
pg_isready -h localhost -p 5432
```

### Error: "No se puede conectar como postgres"

El script necesita acceso como superusuario postgres. Opciones:

```bash
# Opción 1: Ejecutar como postgres
sudo -u postgres /home/gamilit/gamilit-deployment-scripts/scripts/database/setup-and-recreate-db.sh --env prod

# Opción 2: Configurar sudo sin password
sudo visudo
# Agregar: gamilit ALL=(postgres) NOPASSWD: /usr/bin/psql
```

### Error: "Faltan archivos SQL"

```bash
# Verificar sincronización
cd /home/gamilit/gamilit-deployment-scripts/scripts/database
./sync-ddl-from-docs.sh

# Verificar conteo
find ../../../database -name "*.sql" | wc -l
# Debe mostrar ~354
```

### Backend no conecta a la BD

```bash
# Verificar .env del backend
cat /home/gamilit/gamilit-platform-backend/.env | grep DB_

# Debe tener:
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=gamilit_platform
# DB_USER=gamilit_user
# DB_PASSWORD=<generado>

# Reiniciar backend
pm2 restart gamilit-backend
pm2 logs gamilit-backend
```

---

## 📝 Comandos Rápidos

```bash
# Actualizar todo y redesplegar
cd /home/gamilit/gamilit-deployment-scripts/scripts/database
./sync-ddl-from-docs.sh
./setup-and-recreate-db.sh --env prod
cp ../../.env.prod ../../../gamilit-platform-backend/.env
cd ../../../gamilit-platform-backend
npm run build
pm2 restart gamilit-backend

# Verificar logs
pm2 logs gamilit-backend --lines 100

# Verificar BD
PGPASSWORD='<password>' psql -h localhost -U gamilit_user -d gamilit_platform -c "SELECT COUNT(*) FROM auth.users;"
```

---

## ✅ Checklist de Deployment

- [ ] Pull de todos los repos
- [ ] Sincronizar DDL (`sync-ddl-from-docs.sh`)
- [ ] Verificar setup (`test-setup-verification.sh`)
- [ ] Recrear BD (`setup-and-recreate-db.sh --env prod`)
- [ ] Copiar .env al backend
- [ ] Build backend (`npm run build`)
- [ ] Restart PM2 backend
- [ ] Build frontend (`npm run build`)
- [ ] Restart PM2 frontend
- [ ] Health check
- [ ] Probar login
- [ ] Cambiar passwords de usuarios de prueba

---

## 🎯 Resumen Ejecutivo

**Comandos esenciales para deployment completo:**

```bash
# 1. Sync
cd /home/gamilit/gamilit-deployment-scripts/scripts/database
./sync-ddl-from-docs.sh

# 2. Recrear BD
./setup-and-recreate-db.sh --env prod

# 3. Deploy Backend
cp ../../.env.prod ../../../gamilit-platform-backend/.env
cd ../../../gamilit-platform-backend
npm run build && pm2 restart gamilit-backend

# 4. Deploy Frontend
cd ../gamilit-platform-web
npm run build && pm2 restart gamilit-frontend
```

¡Listo! 🚀
