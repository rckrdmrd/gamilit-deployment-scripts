# GAMILIT Platform - Guía de Deployment

**Última actualización:** 2025-10-28

---

## 📋 Resumen

Esta guía te ayudará a:
1. Configurar variables de entorno de forma segura
2. Desplegar la base de datos desde cero
3. Desplegar el backend y frontend en producción

---

## 🎯 Antes de Empezar

### Requisitos
- ✅ Servidor con Ubuntu/Debian (74.208.126.102)
- ✅ PostgreSQL 16+ instalado
- ✅ Node.js 18+ y npm instalados
- ✅ Acceso SSH al servidor
- ✅ Permisos sudo en el servidor

### Archivos Importantes
```
gamilit-deployment-scripts/
├── .env.example              # Template (SÍ commitear)
├── .env.development          # Local (NO commitear)
├── .env.production           # Producción (NO commitear)
└── scripts/
    ├── setup/
    │   └── generate-secrets.sh    # Genera passwords seguros
    └── database/
        ├── 01_manual_db_setup.sh  # (DEPRECADO - usa el nuevo)
        └── 02_execute_ddl.sh      # Ejecuta DDL
```

---

## 🚀 Deployment en Producción

### Paso 1: Generar Secrets

En tu máquina local:

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# Generar secrets aleatorios
bash scripts/setup/generate-secrets.sh
```

Esto generará:
- `DB_PASSWORD` (password de gamilit_user)
- `JWT_SECRET` (secret para tokens JWT)
- `POSTGRES_PASSWORD` (password de postgres superuser)

**Salida:**
```
DB_PASSWORD: kX7p9... (guarda este valor)
JWT_SECRET: mK3t8... (guarda este valor)
POSTGRES_PASSWORD: nP4r2... (guarda este valor)
```

---

### Paso 2: Configurar .env.production

```bash
# Copiar template
cp .env.example .env.production

# Editar con los valores generados
nano .env.production
```

**Configuración para el servidor 74.208.126.102:**

```bash
# Environment
APP_ENV=production
NODE_ENV=production

# Server
SERVER_IP=74.208.126.102
PORT=3006

# Database
DB_HOST=74.208.126.102
DB_PORT=5432
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=<PASTE_GENERATED_DB_PASSWORD_HERE>

# Postgres superuser
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<PASTE_GENERATED_POSTGRES_PASSWORD_HERE>

# JWT
JWT_SECRET=<PASTE_GENERATED_JWT_SECRET_HERE>
JWT_EXPIRES_IN=7d

# CORS (ajusta según tus dominios)
CORS_ORIGIN=http://74.208.126.102:3005,http://74.208.126.102:5173

# Frontend
VITE_API_URL=http://74.208.126.102:3006/api
VITE_WS_URL=ws://74.208.126.102:3006
```

**Validar que no hay placeholders:**
```bash
grep "CHANGE_ME" .env.production && echo "❌ ERROR!" || echo "✅ OK"
```

---

### Paso 3: Transferir al Servidor

```bash
# Comprimir archivos necesarios
tar -czf gamilit-deployment.tar.gz \
    .env.production \
    scripts/ \
    docs/03-desarrollo/base-de-datos/backup-ddl/

# Transferir al servidor
scp gamilit-deployment.tar.gz user@74.208.126.102:/home/user/

# Conectar al servidor
ssh user@74.208.126.102
```

---

### Paso 4: Descomprimir en el Servidor

```bash
# En el servidor
cd /home/user
mkdir -p gamilit-deployment
cd gamilit-deployment
tar -xzf ../gamilit-deployment.tar.gz

# Verificar estructura
ls -la
# Debes ver: .env.production, scripts/, docs/
```

---

### Paso 5: Configurar PostgreSQL (Primera vez)

```bash
# En el servidor, como postgres user
sudo -u postgres psql

# Dentro de psql:
-- Cambiar password de postgres (usa el generado)
ALTER USER postgres WITH PASSWORD '<POSTGRES_PASSWORD>';

-- Salir
\q
```

---

### Paso 6: Crear Base de Datos

```bash
# Opción A: Si tienes el script mejorado (recomendado)
# El script lee de .env.production automáticamente
bash scripts/database/01_create_db_from_env.sh

# Opción B: Si usas el script actual (requiere sudo)
# Primero edita el script para usar variables de entorno
sudo bash scripts/database/01_manual_db_setup.sh
```

**Verificar creación:**
```bash
PGPASSWORD='<DB_PASSWORD>' psql -h localhost -U gamilit_user -d gamilit_platform -c "SELECT version();"
```

---

### Paso 7: Ejecutar DDL (Crear Tablas)

```bash
# Asegúrate que la ruta del DDL sea correcta
bash scripts/database/02_execute_ddl.sh
```

Esto ejecutará:
1. Schemas
2. Tables
3. Functions
4. Triggers
5. RLS Policies
6. Grants

---

### Paso 8: Cargar Datos Iniciales (Seeds)

```bash
bash scripts/database/03_load_seeds.sh
```

Esto cargará:
- Tenant inicial
- Usuario demo (student@gamilit.com)
- Rangos y logros
- Módulos educativos de ejemplo

---

### Paso 9: Desplegar Backend

```bash
# Ir al directorio del backend
cd /home/user/gamilit-platform-backend

# Copiar .env.production
cp ../gamilit-deployment/.env.production .env.production

# Instalar dependencias
npm install --production

# Build del proyecto
npm run build

# Iniciar con PM2 (recomendado para producción)
npm install -g pm2
pm2 start npm --name "gamilit-backend" -- run start:prod

# O iniciar directamente
npm run start:prod
```

---

### Paso 10: Desplegar Frontend

```bash
# Ir al directorio del frontend
cd /home/user/gamilit-platform-web

# Copiar .env.production
cp ../gamilit-deployment/.env.production .env.production

# Instalar dependencias
npm install

# Build para producción
npm run build:prod

# Servir con nginx o servir estáticamente
# Opción 1: Con serve
npm install -g serve
serve -s dist -l 3005

# Opción 2: Con PM2
pm2 serve dist 3005 --name "gamilit-frontend"
```

---

## ✅ Verificación

### Backend
```bash
curl http://74.208.126.102:3006/api/health
# Debería retornar: {"status":"ok"}
```

### Frontend
```bash
curl -I http://74.208.126.102:3005
# Debería retornar: 200 OK
```

### Base de Datos
```bash
PGPASSWORD='<DB_PASSWORD>' psql -h localhost -U gamilit_user -d gamilit_platform << EOF
SELECT COUNT(*) as tenants FROM auth_management.tenants;
SELECT COUNT(*) as users FROM auth.users;
SELECT COUNT(*) as modules FROM educational_content.modules;
EOF
```

---

## 🔒 Seguridad Post-Deployment

### 1. Eliminar Archivos Temporales
```bash
# En servidor
rm -f .env.production.secrets
rm -f gamilit-deployment.tar.gz

# En local
rm -f .env.production.secrets
```

### 2. Verificar Permisos
```bash
chmod 600 .env.production
chmod 700 scripts/
```

### 3. Configurar Firewall
```bash
# Permitir solo puertos necesarios
sudo ufw allow 3006/tcp  # Backend
sudo ufw allow 3005/tcp  # Frontend (si aplica)
sudo ufw allow 5432/tcp  # PostgreSQL (solo si acceso remoto)
```

### 4. Backup de .env
```bash
# Guardar .env.production en un lugar seguro (fuera del servidor)
# Ejemplo: KeePass, 1Password, etc.
```

---

## 🔄 Actualizar Deployment

### Actualizar solo Backend
```bash
cd /home/user/gamilit-platform-backend
git pull
npm install
npm run build
pm2 restart gamilit-backend
```

### Actualizar solo Frontend
```bash
cd /home/user/gamilit-platform-web
git pull
npm install
npm run build:prod
pm2 restart gamilit-frontend
```

### Actualizar Base de Datos
```bash
# Solo ejecuta scripts DDL nuevos
bash scripts/database/02_execute_ddl.sh
```

---

## 🆘 Troubleshooting

### Backend no inicia
```bash
# Ver logs
pm2 logs gamilit-backend

# Verificar que .env.production existe
ls -la .env.production

# Verificar conexión a DB
PGPASSWORD='<DB_PASSWORD>' psql -h localhost -U gamilit_user -d gamilit_platform -c "SELECT 1;"
```

### Error de CORS
```bash
# Verificar CORS_ORIGIN en .env.production
grep CORS_ORIGIN .env.production

# Debe incluir el origen del frontend
# CORS_ORIGIN=http://74.208.126.102:3005
```

### Error de JWT
```bash
# Verificar que JWT_SECRET es el mismo en backend y variables de entorno
grep JWT_SECRET .env.production
```

---

## 📝 Checklist de Deployment

### Pre-Deployment
- [ ] Generar secrets con `generate-secrets.sh`
- [ ] Crear `.env.production` con valores reales
- [ ] Validar que no hay placeholders (`CHANGE_ME`)
- [ ] Hacer backup del `.env.production`

### Deployment
- [ ] Transferir archivos al servidor
- [ ] Configurar password de postgres
- [ ] Crear base de datos y usuario
- [ ] Ejecutar DDL (schemas, tables, functions)
- [ ] Cargar seeds (datos iniciales)
- [ ] Desplegar backend
- [ ] Desplegar frontend
- [ ] Configurar PM2/systemd para auto-restart

### Post-Deployment
- [ ] Verificar backend (`/api/health`)
- [ ] Verificar frontend (abrir en navegador)
- [ ] Probar login con usuario demo
- [ ] Eliminar archivos `.secrets` temporales
- [ ] Configurar firewall
- [ ] Configurar backups automáticos de BD

---

## 📞 Soporte

- **Documentación completa:** `/docs-analisys/consistency-db-backend-frontend/correcciones/16-DEPLOYMENT-STRATEGY-ENV-VARS.md`
- **Configuración de ambientes:** `/docs-analisys/consistency-db-backend-frontend/correcciones/12-CONFIGURACION-AMBIENTES-DEPLOYMENT.md`

---

**Última actualización:** 2025-10-28
