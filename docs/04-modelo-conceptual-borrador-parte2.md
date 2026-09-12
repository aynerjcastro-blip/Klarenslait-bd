## 5. Relaciones M:N y entidades asociativas

### 5.1. Silo y LoteLecheCruda

## Relación identificada: `Silo (0,N) — contiene — LoteLecheCruda (0,N)`.

## Entidad asociativa propuesta: `MovimientoSilo`.

## Atributos principales:  fechaHora, tipoMovimiento, volumenLitros, observaciones.

## Justificación: un silo puede recibir leche de varios lotes, y un lote de leche puede trasladarse o permanecer en diferentes silos. La relación necesita registrar cantidades y momentos de entrada o salida.

## Observación: Si el proceso confirmado solo registra asignación desde silo hacia tanque, esta entidad puede ajustarse o integrarse con AsignaciónLecheTanque.

### 5.2. Silo, Tanque y LoteProducción

## Relación identificada:la asignación de leche conecta simultáneamente un silo de origen, un tanque de destino y un lote de producción.

## Entidad asociativa propuesta: `AsignaciónLecheTanque`.

## Atributos principales: fechaHoraAsignación, volumenAsignadoLitros.

## Justificación: la relación no puede ser un simple atributo, porque un tanque puede recibir volumen de varios silos y un silo puede aportar leche a diferentes tanques a lo largo del tiempo. Esta entidad permite verificar la capacidad máxima del tanque y soporta la trazabilidad de origen de la leche.

### 5.3. LoteProducción y LoteInsumo

## Relación identificada: `LoteProducción (0,N) — consume — LoteInsumo (0,N)`.

## Entidad asociativa propuesta: `ConsumoInsumo`.

## Atributos principales:fechaHoraConsumo, cantidadConsumida.

## Justificación: un lote de yogurt puede utilizar uno o varios lotes de cultivo, pulpa o saborizante, mientras que un lote de insumo puede consumirse de forma parcial en varios lotes de producción. La entidad permite controlar la disponibilidad y la caducidad del insumo.

### 5.4. Tanque y LoteProducción

## Relación identificada: `Tanque (0,N) — es utilizado por — LoteProducción (1,N)`.

## Entidad asociativa propuesta: `UsoTanque`.

## Atributos principales: fechaHoraInicio, fechaHoraFin, estadoUso.

## Justificación: un tanque puede usarse en muchos lotes a lo largo del tiempo, pero no puede mantener más de un lote activo simultáneamente. Registrar la ocupación temporal permite verificar la regla RN-06.

### 5.5. LoteProducción y Envasado

## Relación identificada: inicialmente `LoteProducción (0,N) — Envasado (1,1)`.

## No es necesariamente M:N si cada registro de envasado pertenece a un único lote. Sin embargo, si en el futuro un evento de envasado puede incluir producto de varios lotes, se requerirá una entidad asociativa denominada `DetalleEnvasado`.

## 6. Posibles especializaciones o generalizaciones

### 6.1. Insumo

## Se propone la entidad general `Insumo`, que puede especializarse conceptualmente en:

- ## CultivoLáctico.
- ## PulpaFruta.
- ## Saborizante.
- ## MaterialEmpaque.

## La primera versión puede manejar estas diferencias mediante el atributo `categoríaInsumo`. La especialización solo se implementará si cada categoría requiere atributos exclusivos o reglas sustancialmente distintas.

### 6.2. PruebaCalidad

## La entidad general `PruebaCalidad` puede especializarse en:

- ## PruebaMicrobiológica.
- ## MediciónAutomática.
- ## ValidaciónManual.
- ## PruebaProductoTerminado.

## Por ahora, se recomienda representar el origen mediante `origenRegistro` con valores como `Sensor` y `Operario`, además de `tipoPrueba`. La especialización se considerará si el diagrama conceptual requiere diferenciar claramente datos obligatorios de cada tipo de prueba.

### 6.3. Empleado

## `Empleado` podría especializarse por rol en:

- ## OperadorTanque.
- ## TécnicoCalidad.
- ## Supervisor.

## En el modelo conceptual inicial se propone conservar una sola entidad y usar el atributo `rol`, porque los datos básicos de identificación son comunes. La regla de que solo el técnico de calidad registra pruebas de laboratorio se controla desde las reglas de negocio y permisos.

## 7. Reglas de negocio que afectan al modelo
## | Regla del Módulo 3 | Impacto en el modelo conceptual |
## |---                 |---                              |
## | RN-01: leche con análisis microbiológico rechazado no puede asignarse a tanque/lote | Se requieren `LoteLecheCruda`, `PruebaCalidad`, `Silo`, `Tanque` y `AsignaciónLecheTanque`. |
## | RN-02: un insumo vencido no puede usarse | `LoteInsumo` debe incluir fechaCaducidad, cantidadDisponible y relación con `ConsumoInsumo`. |
## | RN-03: lote rechazado no puede envasarse | `LoteProducción` necesita estado/dictamen, y `Envasado` se relaciona con el lote aprobado. |
## | RN-04: pH fuera de rango durante más de 15 minutos genera alerta | `PruebaCalidad` debe conservar fechaHora, parámetro, valor, límites y origen del registro. |
## | RN-05: descarte exige motivo y volumen | Se crea la entidad `Descarte` con motivo, volumen y fecha. |
## | RN-06: tanque no puede tener más de un lote activo | Se crea `UsoTanque` con inicio, fin y estado de ocupación. |
## | RN-07: no se puede superar la capacidad del tanque | `Tanque` debe incluir capacidadMáximaLitros y `AsignaciónLecheTanque` debe registrar volumenAsignadoLitros. |
## | RN-08: conservar lotes y pruebas por al menos un año | Las entidades `LoteProducción`, `LoteLecheCruda` y `PruebaCalidad` deben conservar información histórica y no diseñarse como registros eliminables. |
## | RN-09: solo técnico de calidad registra pruebas de laboratorio | Se incluye `Empleado` con atributo rol y relación con `PruebaCalidad`. |
## | RN-10: lote de pulpa no puede consumirse si se agotó | `LoteInsumo` debe registrar cantidadDisponible y `ConsumoInsumo` cantidadConsumida. |
## | RN-11: envasado exige canal de destino | `Envasado` debe incluir el atributo canalDestino. |

