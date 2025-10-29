# Scripts Review Checklist

Este documento lista todos los archivos que requieren revisión o actualización manual después de la migración.

## CRÍTICO - Requiere Acción Inmediata

### 1. docker/docker-compose.yml

**Línea 18:** Path incorrecto al volumen
```yaml
# ACTUAL:
- ./workspace-gamilit/docs/06-database/ddl:/docker-entrypoint-initdb.d:ro

# DEBE SER:
- ../../docs/06-database/ddl:/docker-entrypoint-initdb.d:ro
# O ruta absoluta:
- /home/isem/workspace/workspace-gamilit/docs/06-database/ddl:/docker-entrypoint-initdb.d:ro
```

**Línea 12:** Password por defecto inseguro
```yaml
# ACTUAL:
DB_PASSWORD: ${DB_PASSWORD:-glit_password}

# DEBE SER:
DB_PASSWORD: ${DB_PASSWORD:-gamilit_password}
# O mejor aún, sin default:
DB_PASSWORD: ${DB_PASSWORD}
```

**Acción:**
```bash
nano /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/docker/docker-compose.yml
```

---

## ALTA PRIORIDAD - Revisar Antes de Usar

### 2. scripts/database/create_all_mechanics.sh

**Línea ~10:** Verificar API_URL
```bash
# Revisar que apunte al backend correcto
API_URL="http://localhost:3006/api"
```

**Acción:**
```bash
nano /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database/create_all_mechanics.sh
# Verificar variable API_URL
```

---

### 3. scripts/database/create_remaining_mechanics.sh

**Línea ~10:** Verificar API_URL
```bash
# Revisar que apunte al backend correcto
API_URL="http://localhost:3006/api"
```

**Acción:**
```bash
nano /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database/create_remaining_mechanics.sh
# Verificar variable API_URL
```

---

### 4. .env.example

**Acción:** Crear archivo .env desde template
```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts
cp .env.example .env

# Generar secretos seguros
echo "JWT_SECRET=$(openssl rand -base64 32)"
echo "DB_PASSWORD=$(openssl rand -base64 24)"

# Editar .env y agregar los secretos generados
nano .env
```

---

### 5. ci-cd/github/ci.yml

**Revisar:**
- URLs del repositorio
- Nombres de branches
- Secrets de GitHub Actions
- Targets de deployment

**Acción:**
```bash
nano /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/ci-cd/github/ci.yml
# Actualizar configuración según nuevo repositorio
```

---

## MEDIA PRIORIDAD - Verificar Configuración

### 6. scripts/setup/setup.sh

**Líneas 230-232:** Referencias a documentación
```bash
# Verificar que estas rutas existan:
echo "  - Setup Guide: $PROJECT_ROOT/SETUP.md"
echo "  - Infrastructure: $PROJECT_ROOT/INFRASTRUCTURE.md"
echo "  - Main README: $PROJECT_ROOT/README.md"
```

**Acción:**
```bash
# Verificar si estos archivos existen en la ubicación esperada
ls -la /home/isem/workspace/workspace-gamilit/projects/gamilit-backend/SETUP.md
ls -la /home/isem/workspace/workspace-gamilit/projects/gamilit-backend/INFRASTRUCTURE.md
```

---

### 7. config/nginx/nginx.conf

**Revisar:** Configuración para frontend

**Acción:**
```bash
nano /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/config/nginx/nginx.conf
# Añadir configuración para servir frontend si es necesario
```

---

### 8. scripts/database/db-setup.sh

**Verificar:** Rutas a archivos DDL

**Acción:**
```bash
# Ejecutar en modo dry-run para verificar paths
bash -n /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/database/db-setup.sh
```

---

## BAJA PRIORIDAD - Mejoras Futuras

### 9. Crear scripts de monitoring

**Directorio:** `scripts/monitoring/`

**Scripts sugeridos:**
- `monitor-health.sh` - Monitoreo continuo de health
- `alert-on-failure.sh` - Alertas cuando fallan servicios
- `performance-monitor.sh` - Monitoreo de performance

---

### 10. Crear scripts de deployment

**Directorio:** `scripts/deployment/`

**Scripts sugeridos:**
- `deploy-production.sh` - Deploy a producción
- `deploy-staging.sh` - Deploy a staging
- `rollback.sh` - Rollback a versión anterior

---

### 11. Crear scripts de maintenance

**Directorio:** `scripts/maintenance/`

**Scripts sugeridos:**
- `backup-database.sh` - Backup automático
- `cleanup-logs.sh` - Limpieza de logs
- `optimize-database.sh` - Optimización de DB

---

### 12. Configuración PM2

**Directorio:** `config/pm2/`

**Archivos sugeridos:**
- `ecosystem.config.js` - Configuración PM2
- `development.config.js` - Config para dev
- `production.config.js` - Config para prod

---

## Checklist de Verificación

Marcar cuando se complete cada tarea:

### Antes de Primer Uso
- [ ] Actualizar docker-compose.yml (path volumen)
- [ ] Cambiar password default en docker-compose.yml
- [ ] Crear archivo .env desde template
- [ ] Generar JWT_SECRET seguro
- [ ] Generar DB_PASSWORD seguro
- [ ] Verificar permisos de ejecución en scripts
- [ ] Revisar API_URL en scripts de mechanics

### Configuración Inicial
- [ ] Actualizar ci.yml para nuevo repositorio
- [ ] Configurar GitHub Actions secrets
- [ ] Verificar paths de documentación
- [ ] Revisar nginx.conf
- [ ] Verificar paths DDL en db-setup.sh

### Testing
- [ ] Ejecutar setup.sh en ambiente de prueba
- [ ] Ejecutar db-setup.sh
- [ ] Ejecutar db-validate.sh
- [ ] Ejecutar health-check.sh
- [ ] Ejecutar test.sh
- [ ] Probar docker-compose up

### Deployment
- [ ] Crear scripts de monitoring
- [ ] Crear scripts de deployment
- [ ] Crear scripts de maintenance
- [ ] Configurar PM2
- [ ] Documentar procedimientos específicos del proyecto

---

## Comandos Rápidos de Verificación

```bash
# Navegar al proyecto
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# Verificar permisos
find scripts -name "*.sh" -type f ! -executable

# Hacer scripts ejecutables
find scripts -name "*.sh" -type f -exec chmod +x {} \;

# Buscar referencias a paths absolutos que puedan necesitar actualización
grep -r "/home/isem/workspace/projects/glit" --include="*.sh" --include="*.yml"

# Verificar sintaxis de todos los scripts
for script in $(find scripts -name "*.sh"); do
    echo "Checking $script..."
    bash -n "$script" || echo "ERROR in $script"
done

# Verificar que no queden referencias a "glit" sin "gamilit"
grep -r "glit" --include="*.sh" --include="*.yml" | grep -v "gamilit"

# Listar archivos que necesitan .env
grep -r "\.env" scripts/ --include="*.sh" -l
```

---

## Recursos Adicionales

- **README.md** - Documentación completa de scripts
- **DEPLOYMENT.md** - Guía de deployment a producción
- **QUICKSTART.md** - Guía de inicio rápido
- **MIGRATION_SUMMARY.md** - Resumen completo de la migración

---

## Notas Importantes

1. **Seguridad:** NUNCA commitear archivos .env con secretos reales
2. **Testing:** Siempre probar en ambiente de desarrollo primero
3. **Backups:** Hacer backup antes de ejecutar scripts en producción
4. **Logs:** Revisar logs después de ejecutar cualquier script
5. **Permisos:** Verificar permisos de archivos y carpetas

---

**Última actualización:** 2025-10-27
