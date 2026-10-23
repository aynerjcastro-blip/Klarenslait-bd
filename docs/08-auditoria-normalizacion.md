# Módulo 6 — Auditoría de Normalización


## 1. Criterios usados

| Forma normal | Qué se verifica |
|---|---|
| 1FN | Valores atómicos, sin grupos repetidos y con clave primaria definida. |
| 2FN | Cumple 1FN y ningún atributo depende solo de una parte de una clave compuesta. |
| 3FN | Cumple 2FN y ningún atributo no clave depende de otro atributo no clave (sin dependencias transitivas). |
| BCNF | Todo determinante de una dependencia funcional es clave candidata. |

Notación: `A → B` significa que el valor de A determina el valor de B. Las claves candidatas, además de la PK, se señalan en cada tabla.

## 2. Resumen por tabla

| Tabla | PK | 1FN | 2FN | 3FN | BCNF | Observación |
|---|---|---|---|---|---|---|
| `proveedor` | id_proveedor | Sí | Sí | Sí | Sí | Sin observaciones. |
| `lote_leche` | id_lote_leche | Sí | Sí | Sí | Sí | `volumen_disponible_litros` es dato de estado; `dictamen_microbiologico` y `estado_lote` son derivados (ver 4.2). |
| `silo` | id_silo | Sí | Sí | Sí | Sí | `volumen_actual` es dato de estado (ver 4.2). |
| `tanque` | id_tanque | Sí | Sí | Sí | Sí | `volumen_actual` es dato de estado (ver 4.2). |
| `insumo` | id_insumo | Sí | Sí | Sí* | Sí* | *Condicionado a que la unidad de medida sea propia de cada insumo (ver 4.3). |
| `lote_insumo` | id_lote_insumo | Sí | Sí | Sí | Sí | `cantidad_disponible` es un dato derivado (ver 4.2). |
| `empleado` | id_empleado | Sí | Sí | Sí | Sí | Sin observaciones. |
| `lote_produccion` | id_lote_produccion | Sí | Sí | Sí | Sí | `estado` es un dato derivado en parte (ver 4.2). |
| `estandar_calidad` | id_estandar | Sí | Sí | **No** | **No** | `unidad_medida` depende del parámetro. Excepción justificada (ver 4.1). |
| `prueba_calidad` | id_prueba_calidad | Sí | Sí | Sí | Sí | Resuelta: ya no guarda límites ni unidad (ver 4.4). |
| `envasado` | id_envasado | Sí | Sí | Sí | Sí | Sin observaciones. |
| `descarte` | id_lote_produccion | Sí | Sí | Sí | Sí | La clave es la del lote (entidad débil). |
| `almacena` | id_almacena | Sí | Sí | Sí | Sí | Sin observaciones. |
| `uso_tanque` | id_uso_tanque | Sí | Sí | Sí | Sí | `estado_uso` se deriva de `fecha_hora_fin` (ver 4.2). |
| `consumo_insumo` | id_consumo_insumo | Sí | Sí | Sí | Sí | Resuelta: clave propia (ver 4.4). |
| `asigna` | id_asigna | Sí | Sí | Sí | Sí | Sin observaciones. |

**Resultado:** 15 de las 16 tablas están en BCNF (una de ellas, `insumo`, bajo un supuesto que se documenta). Una tabla, `estandar_calidad`, no cumple 3FN/BCNF y se mantiene como excepción justificada.

## 3. Dependencias funcionales por tabla

**proveedor** — Claves candidatas: `id_proveedor`, `identificacion`.
- `id_proveedor → nombre, ubicacion, telefono, tipo_proveedor, identificacion, estado`
- `identificacion → id_proveedor` (y, por tanto, todos los demás atributos)

**lote_leche** — Claves candidatas: `id_lote_leche`, `codigo`.
- `id_lote_leche → codigo, fecha_recepcion, volumen_inicial_litros, volumen_disponible_litros, dictamen_microbiologico, estado_lote, id_proveedor_origen`
- `codigo → id_lote_leche`
- `id_proveedor_origen` no determina nada más: un proveedor tiene muchos lotes, por eso es solo una FK.

**silo** — Claves candidatas: `id_silo`, `codigo`.
- `id_silo → codigo, tipo_silo, capacidad_maxima, volumen_actual, estado_operativo`
- `codigo → id_silo`

**tanque** — Claves candidatas: `id_tanque`, `codigo`.
- `id_tanque → codigo, tipo_tanque, capacidad_maxima, volumen_actual, estado_operativo`
- `codigo → id_tanque`

**insumo** — Claves candidatas: `id_insumo`, `codigo`.
- `id_insumo → codigo, categoria_insumo, unidad_medida, estado`
- `codigo → id_insumo`
- Posible dependencia `categoria_insumo → unidad_medida` (ver 4.3).

**lote_insumo** — Claves candidatas: `id_lote_insumo`, `codigo_lote_insumo`.
- `id_lote_insumo → codigo_lote_insumo, cantidad_inicial, cantidad_disponible, fecha_recepcion, fecha_caducidad, estado, id_insumo, id_proveedor`
- `id_insumo` e `id_proveedor` no determinan las fechas ni las cantidades: cada recepción tiene las suyas.

**empleado** — Claves candidatas: `id_empleado`, `identificacion`.
- `id_empleado → nombre, cargo, identificacion, estado_vinculacion`
- `identificacion → id_empleado`
- `cargo` no determina ningún otro atributo de la tabla.

**lote_produccion** — Claves candidatas: `id_lote_produccion`, `codigo`.
- `id_lote_produccion → codigo, tipo_producto, volumen_planificado_litros, volumen_producido_litros, fecha_hora_inicio, fecha_hora_fin, estado, id_supervisor`
- `codigo → id_lote_produccion`
- `id_supervisor` no determina atributos del lote: un empleado supervisa muchos lotes.

**estandar_calidad** — Claves candidatas: `id_estandar` y `(tipo_producto, parametro, etapa, vigente_desde)`.
- `id_estandar → tipo_producto, parametro, etapa, unidad_medida, valor_minimo_permitido, valor_maximo_permitido, vigente_desde, vigente_hasta`
- `(tipo_producto, parametro, etapa, vigente_desde) → id_estandar` (y todos los demás atributos)
- `parametro → unidad_medida` (con los dominios del diccionario: el pH es adimensional, la temperatura va en grados Celsius, la acidez en grados Dornic, etc.)
- El último determinante no es clave: es lo que impide 3FN/BCNF (ver 4.1).

**prueba_calidad** — Clave candidata: `id_prueba_calidad`.
- `id_prueba_calidad → fecha_hora, tipo_prueba, valor_obtenido, resultado, origen_registro, id_lote_produccion, id_lote_leche, id_responsable_registro, id_estandar`
- Ningún otro atributo determina a los demás: `id_estandar` lo comparten muchas pruebas con valores distintos, y un mismo parámetro puede medirse con distintos `tipo_prueba` (por ejemplo, el pH en línea o el pH de recepción en laboratorio).

**envasado** — Clave candidata: `id_envasado`.
- `id_envasado → fecha_hora_envasado, presentacion, cantidad_envasada, destino, temperatura_envasado, temperatura_despacho, fecha_vencimiento, fecha_hora_despacho, estado, id_lote_produccion`
- No hay otro determinante: `presentacion` y `destino` no determinan ningún otro atributo guardado. La `fecha_vencimiento` depende de la vida útil del producto, que no se guarda en esta tabla.

**descarte** — Clave primaria: `id_lote_produccion` (entidad débil: su clave es la del lote).
- `id_lote_produccion → fecha_hora_descarte, motivo, volumen_descartado, observaciones`

**almacena** — Claves candidatas: `id_almacena` y `(id_lote_leche, id_silo, fecha_hora, tipo_movimiento)`.
- `id_almacena → id_lote_leche, id_silo, fecha_hora, tipo_movimiento, volumen_litros, observaciones`
- `tipo_movimiento` no determina otros atributos.

**uso_tanque** — Claves candidatas: `id_uso_tanque` y `(id_tanque, id_lote_produccion, fecha_hora_inicio)`.
- `id_uso_tanque → id_tanque, id_lote_produccion, fecha_hora_inicio, fecha_hora_fin, estado_uso`

**consumo_insumo** — Claves candidatas: `id_consumo_insumo` y `(id_lote_insumo, id_lote_produccion, fecha_hora_consumo)`.
- `id_consumo_insumo → id_lote_insumo, id_lote_produccion, cantidad_consumida, fecha_hora_consumo`
- La clave primaria es de una sola columna: la 2FN se cumple de forma automática.

**asigna** — Claves candidatas: `id_asigna` y `(id_silo_origen, id_tanque_destino, id_lote_produccion, fecha_hora_asignacion)`.
- `id_asigna → id_silo_origen, id_tanque_destino, id_lote_produccion, volumen_asignado_litros, fecha_hora_asignacion`

## 4. Hallazgos y excepciones justificadas

### 4.1. `estandar_calidad` no cumple 3FN/BCNF (excepción deliberada)

**Qué pasa:** `parametro` determina `unidad_medida` y no es clave de la tabla. Hay una dependencia transitiva (`id_estandar → parametro → unidad_medida`): la misma unidad se repite en cada versión, producto y etapa del mismo parámetro.

**Decisión:** mantener la tabla como está, como excepción documentada.

**Justificación:**
1. **Es un catálogo pequeño.** Son unas pocas decenas de filas, así que la repetición de la unidad es mínima.
2. **La unidad es una propiedad estable de la magnitud.** El pH siempre es adimensional y la temperatura siempre va en grados Celsius; no cambia con el tiempo, así que no hay riesgo de anomalía de actualización.
3. **Separarla cuesta más de lo que aporta.** Una tabla `parametro_calidad` sería la tabla 17, cambiaría el diagrama EER y los Módulos 4 a 6, y obligaría a una reunión más en cada consulta de alertas, para guardar un dato que nunca cambia.

**Mitigación:** un `CHECK` que ate cada parámetro con su única unidad válida (`ph` con `adimensional`, `temperatura` con `grados_celsius`, `acidez_dornic` con `grados_dornic`, `grasa` con `porcentaje`, `viscosidad` con `cp`, `microorganismos` con `ufc_ml`). Con él, no puede existir una combinación inconsistente y la redundancia no genera anomalías.

**Alternativa si el grupo prefiere 3FN estricta:** crear `parametro_calidad (parametro, unidad_medida)` y que `estandar_calidad` apunte a ella con una FK.

### 4.2. Datos derivados y datos de estado

**Datos derivados (se pueden calcular con las tablas actuales y se conservan por rapidez):**

| Tabla.columna | Cómo se calcula | Por qué se conserva |
|---|---|---|
| `lote_insumo.cantidad_disponible` | `cantidad_inicial` menos la suma de `consumo_insumo.cantidad_consumida` | Soporta la regla RN-10 (no consumir un lote agotado) sin sumar cada vez. |
| `lote_leche.dictamen_microbiologico` | Pruebas microbiológicas del lote en `prueba_calidad` (supuesto 24) | Permite decidir al instante si la leche puede entrar al silo (RN-01). |
| `lote_leche.estado_lote` | Dictamen y volumen disponible; derivable solo en parte, porque un dictamen `aprobado` puede ser `disponible` o `agotado` | Filtra rápido la leche utilizable. |
| `lote_produccion.estado` | Último resultado de las pruebas y existencia de envasado o descarte; derivable solo en parte (el "reproceso" y el descarte directo dependen de decisiones) | RN-03 y RN-06 lo consultan constantemente. |
| `uso_tanque.estado_uso` | `activo` si `fecha_hora_fin` está vacía | Claridad en las consultas. |
| `estandar_calidad.vigente_hasta` | Un día antes de la `vigente_desde` de la versión siguiente | Hace falta una columna que marque cuál estándar sigue vigente para el índice único parcial. |

**Datos de estado (no se pueden calcular con las tablas actuales):**

| Tabla.columna | Por qué no se puede calcular |
|---|---|
| `tanque.volumen_actual` | Ninguna tabla registra la leche que sale del tanque. |
| `silo.volumen_actual` | Depende de las salidas de `almacena`, y hoy nadie las registra cuando la leche pasa al tanque, porque `asigna` no lleva el lote de leche. |
| `lote_leche.volumen_disponible_litros` | Misma razón que `silo.volumen_actual`. |

Ninguna de estas columnas rompe una forma normal: las derivadas dependen de la clave de su propia tabla, y las de estado guardan información que no existe en otro lugar, por lo que no son redundancia. El riesgo es de mantenimiento: las derivadas pueden desincronizarse de sus fuentes y las de estado dependen de que un trigger (Entrega 3) las actualice. Se protegen con `CHECK` ahora (ver `docs/07`, sección 6).

### 4.3. `insumo`: dependencia transitiva condicionada

Si cada categoría tuviera una unidad fija (por ejemplo, todas las pulpas en kg y todos los cultivos en gramos), entonces `categoria_insumo → unidad_medida` sería una dependencia transitiva (`id_insumo → categoria_insumo → unidad_medida`) y la tabla no estaría en 3FN.

**Supuesto adoptado:** la unidad de medida es propia de cada insumo, no de la categoría; por eso no hay dependencia transitiva. El diccionario de datos ya recoge este supuesto.

**Si el grupo decide lo contrario:** se separaría `categoria_insumo (categoria_insumo, unidad_medida)` y `insumo` guardaría solo la categoría. **Pendiente de confirmar con el grupo.**

### 4.4. Hallazgos de la versión anterior que ya quedaron resueltos

| Tabla | Hallazgo anterior | Cómo quedó |
|---|---|---|
| `prueba_calidad` | No cumplía 3FN/BCNF porque repetía unidad y límites por parámetro (se había aceptado como excepción por el histórico). | Los límites y la unidad se movieron a `estandar_calidad`, y el histórico se conserva con la vigencia (`vigente_desde` y `vigente_hasta`). La tabla quedó en BCNF; la dependencia se trasladó a `estandar_calidad` (4.1), donde es menor. |
| `consumo_insumo` | La clave compuesta permitía un solo registro por pareja de lotes. | Tiene clave propia (`id_consumo_insumo`): cada consumo se guarda por separado. Al ser de una sola columna, la 2FN se cumple. |
| `descarte` | Se recomendaba `UNIQUE (id_lote_produccion)` con una clave propia. | La clave primaria es la del lote (entidad débil), que ya garantiza un descarte como máximo por lote. |

## 5. Ajustes sugeridos para las migraciones y decisiones pendientes

Los ajustes de la versión anterior ya están en `docs/07-diccionario-datos.md` (sección 6: `CHECK`, índices únicos parciales y triggers) o quedaron obsoletos por los cambios de la sección 4.4. Lo que sigue abierto:

| # | Tabla | Ajuste o decisión | Módulo |
|---|---|---|---|
| 1 | `estandar_calidad` | Agregar el `CHECK` que ata cada parámetro con su unidad (sección 4.1). Si el grupo prefiere 3FN estricta, crear `parametro_calidad`. | 2 y 7 |
| 2 | `almacena` y `asigna` | Definir quién registra las salidas de `almacena` cuando la leche pasa al tanque, o agregar `id_lote_leche` a `asigna`. Sin eso, los datos de estado de la sección 4.2 no se pueden mantener ni verificar. | Grupo; afecta a 1, 2, 3 (supuesto 19) y 7 |
| 3 | `insumo` | Confirmar la decisión de la sección 4.3. | Grupo |
| 4 | `estandar_calidad` | Confirmar la vigencia con `vigente_desde` y `vigente_hasta` (D13). | Grupo |

## 6. Conclusiones

1. El esquema está bien normalizado: 15 de las 16 tablas están en BCNF, y las tablas intermedias resuelven correctamente las relaciones M:N y la ternaria sin esconder datos repetidos.
2. Los cambios del grupo mejoraron la normalización: la excepción de `prueba_calidad` desapareció al crear `estandar_calidad`, y las claves de `consumo_insumo` y `descarte` quedaron alineadas con el diseño.
3. La única excepción es `estandar_calidad`, con una dependencia menor (`parametro → unidad_medida`) en un catálogo pequeño, controlada con un `CHECK`.
4. Las columnas derivadas y de estado son una redundancia o un estado consciente para tener el estado al instante; su consistencia se protege con restricciones ahora y con triggers en la Entrega 3.
5. Quedan tres decisiones del grupo (4.3, la vigencia y quién registra las salidas de `almacena`) que no cambian la estructura general, solo puntos concretos del esquema.
