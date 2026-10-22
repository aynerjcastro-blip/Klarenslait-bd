# Módulo 3 — Interrogatorio, Supuestos y Reglas de Negocio (versión corregida, segunda ronda)

**Proyecto:** KlarensLait — Trazabilidad de producción láctea
**RP:** Juan Guerra
**RA:** Carlos Camargo, Junior Ávila, Sebastián Ramos, Alfonso Araujo

Esta versión incorpora las dos rondas de correcciones (resumidas en la sección 6). Los nombres de tablas y columnas son los del esquema relacional (`docs/06`) y el diagrama EER.

## 1. Dominios y definiciones

Estas definiciones se usan en todos los supuestos y reglas; así cada término tiene un solo significado y cada dominio tiene valores exactos.

### 1.1. Estado del lote de producción (dominio único) — `LOTE_PRODUCCION.estado`

| Estado | Significado | ¿Activo o cerrado? |
|---|---|---|
| `en_proceso` | Se está elaborando (fermentación o mezcla) o espera dictamen. Un resultado de prueba `reproceso` lo mantiene aquí. | Activo |
| `aprobado` | Pasó el control de calidad; puede envasarse. Mientras el envasado esté abierto, el lote sigue `aprobado`. | Activo |
| `rechazado` | No pasó el control de calidad; no puede envasarse y debe terminar en descarte. | Activo |
| `envasado` | El Supervisor cerró el envasado del lote (ver 1.3). | Cerrado |
| `descartado` | Se registró el descarte (motivo y volumen). | Cerrado |

Transiciones permitidas: `en_proceso` → `aprobado` o `rechazado`; `aprobado` → `envasado`; `rechazado` → `descartado`; `en_proceso` → `descartado` (descarte directo por un incidente).

### 1.2. Lote de leche cruda

| Columna | Valores |
|---|---|
| `dictamen_microbiologico` | `pendiente`, `aprobado`, `rechazado` |
| `estado_lote` | `recibido` (antes del dictamen), `disponible` (dictamen aprobado y con litros), `agotado` (sin litros disponibles), `rechazado` (dictamen rechazado) |

Coherencia: un lote `disponible` exige dictamen `aprobado`, y un dictamen `rechazado` implica estado `rechazado`. El dictamen se deriva de las pruebas microbiológicas del lote de leche (supuesto 24): ninguna prueba `rechazado` y al menos una `aprobado` da `aprobado`; cualquier prueba `rechazado` da `rechazado`; sin pruebas queda `pendiente`.

### 1.3. Lote activo, lote cerrado, uso activo de un tanque y cierre del envasado

- **Lote cerrado:** estado `envasado` o `descartado`. Cualquier otro estado es **lote activo**.
- **Fecha de cierre del lote:** `fecha_hora_envasado` del último envasado, o `fecha_hora_descarte` si fue descartado.
- **Uso activo de un tanque:** registro de `OCUPA` con `fecha_hora_fin` vacía. El uso termina cuando el lote sale del tanque: al trasladarse al tanque de mezcla, o al envasarse o descartarse si no pasa por mezcla.
- **Envasado abierto y cerrado:** cada registro de `ENVASADO` nace `abierto` mientras se llena esa presentación y pasa a `cerrado` al terminarla. El **envasado del lote se cierra** cuando el Supervisor lo cierra explícitamente, lo que exige al menos un registro `cerrado` y ninguno `abierto`; en ese momento el lote pasa a `envasado` y ya no admite más registros (supuesto 28).

### 1.4. A qué pertenece cada prueba y quién la registra (`PRUEBA_CALIDAD`)

Una prueba pertenece a **un lote de producción o a un lote de leche, nunca a ambos ni a ninguno** (`id_lote_produccion` o `id_lote_leche`, exactamente uno no nulo).

| `tipo_prueba` | Tipo | Puede pertenecer a |
|---|---|---|
| `microbiologica` | Laboratorio | Lote de leche o de producción |
| `fisicoquimica` | Laboratorio (acidez, grasa, proteína, pH de recepción, viscosidad) | Lote de leche o de producción |
| `ph_linea` | En línea | Solo lote de producción |
| `temperatura_linea` | En línea | Solo lote de producción |

| `origen_registro` | Quién lo registra | Aplica a |
|---|---|---|
| `Sensor` | Nadie (sin empleado) | Solo tipos en línea |
| `Operario` | Un empleado: Técnico de calidad para laboratorio; Operador de tanque o Técnico de calidad para en línea | Cualquier tipo |

### 1.5. Cargo del empleado — `EMPLEADO.cargo`

Valores: `Operador de tanque`, `Técnico de calidad`, `Supervisor`. En todo el documento se usa **cargo**, que es el atributo del modelo (no "rol").

### 1.6. Otros dominios con valores exactos

| Columna | Valores |
|---|---|
| `PRUEBA_CALIDAD.resultado` | `aprobado`, `rechazado`, `reproceso` |
| `OCUPA.estado_uso` | `activo`, `finalizado` |
| `ALMACENA.tipo_movimiento` | `entrada` (ingresa leche al silo), `salida` (sale del silo) |
| `ENVASADO.destino` | `mayorista`, `minorista`, `venta directa` |
| `ENVASADO.estado` | `abierto`, `cerrado` |
| `LOTE_PRODUCCION.tipo_produccion` | `yogurt`, `queso`, `suero`, `avena`, `leche_uht` |
| `ESTANDAR_CALIDAD`: parámetro | `ph`, `temperatura`, `acidez_dornic`, `grasa`, `viscosidad`, `microorganismos` |
| `ESTANDAR_CALIDAD`: etapa | `recepcion`, `fermentacion`, `mezcla`, `envasado` |

## 2. Preguntas y decisiones de diseño

La columna **Origen** indica si la afirmación viene de la planta (planteamiento del Módulo 1), de una norma o práctica general de la industria, o si es un supuesto del grupo. Las cardinalidades se expresan como en el diagrama EER.

| # | Pregunta | Decisión | Justificación | Impacto en el diseño | Origen |
|---|---|---|---|---|---|
| 1 | ¿Un lote de producción puede contener leche de varios proveedores? | Sí. La leche de distintos proveedores se acopia en un silo antes de asignarse a un tanque. | La leche se homogeniza en el silo; exigir un solo proveedor por lote no reflejaría la operación. | `ALMACENA` es M:N entre lote de leche (0,N) y silo (0,N). `ASIGNA` es ternaria: Silo (0,N), Tanque (0,N) y LoteProducción (1,N), con el volumen aportado por cada silo. | Supuesto del grupo |
| 2 | ¿El saborizante o la pulpa se añaden en el tanque principal o en una etapa posterior? | En un tanque secundario de mezcla, después de la fermentación base. Al trasladar el lote a la mezcla se libera el tanque de fermentación y se abre el uso del tanque de mezcla (ver #7). | Corresponde al proceso de yogurt saborizado (base blanca y luego mezcla). | `OCUPA` es M:N: un lote usa al menos un tanque, de 1 a N en secuencia (1,N), y un tanque puede tener de 0 a N lotes a lo largo del tiempo (0,N). Hay un registro de `OCUPA` por tanque usado. El sabor se registra en `CONSUME`. El lote base y el mezclado son el mismo lote que cambia de tanque. | Supuesto del grupo |
| 3 | ¿A qué pertenece una prueba de calidad y puede un lote que reprueba llegar a producto terminado? | Una prueba pertenece a un lote de producción o a uno de leche, nunca a ambos. Un lote de producción con estado `rechazado` no puede llegar a `ENVASADO`; solo se envasa uno `aprobado`. | Regla de inocuidad: no sale producto que no pasó control de calidad. Las pruebas de la leche cruda se hacen antes de que exista un lote de producción. | `TIENE` pasa a (0,1) del lado de la prueba: cada prueba tiene 0 o 1 lote de producción, y un lote de producción tiene de 0 a N pruebas. `ANALIZA` (#24) relaciona la prueba con 0 o 1 lote de leche. Exactamente una de las dos FK es no nula (RN-13). El estado del lote controla si puede envasarse (RN-03). | Norma o práctica general |
| 4 | ¿Quién registra el pH en línea: un sensor o un operario? | Ambos: el sensor mide cada 5 minutos y el operario valida manualmente cada 2 horas. | El sensor da continuidad pero puede fallar; la validación humana es el respaldo. | `PRUEBA_CALIDAD` guarda `origen_registro` (`Sensor` u `Operario`). `REGISTRA`: una prueba tiene 0 o 1 empleado (0,1) y un empleado registra de 0 a N pruebas; la prueba de sensor no lleva empleado. | Supuesto del grupo (valores de ejemplo, ajustables a la planta) |
| 5 | ¿La leche con dictamen microbiológico rechazado puede usarse? | No, y ni siquiera ingresa al silo: solo entra leche con dictamen `aprobado`. El dictamen lo deriva de las pruebas que registra el Técnico de calidad en la recepción, antes de descargar (#24). | La recepción y el laboratorio deciden la aprobación o el descarte de la leche cruda (Módulo 1). | El dictamen de `LOTE_LECHE` debe consultarse antes de registrar la entrada a un silo en `ALMACENA` (RN-01). | Planta (Módulo 1) |
| 6 | ¿Un lote descartado genera producto terminado? | No. El estado `descartado` cierra el lote sin pasar por envasado. | Evita que un lote inválido termine despachado. | El estado del lote (dominio 1.1) separa los lotes que pueden envasarse de los que no. `GENERA`: un lote tiene de 0 a 1 descarte. | Supuesto del grupo (consecuencia de #3) |
| 7 | ¿Un tanque puede usarse para más de un lote en paralelo? | No. Procesa un lote a la vez. Se libera cuando el lote sale de él (traslado a la mezcla, envasado o descarte) y desde ese momento otro lote puede ocuparlo. | Limitación física: un tanque tiene una sola temperatura y proceso activo. | `OCUPA` guarda `fecha_hora_inicio` y `fecha_hora_fin` por cada uso; a lo sumo hay un uso activo por tanque (RN-06). Un lote usa al menos un tanque (1,N). | Norma o práctica general |
| 8 | ¿Los insumos (cultivos, pulpas, saborizantes) caducan y eso afecta su uso? | Sí. Cada lote de insumo tiene `fecha_caducidad` y no puede consumirse después de ella. | Un insumo vencido altera la fermentación y compromete el producto. | `LOTE_INSUMO.fecha_caducidad` debe poder compararse con la fecha de consumo (RN-02). | Norma o práctica general |
| 9 | ¿Un empleado puede ser responsable de varios lotes? | Sí, puede supervisar varios lotes en tanques distintos, pero cada lote tiene exactamente un supervisor durante todo su ciclo (ver #22). | Refleja la operación (un supervisor rota entre tanques) sin perder la responsabilidad individual. | `SUPERVISA`: cada lote tiene exactamente un supervisor (1,1) y un empleado supervisa de 0 a N lotes; `LOTE_PRODUCCION.id_empleado` es obligatoria. | Supuesto del grupo |
| 10 | ¿Qué pasa con los lotes de un supervisor que deja la planta? | El registro se conserva. El empleado no se elimina mientras tenga lotes; se marca como inactivo en `estado_vinculacion`. | Por auditoría no puede perderse quién autorizó un lote. | La FK `LOTE_PRODUCCION.id_empleado` usa `ON DELETE RESTRICT`. | Norma o práctica general |
| 11 | ¿El pH fuera de rango debe generar alerta o solo quedar registrado? | Genera alerta si permanece fuera de los límites del estándar de calidad 15 minutos o más seguidos. Los límites no se guardan en cada prueba: vienen del estándar (#26). | Un solo dato fuera de rango puede ser ruido del sensor; la persistencia indica un problema real. | Se conserva el historial completo de mediciones (valor, fecha y hora y su estándar), porque la alerta mira varios registros seguidos. La alerta se calcula por consulta (#23). | Supuesto del grupo (el laboratorio de la planta inspecciona cada 15 minutos, Módulo 1) |
| 12 | ¿Todo descarte debe justificarse? | Sí: motivo, volumen descartado y fecha. | Sin motivo no hay análisis de causas ni auditoría de pérdidas. | `DESCARTE` es entidad débil de `LOTE_PRODUCCION`: cada descarte pertenece a exactamente un lote (1,1) y un lote tiene de 0 a 1 descarte (RN-05). | Supuesto del grupo |
| 13 | ¿Un lote de insumo puede usarse en varios lotes de producción? | Sí. Se consume parcialmente en distintos lotes hasta agotarse; vale para cualquier tipo de insumo. | Los insumos se reciben por lote de proveedor y se usan en varias tandas. | `CONSUME` es M:N entre LoteInsumo (0,N) y LoteProducción (0,N) y guarda `cantidad_consumida`; `LOTE_INSUMO.cantidad_disponible` lleva lo que queda (RN-10). | Supuesto del grupo |
| 14 | ¿Se registra la temperatura del producto terminado? | Sí, la de envasado y la de despacho (al momento de salir de la planta); no la del trayecto. | La cadena de frío es causa común de reclamos; el transporte externo está fuera del alcance (Módulo 1). | `ENVASADO.temperatura_envasado` y `ENVASADO.temperatura_despacho`. | Supuesto del grupo |
| 15 | ¿Todos los empleados pueden hacer cualquier tarea? | No. Cada empleado tiene un cargo (Operador de tanque, Técnico de calidad o Supervisor) que determina qué puede registrar. | Hay separación de funciones en la planta (bacteriólogas en calidad, operarios por turno). | `EMPLEADO.cargo` es la base de los permisos por cargo (RN-09) y de los roles de la Entrega 3. | Supuesto del grupo (apoyado en el Módulo 1) |
| 16 | ¿Un tanque tiene una capacidad máxima que deba respetarse? | Sí. La leche asignada al lote activo de un tanque no puede superar su `capacidad_maxima` en litros. | Evita datos físicamente imposibles. | `TANQUE.capacidad_maxima` y `ASIGNA.volumen_asignado_litros` permiten la comparación (RN-07). | Norma o práctica general (límite físico) |
| 17 | ¿Cuánto tiempo se conserva el histórico de lotes y pruebas? | Mínimo 365 días desde el cierre del lote de producción (último envasado o descarte); para las pruebas de un lote de leche, desde su `fecha_recepcion`. | Ante un reclamo o auditoría, debe poder mostrarse el historial completo de un lote. | No se borran lotes ni pruebas dentro del plazo; las FK hacia `LOTE_PRODUCCION` y `LOTE_LECHE` usan `ON DELETE RESTRICT` (RN-08). | Supuesto del grupo (el plazo se confirma con la norma sanitaria vigente) |
| 18 | ¿Se distingue el canal de destino del producto envasado? | Sí: `destino` puede ser mayorista, minorista o venta directa. | El canal afecta el empaque y la respuesta a reclamos. | `ENVASADO.destino` es obligatorio y de valores controlados (RN-11). | Supuesto del grupo |
| 19 | ¿Hasta dónde llega la trazabilidad de un lote: finca, proveedor o silo? | Hasta el silo y solo con lo que había en él en el momento de la asignación. De un lote de producción se llega a sus asignaciones (`ASIGNA`) y, de cada una, al silo y a los lotes de leche que estaban en ese silo en `fecha_hora_asignacion`. No se devuelven todos los lotes que pasaron alguna vez por el silo ni se calcula una proporción por proveedor. | La leche se homogeniza en el silo y los lotes de leche entran y salen en momentos distintos; solo los presentes en el momento de la asignación pudieron formar parte de ella. | Un lote de leche "estaba en el silo" si, hasta `fecha_hora_asignacion`, la suma de sus `entrada` en `ALMACENA` menos la de sus `salida` es mayor que 0. Cadena de consulta: lote de producción, `ASIGNA`, silo, `ALMACENA` (saldo en ese momento), lote de leche y proveedor (`SUMINISTRA`: un lote de leche tiene exactamente 1 proveedor y un proveedor suministra 0 a N lotes). | Supuesto del grupo (consecuencia de #1) |
| 20 | ¿La leche cruda rechazada en la recepción genera un descarte? | No. Se registra el lote de leche con dictamen `rechazado` y no ingresa a silo; no se crea un `DESCARTE`. | `DESCARTE` depende de un lote de producción y esa leche nunca llegó a producción. | `DESCARTE` se relaciona solo con `LOTE_PRODUCCION`; `LOTE_LECHE` conserva el registro rechazado para auditoría. | Supuesto del grupo |
| 21 | ¿Cuándo se considera cerrado un lote? | Cuando llega a un estado final: `envasado` o `descartado`. La fecha de cierre es la del último envasado o la del descarte. | Hace falta una definición única para aplicar las reglas de tanque, volumen y conservación. | Define "lote activo" y "lote cerrado" en RN-06, RN-07 y RN-08 (sección 1.3). | Supuesto del grupo |
| 22 | ¿Se guarda el historial de supervisores de un lote? | No. Cada lote tiene un solo supervisor durante todo su ciclo (quien lo autorizó), sin historial de cambios. | Mantiene clara la responsabilidad individual y evita una tabla de historial innecesaria. | Basta `LOTE_PRODUCCION.id_empleado`; `SUPERVISA` queda en (1,1) del lado del lote y (0,N) del lado del empleado. | Supuesto del grupo |
| 23 | ¿Las alertas de pH se guardan en una tabla? | No. Se calculan por consulta (vista) sobre el historial de `PRUEBA_CALIDAD`. | Todo lo necesario ya está registrado; una tabla de alertas duplicaría datos. | No hay entidad nueva; la vista detecta las rachas fuera de rango de 15 minutos o más (RN-04). | Supuesto del grupo |
| 24 | ¿Quién registra las pruebas de la leche cruda y el dictamen se deriva de ellas? | Las pruebas microbiológicas y fisicoquímicas de un lote de leche las registra el Técnico de calidad. El `dictamen_microbiologico` del lote se deriva de sus pruebas microbiológicas (regla en 1.2); no se edita a mano. | El dictamen debe poder justificarse con las pruebas que lo respaldan, y la leche se analiza antes de entrar al silo. | `ANALIZA`: cada prueba tiene 0 o 1 lote de leche (0,1) y un lote de leche tiene de 0 a N pruebas (0,N). `PRUEBA_CALIDAD.id_lote_leche` es opcional y excluyente con `id_lote_produccion` (RN-13). | Supuesto del grupo |
| 25 | ¿Cada lote de insumo tiene un proveedor? | Sí, exactamente uno. | La trazabilidad de insumos (cultivos, pulpas) exige saber quién los entregó y cuándo caducan. | `PROVEE`: un proveedor provee de 0 a N lotes de insumo y cada lote de insumo tiene exactamente un proveedor (1,1); `LOTE_INSUMO.id_proveedor` es obligatoria. | Supuesto del grupo (apoyado en el Módulo 4: el proveedor suministra leche u otros insumos) |
| 26 | ¿De dónde salen los límites permitidos de una prueba? | Del estándar de calidad, que define los límites por parámetro, producto y etapa. No se guardan en cada prueba: cada prueba referencia su estándar. Un cambio de límite se hace creando un estándar nuevo, no editando el que ya usan pruebas existentes. | Los límites son compartidos por todas las pruebas del mismo parámetro, producto y etapa; así se evita repetirlos y se conserva el resultado histórico. | `ESTANDAR_CALIDAD` guarda `valor_minimo_permitido` y `valor_maximo_permitido`, con `CHECK` de mínimo menor o igual que máximo. Reemplaza los límites que antes estaban en `PRUEBA_CALIDAD` (RN-04). | Supuesto del grupo (los valores vienen de la norma sanitaria y de la planta) |
| 27 | ¿Qué fechas se registran en el producto envasado? | `fecha_vencimiento` (fecha límite de consumo, definida al envasar) y `fecha_despacho` (fecha de salida de la planta; vacía mientras no se despacha). | Son las fechas que pide la auditoría sanitaria para el producto terminado. | `ENVASADO.fecha_vencimiento` es obligatoria y posterior a `fecha_hora_envasado`; `ENVASADO.fecha_despacho`, si existe, no es anterior a `fecha_hora_envasado`. | Supuesto del grupo |
| 28 | ¿Cuándo se cierra el envasado de un lote? | Un lote puede tener varios registros de envasado (varias presentaciones). El envasado se cierra cuando el Supervisor lo cierra, con al menos un registro `cerrado` y ninguno `abierto`; entonces el lote pasa a `envasado`. | Con una sola regla de "solo envasar si `aprobado`", el primer envasado cambiaría el estado y impediría registrar las demás presentaciones. | `ENVASADO.estado` (`abierto`, `cerrado`). RN-03 permite registrar envasados solo con el lote `aprobado` y solo permite pasar a `envasado` al cerrar. | Supuesto del grupo |

## 3. Reglas de negocio (restricciones que el sistema debe forzar)

Cada regla se verifica con un sí o no, un número o una fecha. **[E2]** indica un mecanismo declarativo (`NOT NULL`, `CHECK`, `FK`, `UNIQUE`) que se implementa en la Entrega 2; **[E3]** indica un *trigger* o permiso que se implementa en la Entrega 3.

| Código | Regla | Se verifica con | Mecanismo concreto |
|---|---|---|---|
| RN-01 | Solo la leche con dictamen microbiológico `aprobado` puede ingresar a un silo (y, por tanto, asignarse a un tanque). El dictamen se deriva de las pruebas que registra el Técnico de calidad en la recepción, antes de descargar. | Sí o no (dictamen = `aprobado`) | `CHECK` en `LOTE_LECHE`: estado `disponible` solo con dictamen `aprobado` [E2]. *Trigger* `BEFORE INSERT` en `ALMACENA` que consulta `LOTE_LECHE.dictamen_microbiologico` [E3]. |
| RN-02 | Un lote de insumo no puede consumirse después de su fecha de caducidad. | Fecha (`fecha_hora_consumo` menor o igual a `fecha_caducidad`) | `CHECK` (`fecha_caducidad` mayor o igual a `fecha_recepcion`) en `LOTE_INSUMO` [E2]. *Trigger* `BEFORE INSERT` en `CONSUME` que compara las fechas [E3]. |
| RN-03 | Solo puede registrarse un envasado en un lote con estado `aprobado` (envasado abierto); con cualquier otro estado, incluido `rechazado`, no. El lote solo pasa a `envasado` cuando el Supervisor cierra el envasado y ninguno de sus registros está `abierto`. | Sí o no (estado = `aprobado`; sin registros `abierto`) | `CHECK` del dominio de estados en `LOTE_PRODUCCION` y de `ENVASADO.estado` [E2]. *Trigger* `BEFORE INSERT` en `ENVASADO` que lee `LOTE_PRODUCCION.estado`, y *trigger* `BEFORE UPDATE` en `LOTE_PRODUCCION` que solo permite pasar a `envasado` con al menos un envasado `cerrado` y ninguno `abierto` [E3]. |
| RN-04 | Se genera una alerta cuando las mediciones de un parámetro (por ejemplo pH) de un lote permanecen fuera de `[valor_minimo_permitido, valor_maximo_permitido]` durante 15 minutos o más seguidos. Los límites son los del `ESTANDAR_CALIDAD` que corresponde al parámetro, producto y etapa de la prueba. | Número (15 minutos) y rango (mínimo y máximo del estándar) | `CHECK` (`valor_minimo_permitido` menor o igual a `valor_maximo_permitido`) en `ESTANDAR_CALIDAD` [E2]. Vista sobre `PRUEBA_CALIDAD` unida con `ESTANDAR_CALIDAD` que detecta las rachas; no hay tabla de alertas (#23) [E2]. |
| RN-05 | Todo descarte debe tener motivo, volumen descartado mayor que 0 y fecha. | Sí o no; número (volumen mayor que 0) | `NOT NULL` en `motivo`, `volumen_descartado`, `fecha_hora_descarte` y `id_lote_produccion`; `CHECK` (`volumen_descartado` mayor que 0) en `DESCARTE` [E2]. |
| RN-06 | Un tanque no puede tener dos usos activos. Uso activo = registro de `OCUPA` sin `fecha_hora_fin`. Termina cuando el lote sale del tanque (traslado a la mezcla, envasado o descarte); solo entonces otro lote puede ocuparlo. | Sí o no (`fecha_hora_fin` vacía) | Índice único parcial en `OCUPA (id_tanque)` donde `fecha_hora_fin` es nula [E2]. *Trigger* de respaldo que valida el traslado entre tanques [E3]. |
| RN-07 | Para el lote activo de un tanque, la suma de `volumen_asignado_litros` de sus asignaciones a ese tanque no puede superar la `capacidad_maxima` del tanque. | Número (litros) | `CHECK` (`volumen_actual` menor o igual a `capacidad_maxima`) en `TANQUE` [E2]. *Trigger* `BEFORE INSERT` en `ASIGNA` que suma las asignaciones del lote a ese tanque [E3]. |
| RN-08 | Los lotes de producción y sus pruebas no pueden eliminarse antes de 365 días contados desde el cierre del lote (último envasado, o descarte si fue descartado). Las pruebas de un lote de leche no pueden eliminarse antes de 365 días desde su `fecha_recepcion`. | Fecha (cierre más 365 días; recepción más 365 días) | FK con `ON DELETE RESTRICT` desde `PRUEBA_CALIDAD`, `ENVASADO` y `DESCARTE` hacia `LOTE_PRODUCCION`, y desde `PRUEBA_CALIDAD` hacia `LOTE_LECHE` [E2]. *Trigger* `BEFORE DELETE` que compara la fecha, y rol de la aplicación sin privilegio `DELETE` [E3]. |
| RN-09 | Una prueba de laboratorio (`microbiologica` o `fisicoquimica`), de un lote de leche o de producción, solo puede registrarla un empleado con cargo `Técnico de calidad`. La validación manual en línea (`ph_linea` o `temperatura_linea` con origen `Operario`) la registra un Operador de tanque o un Técnico de calidad. La medición del sensor (origen `Sensor`) no lleva empleado y solo existe para tipos en línea. | Sí o no (cargo del empleado según `tipo_prueba`) | `CHECK` en `PRUEBA_CALIDAD`: origen `Sensor` implica `id_empleado` nulo y `tipo_prueba` en línea; origen `Operario` implica `id_empleado` no nulo [E2]. *Trigger* `BEFORE INSERT` que verifica `EMPLEADO.cargo` según `tipo_prueba` [E3]. |
| RN-10 | Ningún lote de insumo (cultivo, pulpa, saborizante u otro) puede consumirse si su `cantidad_disponible` es 0, ni en una cantidad mayor a la disponible. | Número (`cantidad_consumida` menor o igual a `cantidad_disponible`) | `CHECK` (0 menor o igual a `cantidad_disponible`, y esta menor o igual a `cantidad_inicial`) en `LOTE_INSUMO` [E2]. *Trigger* `BEFORE INSERT` en `CONSUME` que compara la cantidad [E3]. |
| RN-11 | Todo envasado debe indicar un `destino` válido (mayorista, minorista o venta directa) y una `fecha_vencimiento` posterior a `fecha_hora_envasado`; si tiene `fecha_despacho`, no puede ser anterior a `fecha_hora_envasado`. | Sí o no; fecha | `NOT NULL` y `CHECK` (`destino` en los tres valores) en `ENVASADO`; `CHECK` de las fechas en `ENVASADO` [E2]. |
| RN-12 | Toda asignación de leche (fila de `ASIGNA`) exige un uso activo de `OCUPA` para ese mismo lote de producción y ese mismo tanque. | Sí o no (existe un `OCUPA` con ese `id_tanque` e `id_lote_produccion` y `fecha_hora_fin` vacía) | *Trigger* `BEFORE INSERT` en `ASIGNA` que busca ese uso activo en `OCUPA` [E3]. |
| RN-13 | Una prueba de calidad pertenece a exactamente un lote: de producción o de leche, nunca a ambos ni a ninguno. Las pruebas en línea (`ph_linea`, `temperatura_linea`) solo pertenecen a un lote de producción. | Sí o no | `CHECK` en `PRUEBA_CALIDAD`: exactamente uno entre `id_lote_produccion` e `id_lote_leche` es no nulo, y los tipos en línea exigen `id_lote_produccion` [E2]. |

## 4. Origen de las cifras y ejemplos

| Cifra o ejemplo | Origen | Comentario |
|---|---|---|
| 5 minutos (lectura del sensor) | Supuesto del grupo | Valor de ejemplo; no es una medición de la planta. Se ajusta si la planta usa otro intervalo. |
| 2 horas (validación manual) | Supuesto del grupo | Igual que el anterior. |
| 15 minutos (alerta de pH) | Supuesto del grupo | Se toma como referencia que el laboratorio de la planta inspecciona cada 15 minutos (Módulo 1). |
| 365 días (conservación) | Supuesto del grupo | Se confirma con la norma sanitaria vigente. |
| Supuestos 4 a 6 | #4 y #6: grupo. #5: planta (Módulo 1) | Ver la columna Origen de la sección 2. |


## 5. Registro de correcciones

### 5.1. Primera ronda

| # | Corrección pedida | Qué cambió | Dónde |
|---|---|---|---|
| 1 | Ajustar RN-01, RN-03, RN-04, RN-06 y RN-07 | RN-01 se aplica al ingresar al silo y dice quién valida; RN-03 usa el dominio único de estado; RN-04 se apoya en los límites del estándar de calidad; RN-06 define uso activo; RN-07 suma por lote activo. | Sección 3; definiciones en 1.1 y 1.3 |
| 2 | Ajustar RN-08, RN-09, RN-10 y RN-11 | RN-08 define desde cuándo corre el plazo (incluye lotes descartados); RN-09 distingue prueba de laboratorio y validación manual; RN-10 aplica a cualquier lote de insumo; RN-11 usa el nombre real del atributo (`destino`). | Sección 3; definición en 1.4 |
| 3 | Agregar supuestos nuevos | Supuestos #19 a #23: trazabilidad por silo, rechazo de leche en recepción sin descarte, lote cerrado, un supervisor por lote sin historial y alertas calculadas por consulta. | Sección 2 |
| 4 | Resolver la contradicción entre #2, #7 y RN-06 | El tanque se libera al trasladar el lote a la mezcla; un lote puede usar varios tanques en secuencia. | #2, #7 y RN-06 |
| 5 | Un solo dominio de estado del lote | Se define un dominio único con estados activos y cerrados, y todas las reglas lo usan. | Secciones 1.1 y 1.2 |
| 6 | Reemplazar "entrega posterior" por el mecanismo concreto | Cada regla indica `NOT NULL`, `CHECK`, FK con `RESTRICT`, índice único parcial o *trigger*, con la entrega en que se implementa. | Sección 3 |
| 7 | Aclarar el origen de las cifras y unificar rol con el atributo | Columna Origen en la sección 2 y tabla de la sección 4; "rol" se reemplazó por `cargo`. | Secciones 2, 4 y 1.5 |

### 5.2. Segunda ronda

| # | Corrección pedida | Qué cambió | Dónde |
|---|---|---|---|
| 1 | Supuesto 3: una prueba pertenece a un lote de producción o a uno de leche, nunca a ambos; `TIENE` pasa de (1,1) a (0,1) | #3 reescrito; `TIENE` queda (0,1) del lado de la prueba; nueva regla RN-13 con el `CHECK` de exclusividad. | #3, RN-13, sección 1.4 |
| 2 | RN-04 y supuesto 11: los límites vienen del estándar de calidad, no de cada prueba; el `CHECK` de mínimo menor o igual al máximo va en `ESTANDAR_CALIDAD` | #11 y RN-04 ya no usan límites guardados en la prueba; el `CHECK` se mueve a `ESTANDAR_CALIDAD`; nuevo supuesto #26. | #11, #26, RN-04 |
| 3 | Supuesto 2: en `OCUPA`, Tanque pasa de (0,N) a (1,N), porque un lote usa al menos un tanque | #2 y #7 indican que un lote usa de 1 a N tanques (1,N) y un tanque puede tener de 0 a N lotes (0,N). | #2, #7 |
| 4 | Agregar supuestos para `ANALIZA`, `PROVEE`, el estándar de calidad y las fechas de `ENVASADO` | Nuevos supuestos #24 (`ANALIZA`: quién registra las pruebas de leche y de dónde sale el dictamen), #25 (`PROVEE`), #26 (estándar de calidad) y #27 (fechas de vencimiento y despacho). RN-11 y RN-08 se ajustan. | #24 a #27, RN-08, RN-11 |
| 5 | Definir cuándo se cierra el envasado de un lote y reconciliarlo con RN-03 | Nuevo supuesto #28: el Supervisor cierra el envasado y el lote pasa a `envasado`; RN-03 solo permite envasar con el lote `aprobado` y solo permite el cierre sin registros `abierto`. | #28, RN-03, sección 1.3 |
| 6 | Definir el dominio de `tipo_prueba` y el de `ENVASADO.estado` | Dominio exacto de `tipo_prueba` y `origen_registro` (1.4) y de `ENVASADO.estado` (1.6); RN-09 usa esos valores. | Secciones 1.4 y 1.6, RN-09 |
| 7 | Regla de coherencia: toda fila de `ASIGNA` necesita su uso activo de `OCUPA` para ese lote y ese tanque | Nueva regla RN-12. | RN-12 |
| 8 | Supuesto 19: limitar la cadena de trazabilidad a los lotes de leche que estaban en el silo en el momento de la asignación | #19 define "estaba en el silo" con el saldo de `ALMACENA` hasta `fecha_hora_asignacion`; ya no se devuelven todos los lotes que pasaron alguna vez. | #19, `ALMACENA.tipo_movimiento` en 1.6 |
