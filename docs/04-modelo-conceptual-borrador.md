# Modulo 4 — Entidades, Atributos y Relaciones

## 1. Propósito y alcance

El objetivo de este módulo es identificar los elementos que componen el dominio de KlarensLait y describir sus relaciones antes de construir el diagrama entidad-relación formal.

El modelo se basa en las decisiones del Modulo 3. En particular, considera que:

- La leche de varios proveedores puede acopiarse en silos antes de asignarse a un tanque.
- Un tanque procesa un solo lote activo a la vez.
- Los lotes de producción pueden requerir cultivos y pulpas de fruta por lote de insumo.
- Los lotes pasan por pruebas de calidad automatizadas y manuales.
- Los lotes rechazados o descartados no pueden llegar a envasado.
- El envasado debe registrar el canal de destino.

**Convención de lectura de cardinalidades:** El valor (min, max) ubicado junto a una entidad indica cuántas instancias de esa entidad se asocian a una instancia de la entidad en el extremo opuesto de la relación.

## 2. Entidades del dominio

| Entidad         | Tipo       | Descripcion conceptual                                                                               |
| --------------- | ---------- | ---------------------------------------------------------------------------------------------------- |
| Proveedor       | Fuerte     | Persona, finca o empresa que suministra leche cruda u otros insumos a la planta.                     |
| LoteLeche       | Fuerte     | Cantidad identificable de leche recibida, con volumen, origen, estado y dictamen de calidad.         |
| Silo            | Fuerte     | Contenedor físico de recepción o acopio de leche, con capacidad máxima y estado operativo.           |
| Tanque          | Fuerte     | Equipo físico donde se procesa un lote de producción; puede corresponder a fermentación o mezcla.    |
| LoteProducción  | Fuerte     | Unidad trazable de yogurt elaborada durante un ciclo de producción.                                  |
| Insumo          | Fuerte     | Tipo de materia prima adicional utilizada en producción, como cultivo láctico o pulpa de fruta, etc. |
| LoteInsumo      | Fuerte     | Unidad identificable de un insumo recibido, con cantidad disponible y fecha de caducidad.            |
| PruebaCalidad   | Fuerte     | Registro de una prueba aplicada a leche, lote de producción, como microbiología, pH o temperatura.   |
| EstandarCalidad | Fuerte     | Parámetros y rangos permitidos (mínimo y máximo) para evaluar las pruebas de calidad.                |
| Empleado        | Fuerte     | Persona que interviene como operario, supervisor o técnico de calidad.                               |
| Envasado        | Fuerte     | Registro del proceso final de empaque de un lote aprobado, incluyendo fecha y canal de destino.      |
| Asigna          | Asociativa | Registra el volumen de leche transferido desde un silo hacia un tanque para un lote de producción.   |
| Almacena        | Asociativa | Movimiento que registra qué lote de leche ingresa o sale de qué silo.                                |
| ConsumoInsumo   | Asociativa | Registra el consumo parcial de un lote de insumo en un lote de producción.                           |
| UsoTanque       | Asociativa | Registra qué lote ocupó un tanque, con fecha y hora de inicio y finalización.                        |
| Descarte        | Debil      | Registra el descarte de un lote, con fecha, motivo y volumen descartado. Depende de LoteProducción.  |

## 3. Atributos por entidad

### Proveedor

- PK_idProveedor
- nombre
- tipoProveedor
- identificacion
- telefono
- ubicación
- estado

### LoteLeche

- PK_idLoteleche
- codigo
- fechaRecepción
- volumenInicialLitros
- volumenDisponibleLitros
- estadoLote
- dictamenMicrobiológico
- proveedorOrigen

### Silo

- PK_idSilo
- codigo
- tipoSilo
- capacidadMaxima
- volumenActual
- estadoOperativo

### Tanque

- PK_idTanque
- codigo
- tipoTanque
- capacidadMaxima
- volumenActual
- estadoOperativo

### LoteProduccion

- PK_idLoteProduccion
- codigo
- tipoProducto
- fechaHoraInicio
- fechaHoraFin
- volumenPlanificadoLitros
- volumenProducidoLitros
- estado
- supervisor

### Insumo

- PK_idInsumo
- codigo
- categoriaInsumo
- UnidadDeMedida
- estado

### LoteInsumo

- PK_loteInsumo
- codigoLoteInsumo
- fechaRecepcion
- fechaCaducidad
- cantidadInicial
- cantidadDisponible
- estado
- FK_idInsumo

### PruebaCalidad

- PK_PruebaCalidad
- fechaHora
- tipoPrueba
- parámetroMedido
- valorObtenido
- unidadMedida
- resultado
- origenRegistro
- responsableRegistro
- FK_Lote

### EstandarCalidad

- PK_idEstandar
- parametro
- valorMinimoPermitido
- valorMaximoPermitido

### Empleado

- PK_idEmpleado
- nombre
- identificacion
- cargo
- estadoVinculacion

### Envasado

- PK_idEnvasado
- fechaHora_envasado
- fecha_vencimiento
- fecha_hora_despacho
- presentacion
- cantidadEnvasada
- destino
- temperaturaEnvasado
- temperaturaDespacho
- estado (Por definir según revisión grupal)
- FK_idLoteProduccion

### Asigna

- PK_idAsigna
- fechaHora
- volumenAsignado
- siloOrigen
- tanqueDestino
- loteProduccion

### Almacena

- PK_idAlmacena
- fechaHoraMovimiento
- tipoMovimiento
- volumenLitros
- FK_idSilo
- FK_idLoteLeche

### ConsumoInsumo

- PK_ConsumoInsumo
- fechaHoraConsumo
- cantidad
- loteInsumo
- loteProduccion

### UsoTanque

- PK_UsoTanque
- fechaHoraInicio
- fechaHoraFin
- estado
- tanque
- loteProduccion

### Descarte

- PK_id_lote_produccion (Clave parcial por ser entidad débil)
- fechaHoraDescarte
- motivo
- volumenDescartado
- observaciones

## 4. Relaciones y cardinalidades

| Codigo | Relacion propuesta                     | Cardinalidad (min/max)                  | Descripcion                                                                                        |
| ------ | -------------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------- |
| R01    | Proveedor—[suministra]—LoteLeche       | Proveedor(1:N)—LoteLeche(1:1)           | Un proveedor puede suministrar varios lotes de leche; cada lote tiene un proveedor de origen.      |
| R02    | Silo—[almacena]—LoteLeche              | Silo(0:N)—LoteLeche(0:N)                | Un silo puede almacenar leche de varios lotes y un lote puede pasar por uno o más silos.           |
| R03    | LoteProduccion—[ocupa]—Tanque          | LoteProduccion(1:N)—Tanque(0:N)         | Un lote ocupa uno o más tanques; un tanque procesa múltiples lotes en diferentes momentos.         |
| R04    | Empleado—[supervisa]—LoteProduccion    | Empleado(0:N)—LoteProducción(1:1)       | Un empleado puede supervisar varios lotes; cada lote tiene un supervisor responsable.              |
| R05    | LoteProduccion—[consume]—LoteInsumo    | LoteProduccion(0:N)—LoteInsumo(0:N)     | Un lote puede consumir cultivos; un lote de insumo puede consumirse parcialmente.                  |
| R06    | Insumo—[identifica]—LoteInsumo         | Insumo(1:N)—LoteInsumo(1:1)             | Un tipo de insumo puede recibirse en múltiples lotes; cada lote corresponde a un insumo.           |
| R07    | LoteProduccion—[tiene]—PruebaCalidad   | LoteProduccion(0:N)—PruebaCalidad(0:1)  | Un lote puede tener varias pruebas; cada prueba se asocia opcionalmente a un lote.                 |
| R08    | Empleado—[registra]—PruebaCalidad      | Empleado(0:N)—PruebaCalidad(0:1)        | Un empleado puede registrar varias pruebas; una prueba puede tener un responsable o ser de sensor. |
| R09    | LoteProduccion—[envasa]—Envasado       | LoteProduccion(1:N)—Envasado(1:1)       | Un lote puede generar varios registros de envasado; cada envasado corresponde a un lote.           |
| R10    | LoteProducción—[genera]—Descarte       | LoteProducción(0:1)—Descarte(1:1)       | Un lote puede generar un descarte; cada descarte corresponde a un solo lote.                       |
| R11    | LoteLeche—[analiza]—PruebaCalidad      | LoteLeche(0:N)—PruebaCalidad(1:1)       | Un lote de leche cruda puede ser analizado en múltiples pruebas de calidad.                        |
| R12    | Proveedor—[provee]—LoteInsumo          | Proveedor(1:N)—LoteInsumo(1:1)          | Un proveedor puede suministrar múltiples lotes de insumos.                                         |
| R13    | EstandarCalidad—[evalúa]—PruebaCalidad | EstandarCalidad(1:N)—PruebaCalidad(1:1) | Un estándar evalúa múltiples pruebas; cada prueba se rige por un estándar.                         |

## 5. Justificaciones de diseño y entidades no obvias

### ¿Por qué "Fermentación" no es una entidad?

En el modelo no se incluyó la fermentación como una entidad independiente porque no representa un objeto físico o un registro transaccional con ciclo de vida propio, sino una etapa del proceso. En la planta, la leche con menor proporción de grasa se destina a la elaboración de productos fermentados como el suero[cite: 14] o yogures[cite: 15]. Este proceso ocurre dentro de un equipo físico, por lo que el tiempo de fermentación se define como la duración del uso del tanque[cite: 4]. Por lo tanto, la trazabilidad de esta etapa se resuelve mediante la entidad física `Tanque` y la entidad temporal `UsoTanque`, las cuales registran el tiempo de inicio y fin en el que un lote de producción permanece allí, haciendo innecesario crear una entidad exclusiva para el proceso químico de fermentar.

### Atributos que podrían ser entidades

- **Producto:** En lugar de crear una entidad maestra separada para el catálogo de productos (dado que el alcance de la Fase 1 se limitó a yogurt), el producto a elaborar se maneja como el atributo `tipoProducto` directamente dentro de la entidad `LoteProduccion`.
- **Estándar de Calidad:** Inicialmente, los valores mínimos y máximos de las pruebas se consideraban atributos de `PruebaCalidad`. Se decidió transformarlo en una entidad fuerte independiente (`EstandarCalidad`), ya que estos rangos son reglas de negocio maestras que dictan cómo se evalúan las pruebas, separando el registro transaccional (la prueba en sí) de la regla que lo rige[cite: 6].
