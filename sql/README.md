# Base de datos KlarensLait

Scripts SQL para PostgreSQL 16 o superior, a partir del esquema relacional (`docs/06-esquema-relacional.md`).

## Estructura

```
sql/
├── README.md
└── migrations/
    ├── 001_crear_proveedor.sql
    ├── 002_crear_silo.sql
    ├── 003_crear_tanque.sql
    ├── 004_crear_insumo.sql
    ├── 005_crear_empleado.sql
    ├── 006_crear_lote_leche.sql
    └── 007_crear_lote_insumo.sql
```

Las migraciones se ejecutan en orden numérico sobre una base de datos vacía.

## Paso a paso

### 1. Crear la base de datos vacía

```bash
createdb -U postgres klarenslait
```

### 2. Ejecutar las migraciones en orden

Desde la raíz del repositorio:

```bash
for f in sql/migrations/*.sql; do
  echo "Aplicando $f"
  psql -U postgres -d klarenslait -v ON_ERROR_STOP=1 -f "$f" || break
done
```

### 3. Verificar

```bash
psql -U postgres -d klarenslait -c "\dt"
```

Deben aparecer 7 tablas: Proveedor, Silo, Tanque, Insumo, Empleado, LoteLeche y LoteInsumo.

## Regla de oro

Una migración que ya se aplicó no se edita. Si hay un error, se corrige con una migración nueva (por ejemplo `008_...sql`).
