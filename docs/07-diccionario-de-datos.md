# Diccionario de datos — KlarensLait

**Proyecto:** KlarensLait — Trazabilidad de producción láctea
**Motor:** PostgreSQL 16+
**Fuentes:** esquema relacional (`docs/06`), diagrama EER, supuestos y reglas de negocio (`docs/03`). Los nombres de tablas y columnas son los del Módulo 6.

## 1. Convenciones

- Nombres de tablas y columnas en `snake_case`.
- Llaves primarias numéricas: `INTEGER` generado automáticamente (`GENERATED ALWAYS AS IDENTITY`). Se abrevian como "INTEGER (identity)".
- Fechas con hora: `TIMESTAMPTZ`. Solo fecha: `DATE`.
- Volúmenes en litros: `NUMERIC(12,2)`. Cantidades de insumos: `NUMERIC(12,3)`. Valores medidos y límites de calidad: `NUMERIC(12,4)`.
- Todas las llaves foráneas usan `ON DELETE RESTRICT`: no se puede borrar un registro al que otro hace referencia (apoya RN-08). El detalle de políticas está en `docs/06`, sección 7.
- **Clave:** PK = llave primaria; FK = llave foránea, escrita como `tabla(columna)` de destino; UK = valor único.
- **¿Nulo?:** NO = obligatorio (`NOT NULL`); SÍ = puede quedar vacío.
- **Ejemplo:** valor ficticio y realista; no corresponde a personas ni datos reales.
- **Dato de estado / dato derivado:** ver sección 5.
- **Dato personal:** columna que identifica o permite contactar a una persona (ver sección 7).
- **†** Valor propuesto en este diccionario; si el Módulo 6 ya define el valor, se usa el del Módulo 6.
- Los tipos son los **previstos**; se confirman con el DDL cuando exista.

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
| `estandar_calidad` | Límites permitidos de un parámetro, por producto y etapa, con su vigencia. |
| `prueba_calidad` | Registro de una medición o análisis de calidad. |
| `envasado` | Registro del empaque final de un lote aprobado. |
| `descarte` | Registro del descarte de un lote de producción. |
| `almacena` | Movimientos de leche de un lote hacia o desde un silo. |
| `uso_tanque` | Uso de un tanque por un lote, con inicio y fin. |
| `consumo_insumo` | Cada consumo de un lote de insumo en un lote de producción. |
| `asigna` | Transferencia de leche desde un silo a un tanque para un lote de producción. |

## 3. Tablas de entidades

### 3.1. `proveedor`

Persona, finca o empresa que suministra leche cruda y otros insumos a la planta.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_proveedor` | INTEGER (identity) | NO | PK | Identificador interno del proveedor. | Generado automáticamente. | `3` |
| `nombre` | VARCHAR(120) | NO | | Nombre de la finca, empresa o persona. Dato personal cuando es persona natural. | | `Finca La Esperanza` |
| `ubicacion` | VARCHAR(150) | NO | | Lugar de origen del suministro (vereda y municipio); permite rastrear la procedencia de la leche. | | `Vereda El Placer, Codazzi` |
| `telefono` | VARCHAR(20) | SÍ | | Teléfono de contacto. Dato personal. | | `3105550142` |
| `tipo_proveedor` | VARCHAR(20) | NO | | Naturaleza del proveedor. | `persona`, `finca`, `empresa` † | `finca` |
| `identificacion` | VARCHAR(20) | NO | UK | Cédula o NIT del proveedor. Dato personal cuando es persona natural. | Única. | `900123456-7` |
| `estado` | VARCHAR(20) | NO | | Indica si el proveedor está habilitado para suministrar. | `activo`, `inactivo` †. Por defecto `activo`. | `activo` |

### 3.2. `lote_leche`

Cantidad identificable de leche cruda recibida de un proveedor, con su dictamen microbiológico.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_lote_leche` | INTEGER (identity) | NO | PK | Identificador interno del lote de leche. | Generado automáticamente. | `412` |
| `codigo` | VARCHAR(30) | NO | UK | Código con el que se identifica el lote en la planta. | Único. | `LL-2026-0412` |
| `fecha_recepcion` | TIMESTAMPTZ | NO | | Fecha y hora en que llegó la leche. Desde esta fecha corre el plazo de conservación de sus pruebas (RN-08). | | `2026-03-14 05:40` |
| `volumen_inicial_litros` | NUMERIC(12,2) | NO | | Litros recibidos. | Mayor que 0. | `8500.00` |
| `volumen_disponible_litros` | NUMERIC(12,2) | NO | | Litros que aún quedan del lote. **Dato de estado** que mantiene un trigger (sección 5). | Entre 0 y `volumen_inicial_litros`. | `3200.00` |
| `dictamen_microbiologico` | VARCHAR(20) | NO | | Resultado del control microbiológico de la leche. **Dato derivado** de las pruebas microbiológicas del lote (supuesto 24). Solo la leche `aprobado` ingresa al silo (RN-01). | `pendiente`, `aprobado`, `rechazado`. Por defecto `pendiente`. | `aprobado` |
| `estado_lote` | VARCHAR(20) | NO | | Situación actual de la leche. | `recibido`, `disponible`, `agotado`, `rechazado`. Por defecto `recibido`. `disponible` exige dictamen `aprobado`; dictamen `rechazado` implica estado `rechazado`. | `disponible` |
| `id_proveedor_origen` | INTEGER | NO | FK → `proveedor(id_proveedor)` | Proveedor que entregó el lote. Un lote tiene exactamente un proveedor. | | `3` |

### 3.3. `silo`

Contenedor físico de recepción y acopio de leche cruda.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_silo` | INTEGER (identity) | NO | PK | Identificador interno del silo. | Generado automáticamente. | `2` |
| `codigo` | VARCHAR(20) | NO | UK | Código del silo en la planta (la planta tiene 6). | Único. | `SIL-02` |
| `tipo_silo` | VARCHAR(20) | NO | | Función del silo. | `recepcion`, `acopio` † | `acopio` |
| `capacidad_maxima` | NUMERIC(12,2) | NO | | Litros que puede almacenar. | Mayor que 0. | `25000.00` |
| `volumen_actual` | NUMERIC(12,2) | NO | | Litros que contiene en este momento. **Dato de estado** que mantiene un trigger (sección 5). | Entre 0 y `capacidad_maxima`. Por defecto 0. | `18400.00` |
| `estado_operativo` | VARCHAR(20) | NO | | Si el silo puede recibir leche. | `operativo`, `en_mantenimiento`, `fuera_de_servicio` † | `operativo` |

### 3.4. `tanque`

Equipo físico donde se procesa un lote de producción; puede ser de fermentación o de mezcla.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_tanque` | INTEGER (identity) | NO | PK | Identificador interno del tanque. | Generado automáticamente. | `3` |
| `codigo` | VARCHAR(20) | NO | UK | Código del tanque en la planta. | Único. | `TQ-03` |
| `tipo_tanque` | VARCHAR(20) | NO | | Función del tanque. El de mezcla es el tanque secundario donde se añade el sabor (supuesto 2). | `fermentacion`, `mezcla` † | `fermentacion` |
| `capacidad_maxima` | NUMERIC(12,2) | NO | | Litros que puede contener. No puede superarse con las asignaciones de leche (RN-07). | Mayor que 0. | `5000.00` |
| `volumen_actual` | NUMERIC(12,2) | NO | | Litros que contiene en este momento. **Dato de estado** que mantiene un trigger (sección 5). | Entre 0 y `capacidad_maxima`. Por defecto 0. | `4200.00` |
| `estado_operativo` | VARCHAR(20) | NO | | Si el tanque puede usarse. | `operativo`, `en_mantenimiento`, `fuera_de_servicio` † | `operativo` |

### 3.5. `insumo`

Catálogo de tipos de materia prima adicional que se usa en la producción.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_insumo` | INTEGER (identity) | NO | PK | Identificador interno del tipo de insumo. | Generado automáticamente. | `7` |
| `codigo` | VARCHAR(30) | NO | UK | Código del insumo en el catálogo. | Único. | `INS-PUL-FRE` |
| `categoria_insumo` | VARCHAR(30) | NO | | Familia a la que pertenece el insumo. | `cultivo_lactico`, `pulpa_fruta`, `saborizante`, `material_empaque` † | `pulpa_fruta` |
| `unidad_medida` | VARCHAR(20) | NO | | Unidad en que se mide este insumo. Es propia de cada insumo, no de la categoría. | `kg`, `g`, `l`, `ml`, `unidad` † | `kg` |
| `estado` | VARCHAR(20) | NO | | Si el insumo se sigue usando. | `activo`, `inactivo` †. Por defecto `activo`. | `activo` |

### 3.6. `lote_insumo`

Recepción concreta de un insumo, con su cantidad y su fecha de caducidad.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_lote_insumo` | INTEGER (identity) | NO | PK | Identificador interno del lote de insumo. | Generado automáticamente. | `21` |
| `codigo_lote_insumo` | VARCHAR(30) | NO | UK | Código del lote que trae el insumo. | Único. | `PF-2026-018` |
| `cantidad_inicial` | NUMERIC(12,3) | NO | | Cantidad recibida, en la unidad del insumo. | Mayor que 0. | `200.000` |
| `cantidad_disponible` | NUMERIC(12,3) | NO | | Cantidad que aún queda sin consumir. **Dato derivado:** inicial menos la suma de `consumo_insumo.cantidad_consumida` (RN-10). | Entre 0 y `cantidad_inicial`. | `135.500` |
| `fecha_recepcion` | DATE | NO | | Día en que llegó el lote. | | `2026-03-10` |
| `fecha_caducidad` | DATE | NO | | Último día en que puede consumirse (RN-02). | Mayor o igual que `fecha_recepcion`. | `2026-06-10` |
| `estado` | VARCHAR(20) | NO | | Situación actual del lote de insumo. | `disponible`, `agotado`, `vencido` †. Por defecto `disponible`. | `disponible` |
| `id_insumo` | INTEGER | NO | FK → `insumo(id_insumo)` | Tipo de insumo al que corresponde el lote. | | `7` |
| `id_proveedor` | INTEGER | NO | FK → `proveedor(id_proveedor)` | Proveedor que entregó el lote. Un lote de insumo tiene exactamente un proveedor (supuesto 25). | | `5` |

### 3.7. `empleado`

Persona que interviene en la producción como operador, técnico de calidad o supervisor.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_empleado` | INTEGER (identity) | NO | PK | Identificador interno del empleado. | Generado automáticamente. | `4` |
| `nombre` | VARCHAR(120) | NO | | Nombre completo. Dato personal. | | `Laura Mendoza` |
| `cargo` | VARCHAR(30) | NO | | Función que cumple; determina qué puede registrar (RN-09). | `operador_tanque`, `tecnico_calidad`, `supervisor` | `tecnico_calidad` |
| `identificacion` | VARCHAR(20) | NO | UK | Cédula del empleado. Dato personal. | Única. | `1065000000` |
| `estado_vinculacion` | VARCHAR(20) | NO | | Si el empleado sigue vinculado. No se borra al retirarse; se marca inactivo para conservar la trazabilidad (supuesto 10). | `activo`, `inactivo` †. Por defecto `activo`. | `activo` |

### 3.8. `lote_produccion`

Unidad trazable de producto elaborado durante un ciclo de producción.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_lote_produccion` | INTEGER (identity) | NO | PK | Identificador interno del lote. | Generado automáticamente. | `150` |
| `codigo` | VARCHAR(30) | NO | UK | Código del lote que se imprime y se sigue en la planta. | Único. | `YOG-2026-0150` |
| `tipo_producto` | VARCHAR(20) | NO | | Producto que se elabora. | `yogurt`, `queso`, `suero`, `avena`, `leche_uht` | `yogurt` |
| `volumen_planificado_litros` | NUMERIC(12,2) | NO | | Litros que se planea producir. | Mayor que 0. | `4000.00` |
| `volumen_producido_litros` | NUMERIC(12,2) | SÍ | | Litros realmente producidos; vacío mientras el lote está en proceso. | Mayor o igual que 0. | `3920.00` |
| `fecha_hora_inicio` | TIMESTAMPTZ | NO | | Momento en que comienza la elaboración. | | `2026-03-14 07:00` |
| `fecha_hora_fin` | TIMESTAMPTZ | SÍ | | Momento en que termina la elaboración (fin de fermentación y mezcla); vacío mientras está en proceso. No es la fecha de cierre del lote (ver Módulo 3, sección 1.3). | Mayor o igual que `fecha_hora_inicio`. | `2026-03-14 15:30` |
| `estado` | VARCHAR(20) | NO | | Situación del lote en su ciclo de vida. **Dato derivado en parte** de las pruebas, el envasado y el descarte. Solo se envasa un lote `aprobado` (RN-03). | `en_proceso`, `aprobado`, `rechazado`, `envasado`, `descartado`. Por defecto `en_proceso`. | `envasado` |
| `id_supervisor` | INTEGER | NO | FK → `empleado(id_empleado)` | Supervisor responsable del lote durante todo su ciclo, sin historial (supuestos 9 y 22). | | `2` |

### 3.9. `estandar_calidad`

Límites permitidos de un parámetro de calidad para un producto y una etapa, con su vigencia. Las pruebas no guardan sus límites: referencian un estándar (supuesto 26). Un cambio de límite crea un estándar nuevo y cierra la vigencia del anterior.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_estandar` | INTEGER (identity) | NO | PK | Identificador interno del estándar. | Generado automáticamente. | `12` |
| `tipo_producto` | VARCHAR(20) | NO | | Producto al que aplica el límite. | Los valores de `lote_produccion.tipo_producto` y `leche_cruda` † | `yogurt` |
| `parametro` | VARCHAR(20) | NO | | Magnitud que se mide. | `ph`, `temperatura`, `acidez_dornic`, `grasa`, `viscosidad`, `microorganismos` | `ph` |
| `etapa` | VARCHAR(20) | NO | | Momento del proceso en que se mide. | `recepcion`, `fermentacion`, `mezcla`, `envasado` | `fermentacion` |
| `unidad_medida` | VARCHAR(20) | NO | | Unidad del valor. El pH no tiene unidad y usa `adimensional`. | `adimensional`, `grados_celsius`, `grados_dornic`, `porcentaje`, `cp`, `ufc_ml` † | `adimensional` |
| `valor_minimo_permitido` | NUMERIC(12,4) | NO | | Valor más bajo aceptable. | Menor o igual que `valor_maximo_permitido` (RN-04). | `4.2000` |
| `valor_maximo_permitido` | NUMERIC(12,4) | NO | | Valor más alto aceptable. | Mayor o igual que `valor_minimo_permitido`. | `4.6000` |
| `vigente_desde` | DATE | NO | | Primer día en que el estándar aplica. | | `2026-01-01` |
| `vigente_hasta` | DATE | SÍ | | Último día en que aplica; vacío mientras el estándar sigue vigente. | Mayor o igual que `vigente_desde`. Solo puede haber un estándar vigente por producto, parámetro y etapa. | |

### 3.10. `prueba_calidad`

Registro de una medición o análisis de calidad. Pertenece a un lote de producción o a un lote de leche, nunca a ambos.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_prueba_calidad` | INTEGER (identity) | NO | PK | Identificador interno de la prueba. | Generado automáticamente. | `3301` |
| `fecha_hora` | TIMESTAMPTZ | NO | | Momento en que se tomó la medición. Con la serie de mediciones se calculan las alertas (RN-04). | | `2026-03-14 11:15` |
| `tipo_prueba` | VARCHAR(25) | NO | | Clase de prueba. Las de laboratorio las registra solo un Técnico de calidad (RN-09). | `microbiologica`, `fisicoquimica`, `ph_linea`, `temperatura_linea` | `ph_linea` |
| `valor_obtenido` | NUMERIC(12,4) | NO | | Valor medido, en la unidad del estándar. | | `4.3500` |
| `resultado` | VARCHAR(20) | NO | | Dictamen de la prueba. `reproceso` es decisión del técnico y mantiene el lote en proceso. | `aprobado`, `rechazado`, `reproceso` | `aprobado` |
| `origen_registro` | VARCHAR(20) | NO | | Quién generó el dato. | `sensor`, `manual`. `sensor` solo con tipos en línea y sin responsable. | `sensor` |
| `id_lote_produccion` | INTEGER | SÍ | FK → `lote_produccion(id_lote_produccion)` | Lote de producción al que pertenece la prueba. | Exactamente uno entre este y `id_lote_leche` es no nulo (RN-13). Obligatorio en tipos en línea. | `150` |
| `id_lote_leche` | INTEGER | SÍ | FK → `lote_leche(id_lote_leche)` | Lote de leche al que pertenece la prueba. | Ver arriba. | |
| `id_responsable_registro` | INTEGER | SÍ | FK → `empleado(id_empleado)` | Empleado que registró la prueba; vacío si la generó un sensor. | Nulo si `origen_registro` es `sensor`; no nulo si es `manual` (RN-09). | |
| `id_estandar` | INTEGER | NO | FK → `estandar_calidad(id_estandar)` | Estándar con el que se evalúa la prueba. | | `12` |

### 3.11. `envasado`

Registro del proceso final de empaque de un lote aprobado. Un lote puede tener varios registros (varias presentaciones).

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_envasado` | INTEGER (identity) | NO | PK | Identificador interno del registro de envasado. | Generado automáticamente. | `88` |
| `fecha_hora_envasado` | TIMESTAMPTZ | NO | | Momento del envasado. La del último registro es la fecha de cierre del lote. | | `2026-03-15 08:10` |
| `presentacion` | VARCHAR(30) | NO | | Empaque utilizado. | `bolsa_150g`, `botella_1l`, `garrafa` † | `botella_1l` |
| `cantidad_envasada` | INTEGER | NO | | Unidades empacadas de esa presentación. | Mayor que 0. | `1500` |
| `destino` | VARCHAR(20) | NO | | Canal al que se destina el producto (RN-11). | `mayorista`, `minorista`, `venta_directa` | `minorista` |
| `temperatura_envasado` | NUMERIC(5,2) | SÍ | | Temperatura del producto al envasar, en °C. | | `5.50` |
| `temperatura_despacho` | NUMERIC(5,2) | SÍ | | Temperatura al salir de la planta, en °C; vacía mientras no se despacha. | | `4.80` |
| `fecha_vencimiento` | DATE | NO | | Fecha límite de consumo del producto. | Posterior a la fecha de `fecha_hora_envasado` (RN-11). | `2026-04-05` |
| `fecha_hora_despacho` | TIMESTAMPTZ | SÍ | | Momento en que el producto sale de la planta; vacío mientras no se despacha. | No anterior a `fecha_hora_envasado` (RN-11). | `2026-03-15 14:00` |
| `estado` | VARCHAR(20) | NO | | `abierto` mientras se llena esa presentación; `cerrado` al terminarla (supuesto 28). | `abierto`, `cerrado`. Por defecto `abierto`. | `cerrado` |
| `id_lote_produccion` | INTEGER | NO | FK → `lote_produccion(id_lote_produccion)` | Lote del que proviene el producto. Solo puede envasarse un lote `aprobado` (RN-03). | | `150` |

### 3.12. `descarte`

Registro del descarte de un lote de producción. Es una entidad débil: su clave es la del lote, por lo que un lote tiene como máximo un descarte.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_lote_produccion` | INTEGER | NO | PK, FK → `lote_produccion(id_lote_produccion)` | Lote descartado; identifica al descarte. | | `148` |
| `fecha_hora_descarte` | TIMESTAMPTZ | NO | | Momento del descarte. Es la fecha de cierre del lote si fue descartado. | | `2026-03-12 16:20` |
| `motivo` | VARCHAR(200) | NO | | Razón del descarte (RN-05). | | `pH fuera de rango sostenido en fermentación` |
| `volumen_descartado` | NUMERIC(12,2) | NO | | Litros desechados (RN-05). | Mayor que 0. | `3800.00` |
| `observaciones` | TEXT | SÍ | | Comentarios adicionales. | | `Se informó al supervisor del turno` |

## 4. Tablas intermedias

### 4.1. `almacena`

Movimiento de leche de un lote hacia o desde un silo. Con estos movimientos se calcula qué lotes estaban en un silo en un momento dado (supuesto 19).

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_almacena` | INTEGER (identity) | NO | PK | Identificador interno del movimiento. | Generado automáticamente. | `905` |
| `id_lote_leche` | INTEGER | NO | FK → `lote_leche(id_lote_leche)` | Lote de leche que se mueve. Debe tener dictamen `aprobado` para entrar (RN-01). | | `412` |
| `id_silo` | INTEGER | NO | FK → `silo(id_silo)` | Silo que recibe o entrega la leche. | | `2` |
| `fecha_hora` | TIMESTAMPTZ | NO | | Momento del movimiento. | | `2026-03-14 06:05` |
| `tipo_movimiento` | VARCHAR(20) | NO | | Sentido del movimiento. | `entrada`, `salida` | `entrada` |
| `volumen_litros` | NUMERIC(12,2) | NO | | Litros movidos. | Mayor que 0. | `8500.00` |
| `observaciones` | TEXT | SÍ | | Comentarios adicionales. | | `Descarga del carro tanque 1` |

### 4.2. `uso_tanque`

Uso de un tanque por un lote de producción, con su inicio y su fin. Un lote puede usar varios tanques en secuencia (mínimo uno).

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_uso_tanque` | INTEGER (identity) | NO | PK | Identificador interno del uso. | Generado automáticamente. | `210` |
| `id_tanque` | INTEGER | NO | FK → `tanque(id_tanque)` | Tanque ocupado. | Un solo uso activo por tanque (RN-06). | `3` |
| `id_lote_produccion` | INTEGER | NO | FK → `lote_produccion(id_lote_produccion)` | Lote que ocupa el tanque. | Un solo tanque activo por lote. | `150` |
| `fecha_hora_inicio` | TIMESTAMPTZ | NO | | Momento en que el lote entra al tanque. | | `2026-03-14 07:00` |
| `fecha_hora_fin` | TIMESTAMPTZ | SÍ | | Momento en que el lote sale (traslado a mezcla, envasado o descarte); vacía mientras el uso está activo. | Mayor o igual que `fecha_hora_inicio`. | `2026-03-14 15:30` |
| `estado_uso` | VARCHAR(20) | NO | | Si el uso sigue en curso. **Dato derivado:** `activo` si `fecha_hora_fin` está vacía. | `activo`, `finalizado` | `finalizado` |

### 4.3. `consumo_insumo`

Cada consumo, total o parcial, de un lote de insumo en un lote de producción. Un mismo par de lotes puede tener varios consumos.

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_consumo_insumo` | INTEGER (identity) | NO | PK | Identificador interno del consumo. | Generado automáticamente. | `640` |
| `id_lote_insumo` | INTEGER | NO | FK → `lote_insumo(id_lote_insumo)` | Lote de insumo que se consume. | | `21` |
| `id_lote_produccion` | INTEGER | NO | FK → `lote_produccion(id_lote_produccion)` | Lote de producción que lo usa. | | `150` |
| `cantidad_consumida` | NUMERIC(12,3) | NO | | Cantidad usada en este consumo, en la unidad del insumo. No puede superar la disponible (RN-10). | Mayor que 0. | `64.500` |
| `fecha_hora_consumo` | TIMESTAMPTZ | NO | | Momento del consumo. No puede ser posterior a la caducidad del lote (RN-02). | | `2026-03-14 13:45` |

### 4.4. `asigna`

Transferencia de leche desde un silo hacia un tanque para un lote de producción (relación ternaria).

| Columna | Tipo | ¿Nulo? | Clave | Significado de negocio | Dominio y restricciones | Ejemplo |
|---|---|---|---|---|---|---|
| `id_asigna` | INTEGER (identity) | NO | PK | Identificador interno de la asignación. | Generado automáticamente. | `330` |
| `id_silo_origen` | INTEGER | NO | FK → `silo(id_silo)` | Silo de origen de la leche. | | `2` |
| `id_tanque_destino` | INTEGER | NO | FK → `tanque(id_tanque)` | Tanque de destino. | | `3` |
| `id_lote_produccion` | INTEGER | NO | FK → `lote_produccion(id_lote_produccion)` | Lote para el que se asigna la leche. Debe tener un uso activo de ese tanque en `uso_tanque` (RN-12). | | `150` |
| `volumen_asignado_litros` | NUMERIC(12,2) | NO | | Litros transferidos. La suma por lote y tanque no puede superar la capacidad del tanque (RN-07). | Mayor que 0. | `4000.00` |
| `fecha_hora_asignacion` | TIMESTAMPTZ | NO | | Momento de la transferencia. Sirve para saber qué lotes de leche estaban en el silo (supuesto 19). | | `2026-03-14 07:10` |

## 5. Datos derivados y datos de estado

Estas columnas no rompen ninguna forma normal. Se distinguen dos casos.

**Datos derivados (se pueden calcular con las tablas actuales):**

| Columna | Se calcula desde |
|---|---|
| `lote_insumo.cantidad_disponible` | Cantidad inicial menos lo consumido en `consumo_insumo` |
| `lote_leche.dictamen_microbiologico` | Pruebas microbiológicas del lote en `prueba_calidad` |
| `lote_leche.estado_lote` | Dictamen y volumen disponible (en parte) |
| `lote_produccion.estado` | Pruebas, envasado y descarte del lote (en parte) |
| `uso_tanque.estado_uso` | `uso_tanque.fecha_hora_fin` |

**Datos de estado (no se pueden calcular con las tablas actuales; los mantiene un trigger en la Entrega 3):**

| Columna | Por qué no se calcula |
|---|---|
| `tanque.volumen_actual` | Ninguna tabla registra la leche que sale del tanque. El trigger la suma al registrar una asignación y la pone en 0 cuando termina el uso del tanque. |
| `silo.volumen_actual` | Depende de las salidas de `almacena`, y hoy nadie las registra cuando la leche pasa al tanque (`asigna` no lleva el lote de leche). |
| `lote_leche.volumen_disponible_litros` | Misma razón que `silo.volumen_actual`. |

El riesgo común es que el valor guardado se desincronice de los movimientos; por eso se protegen con restricciones `CHECK` ahora y con validaciones automáticas después.

## 6. Restricciones, índices únicos parciales y triggers

Los detalles de las políticas de borrado están en `docs/06`, sección 7. La verificación de cada regla de negocio está en `docs/03`, sección 3.

### 6.1. Restricciones `CHECK`

| Tabla | Expresiones |
|---|---|
| `proveedor` | `tipo_proveedor IN ('persona','finca','empresa')`; `estado IN ('activo','inactivo')` |
| `lote_leche` | `volumen_inicial_litros > 0`; `volumen_disponible_litros BETWEEN 0 AND volumen_inicial_litros`; `dictamen_microbiologico IN ('pendiente','aprobado','rechazado')`; `estado_lote IN ('recibido','disponible','agotado','rechazado')`; `estado_lote <> 'disponible' OR dictamen_microbiologico = 'aprobado'`; `dictamen_microbiologico <> 'rechazado' OR estado_lote = 'rechazado'` |
| `silo` | `capacidad_maxima > 0`; `volumen_actual BETWEEN 0 AND capacidad_maxima`; `tipo_silo IN ('recepcion','acopio')`; `estado_operativo IN ('operativo','en_mantenimiento','fuera_de_servicio')` |
| `tanque` | `capacidad_maxima > 0`; `volumen_actual BETWEEN 0 AND capacidad_maxima`; `tipo_tanque IN ('fermentacion','mezcla')`; `estado_operativo IN ('operativo','en_mantenimiento','fuera_de_servicio')` |
| `insumo` | `categoria_insumo IN ('cultivo_lactico','pulpa_fruta','saborizante','material_empaque')`; `unidad_medida IN ('kg','g','l','ml','unidad')`; `estado IN ('activo','inactivo')` |
| `lote_insumo` | `cantidad_inicial > 0`; `cantidad_disponible BETWEEN 0 AND cantidad_inicial`; `fecha_caducidad >= fecha_recepcion`; `estado IN ('disponible','agotado','vencido')` |
| `empleado` | `cargo IN ('operador_tanque','tecnico_calidad','supervisor')`; `estado_vinculacion IN ('activo','inactivo')` |
| `lote_produccion` | `tipo_producto IN ('yogurt','queso','suero','avena','leche_uht')`; `volumen_planificado_litros > 0`; `volumen_producido_litros >= 0`; `fecha_hora_fin >= fecha_hora_inicio`; `estado IN ('en_proceso','aprobado','rechazado','envasado','descartado')` |
| `estandar_calidad` | `valor_minimo_permitido <= valor_maximo_permitido`; `vigente_hasta >= vigente_desde`; `parametro IN ('ph','temperatura','acidez_dornic','grasa','viscosidad','microorganismos')`; `etapa IN ('recepcion','fermentacion','mezcla','envasado')`; `unidad_medida IN ('adimensional','grados_celsius','grados_dornic','porcentaje','cp','ufc_ml')` |
| `prueba_calidad` | `tipo_prueba IN ('microbiologica','fisicoquimica','ph_linea','temperatura_linea')`; `resultado IN ('aprobado','rechazado','reproceso')`; `origen_registro IN ('sensor','manual')`; `num_nonnulls(id_lote_produccion, id_lote_leche) = 1`; `tipo_prueba NOT IN ('ph_linea','temperatura_linea') OR id_lote_produccion IS NOT NULL`; `origen_registro <> 'sensor' OR (id_responsable_registro IS NULL AND tipo_prueba IN ('ph_linea','temperatura_linea'))`; `origen_registro <> 'manual' OR id_responsable_registro IS NOT NULL` |
| `envasado` | `cantidad_envasada > 0`; `destino IN ('mayorista','minorista','venta_directa')`; `estado IN ('abierto','cerrado')`; `presentacion IN ('bolsa_150g','botella_1l','garrafa')`; `fecha_vencimiento > fecha_hora_envasado::date`; `fecha_hora_despacho IS NULL OR fecha_hora_despacho >= fecha_hora_envasado` |
| `descarte` | `volumen_descartado > 0` |
| `almacena` | `tipo_movimiento IN ('entrada','salida')`; `volumen_litros > 0` |
| `uso_tanque` | `fecha_hora_fin IS NULL OR fecha_hora_fin >= fecha_hora_inicio`; `estado_uso IN ('activo','finalizado')` |
| `consumo_insumo` | `cantidad_consumida > 0` |
| `asigna` | `volumen_asignado_litros > 0` |

### 6.2. Índices únicos parciales

| Tabla | Índice | Qué garantiza |
|---|---|---|
| `uso_tanque` | Único sobre `id_tanque` donde `fecha_hora_fin IS NULL` | Un solo uso activo por tanque (RN-06). |
| `uso_tanque` | Único sobre `id_lote_produccion` donde `fecha_hora_fin IS NULL` | Un lote está en un solo tanque a la vez. |
| `estandar_calidad` | Único sobre `(tipo_producto, parametro, etapa)` donde `vigente_hasta IS NULL` | Un solo estándar vigente por producto, parámetro y etapa. |

### 6.3. Triggers (Entrega 3)

| Tabla | Qué valida | Regla |
|---|---|---|
| `almacena` | Que el lote de leche tenga dictamen `aprobado` antes de una entrada | RN-01 |
| `consumo_insumo` | Que la fecha no supere la caducidad y la cantidad no supere la disponible | RN-02, RN-10 |
| `envasado` y `lote_produccion` | Que solo se envase un lote `aprobado` y que el lote pase a `envasado` solo con un envasado `cerrado` y ninguno `abierto` | RN-03 |
| `asigna` | Que la suma por lote y tanque no supere la capacidad, y que exista un uso activo de ese tanque para ese lote | RN-07, RN-12 |
| `prueba_calidad` | Que el cargo del responsable corresponda al tipo de prueba | RN-09 |
| Todas las tablas con `ON DELETE RESTRICT` | Que no se borren lotes ni pruebas antes de 365 días | RN-08 |
| `lote_produccion` | Mínimo (1,N): cada lote debe tener al menos un registro en `uso_tanque` y uno en `asigna` (se valida al confirmar la transacción) | Cardinalidad del diagrama |
| `asigna`, `uso_tanque`, `almacena` | Mantener `tanque.volumen_actual`, `silo.volumen_actual` y `lote_leche.volumen_disponible_litros` | Datos de estado (sección 5) |

## 7. Datos personales y medidas de protección

| Columna | Por qué es dato personal | Medida que lo protege |
|---|---|---|
| `proveedor.nombre` | Identifica a la persona cuando el proveedor es persona natural. | Excluida de la vista del rol de análisis; acceso solo para el rol de la aplicación. |
| `proveedor.identificacion` | Cédula o NIT de una persona natural. | Excluida de la vista de análisis. |
| `proveedor.telefono` | Permite contactar a una persona. | Excluida de la vista de análisis. |
| `empleado.nombre` | Identifica a una persona. | La vista de análisis muestra solo `id_empleado` y `cargo`. |
| `empleado.identificacion` | Cédula de una persona. | Excluida de la vista de análisis. |

Además: los datos de ejemplo del repositorio son ficticios y no contienen personas reales; las credenciales de conexión no se guardan en el repositorio.

