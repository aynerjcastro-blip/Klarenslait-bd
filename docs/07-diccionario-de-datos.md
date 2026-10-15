# Diccionario de datos — KlarensLait

**Proyecto:** KlarensLait — Trazabilidad de producción láctea
**Motor:** PostgreSQL 16+
**Fuentes:** esquema relacional (`docs/06`), diagrama EER, supuestos y reglas de negocio (`docs/03`).

## 1. Convenciones

- Nombres de tablas y columnas en `snake_case`.
- Llaves primarias numéricas: `INTEGER` generado automáticamente (`GENERATED ALWAYS AS IDENTITY`). Se abrevian como "INTEGER (identity)".
- Fechas con hora: `TIMESTAMPTZ`. Solo fecha: `DATE`.
- Volúmenes en litros: `NUMERIC(12,2)`. Cantidades de insumos: `NUMERIC(12,3)`.
- Todas las llaves foráneas usan `ON DELETE RESTRICT`: no se puede borrar un registro al que otro hace referencia (apoya RN-08).
- **Clave:** PK = llave primaria; FK = llave foránea (se indica la tabla de destino); UK = valor único.
- **¿Nulo?:** NO = obligatorio (`NOT NULL`); SÍ = puede quedar vacío.
- **Dato derivado:** columna que se puede calcular desde otras tablas y se conserva para consultar el estado al instante (ver sección 5).
- **Dato personal:** columna que identifica o permite contactar a una persona (ver sección 6).
- **†** Valor propuesto en este diccionario; aún no está definido en otro documento del proyecto.

## 2. Índice de tablas

| Tabla | Descripción |
|---|---|
| `proveedor` | Quien suministra leche cruda y otros insumos a la planta. |
| `lote_leche` | Cantidad identificable de leche cruda recibida de un proveedor. |
| `silo` | Contenedor de recepción y acopio de leche cruda. |
| `tanque` | Equipo donde se procesa un lote (fermentación o mezcla). |
| `insumo` | Catálogo de tipos de materia prima adicional (cultivos, pulpas, saborizantes). |
| `lote_insumo` | Recepción concreta de un insumo, con cantidad y fecha de caducidad. |
| `empleado` | Persona que interviene en la producción. |
| `lote_produccion` | Unidad trazable de producto elaborado en un ciclo de producción. |
| `estandar_calidad` | Límites permitidos de un parámetro, por producto y etapa. |
| `prueba_calidad` | Registro de una medición o análisis de calidad. |
| `envasado` | Registro del empaque final de un lote aprobado. |
| `descarte` | Registro del descarte de un lote de producción. |
| `almacena` | Movimientos de leche de un lote hacia o desde un silo. |
| `ocupa` | Uso de un tanque por un lote, con inicio y fin. |
| `consume` | Consumo de un lote de insumo en un lote de producción. |
| `asigna` | Transferencia de leche desde un silo a un tanque para un lote de producción. |

## 3. Tablas de entidades

### 3.1. `proveedor`

Persona, finca o empresa que suministra leche cruda y otros insumos a la planta.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_proveedor` | INTEGER (identity) | NO | PK | Identificador interno del proveedor. | Generado automáticamente. |
| `nombre` | VARCHAR(120) | NO | | Nombre de la finca, empresa o persona. Dato personal cuando es persona natural. | |
| `ubicacion` | VARCHAR(150) | NO | | Lugar de origen del suministro (vereda y municipio); permite rastrear la procedencia de la leche. | |
| `telefono` | VARCHAR(20) | SÍ | | Teléfono de contacto. Dato personal. | |
| `tipo_proveedor` | VARCHAR(10) | NO | | Naturaleza del proveedor. | `persona`, `finca`, `empresa` † |
| `identificacion` | VARCHAR(20) | NO | UK | Cédula o NIT del proveedor. Dato personal cuando es persona natural. | Única. |
| `estado` | VARCHAR(10) | NO | | Indica si el proveedor está habilitado para suministrar. | `activo`, `inactivo` †. Por defecto `activo`. |

### 3.2. `lote_leche`

Cantidad identificable de leche cruda recibida de un proveedor, con su dictamen microbiológico.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_lote_leche` | INTEGER (identity) | NO | PK | Identificador interno del lote de leche. | Generado automáticamente. |
| `codigo` | VARCHAR(30) | NO | UK | Código con el que se identifica el lote en la planta. | Único. |
| `fecha_recepcion` | TIMESTAMPTZ | NO | | Fecha y hora en que llegó la leche. Desde esta fecha corre el plazo de conservación de sus pruebas (RN-08). | |
| `volumen_inicial_litros` | NUMERIC(12,2) | NO | | Litros recibidos. | Mayor que 0. |
| `volumen_disponible_litros` | NUMERIC(12,2) | NO | | Litros que aún quedan del lote. **Dato derivado:** volumen inicial menos las salidas registradas en `almacena`. | Entre 0 y `volumen_inicial_litros`. |
| `dictamen_microbiologico` | VARCHAR(10) | NO | | Resultado del control microbiológico de la leche. **Dato derivado** de las pruebas microbiológicas del lote (supuesto 24). Solo la leche `aprobado` ingresa al silo (RN-01). | `pendiente`, `aprobado`, `rechazado`. Por defecto `pendiente`. |
| `estado_lote` | VARCHAR(10) | NO | | Situación actual de la leche. | `recibido`, `disponible`, `agotado`, `rechazado`. Por defecto `recibido`. `disponible` exige dictamen `aprobado`; dictamen `rechazado` implica estado `rechazado`. |
| `id_proveedor` | INTEGER | NO | FK → `proveedor` | Proveedor que entregó el lote. Un lote tiene exactamente un proveedor. | |

### 3.3. `silo`

Contenedor físico de recepción y acopio de leche cruda.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_silo` | INTEGER (identity) | NO | PK | Identificador interno del silo. | Generado automáticamente. |
| `codigo` | VARCHAR(20) | NO | UK | Código del silo en la planta (la planta tiene 6). | Único. |
| `tipo_silo` | VARCHAR(10) | NO | | Función del silo. | `recepcion`, `acopio` † |
| `capacidad_maxima` | NUMERIC(12,2) | NO | | Litros que puede almacenar. | Mayor que 0. |
| `volumen_actual` | NUMERIC(12,2) | NO | | Litros que contiene en este momento. **Dato derivado:** entradas menos salidas en `almacena`. | Entre 0 y `capacidad_maxima`. Por defecto 0. |
| `estado_operativo` | VARCHAR(20) | NO | | Si el silo puede recibir leche. | `operativo`, `en_mantenimiento`, `fuera_de_servicio` † |

### 3.4. `tanque`

Equipo físico donde se procesa un lote de producción; puede ser de fermentación o de mezcla.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_tanque` | INTEGER (identity) | NO | PK | Identificador interno del tanque. | Generado automáticamente. |
| `codigo` | VARCHAR(20) | NO | UK | Código del tanque en la planta. | Único. |
| `tipo_tanque` | VARCHAR(15) | NO | | Función del tanque. El de mezcla es el tanque secundario donde se añade el sabor (supuesto 2). | `fermentacion`, `mezcla` † |
| `capacidad_maxima` | NUMERIC(12,2) | NO | | Litros que puede contener. No puede superarse con las asignaciones de leche (RN-07). | Mayor que 0. |
| `volumen_actual` | NUMERIC(12,2) | NO | | Litros que contiene en este momento. **Dato derivado:** lo recibido en `asigna` menos lo que ya salió. | Entre 0 y `capacidad_maxima`. Por defecto 0. |
| `estado_operativo` | VARCHAR(20) | NO | | Si el tanque puede usarse. | `operativo`, `en_mantenimiento`, `fuera_de_servicio` † |

### 3.5. `insumo`

Catálogo de tipos de materia prima adicional que se usa en la producción.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_insumo` | INTEGER (identity) | NO | PK | Identificador interno del tipo de insumo. | Generado automáticamente. |
| `codigo` | VARCHAR(30) | NO | UK | Código del insumo en el catálogo. | Único. |
| `categoria_insumo` | VARCHAR(20) | NO | | Familia a la que pertenece el insumo. | `cultivo_lactico`, `pulpa_fruta`, `saborizante`, `material_empaque` † |
| `unidad_medida` | VARCHAR(10) | NO | | Unidad en que se mide este insumo. Es propia de cada insumo, no de la categoría. | `kg`, `g`, `l`, `ml`, `unidad` † |
| `estado` | VARCHAR(10) | NO | | Si el insumo se sigue usando. | `activo`, `inactivo` †. Por defecto `activo`. |

### 3.6. `lote_insumo`

Recepción concreta de un insumo, con su cantidad y su fecha de caducidad.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_lote_insumo` | INTEGER (identity) | NO | PK | Identificador interno del lote de insumo. | Generado automáticamente. |
| `codigo_lote_insumo` | VARCHAR(30) | NO | UK | Código del lote que trae el insumo. | Único. |
| `cantidad_inicial` | NUMERIC(12,3) | NO | | Cantidad recibida, en la unidad del insumo. | Mayor que 0. |
| `cantidad_disponible` | NUMERIC(12,3) | NO | | Cantidad que aún queda sin consumir. **Dato derivado:** inicial menos la suma de `consume.cantidad_consumida` (RN-10). | Entre 0 y `cantidad_inicial`. |
| `fecha_recepcion` | DATE | NO | | Día en que llegó el lote. | |
| `fecha_caducidad` | DATE | NO | | Último día en que puede consumirse (RN-02). | Mayor o igual que `fecha_recepcion`. |
| `estado` | VARCHAR(12) | NO | | Situación actual del lote de insumo. | `disponible`, `agotado`, `vencido` †. Por defecto `disponible`. |
| `id_insumo` | INTEGER | NO | FK → `insumo` | Tipo de insumo al que corresponde el lote. | |
| `id_proveedor` | INTEGER | NO | FK → `proveedor` | Proveedor que entregó el lote. Un lote de insumo tiene exactamente un proveedor (supuesto 25). | |

### 3.7. `empleado`

Persona que interviene en la producción como operador, técnico de calidad o supervisor.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_empleado` | INTEGER (identity) | NO | PK | Identificador interno del empleado. | Generado automáticamente. |
| `nombre` | VARCHAR(120) | NO | | Nombre completo. Dato personal. | |
| `cargo` | VARCHAR(20) | NO | | Función que cumple; determina qué puede registrar (RN-09). | `Operador de tanque`, `Técnico de calidad`, `Supervisor` |
| `identificacion` | VARCHAR(20) | NO | UK | Cédula del empleado. Dato personal. | Única. |
| `estado_vinculacion` | VARCHAR(10) | NO | | Si el empleado sigue vinculado. No se borra al retirarse; se marca inactivo para conservar la trazabilidad (supuesto 10). | `activo`, `inactivo` †. Por defecto `activo`. |

### 3.8. `lote_produccion`

Unidad trazable de producto elaborado durante un ciclo de producción.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_lote_produccion` | INTEGER (identity) | NO | PK | Identificador interno del lote. | Generado automáticamente. |
| `codigo` | VARCHAR(30) | NO | UK | Código del lote que se imprime y se sigue en la planta. | Único. |
| `tipo_produccion` | VARCHAR(10) | NO | | Producto que se elabora. | `yogurt`, `queso`, `suero`, `avena`, `leche_uht` |
| `volumen_planificado_litros` | NUMERIC(12,2) | NO | | Litros que se planea producir. | Mayor que 0. |
| `volumen_producido_litros` | NUMERIC(12,2) | SÍ | | Litros realmente producidos; vacío mientras el lote está en proceso. | Mayor o igual que 0. |
| `fecha_hora_inicio` | TIMESTAMPTZ | NO | | Momento en que comienza la elaboración. | |
| `fecha_hora_fin` | TIMESTAMPTZ | SÍ | | Momento en que termina la elaboración (fin de fermentación y mezcla); vacío mientras está en proceso. No es la fecha de cierre del lote (ver Módulo 3, sección 1.3). | Mayor o igual que `fecha_hora_inicio`. |
| `estado` | VARCHAR(12) | NO | | Situación del lote en su ciclo de vida. | `en_proceso`, `aprobado`, `rechazado`, `envasado`, `descartado`. Por defecto `en_proceso`. Solo se envasa un lote `aprobado` (RN-03). **Dato derivado en parte** de las pruebas, el envasado y el descarte. |
| `id_empleado` | INTEGER | NO | FK → `empleado` | Supervisor responsable del lote durante todo su ciclo, sin historial (supuestos 9 y 22). | |

### 3.9. `estandar_calidad`

Límites permitidos de un parámetro de calidad para un producto y una etapa. Las pruebas no guardan sus límites: referencian un estándar (supuesto 26).

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_estandar_calidad` | INTEGER (identity) | NO | PK | Identificador interno del estándar. | Generado automáticamente. |
| `parametro` | VARCHAR(15) | NO | | Magnitud que se mide. | `ph`, `temperatura`, `acidez_dornic`, `grasa`, `viscosidad`, `microorganismos` |
| `producto` | VARCHAR(12) | NO | | Producto al que aplica el límite. | Los valores de `lote_produccion.tipo_produccion` y `leche_cruda` † |
| `etapa` | VARCHAR(12) | NO | | Momento del proceso en que se mide. | `recepcion`, `fermentacion`, `mezcla`, `envasado` |
| `unidad_medida` | VARCHAR(20) | NO | | Unidad del valor (por ejemplo °C o grados Dornic). | Texto libre controlado † |
| `valor_minimo_permitido` | NUMERIC(10,3) | NO | | Valor más bajo aceptable. | Menor o igual que `valor_maximo_permitido` (RN-04). |
| `valor_maximo_permitido` | NUMERIC(10,3) | NO | | Valor más alto aceptable. | Mayor o igual que `valor_minimo_permitido`. |

### 3.10. `prueba_calidad`

Registro de una medición o análisis de calidad. Pertenece a un lote de producción o a un lote de leche, nunca a ambos.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_prueba_calidad` | INTEGER (identity) | NO | PK | Identificador interno de la prueba. | Generado automáticamente. |
| `fecha_hora` | TIMESTAMPTZ | NO | | Momento en que se tomó la medición. Con la serie de mediciones se calculan las alertas (RN-04). | |
| `tipo_prueba` | VARCHAR(20) | NO | | Clase de prueba. Las de laboratorio las registra solo un Técnico de calidad (RN-09). | `microbiologica`, `fisicoquimica`, `ph_linea`, `temperatura_linea` |
| `valor_obtenido` | NUMERIC(12,4) | NO | | Valor medido, en la unidad del estándar. | |
| `resultado` | VARCHAR(10) | NO | | Dictamen de la prueba. `reproceso` es decisión del técnico y mantiene el lote en proceso. | `aprobado`, `rechazado`, `reproceso` |
| `origen_registro` | VARCHAR(10) | NO | | Quién generó el dato. | `Sensor`, `Operario`. `Sensor` solo con tipos en línea y sin empleado. |
| `id_lote_produccion` | INTEGER | SÍ | FK → `lote_produccion` | Lote de producción al que pertenece la prueba. | Exactamente uno entre este y `id_lote_leche` es no nulo (RN-13). Obligatorio en tipos en línea. |
| `id_lote_leche` | INTEGER | SÍ | FK → `lote_leche` | Lote de leche al que pertenece la prueba. | Ver arriba. |
| `id_empleado` | INTEGER | SÍ | FK → `empleado` | Empleado que registró la prueba; vacío si la generó un sensor. | Nulo si `origen_registro` es `Sensor`; no nulo si es `Operario` (RN-09). |
| `id_estandar_calidad` | INTEGER | NO | FK → `estandar_calidad` | Estándar con el que se evalúa la prueba. | |

### 3.11. `envasado`

Registro del proceso final de empaque de un lote aprobado. Un lote puede tener varios registros (varias presentaciones).

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_envasado` | INTEGER (identity) | NO | PK | Identificador interno del registro de envasado. | Generado automáticamente. |
| `fecha_hora_envasado` | TIMESTAMPTZ | NO | | Momento del envasado. La del último registro es la fecha de cierre del lote. | |
| `presentacion` | VARCHAR(30) | NO | | Empaque utilizado (por ejemplo bolsa de 150 g, botella de 1 L, garrafa). | Texto controlado † |
| `cantidad_envasada` | INTEGER | NO | | Unidades empacadas de esa presentación. | Mayor que 0. |
| `destino` | VARCHAR(15) | NO | | Canal al que se destina el producto (RN-11). | `mayorista`, `minorista`, `venta directa` |
| `temperatura_envasado` | NUMERIC(5,2) | SÍ | | Temperatura del producto al envasar, en °C. | |
| `temperatura_despacho` | NUMERIC(5,2) | SÍ | | Temperatura al salir de la planta, en °C; vacía mientras no se despacha. | |
| `fecha_vencimiento` | DATE | NO | | Fecha límite de consumo del producto. | Posterior a la fecha de `fecha_hora_envasado` (RN-11). |
| `fecha_despacho` | DATE | SÍ | | Día en que el producto sale de la planta; vacía mientras no se despacha. | No anterior a la fecha de `fecha_hora_envasado` (RN-11). |
| `estado` | VARCHAR(10) | NO | | `abierto` mientras se llena esa presentación; `cerrado` al terminarla (supuesto 28). | `abierto`, `cerrado`. Por defecto `abierto`. |
| `id_lote_produccion` | INTEGER | NO | FK → `lote_produccion` | Lote del que proviene el producto. Solo puede envasarse un lote `aprobado` (RN-03). | |

### 3.12. `descarte`

Registro del descarte de un lote de producción. Es una entidad débil: no existe sin su lote.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_descarte` | INTEGER (identity) | NO | PK | Identificador interno del descarte. | Generado automáticamente. |
| `fecha_hora_descarte` | TIMESTAMPTZ | NO | | Momento del descarte. Es la fecha de cierre del lote si fue descartado. | |
| `motivo` | VARCHAR(200) | NO | | Razón del descarte (RN-05). | |
| `volumen_descartado` | NUMERIC(12,2) | NO | | Litros desechados (RN-05). | Mayor que 0. |
| `observaciones` | TEXT | SÍ | | Comentarios adicionales. | |
| `id_lote_produccion` | INTEGER | NO | FK → `lote_produccion`, UK | Lote descartado. Un lote tiene como máximo un descarte. | Único. |

## 4. Tablas intermedias

### 4.1. `almacena`

Movimiento de leche de un lote hacia o desde un silo. Con estos movimientos se calcula qué lotes estaban en un silo en un momento dado (supuesto 19).

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_almacenamiento` | INTEGER (identity) | NO | PK | Identificador interno del movimiento. | Generado automáticamente. |
| `id_lote_leche` | INTEGER | NO | FK → `lote_leche` | Lote de leche que se mueve. Debe tener dictamen `aprobado` para entrar (RN-01). | |
| `id_silo` | INTEGER | NO | FK → `silo` | Silo que recibe o entrega la leche. | |
| `fecha_hora` | TIMESTAMPTZ | NO | | Momento del movimiento. | |
| `tipo_movimiento` | VARCHAR(10) | NO | | Sentido del movimiento. | `entrada`, `salida` † |
| `volumen_litros` | NUMERIC(12,2) | NO | | Litros movidos. | Mayor que 0. |
| `observaciones` | TEXT | SÍ | | Comentarios adicionales. | |

### 4.2. `ocupa`

Uso de un tanque por un lote de producción, con su inicio y su fin. Un lote puede usar varios tanques en secuencia.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_ocupacion` | INTEGER (identity) | NO | PK | Identificador interno del uso. | Generado automáticamente. |
| `id_tanque` | INTEGER | NO | FK → `tanque` | Tanque ocupado. | Un solo uso activo por tanque (RN-06). |
| `id_lote_produccion` | INTEGER | NO | FK → `lote_produccion` | Lote que ocupa el tanque. | |
| `fecha_hora_inicio` | TIMESTAMPTZ | NO | | Momento en que el lote entra al tanque. | |
| `fecha_hora_fin` | TIMESTAMPTZ | SÍ | | Momento en que el lote sale (traslado a mezcla, envasado o descarte); vacía mientras el uso está activo. | Mayor o igual que `fecha_hora_inicio`. |
| `estado_uso` | VARCHAR(10) | NO | | Si el uso sigue en curso. **Dato derivado:** `activo` si `fecha_hora_fin` está vacía. | `activo`, `finalizado` |

### 4.3. `consume`

Consumo, total o parcial, de un lote de insumo en un lote de producción.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_lote_insumo` | INTEGER | NO | PK, FK → `lote_insumo` | Lote de insumo que se consume. | |
| `id_lote_produccion` | INTEGER | NO | PK, FK → `lote_produccion` | Lote de producción que lo usa. | Un registro por pareja de lotes (consumo acumulado). |
| `cantidad_consumida` | NUMERIC(12,3) | NO | | Cantidad usada, en la unidad del insumo. No puede superar la disponible (RN-10). | Mayor que 0. |
| `fecha_hora_consumo` | TIMESTAMPTZ | NO | | Momento del consumo. No puede ser posterior a la caducidad del lote (RN-02). | |

### 4.4. `asigna`

Transferencia de leche desde un silo hacia un tanque para un lote de producción (relación ternaria).

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones |
|---|---|---|---|---|---|
| `id_asignacion` | INTEGER (identity) | NO | PK | Identificador interno de la asignación. | Generado automáticamente. |
| `id_silo` | INTEGER | NO | FK → `silo` | Silo de origen de la leche. | |
| `id_tanque` | INTEGER | NO | FK → `tanque` | Tanque de destino. | |
| `id_lote_produccion` | INTEGER | NO | FK → `lote_produccion` | Lote para el que se asigna la leche. Debe tener un uso activo de ese tanque en `ocupa` (RN-12). | |
| `volumen_asignado_litros` | NUMERIC(12,2) | NO | | Litros transferidos. La suma por lote y tanque no puede superar la capacidad del tanque (RN-07). | Mayor que 0. |
| `fecha_hora_asignacion` | TIMESTAMPTZ | NO | | Momento de la transferencia. Sirve para saber qué lotes de leche estaban en el silo (supuesto 19). | |

## 5. Datos derivados

Estas columnas no rompen ninguna forma normal; se conservan para tener el estado al instante, y el riesgo es que se desincronicen de los movimientos. Se protegen con restricciones `CHECK` ahora y con validaciones automáticas en la Entrega 3.

| Columna | Se calcula desde |
|---|---|
| `lote_leche.volumen_disponible_litros` | Volumen inicial menos las salidas de `almacena` |
| `lote_leche.dictamen_microbiologico` | Pruebas microbiológicas del lote en `prueba_calidad` |
| `lote_leche.estado_lote` | Dictamen y volumen disponible |
| `silo.volumen_actual` | Entradas y salidas de `almacena` |
| `tanque.volumen_actual` | Asignaciones en `asigna` |
| `lote_insumo.cantidad_disponible` | Cantidad inicial menos lo consumido en `consume` |
| `lote_produccion.estado` | Pruebas, envasado y descarte del lote (en parte) |
| `ocupa.estado_uso` | `ocupa.fecha_hora_fin` |

## 6. Datos personales y medidas de protección

| Columna | Por qué es dato personal | Medida que lo protege |
|---|---|---|
| `proveedor.nombre` | Identifica a la persona cuando el proveedor es persona natural. | Excluida de la vista del rol de análisis; acceso solo para el rol de la aplicación. |
| `proveedor.identificacion` | Cédula o NIT de una persona natural. | Excluida de la vista de análisis. |
| `proveedor.telefono` | Permite contactar a una persona. | Excluida de la vista de análisis. |
| `empleado.nombre` | Identifica a una persona. | La vista de análisis muestra solo `id_empleado` y `cargo`. |
| `empleado.identificacion` | Cédula de una persona. | Excluida de la vista de análisis. |

Además: los datos de ejemplo del repositorio son ficticios y no contienen personas reales; las credenciales de conexión no se guardan en el repositorio.

## 7. Nota de verificación contra el esquema implementado

Este diccionario se construyó con el esquema relacional de `docs/06` y los cambios acordados en las correcciones del Módulo 3. Antes de la entrega, comparar con el DDL real (`\d+ tabla` en `psql`) y confirmar o ajustar:

1. `prueba_calidad`: se asumió que ya no tiene `parametro_medido`, `unidad_medida`, `valor_minimo_permitido` ni `valor_maximo_permitido` (pasaron a `estandar_calidad`) y que tiene `id_estandar_calidad`.
2. `estandar_calidad`: columnas, longitudes y que no tiene `UNIQUE (parametro, producto, etapa)` porque un cambio de límite crea un estándar nuevo (supuesto 26). Falta definir cómo se sabe cuál estándar es el vigente.
3. `estandar_calidad.producto`: incluye `leche_cruda`, valor que todavía no aparece en el Módulo 3 (sección 1.6).
4. `envasado.estado`, `envasado.fecha_vencimiento` y `envasado.fecha_despacho`: nombres y tipos.
5. `lote_insumo.id_proveedor` (relación `PROVEE`).
6. Valores marcados con † y longitudes y precisiones de los tipos.
