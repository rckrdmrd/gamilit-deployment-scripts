# 📚 GAMILIT Platform - Índice de Documentación

Guía de navegación de toda la documentación del proyecto.

## 🎯 ¿Por dónde empezar?

### Si quieres inicializar la base de datos RÁPIDO:
👉 **[QUICKSTART.md](QUICKSTART.md)** - 5 minutos para tener todo funcionando

### Si es tu primera vez con el proyecto:
👉 **[DATABASE-SETUP.md](DATABASE-SETUP.md)** - Guía completa de setup de base de datos

### Si necesitas deploy en producción:
👉 **[scripts/database/README-DEPLOYMENT.md](scripts/database/README-DEPLOYMENT.md)** - Guía detallada de deployment

---

## 📖 Documentación por Categoría

### 🚀 Inicialización y Setup

| Archivo | Descripción | Cuándo usar |
|---------|-------------|-------------|
| **[QUICKSTART.md](QUICKSTART.md)** | Guía rápida 5 min | Primera vez, quieres algo rápido |
| **[SETUP-SUMMARY.txt](SETUP-SUMMARY.txt)** | Resumen completo de la solución | Ver qué se creó y cómo funciona |
| **[DATABASE-SETUP.md](DATABASE-SETUP.md)** | Guía completa de base de datos | Entender todos los detalles |

### 🌍 Deployment y Producción

| Archivo | Descripción | Cuándo usar |
|---------|-------------|-------------|
| **[scripts/database/README-DEPLOYMENT.md](scripts/database/README-DEPLOYMENT.md)** | Guía detallada de deployment | Deploy en servidor productivo |
| **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)** | Guía general de deployment | Overview de deployment completo |
| **[.env.dev.example](.env.dev.example)** | Template desarrollo | Configurar ambiente dev |
| **[.env.prod.example](.env.prod.example)** | Template producción | Configurar ambiente prod |

### 📋 Referencia y Troubleshooting

| Archivo | Descripción | Cuándo usar |
|---------|-------------|-------------|
| **[scripts/database/README-RECREATE.md](scripts/database/README-RECREATE.md)** | Recrear base de datos | Ya tienes BD y quieres recrear |
| **[REVIEW_CHECKLIST.md](REVIEW_CHECKLIST.md)** | Checklist de revisión | Antes de deploy a producción |
| **[README.md](README.md)** | Documentación general | Overview del proyecto |

### 🔄 Migración y Histórico

| Archivo | Descripción | Cuándo usar |
|---------|-------------|-------------|
| **[MIGRATION_SUMMARY.md](MIGRATION_SUMMARY.md)** | Resumen de migración | Entender cambios de migración |

---

## 🛠️ Scripts Principales

### Ubicación: `scripts/database/`

| Script | Propósito | Uso Común |
|--------|-----------|-----------|
| **00-init-database-from-scratch.sh** ⭐ | Inicialización completa desde cero | `./00-init-database-from-scratch.sh --env dev` |
| **setup-and-recreate-db.sh** | Recrear BD existente | `./setup-and-recreate-db.sh` |
| **sync-ddl-from-docs.sh** | Sincronizar DDL desde docs | `./sync-ddl-from-docs.sh` |
| full-recreate-database.sh | Recrear con sudo | Cuando necesitas permisos elevados |
| db-validate.sh | Validar instalación | Verificar que todo esté OK |

---

## 🗂️ Estructura de Archivos

```
gamilit-deployment-scripts/
│
├── 📄 Documentación
│   ├── INDEX.md                    ← ESTE ARCHIVO
│   ├── QUICKSTART.md               ← Inicio rápido
│   ├── DATABASE-SETUP.md           ← Guía completa
│   ├── SETUP-SUMMARY.txt           ← Resumen técnico
│   ├── DEPLOYMENT-GUIDE.md         ← Deployment general
│   ├── README.md                   ← Overview
│   └── REVIEW_CHECKLIST.md         ← Checklist
│
├── 📄 Templates de Configuración
│   ├── .env.dev.example            ← Template desarrollo
│   └── .env.prod.example           ← Template producción
│
├── 📂 database/                    ← DDL y SQL (354 archivos)
│   ├── gamilit_platform/
│   │   ├── schemas/               ← 9 esquemas
│   │   └── seed-data/             ← Datos iniciales
│   └── setup/
│       └── install-all.sh         ← Ejecutor DDL
│
└── 📂 scripts/
    └── database/
        ├── 00-init-database-from-scratch.sh  ← ⭐ Script principal
        ├── setup-and-recreate-db.sh
        ├── sync-ddl-from-docs.sh
        └── README-DEPLOYMENT.md              ← Guía detallada
```

---

## 🎓 Flujos de Trabajo

### Flujo 1: Primera Instalación (Servidor Nuevo)

```bash
1. Leer: QUICKSTART.md
2. Ejecutar: scripts/database/00-init-database-from-scratch.sh --env dev
3. Verificar: cat .env.dev
4. Iniciar backend
```

### Flujo 2: Deployment a Producción

```bash
1. Leer: scripts/database/README-DEPLOYMENT.md
2. Revisar: REVIEW_CHECKLIST.md
3. Ejecutar: scripts/database/00-init-database-from-scratch.sh --env prod
4. Seguir checklist de seguridad
```

### Flujo 3: Recrear Base de Datos Existente

```bash
1. Leer: scripts/database/README-RECREATE.md
2. Ejecutar: scripts/database/setup-and-recreate-db.sh
3. Validar: scripts/database/db-validate.sh
```

### Flujo 4: Actualizar DDL desde Docs

```bash
1. Ejecutar: scripts/database/sync-ddl-from-docs.sh --dry-run
2. Revisar cambios
3. Ejecutar: scripts/database/sync-ddl-from-docs.sh
4. Recrear BD: scripts/database/setup-and-recreate-db.sh
```

---

## 📞 FAQ - Preguntas Frecuentes

### ¿Qué archivo leo primero?
👉 [QUICKSTART.md](QUICKSTART.md) - Te lleva paso a paso

### ¿Cómo creo la base de datos desde cero?
👉 Ejecuta: `scripts/database/00-init-database-from-scratch.sh`

### ¿Dónde están los DDL/SQL?
👉 En: `database/gamilit_platform/`

### ¿Cómo actualizo los DDL desde docs?
👉 Ejecuta: `scripts/database/sync-ddl-from-docs.sh`

### ¿Qué usuarios de prueba hay?
👉 Ver: [QUICKSTART.md](QUICKSTART.md) - Sección "Usuarios de Prueba"

### ¿Dónde están las credenciales después del setup?
👉 En: `.env.dev` o `.env.prod` y `database-credentials-{env}.txt`

### ¿Cómo deploy en producción?
👉 Lee: [scripts/database/README-DEPLOYMENT.md](scripts/database/README-DEPLOYMENT.md)

### ¿Cómo validar que todo funciona?
👉 Ejecuta: `scripts/database/db-validate.sh`

### PostgreSQL no responde, ¿qué hago?
👉 Ver: [DATABASE-SETUP.md](DATABASE-SETUP.md) - Sección "Troubleshooting"

### ¿Cómo configuro backups?
👉 Ver: [scripts/database/README-DEPLOYMENT.md](scripts/database/README-DEPLOYMENT.md) - Sección "Backups"

---

## 🔗 Enlaces Rápidos

- **Inicio Rápido:** [QUICKSTART.md](QUICKSTART.md)
- **Setup Completo:** [DATABASE-SETUP.md](DATABASE-SETUP.md)
- **Deployment:** [scripts/database/README-DEPLOYMENT.md](scripts/database/README-DEPLOYMENT.md)
- **Scripts:** [scripts/database/](scripts/database/)
- **Templates:** [.env.dev.example](.env.dev.example), [.env.prod.example](.env.prod.example)

---

## 🎯 Resumen Ejecutivo

Este proyecto proporciona:

✅ **Inicialización automatizada** de base de datos desde cero
✅ **Generación automática** de credenciales seguras
✅ **Soporte para múltiples ambientes** (dev/prod)
✅ **354 archivos SQL** con esquemas completos
✅ **Datos iniciales** (usuarios, módulos, ejercicios)
✅ **Validación automática** post-instalación
✅ **Documentación completa** con ejemplos
✅ **Scripts idempotentes** (se pueden ejecutar múltiples veces)

**Script principal:** `scripts/database/00-init-database-from-scratch.sh`

**Documentación principal:** [QUICKSTART.md](QUICKSTART.md)

---

¿Listo para empezar? 👉 [QUICKSTART.md](QUICKSTART.md)
