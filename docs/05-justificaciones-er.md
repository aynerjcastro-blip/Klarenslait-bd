# Módulo 5 — Justificaciones del Diagrama EER

Este documento recoge las decisiones de diseño no obvias tomadas al formalizar el modelo conceptual del Módulo 4 en el diagrama EER, con la notación de Chen. El diagrama tiene 12 entidades (11 fuertes y 1 débil), 4 relaciones asociativas con atributos propios y 14 relaciones en total.

## 1. Notación y convención de lectura

| Símbolo | Significado |
|---|---|
| Rectángulo | Entidad fuerte |
| Rectángulo de doble borde | Entidad débil (`Descarte`) |
| Rombo | Relación sin atributos propios |
| Rombo de doble borde | Relación identificante de una entidad débil (`Genera`) |
| Rombo dentro de un rectángulo | Relación M:N con atributos propios; se convierte en tabla intermedia (`Almacena`, `Asigna`, `Ocupa`, `Consume`) |
| Óvalo | Atributo; subrayado cuando es clave primaria |

**Convención de lectura de cardinalidades:** el valor (min,max) junto a una entidad indica cuántas instancias de *esa* entidad se asocian a una instancia de la entidad del otro extremo. Ejemplo: en `Suministra`, `(1,1)` junto a `Proveedor` y `(0,N)` junto a `LoteLeche` significan que cada lote tiene un solo proveedor y que un proveedor puede tener varios lotes. Es la misma convención del Módulo 4.

En la relación ternaria `Asigna`, cada valor se define por entidad respecto a la relación completa, no por pares de entidades.

## 2. Decisiones de diseño

| Pregunta | Decisión | Justificación | Impacto en el diseño |
|---|---|---|---|
| ¿Cómo se representa la asignación de leche desde un silo hacia un tanque para un lote de producción? | Una **relación ternaria** (`Asigna`), no dos relaciones binarias encadenadas. | Un registro de asignación involucra a la vez un Silo, un Tanque y un LoteProducción en un mismo evento; separarlo en binarias perdería la atomicidad del evento y obligaría a inventar una entidad intermedia artificial. | El rombo `Asigna` tiene tres líneas, con atributos propios (`fecha_hora_asignacion`, `volumen_asignado_litros`), y se traduce en una sola tabla con tres FK. |
| ¿Existe una cardinalidad directa entre Silo y Tanque, o entre Silo y LoteProducción? | **No.** En una ternaria la cardinalidad se define por entidad respecto al conjunto completo de la relación. | Asignar una cardinalidad Silo–Tanque implicaría descomponer la ternaria en binarias escondidas, lo cual no es correcto en la notación de Chen ni refleja el negocio: ninguna regla limita cuántos tanques puede alimentar un silo sin importar el lote. | Silo (0,N), Tanque (0,N) y LoteProducción (1,N) son las únicas cardinalidades de `Asigna`. Cualquier relación Silo–Tanque se deriva por consulta (join). |
| ¿Por qué `Almacena` (Silo↔LoteLeche) y `Asigna` (Silo–Tanque–LoteProducción) son relaciones separadas? | Se mantienen como dos relaciones asociativas independientes. | Son eventos distintos en momentos distintos: `Almacena` registra el acopio de leche cruda en un silo, antes de procesarla; `Asigna` registra la transferencia desde el silo hacia un tanque para iniciar un lote de producción. Fusionarlas obligaría a que todo movimiento de leche tuviera tanque y lote desde el primer momento, lo cual no es cierto. | `Almacena` (M:N) con `fecha_hora`, `tipo_movimiento`, `volumen_litros` y `observaciones` (el grupo decidió conservar este último). Ambas son tablas intermedias distintas en el Módulo 6. |
| ¿`Insumo` es entidad fuerte o débil? | **Fuerte.** | `Insumo` es el catálogo de tipos de materia prima (cultivo láctico, pulpa de fruta, etc.) y tiene identidad propia. Es `LoteInsumo` (cada recepción concreta) quien depende del catálogo, no al revés. | PK propia (`id_insumo`) y relación `Identifica` (1,1)–(0,N) hacia `LoteInsumo`, sin doble borde. |
| ¿Por qué `LoteInsumo` tiene atributos propios en vez de heredarlos de `Insumo`? | `fecha_caducidad`, `cantidad_inicial`, `cantidad_disponible`, `fecha_recepcion` y `codigo_lote_insumo` viven en `LoteInsumo`; `Insumo` conserva solo lo que describe el tipo (`codigo`, `categoria_insumo`, `unidad_medida`, `estado`). | Esos datos varían en cada recepción: cada lote de cultivo o pulpa tiene su propia caducidad y cantidad. Dejarlos en `Insumo` duplicaría información e impediría manejar varios lotes vigentes del mismo insumo. | Permite controlar disponibilidad y caducidad por lote (RN-02 y RN-10 del Módulo 3). |
| ¿Quién suministra los insumos? | Se agrega la relación `Provee` entre `Proveedor` y `LoteInsumo`: (1,1) junto a `Proveedor` y (0,N) junto a `LoteInsumo`. | El Módulo 4 define al proveedor como quien suministra leche cruda *u otros insumos*, pero el diagrama solo lo conectaba con `LoteLeche`. Sin esta relación no se puede responder qué proveedor entregó un cultivo o aditivo (requisito 9 del Módulo 2). | Cada lote de insumo tiene exactamente un proveedor. En el Módulo 6, `LoteInsumo` lleva una FK a `Proveedor`. |
| ¿Cómo se registran las pruebas de calidad de la leche cruda? | Se agrega la relación `Analiza` entre `LoteLeche` y `PruebaCalidad`: (0,1) junto a `LoteLeche` y (0,N) junto a `PruebaCalidad`. Por eso `Tiene` queda en (0,1) junto a `LoteProducción`. | Una prueba puede aplicarse a un lote de leche cruda (en recepción) o a un lote de producción, nunca a ambos. Sin `Analiza` no se podía registrar el pH, la acidez ni la grasa en recepción (requisitos 5, 8 y 14) ni analizar la leche antes de usarla (RN-01). | `PruebaCalidad` tiene dos FK opcionales y, en el Módulo 6, un CHECK que exige que exactamente una esté llena. |
| ¿Por qué existe `EstandarCalidad` en vez de guardar el mínimo y el máximo en cada prueba? | Entidad fuerte `EstandarCalidad` (`id_estandar`, `parametro`, `tipo_producto`, `valor_minimo_permitido`, `valor_maximo_permitido`) y relación `Evalúa`: (1,1) junto a `EstandarCalidad` y (0,N) junto a `PruebaCalidad`. | Los rangos dependen del producto y del parámetro, no de la prueba concreta: copiarlos en cada fila crea una dependencia transitiva que incumple 3NF y obliga a corregir miles de filas si cambia un rango. Es además la regla que usa RN-04. El atributo `tipo_producto` permite un rango de pH para la leche cruda y otro para el yogur. | `PruebaCalidad` ya no tiene `valor_minimo_permitido` ni `valor_maximo_permitido`; el rango se obtiene por la relación `Evalúa`. |
| ¿Por qué `Registra` (Empleado↔PruebaCalidad) es opcional (0,1)? | Una prueba puede no tener empleado responsable si la generó un sensor. | Refleja el Módulo 3: el pH se mide cada 5 minutos por sensor y cada 2 horas lo valida un operario; solo el segundo caso tiene empleado. | El atributo `origen_registro` distingue `Sensor` de `Operario`; el (0,1) permite ambos casos sin forzar un empleado ficticio. |
| ¿`Descarte` es entidad fuerte o débil? | **Débil**, dependiente de `LoteProducción`. | Un descarte no tiene existencia ni identidad fuera de un lote de producción. Como un lote genera como máximo un descarte, no necesita clave parcial: su clave completa es la del lote (`id_lote_produccion`). | Doble borde en `Descarte` y en el rombo `Genera`, sin óvalo de clave propia. `Genera`: (1,1) junto a `LoteProducción` y (0,1) junto a `Descarte`. Corresponde a RN-05. |
| ¿Por qué `Envasa` (LoteProducción↔Envasado) es 1:N y no 1:1? | Un lote puede generar más de un registro de envasado (por ejemplo, en distintas presentaciones o momentos). | Coincide con R09 del Módulo 4. | (1,1) junto a `LoteProducción` y (0,N) junto a `Envasado`. El mínimo es 0 porque un lote rechazado o descartado nunca se envasa (RN-03). |
| ¿Qué datos de despacho guarda `Envasado`? | Se agregan `fecha_vencimiento` y `fecha_hora_despacho`; el grupo decidió conservar también `estado`. | La fecha de vencimiento es parte de los reportes regulatorios (requisito 7) y la fecha y hora de despacho acompaña la temperatura de despacho para rastrear la cadena de frío (supuesto 14 del Módulo 3). | Los valores permitidos de `estado` se definen en el diccionario de datos (Módulo 7). |
| ¿Cómo se modela el uso del tanque (`Ocupa`)? | Relación M:N con atributos propios (`fecha_hora_inicio`, `fecha_hora_fin`, `estado_uso`): (0,N) junto a `LoteProducción` y (1,N) junto a `Tanque`. | Un lote usa al menos un tanque (por ejemplo, tanque de fermentación y tanque de mezcla con fruta) y un tanque procesa muchos lotes a lo largo del tiempo. | Un lote que pasa por dos tanques se registra con dos filas de `Ocupa`. La regla de un solo lote activo por tanque (RN-06) no se ve en la cardinalidad; se controla con las fechas (sección 4). |
| ¿Por qué la fermentación no es una entidad? | Se resuelve con `Ocupa` y `PruebaCalidad`. | La fermentación es una etapa del proceso, no un objeto ni un registro con ciclo de vida propio. Su duración sale del inicio y fin del uso del tanque, y sus mediciones (pH, temperatura) de las pruebas de calidad. | No hay entidad `Fermentacion`. Es la misma justificación que el Módulo 4, sección 5. |
| ¿Por qué el producto es un atributo y no una entidad? | `tipo_producto` es atributo de `LoteProducción`. | El alcance de la fase 1 es solo yogur, así que un catálogo de productos no aporta consultas nuevas. | Si en el futuro se amplía a queso u otros productos, `tipo_producto` pasaría a una entidad `Producto`. |

## 3. Cardinalidades finales

| Relación | Junto a la primera entidad | Junto a la segunda |
|---|---|---|
| Suministra | Proveedor (1,1) | LoteLeche (0,N) |
| Provee | Proveedor (1,1) | LoteInsumo (0,N) |
| Identifica | Insumo (1,1) | LoteInsumo (0,N) |
| Supervisa | Empleado (1,1) | LoteProducción (0,N) |
| Tiene | LoteProducción (0,1) | PruebaCalidad (0,N) |
| Analiza | LoteLeche (0,1) | PruebaCalidad (0,N) |
| Evalúa | EstandarCalidad (1,1) | PruebaCalidad (0,N) |
| Registra | Empleado (0,1) | PruebaCalidad (0,N) |
| Envasa | LoteProducción (1,1) | Envasado (0,N) |
| Genera | LoteProducción (1,1) | Descarte (0,1) |
| Almacena | Silo (0,N) | LoteLeche (0,N) |
| Ocupa | LoteProducción (0,N) | Tanque (1,N) |
| Consume | LoteProducción (0,N) | LoteInsumo (0,N) |
| Asigna (ternaria) | Silo (0,N), Tanque (0,N) | LoteProducción (1,N) |

## 4. Límites del modelo y reglas que se resuelven fuera del diagrama

- **Un solo lote activo por tanque (RN-06):** `Ocupa` es M:N, así que la cardinalidad no lo impide. Se controla con `fecha_hora_inicio` y `fecha_hora_fin` y una restricción en el esquema.
- **Capacidad del tanque (RN-07):** la suma de `volumen_asignado_litros` de `Asigna` para un lote activo no puede superar `capacidad_maxima` del tanque. Se valida fuera del diagrama.
- **Prueba de leche o de producción, nunca ambas:** se implementa en el Módulo 6 con dos FK y un CHECK.
- **Leche cruda rechazada:** queda registrada en `LoteLeche` (`estado_lote` y `dictamen_microbiologico`) y no genera `Descarte`, que aplica solo a lotes de producción.
- **Alertas de pH (RN-04):** no hay entidad `Alerta`; se detectan con una consulta sobre el historial de `PruebaCalidad` frente a `EstandarCalidad`.
- **Trazabilidad por silo:** el silo mezcla leche de varios lotes. El modelo permite saber qué lotes de leche pasaron por un silo (`Almacena`) y qué silos alimentaron cada lote de producción (`Asigna`), pero no qué litros de cada lote de leche terminaron en cada lote de yogur.
- **Supervisor:** cada lote tiene un solo supervisor (`Supervisa`), sin historial de cambios en la fase 1.
- **Claves primarias de las relaciones asociativas:** `Almacena`, `Asigna`, `Ocupa` y `Consume` no llevan óvalo de clave en el diagrama; el Módulo 6 define sus claves.