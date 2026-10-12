# Base de datos KlarensLait

Scripts SQL para PostgreSQL 16 o superior. Salen del esquema relacional (`docs/06-esquema-relacional.md`) y de los módulos 3 y 4 del análisis.

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
    ├── 006_crear_lote_leche.sql      (depende de 001)
    └── 007_crear_lote_insumo.sql     (depende de 001 y 004)
```

Las migraciones se ejecutan en orden numérico sobre una base de datos vacía. Cada archivo corre dentro de su propia transacción (`BEGIN` / `COMMIT`): si algo falla, ese archivo no deja nada a medias.

## Requisitos

- PostgreSQL 16 o superior.
- El cliente `psql` en el PATH.
- Un usuario con permiso para crear bases de datos.

## Paso a paso

### 1. Crear la base de datos vacía

```bash
createdb -U postgres klarenslait
```

O desde `psql`:

```sql
CREATE DATABASE klarenslait;
```

### 2. Ejecutar las migraciones en orden

Linux, macOS o Git Bash en Windows, desde la raíz del repositorio:

```bash
for f in sql/migrations/*.sql; do
  echo "Aplicando $f"
  psql -U postgres -d klarenslait -v ON_ERROR_STOP=1 -f "$f" || break
done
```

`ON_ERROR_STOP=1` hace que `psql` se detenga en el primer error, y `|| break` corta el ciclo para no seguir con las migraciones siguientes.

Si prefieres ejecutarlas una por una:

```bash
psql -U postgres -d klarenslait -v ON_ERROR_STOP=1 -f sql/migrations/001_crear_proveedor.sql
psql -U postgres -d klarenslait -v ON_ERROR_STOP=1 -f sql/migrations/002_crear_silo.sql
# ... y así hasta la 007
```

### 3. Verificar

```bash
psql -U postgres -d klarenslait -c "\dt"
```

Deben aparecer 7 tablas: `proveedor`, `silo`, `tanque`, `insumo`, `empleado`, `lote_leche` y `lote_insumo`.

Para ver las restricciones de una tabla:

```bash
psql -U postgres -d klarenslait -c "\d lote_insumo"
```

### Empezar de cero

Si necesitas reconstruir la base en tu máquina local, bórrala y repite los pasos 1 y 2:

```bash
dropdb -U postgres klarenslait
createdb -U postgres klarenslait
```

## Regla de oro

**Una migración que ya se aplicó no se edita.** Si hay un error o hace falta un cambio, se crea una migración nueva con el siguiente número (por ejemplo `008_agregar_columna_x.sql`) que lo corrija con `ALTER TABLE`. Así todos los integrantes del equipo terminan con la misma estructura al ejecutar los scripts en orden.

## Nombres

Los nombres de tablas y columnas son los del Módulo 4, escritos en `snake_case` y sin tildes porque PostgreSQL pone en minúsculas lo que no va entre comillas.

| Módulo 4 | SQL |
|---|---|
| LoteLeche, LoteInsumo | `lote_leche`, `lote_insumo` |
| idProveedor, idLoteLeche | `id_proveedor`, `id_lote_leche` |
| proveedorOrigen | `proveedor_origen` |
| volumenInicialLitros | `volumen_inicial_litros` |
| unidadDeMedida | `unidad_de_medida` |

## Convenciones

| Elemento | Convención | Ejemplo |
|---|---|---|
| Llave primaria | `pk_<tabla>` | `pk_silo` |
| Llave foránea | `fk_<tabla>_<tabla_referenciada>` | `fk_lote_leche_proveedor` |
| Unicidad | `uq_<tabla>_<columna>` | `uq_silo_codigo` |
| Regla CHECK | `ck_<tabla>_<regla>` | `ck_silo_capacidad_positiva` |
| Índice | `ix_<tabla>_<columna>` | `ix_lote_leche_proveedor_origen` |

Tipos: `NUMERIC` para volúmenes y cantidades, `TIMESTAMPTZ` para fecha y hora, `DATE` para fechas sin hora (recepción y caducidad de insumos) y `BIGINT GENERATED ALWAYS AS IDENTITY` para las llaves primarias.

Todas las llaves foráneas usan `ON DELETE RESTRICT`. El Módulo 3 exige conservar lotes, pruebas y responsables (supuestos 10 y 17, RN-08): un proveedor, un insumo o un empleado con registros no se borra, se desactiva con su campo de estado.

## Reglas que valida la base de datos

| Tabla | Regla | Origen |
|---|---|---|
| `silo`, `tanque` | `capacidad_maxima > 0`; `volumen_actual` entre 0 y `capacidad_maxima` | RN-07 |
| `lote_leche` | `dictamen_microbiologico`: pendiente, aprobado, rechazado | Módulo 3 (1.2) |
| `lote_leche` | `estado_lote`: recibido, disponible, agotado, rechazado | Módulo 3 (1.2) |
| `lote_leche` | Disponible exige dictamen aprobado y litros; dictamen rechazado implica estado rechazado; agotado implica 0 litros | Módulo 3 (1.2) |
| `lote_leche` | `volumen_inicial_litros > 0`; `volumen_disponible_litros` entre 0 y el inicial | Módulo 3 |
| `lote_insumo` | `cantidad_inicial > 0`; `cantidad_disponible` entre 0 y la inicial | RN-10 |
| `lote_insumo` | `fecha_caducidad` posterior a `fecha_recepcion` | RN-02 |
| `empleado` | `cargo`: Operador de tanque, Técnico de calidad, Supervisor | Módulo 3 (1.5) |
| Todas | `UNIQUE` en códigos (silo, tanque, insumo, lote de leche, lote de insumo) e identificaciones (proveedor, empleado) | Entrega |

## Pendiente del diccionario de datos

Estos campos tienen `NOT NULL` pero **sin `CHECK` de dominio**, porque ningún módulo entregado define sus valores. Cuando el diccionario los defina, se agregan con una migración nueva (008 en adelante), nunca editando las existentes.

| Tabla | Columnas |
|---|---|
| `proveedor` | `tipo_proveedor`, `estado` |
| `silo` | `tipo_silo`, `estado_operativo` |
| `tanque` | `tipo_tanque`, `estado_operativo` |
| `insumo` | `categoria_insumo`, `unidad_de_medida`, `estado` |
| `empleado` | `estado_vinculacion` |
| `lote_insumo` | `estado` |

## Pendientes de la siguiente parte

Las tablas que dependen de producción (`estandar_calidad`, `lote_produccion`, `envasado`, `prueba_calidad`, `descarte`, `almacena`, `uso_tanque`, `consumo_insumo`, `asigna`) se crean en las migraciones 008 en adelante.
