# Módulo 3 — Interrogatorio, Supuestos y Reglas de Negocio 


## 1. Dominios y definiciones

Estas definiciones se usan en todos los supuestos y reglas; así cada término tiene un solo significado.

### 1.1. Estado del lote de producción (dominio único) — `LOTE_PRODUCCION.estado`

| Estado | Significado | ¿Activo o cerrado? |
|---|---|---|
| `en_proceso` | Se está elaborando (fermentación o mezcla) o espera dictamen. Un resultado de prueba "reproceso" lo mantiene aquí. | Activo |
| `aprobado` | Pasó el control de calidad; puede envasarse. | Activo |
| `rechazado` | No pasó el control de calidad; no puede envasarse y debe terminar en descarte. | Activo |
| `envasado` | Se registró el envasado final del lote. | Cerrado |
| `descartado` | Se registró el descarte (motivo y volumen). | Cerrado |

Transiciones permitidas: `en_proceso` → `aprobado` o `rechazado`; `aprobado` → `envasado`; `rechazado` → `descartado`; `en_proceso` → `descartado` (descarte directo por un incidente).

El resultado de una prueba (`PRUEBA_CALIDAD.resultado`) tiene su propio dominio: `aprobado`, `rechazado` o `reproceso`.

### 1.2. Lote de leche cruda

| Columna | Valores |
|---|---|
| `dictamen_microbiologico` | `pendiente`, `aprobado`, `rechazado` |
| `estado_lote` | `recibido` (antes del dictamen), `disponible` (dictamen aprobado y con litros), `agotado` (sin litros disponibles), `rechazado` (dictamen rechazado) |

Coherencia: un lote `disponible` exige dictamen `aprobado`, y un dictamen `rechazado` implica estado `rechazado`.

### 1.3. Lote activo, lote cerrado y uso activo de un tanque

- **Lote cerrado:** estado `envasado` o `descartado`. Cualquier otro estado es **lote activo**.
- **Fecha de cierre del lote:** `fecha_hora_envasado` del último envasado, o `fecha_hora_descarte` si fue descartado.
- **Uso activo de un tanque:** registro de `OCUPA` con `fecha_hora_fin` vacía. El uso termina cuando el lote sale del tanque: al trasladarse al tanque de mezcla, o al envasarse o descartarse si no pasa por mezcla.

### 1.4. Quién registra cada tipo de prueba (`PRUEBA_CALIDAD`)

| Tipo de registro | `origen_registro` | Quién lo registra | ¿Es prueba de laboratorio? |
|---|---|---|---|
| Medición automática de pH o temperatura | `Sensor` | Nadie (sin empleado) | No |
| Validación manual de pH o temperatura en línea | `Operario` | Operador de tanque o Técnico de calidad | No |
| Prueba microbiológica o fisicoquímica | `Operario` | Solo Técnico de calidad | Sí |

### 1.5. Cargo del empleado — `EMPLEADO.cargo`

Valores: `Operador de tanque`, `Técnico de calidad`, `Supervisor`. En todo el documento se usa **cargo**, que es el atributo del modelo (no "rol").

## 2. Preguntas y decisiones de diseño

La columna **Origen** indica si la afirmación viene de la planta (planteamiento del Módulo 1), de una norma o práctica general de la industria, o si es un supuesto del grupo. Las cardinalidades se expresan como en el diagrama EER.

| # | Pregunta | Decisión | Justificación | Impacto en el diseño | Origen |
|---|---|---|---|---|---|
| 1 | ¿Un lote de producción puede contener leche de varios proveedores? | Sí. La leche de distintos proveedores se acopia en un silo antes de asignarse a un tanque. | La leche se homogeniza en el silo; exigir un solo proveedor por lote no reflejaría la operación. | `ALMACENA` es M:N entre lote de leche (0,N) y silo (0,N). `ASIGNA` es ternaria: Silo (0,N), Tanque (0,N) y LoteProducción (1,N), con el volumen aportado por cada silo. | Supuesto del grupo |
| 2 | ¿El saborizante o la pulpa se añaden en el tanque principal o en una etapa posterior? | En un tanque secundario de mezcla, después de la fermentación base. Al trasladar el lote a la mezcla se libera el tanque de fermentación y se abre el uso del tanque de mezcla (ver #7). | Corresponde al proceso de yogurt saborizado (base blanca y luego mezcla). | Un lote puede usar más de un tanque en secuencia: `OCUPA` es M:N entre Tanque (0,N) y LoteProducción (0,N), con un registro por tanque usado. El sabor se registra en `CONSUME`. El lote base y el mezclado son el mismo lote que cambia de tanque. | Supuesto del grupo |
| 3 | ¿Un lote que reprueba una prueba de calidad puede llegar a producto terminado? | No. Solo se envasa un lote con estado `aprobado`; uno `rechazado` no puede llegar a `ENVASADO` y termina en descarte. | Regla de inocuidad: no sale producto que no pasó control de calidad. | `TIENE`: un lote tiene de 0 a N pruebas y cada prueba pertenece a exactamente un lote (1,1). El estado del lote (dominio 1.1) controla si puede avanzar a envasado (RN-03). | Norma o práctica general |
| 4 | ¿Quién registra el pH en línea: un sensor o un operario? | Ambos: el sensor mide cada 5 minutos y el operario valida manualmente cada 2 horas. | El sensor da continuidad pero puede fallar; la validación humana es el respaldo. | `PRUEBA_CALIDAD` guarda `origen_registro` (`Sensor` u `Operario`). `REGISTRA`: una prueba tiene 0 o 1 empleado (0,1) y un empleado registra de 0 a N pruebas; la prueba de sensor no lleva empleado. | Supuesto del grupo (valores de ejemplo, ajustables a la planta) |
| 5 | ¿La leche con dictamen microbiológico rechazado puede usarse? | No, y ni siquiera ingresa al silo: solo entra leche con dictamen `aprobado`. El dictamen lo emite el Técnico de calidad en la recepción, antes de descargar. | La recepción y el laboratorio deciden la aprobación o el descarte de la leche cruda (Módulo 1). | El dictamen de `LOTE_LECHE` debe consultarse antes de registrar la entrada a un silo en `ALMACENA` (RN-01). | Planta (Módulo 1) |
| 6 | ¿Un lote descartado genera producto terminado? | No. El estado `descartado` cierra el lote sin pasar por envasado. | Evita que un lote inválido termine despachado. | El estado del lote (dominio 1.1) separa los lotes que pueden envasarse de los que no. `GENERA`: un lote tiene de 0 a 1 descarte. | Supuesto del grupo (consecuencia de #3) |
| 7 | ¿Un tanque puede usarse para más de un lote en paralelo? | No. Procesa un lote a la vez. Se libera cuando el lote sale de él (traslado a la mezcla, envasado o descarte) y desde ese momento otro lote puede ocuparlo. | Limitación física: un tanque tiene una sola temperatura y proceso activo. | `OCUPA` guarda `fecha_hora_inicio` y `fecha_hora_fin` por cada uso; a lo sumo hay un uso activo por tanque (RN-06). | Norma o práctica general |
| 8 | ¿Los insumos (cultivos, pulpas, saborizantes) caducan y eso afecta su uso? | Sí. Cada lote de insumo tiene `fecha_caducidad` y no puede consumirse después de ella. | Un insumo vencido altera la fermentación y compromete el producto. | `LOTE_INSUMO.fecha_caducidad` debe poder compararse con la fecha de consumo (RN-02). | Norma o práctica general |
| 9 | ¿Un empleado puede ser responsable de varios lotes? | Sí, puede supervisar varios lotes en tanques distintos, pero cada lote tiene exactamente un supervisor durante todo su ciclo (ver #22). | Refleja la operación (un supervisor rota entre tanques) sin perder la responsabilidad individual. | `SUPERVISA`: cada lote tiene exactamente un supervisor (1,1) y un empleado supervisa de 0 a N lotes; `LOTE_PRODUCCION.id_empleado` es obligatoria. | Supuesto del grupo |
| 10 | ¿Qué pasa con los lotes de un supervisor que deja la planta? | El registro se conserva. El empleado no se elimina mientras tenga lotes; se marca como inactivo en `estado_vinculacion`. | Por auditoría no puede perderse quién autorizó un lote. | La FK `LOTE_PRODUCCION.id_empleado` usa `ON DELETE RESTRICT`. | Norma o práctica general |
| 11 | ¿El pH fuera de rango debe generar alerta o solo quedar registrado? | Genera alerta si permanece fuera de los límites de la prueba 15 minutos o más seguidos. | Un solo dato fuera de rango puede ser ruido del sensor; la persistencia indica un problema real. | Se conserva el historial completo de mediciones (valor, límites y fecha y hora), porque la alerta mira varios registros seguidos. La alerta se calcula por consulta (ver #23). | Supuesto del grupo (el laboratorio de la planta inspecciona cada 15 minutos, Módulo 1) |
| 12 | ¿Todo descarte debe justificarse? | Sí: motivo, volumen descartado y fecha. | Sin motivo no hay análisis de causas ni auditoría de pérdidas. | `DESCARTE` es entidad débil de `LOTE_PRODUCCION`: cada descarte pertenece a exactamente un lote (1,1) y un lote tiene de 0 a 1 descarte (RN-05). | Supuesto del grupo |
| 13 | ¿Un lote de insumo puede usarse en varios lotes de producción? | Sí. Se consume parcialmente en distintos lotes hasta agotarse; vale para cualquier tipo de insumo. | Los insumos se reciben por lote de proveedor y se usan en varias tandas. | `CONSUME` es M:N entre LoteInsumo (0,N) y LoteProducción (0,N) y guarda `cantidad_consumida`; `LOTE_INSUMO.cantidad_disponible` lleva lo que queda (RN-10). | Supuesto del grupo |
| 14 | ¿Se registra la temperatura del producto terminado? | Sí, la de envasado y la de despacho (al momento de salir de la planta); no la del trayecto. | La cadena de frío es causa común de reclamos; el transporte externo está fuera del alcance (Módulo 1). | `ENVASADO.temperatura_envasado` y `ENVASADO.temperatura_despacho`. | Supuesto del grupo |
| 15 | ¿Todos los empleados pueden hacer cualquier tarea? | No. Cada empleado tiene un cargo (Operador de tanque, Técnico de calidad o Supervisor) que determina qué puede registrar. | Hay separación de funciones en la planta (bacteriólogas en calidad, operarios por turno). | `EMPLEADO.cargo` es la base de los permisos por cargo (RN-09) y de los roles de la Entrega 3. | Supuesto del grupo (apoyado en el Módulo 1) |
| 16 | ¿Un tanque tiene una capacidad máxima que deba respetarse? | Sí. La leche asignada al lote activo de un tanque no puede superar su `capacidad_maxima` en litros. | Evita datos físicamente imposibles. | `TANQUE.capacidad_maxima` y `ASIGNA.volumen_asignado_litros` permiten la comparación (RN-07). | Norma o práctica general (límite físico) |
| 17 | ¿Cuánto tiempo se conserva el histórico de lotes y pruebas? | Mínimo 365 días desde el cierre del lote (último envasado o descarte). | Ante un reclamo o auditoría, debe poder mostrarse el historial completo de un lote. | No se borran lotes ni pruebas dentro del plazo; las FK hacia `LOTE_PRODUCCION` usan `ON DELETE RESTRICT` (RN-08). | Supuesto del grupo (el plazo se confirma con la norma sanitaria vigente) |
| 18 | ¿Se distingue el canal de destino del producto envasado? | Sí: `destino` puede ser mayorista, minorista o venta directa. | El canal afecta el empaque y la respuesta a reclamos. | `ENVASADO.destino` es obligatorio y de valores controlados (RN-11). | Supuesto del grupo |
| 19 | ¿Hasta dónde llega la trazabilidad de un lote: finca, proveedor o silo? | Hasta el silo. De un lote de producción se llega a los silos que lo alimentaron (`ASIGNA`) y de cada silo a los lotes de leche que ingresaron a él (`ALMACENA`); no se calcula una proporción exacta por proveedor. | La leche se homogeniza en el silo, por lo que no se puede atribuir cada litro a un proveedor. | Cadena de consulta: lote de producción, `ASIGNA`, silo, `ALMACENA`, lote de leche y proveedor (`SUMINISTRA`: un lote de leche tiene exactamente 1 proveedor y un proveedor suministra 0 a N lotes). La respuesta a "¿qué proveedores?" es un conjunto candidato, no porcentajes. | Supuesto del grupo (consecuencia de #1) |
| 20 | ¿La leche cruda rechazada en la recepción genera un descarte? | No. Se registra el lote de leche con dictamen `rechazado` y no ingresa a silo; no se crea un `DESCARTE`. | `DESCARTE` depende de un lote de producción y esa leche nunca llegó a producción. | `DESCARTE` se relaciona solo con `LOTE_PRODUCCION`; `LOTE_LECHE` conserva el registro rechazado para auditoría. | Supuesto del grupo |
| 21 | ¿Cuándo se considera cerrado un lote? | Cuando llega a un estado final: `envasado` o `descartado`. La fecha de cierre es la del último envasado o la del descarte. | Hace falta una definición única para aplicar las reglas de tanque, volumen y conservación. | Define "lote activo" y "lote cerrado" en RN-06, RN-07 y RN-08 (sección 1.3). | Supuesto del grupo |
| 22 | ¿Se guarda el historial de supervisores de un lote? | No. Cada lote tiene un solo supervisor durante todo su ciclo (quien lo autorizó), sin historial de cambios. | Mantiene clara la responsabilidad individual y evita una tabla de historial innecesaria. | Basta `LOTE_PRODUCCION.id_empleado`; `SUPERVISA` queda en (1,1) del lado del lote y (0,N) del lado del empleado. | Supuesto del grupo |
| 23 | ¿Las alertas de pH se guardan en una tabla? | No. Se calculan por consulta (vista) sobre el historial de `PRUEBA_CALIDAD`. | Todo lo necesario ya está registrado; una tabla de alertas duplicaría datos. | No hay entidad nueva; la vista detecta las rachas fuera de rango de 15 minutos o más (RN-04). | Supuesto del grupo |

## 3. Reglas de negocio (restricciones que el sistema debe forzar)

Cada regla se verifica con un sí o no, un número o una fecha. **[E2]** indica un mecanismo declarativo (`NOT NULL`, `CHECK`, `FK`, `UNIQUE`) que se implementa en la Entrega 2; **[E3]** indica un *trigger* o permiso que se implementa en la Entrega 3.

| Código | Regla | Se verifica con | Mecanismo concreto |
|---|---|---|---|
| RN-01 | Solo la leche con dictamen microbiológico `aprobado` puede ingresar a un silo (y, por tanto, asignarse a un tanque). El dictamen lo emite el Técnico de calidad en la recepción, antes de descargar. | Sí o no (dictamen = `aprobado`) | `CHECK` en `LOTE_LECHE`: estado `disponible` solo con dictamen `aprobado` [E2]. *Trigger* `BEFORE INSERT` en `ALMACENA` que consulta `LOTE_LECHE.dictamen_microbiologico` [E3]. |
| RN-02 | Un lote de insumo no puede consumirse después de su fecha de caducidad. | Fecha (`fecha_hora_consumo` menor o igual a `fecha_caducidad`) | `CHECK` (`fecha_caducidad` mayor o igual a `fecha_recepcion`) en `LOTE_INSUMO` [E2]. *Trigger* `BEFORE INSERT` en `CONSUME` que compara las fechas [E3]. |
| RN-03 | Un lote solo puede envasarse si su estado es `aprobado`; con estado `rechazado` (o cualquier otro) no puede tener registros de envasado. | Sí o no (estado = `aprobado`) | `CHECK` del dominio de estados en `LOTE_PRODUCCION` [E2]. *Trigger* `BEFORE INSERT` en `ENVASADO` que lee `LOTE_PRODUCCION.estado` [E3]. |
| RN-04 | Se genera una alerta cuando las mediciones de un parámetro (por ejemplo pH) de un lote permanecen fuera de `[valor_minimo_permitido, valor_maximo_permitido]` durante 15 minutos o más seguidos. Los límites son los del estándar de calidad del producto, guardados en cada prueba. | Número (15 minutos) y rango (mínimo y máximo) | `CHECK` (`valor_minimo_permitido` menor o igual a `valor_maximo_permitido`) en `PRUEBA_CALIDAD` [E2]. Vista sobre `PRUEBA_CALIDAD` que detecta las rachas; no hay tabla de alertas (#23) [E2]. |
| RN-05 | Todo descarte debe tener motivo, volumen descartado mayor que 0 y fecha. | Sí o no; número (volumen mayor que 0) | `NOT NULL` en `motivo`, `volumen_descartado`, `fecha_hora_descarte` y `id_lote_produccion`; `CHECK` (`volumen_descartado` mayor que 0) en `DESCARTE` [E2]. |
| RN-06 | Un tanque no puede tener dos usos activos. Uso activo = registro de `OCUPA` sin `fecha_hora_fin`. Termina cuando el lote sale del tanque (traslado a la mezcla, envasado o descarte); solo entonces otro lote puede ocuparlo. | Sí o no (`fecha_hora_fin` vacía) | Índice único parcial en `OCUPA (id_tanque)` donde `fecha_hora_fin` es nula [E2]. *Trigger* de respaldo que valida el traslado entre tanques [E3]. |
| RN-07 | Para el lote activo de un tanque, la suma de `volumen_asignado_litros` de sus asignaciones a ese tanque no puede superar la `capacidad_maxima` del tanque. | Número (litros) | `CHECK` (`volumen_actual` menor o igual a `capacidad_maxima`) en `TANQUE` [E2]. *Trigger* `BEFORE INSERT` en `ASIGNA` que suma las asignaciones del lote a ese tanque [E3]. |
| RN-08 | Los lotes de producción y sus pruebas no pueden eliminarse antes de 365 días contados desde el cierre del lote (último envasado, o descarte si fue descartado). | Fecha (cierre más 365 días) | FK con `ON DELETE RESTRICT` desde `PRUEBA_CALIDAD`, `ENVASADO` y `DESCARTE` hacia `LOTE_PRODUCCION` [E2]. *Trigger* `BEFORE DELETE` que compara la fecha, y rol de la aplicación sin privilegio `DELETE` [E3]. |
| RN-09 | Una prueba de laboratorio (microbiológica o fisicoquímica) solo puede registrarla un empleado con cargo `Técnico de calidad`. La validación manual en línea la registra un Operador de tanque o un Técnico de calidad; la medición del sensor no lleva empleado. | Sí o no (cargo del empleado) | `CHECK` en `PRUEBA_CALIDAD`: `origen_registro` `Sensor` implica `id_empleado` nulo, y `Operario` implica `id_empleado` no nulo [E2]. *Trigger* `BEFORE INSERT` que verifica `EMPLEADO.cargo` según `tipo_prueba` [E3]. |
| RN-10 | Ningún lote de insumo (cultivo, pulpa, saborizante u otro) puede consumirse si su `cantidad_disponible` es 0, ni en una cantidad mayor a la disponible. | Número (`cantidad_consumida` menor o igual a `cantidad_disponible`) | `CHECK` (0 menor o igual a `cantidad_disponible`, y esta menor o igual a `cantidad_inicial`) en `LOTE_INSUMO` [E2]. *Trigger* `BEFORE INSERT` en `CONSUME` que compara la cantidad [E3]. |
| RN-11 | Todo envasado debe indicar un `destino` válido: mayorista, minorista o venta directa. | Sí o no | `NOT NULL` y `CHECK` (`destino` en los tres valores) en `ENVASADO` [E2]. |

## 4. Origen de las cifras y ejemplos

| Cifra o ejemplo | Origen | Comentario |
|---|---|---|
| 5 minutos (lectura del sensor) | Supuesto del grupo | Valor de ejemplo; no es una medición de la planta. Se ajusta si la planta usa otro intervalo. |
| 2 horas (validación manual) | Supuesto del grupo | Igual que el anterior. |
| 15 minutos (alerta de pH) | Supuesto del grupo | Se toma como referencia que el laboratorio de la planta inspecciona cada 15 minutos (Módulo 1). |
| 365 días (conservación) | Supuesto del grupo | Se confirma con la norma sanitaria vigente. |
| Supuestos 4 a 6 | #4 y #6: grupo. #5: planta (Módulo 1) | Ver la columna Origen de la sección 2. |



