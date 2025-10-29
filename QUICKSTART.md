# 🚀 GAMILIT Platform - Quick Start

Guía rápida para inicializar la base de datos GAMILIT en 5 minutos.

## ✅ ¿Qué necesitas?

- PostgreSQL instalado y corriendo
- Acceso como usuario `postgres` (sudo o peer authentication)
- 5 minutos de tu tiempo

## 🎯 Inicialización Rápida

### Para Desarrollo

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database
./00-init-database-from-scratch.sh --env dev
```

### Para Producción

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database
./00-init-database-from-scratch.sh --env prod
```

## 📝 ¿Qué hace el script?

1. ✅ Genera credenciales seguras automáticamente
2. ✅ Crea usuario PostgreSQL `gamilit_user`
3. ✅ Crea base de datos `gamilit_platform`
4. ✅ Ejecuta todos los DDL (354 archivos SQL)
5. ✅ Carga datos iniciales (usuarios, módulos, ejercicios)
6. ✅ Actualiza archivo `.env.dev` o `.env.prod`
7. ✅ Guarda credenciales en archivo seguro
8. ✅ Valida instalación

## 🔑 Archivos Generados

Después de ejecutar el script:

```bash
# Ver configuración
cat .env.dev          # o .env.prod

# Ver credenciales completas
cat database-credentials-dev.txt    # o database-credentials-prod.txt
```

## 👤 Usuarios de Prueba

| Email | Password | Rol |
|-------|----------|-----|
| `student@gamilit.com` | `Test1234` | Estudiante |
| `teacher@gamilit.com` | `Test1234` | Profesor |
| `admin@gamilit.com` | `Test1234` | Admin |

## 🧪 Probar Conexión

```bash
# Conectar a la base de datos
PGPASSWORD='tu_password' psql -h localhost -U gamilit_user -d gamilit_platform

# Ver esquemas
\dn

# Ver usuarios
SELECT email, role FROM auth.users;

# Salir
\q
```

## 🖥️ Iniciar Backend

```bash
# Copiar .env al backend
cp .env.dev ../backend/.env

# O copiar manualmente las variables desde database-credentials-dev.txt

# Iniciar backend
cd ../backend
npm install
npm run dev

# Probar
curl http://localhost:3006/api/health
```

## 📚 Más Información

- **Guía completa:** [DATABASE-SETUP.md](DATABASE-SETUP.md)
- **Despliegue detallado:** [scripts/database/README-DEPLOYMENT.md](scripts/database/README-DEPLOYMENT.md)
- **Troubleshooting:** Ver guías arriba

## 🔧 Comandos Útiles

```bash
# Ver todos los scripts disponibles
ls -lh scripts/database/*.sh

# Sincronizar DDL desde docs (si se actualizaron)
./scripts/database/sync-ddl-from-docs.sh

# Recrear base de datos existente
./scripts/database/setup-and-recreate-db.sh

# Ver logs de instalación
tail -50 /tmp/gamilit_ddl_install.log
```

## 🆘 ¿Problemas?

### PostgreSQL no responde

```bash
sudo systemctl status postgresql
sudo systemctl start postgresql
```

### No puedo conectar como postgres

```bash
sudo -u postgres ./00-init-database-from-scratch.sh
```

### Faltan archivos DDL

```bash
./scripts/database/sync-ddl-from-docs.sh
```

## ✅ ¡Todo Listo!

Si el script se ejecutó sin errores, tienes:

- ✅ Base de datos funcional con 9 esquemas
- ✅ 3 usuarios de prueba
- ✅ 4+ módulos educativos
- ✅ 20+ ejercicios
- ✅ Sistema de gamificación configurado
- ✅ Archivo `.env` listo para el backend

**¡Ahora puedes iniciar tu backend y comenzar a desarrollar!** 🎉

---

**Siguiente paso:** Iniciar el backend con `npm run dev` y probar el login en `http://localhost:3006/api/auth/login`
