# Base de Datos KlarensLait

Scripts SQL para **PostgreSQL 16 o superior**, desarrollados a partir del esquema relacional (`docs/06-esquema-relacional.md`) y el diccionario de datos (`docs/07-diccionario-de-datos.md`).

---

## 📁 Estructura del Directorio

```
sql/
├── README.md
├── migrations/                     # Scripts DDL de creación de tablas (orden numérico)
│   ├── 001_crear_proveedor.sql
│   ├── 002_crear_silo.sql
│   ├── 003_crear_tanque.sql
│   ├── 004_crear_insumo.sql
│   ├── 005_crear_empleado.sql
│   ├── 006_crear_lote_leche.sql
│   ├── 007_crear_lote_insumo.sql
│   ├── 008_crear_estandar_calidad.sql
│   ├── 009_crear_lote_produccion.sql
│   ├── 010_crear_envasado.sql
│   ├── 011_crear_descarte.sql
│   ├── 012_crear_prueba_calidad.sql
│   ├── 013_crear_almacena.sql
│   ├── 014_crear_uso_tanque.sql
│   ├── 015_crear_consumo_insumo.sql
│   └── 016_crear_asigna.sql
├── seeds/                          # Datos de prueba (DML) con coherencia de negocio
│   ├── 01_semillas_maestras.sql
│   ├── 02_semillas_recepcion.sql
│   ├── 03_semillas_produccion.sql
│   └── 04_semillas_movimientos.sql
└── queries/                        # Bancos de consultas del negocio (Módulo 5)
    ├── 01-banco-consultas-a.sql
    └── 02-banco-consultas-b.sql
```

---

## 🗂️ Detalle de Componentes

### 1. Migraciones (`migrations/`)
Contiene los scripts DDL ordenados cronológicamente respetando la integridad referencial y las dependencias de claves foráneas:

| # | Archivo | Tabla Creada | Descripción |
|---|---|---|---|
| 001 | `001_crear_proveedor.sql` | `proveedor` | Fincas y empresas proveedoras de leche e insumos. |
| 002 | `002_crear_silo.sql` | `silo` | Silos de recepción y acopio para almacenamiento de leche. |
| 003 | `003_crear_tanque.sql` | `tanque` | Tanques de fermentación y mezcla para procesos productivos. |
| 004 | `004_crear_insumo.sql` | `insumo` | Catálogo de insumos (cultivos, pulpas, saborizantes, empaques). |
| 005 | `005_crear_empleado.sql` | `empleado` | Personal operativo, supervisores y técnicos de laboratorio. |
| 006 | `006_crear_lote_leche.sql` | `lote_leche` | Lotes de leche cruda recibidos con dictamen y volumen. |
| 007 | `007_crear_lote_insumo.sql` | `lote_insumo` | Lotes de insumos recibidos con fecha de caducidad y stock. |
| 008 | `008_crear_estandar_calidad.sql` | `estandar_calidad` | Parámetros y rangos normativos por producto y etapa. |
| 009 | `009_crear_lote_produccion.sql` | `lote_produccion` | Lotes de elaboración de productos lácteos (ej. Yogurt). |
| 010 | `010_crear_envasado.sql` | `envasado` | Empaque del producto en presentaciones y destinos de despacho. |
| 011 | `011_crear_descarte.sql` | `descarte` | Registro de mermas y descartes de producción con causas. |
| 012 | `012_crear_prueba_calidad.sql` | `prueba_calidad` | Evaluaciones fisicoquímicas, microbiológicas y sensoriales. |
| 013 | `013_crear_almacena.sql` | `almacena` | Entradas y salidas de leche cruda en silos de acopio/recepción. |
| 014 | `014_crear_uso_tanque.sql` | `uso_tanque` | Asignación y tiempos de uso de tanques en lotes de producción. |
| 015 | `015_crear_consumo_insumo.sql` | `consumo_insumo` | Insumos consumidos en cada lote de producción. |
| 016 | `016_crear_asigna.sql` | `asigna` | Asignación de leche desde silos hacia tanques de producción. |

### 2. Semillas de Datos (`seeds/`)
Pueblan la base de datos con casos de prueba diseñados para validar las reglas de negocio (casos aprobados, rechazados, en proceso, estados operativos y movimientos físicos):

| Archivo | Tablas Pobladas | Propósito de los Datos |
|---|---|---|
| `01_semillas_maestras.sql` | `proveedor`, `silo`, `tanque`, `insumo`, `empleado`, `estandar_calidad` | Entidades maestras e infraestructura con estados operativos consistentes (`Operativo`, `En_mantenimiento`) y parámetros normativos vigentes e históricos. |
| `02_semillas_recepcion.sql` | `lote_leche`, `lote_insumo` | Recepción de materia prima con diversos dictámenes (Aprobado, Rechazado) y estados de caducidad/stock. |
| `03_semillas_produccion.sql` | `lote_produccion`, `prueba_calidad`, `envasado` | Lotes procesados, mediciones de laboratorio (dentro y fuera de norma: Aprobado, Reproceso, Rechazado) y registros de empaque. |
| `04_semillas_movimientos.sql` | `almacena`, `uso_tanque`, `consumo_insumo`, `asigna`, `descarte` | Trazabilidad física: transferencias silo-tanque, uso de reactivos, mermas y descartes. |

### 3. Banco de Consultas (`queries/`)
Contiene 14 consultas de negocio organizadas en dos archivos correspondientes al Módulo 5 del proyecto:

* **`01-banco-consultas-a.sql` (Consultas 1 a 7)**:
  1. Proveedores activos (tipo `Finca` o `Empresa`).
  2. Silos de acopio operativos (`Operativo`).
  3. Lotes de leche pendientes de dictamen microbiológico (`Pendiente` y `Recibido`).
  4. Lotes de producción de yogurt en proceso (`En_proceso`).
  5. Estándares normativos vigentes para la etapa de recepción.
  6. Insumos activos de categoría (`Cultivo_lactico`, `Pulpa_fruta`).
  7. Registros de envasado abiertos con presentaciones específicas (`Bolsa_150g`, `Botella_1l`).

* **`02-banco-consultas-b.sql` (Consultas 8 a 14)**:
  1. Empleados activos por cargo y rol operativo (`Operador_tanque`, `Tecnico_calidad`).
  2. Tanques en mantenimiento o fuera de servicio (`En_mantenimiento`, `Fuera_de_servicio`).
  3. Lotes de insumo próximos a caducar y con bajo stock disponible.
  4. Registros de descarte y mermas significativas (`volumen_descartado > 100.00`).
  5. Registros de uso de tanque actualmente activos en planta (`estado_uso = 'Activo'`).
  6. Pruebas de calidad aprobadas en planta con valores obtenidos reales.
  7. Destinos de envasado canalizados a clientes masivos (`Mayorista`, `Minorista`).

---

## 🛠️ Guía de Ejecución Manual Paso a Paso

Esta guía detalla el procedimiento para crear y poblar la base de datos de manera manual utilizando un cliente visual de PostgreSQL (como **pgAdmin 4**, **DBeaver** o la herramienta de administración de su preferencia).

---

### Paso 1: Crear la base de datos vacía

1. Abra su cliente de base de datos (por ejemplo, **pgAdmin** o **DBeaver**) y conéctese a su servidor PostgreSQL local.
2. En el panel lateral de navegación, haga clic derecho sobre el nodo **Databases** (Bases de datos) y seleccione **Create** > **Database...** (Crear > Base de datos).
3. Ingrese el nombre de la base de datos: `klarenslait`.
4. En las opciones de definición o configuración:
   - Asegúrese de que la codificación (**Encoding**) esté establecida en **UTF-8**.
   - Verifique que el propietario (**Owner**) sea su usuario administrativo (por ejemplo, `postgres`).
5. Haga clic en **Save** (Guardar) para crear la base de datos vacía.

---

### Paso 2: Conectarse a la nueva base de datos

1. En el árbol de navegación del cliente, ubique y seleccione la base de datos recién creada: `klarenslait`.
2. Abra una ventana del editor de consultas (**Query Tool** / **Editor SQL**).
3. Verifique que la conexión activa en la barra superior del editor apunte expresamente a `klarenslait` (y no a la base de datos por defecto `postgres`).

---

### Paso 3: Ejecutar las migraciones en orden numérico (DDL)

Las migraciones crean las tablas y definen las restricciones de clave foránea (`FOREIGN KEY`). Debido a las dependencias relacionales, **deben ejecutarse estrictamente una por una en orden numérico ascendente**:

1. En el editor de consultas, abra el primer archivo de la carpeta `sql/migrations/` (o copie y pegue su contenido completo).
2. Ejecute el script (presionando la tecla `F5` o el botón de ejecución ▶).
3. Compruebe en el panel inferior de mensajes que la transacción finalizó satisfactoriamente (`Query returned successfully` / `COMMIT`).
4. Repita este procedimiento abriendo y ejecutando uno a uno los 16 archivos en la siguiente secuencia:

   1. `001_crear_proveedor.sql`
   2. `002_crear_silo.sql`
   3. `003_crear_tanque.sql`
   4. `004_crear_insumo.sql`
   5. `005_crear_empleado.sql`
   6. `006_crear_lote_leche.sql` *(depende de proveedor)*
   7. `007_crear_lote_insumo.sql` *(depende de insumo y proveedor)*
   8. `008_crear_estandar_calidad.sql`
   9. `009_crear_lote_produccion.sql` *(depende de empleado)*
   10. `010_crear_envasado.sql` *(depende de lote_produccion)*
   11. `011_crear_descarte.sql` *(depende de lote_produccion)*
   12. `012_crear_prueba_calidad.sql` *(depende de lote_produccion, lote_leche, empleado y estandar_calidad)*
   13. `013_crear_almacena.sql` *(depende de lote_leche y silo)*
   14. `014_crear_uso_tanque.sql` *(depende de tanque y lote_produccion)*
   15. `015_crear_consumo_insumo.sql` *(depende de lote_insumo y lote_produccion)*
   16. `016_crear_asigna.sql` *(depende de silo, tanque y lote_produccion)*

---

### Paso 4: Verificar la creación de las tablas

1. En el panel lateral del cliente, despliegue la ruta:  
   `klarenslait` > **Schemas** (Esquemas) > **public** > **Tables** (Tablas).
2. Haga clic derecho sobre **Tables** y elija la opción **Refresh** (Actualizar / Refrescar).
3. Confirme visualmente que se listen las **16 tablas** del sistema:
   * `almacena`
   * `asigna`
   * `consumo_insumo`
   * `descarte`
   * `empleado`
   * `envasado`
   * `estandar_calidad`
   * `insumo`
   * `lote_insumo`
   * `lote_leche`
   * `lote_produccion`
   * `proveedor`
   * `prueba_calidad`
   * `silo`
   * `tanque`
   * `uso_tanque`

---

### Paso 5: Cargar las semillas de datos de prueba (DML)

Con la estructura de tablas completa, proceda a cargar los datos de prueba. Por integridad referencial, las semillas también deben ejecutarse una por una en orden secuencial:

1. Abra una pestaña del editor de consultas (**Query Tool**) sobre la base de datos `klarenslait`.
2. Abra y ejecute los 4 archivos de la carpeta `sql/seeds/` en el siguiente orden:

   1. **`01_semillas_maestras.sql`**:  
      Inserta las entidades maestras base (`proveedor`, `silo`, `tanque`, `insumo`, `empleado` y `estandar_calidad`).
   2. **`02_semillas_recepcion.sql`**:  
      Inserta las materias primas recibidas (`lote_leche` y `lote_insumo`).
   3. **`03_semillas_produccion.sql`**:  
      Inserta lotes de elaboración (`lote_produccion`), resultados de laboratorio (`prueba_calidad`) y despachos (`envasado`).
   4. **`04_semillas_movimientos.sql`**:  
      Inserta la trazabilidad de operaciones: transferencias de leche (`almacena`), ocupación de tanques (`uso_tanque`), reactivos e insumos usados (`consumo_insumo`), asignaciones a producción (`asigna`) y mermas (`descarte`).

3. En cada ejecución, verifique en la pestaña de mensajes que las sentencias `INSERT` finalicen sin errores.

---

### Paso 6: Ejecutar y validar las consultas de negocio

Para consultar la información y validar que los datos respondan a los requerimientos del proyecto:

1. **Consultas Parte A (`01-banco-consultas-a.sql`)**:
   - Abra el archivo en el editor SQL.
   - Puede seleccionar cada consulta individualmente o ejecutar el script para visualizar las salidas en la cuadrícula de datos (*Data Output*).
   - Valide los filtros de proveedores activos, silos operativos, lotes pendientes de dictamen microbiológico y parámetros de recepción vigentes.

2. **Consultas Parte B (`02-banco-consultas-b.sql`)**:
   - Abra el archivo en el editor SQL.
   - Ejecute las consultas para verificar empleados por rol técnico/operador, tanques en mantenimiento, lotes de insumos próximos a caducar con stock reducido, descartes significativos, usos de tanque activos y canales de despacho mayorista/minorista.

---

## 📌 Reglas de Oro y Convenciones

1. **Inmutabilidad de Migraciones**: Una migración que ya ha sido versionada o aplicada en un entorno compartido no se edita. Si se requiere modificar la estructura, se crea una nueva migración con el siguiente consecutivo numérico (por ejemplo, `017_...sql`).
2. **Uso de Transacciones**: Cada migración está delimitada por bloques `BEGIN;` y `COMMIT;` para asegurar atomicidad (si falla alguna instrucción, se revierten todos los cambios del archivo).
3. **Manejo de Tiempos con Zona Horaria**: Todos los campos temporales utilizan `TIMESTAMPTZ` configurados para la zona horaria colombiana (`America/Bogota`, UTC-5).
4. **Detención ante Errores**: Si al ejecutar manualmente un script se produce un error, resuelva la causa antes de continuar; no ejecute scripts posteriores si uno anterior falló, ya que las claves foráneas y la coherencia de datos quedarían comprometidas.
