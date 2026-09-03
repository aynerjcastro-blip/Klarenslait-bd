# Modulo 4 — Entidades, Atributos y Relaciones

## 1. Propósito y alcance
## El objetivo de este módulo es identificar los elementos que componen el dominio de KlarensLait y describir sus relaciones antes de ## construir el diagrama entidad-relación formal.

## El modelo se basa en las decisiones del Modulo 3. En particular, considera que:
## - La leche de varios proveedores puede acopiarse en silos antes de asignarse a un tanque.
## - Un tanque procesa un solo lote activo a la vez.
## - Los lotes de producción pueden requerir cultivos y pulpas de fruta por lote de insumo.
## - Los lotes pasan por pruebas de calidad automatizadas y manuales.
## - Los lotes rechazados o descartados no pueden llegar a envasado.
## - El envasado debe registrar el canal de destino.

## 2. Entidades del dominio

## | Entidad           |Tipo   |Descripcion conceptual|
## |-------------------|-------|-----------------------|
## | Proveedor         |Fuerte |Persona, finca o empresa que suministra leche cruda u otros insumos a la planta. |
## | LoteLeche    |Fuerte |Cantidad identificable de leche recibida, con volumen, origen, estado y dictamen de calidad. |
## | Silo              |Fuerte |Contenedor físico de recepción o acopio de leche, con capacidad máxima y estado operativo. |
## | Tanque            |Fuerte |Equipo físico donde se procesa un lote de producción; puede corresponder a fermentación o mezcla. |
## | LoteProducción    |Fuerte |Unidad trazable de yogurt elaborada durante un ciclo de producción. |
## | Insumo            |Debil  |Tipo de materia prima adicional utilizada en producción, como cultivo láctico o pulpa de fruta, etc. 
## | LoteInsumo        |Fuerte |Unidad identificable de un insumo recibido, con cantidad disponible y fecha de caducidad. |
## | PruebaCalidad     |Fuerte |Registro de una prueba aplicada a leche, lote de producción,como microbiología, pH o temperatura.                                   
## | Empleado          |Fuerte |Persona que interviene como operario, supervisor o técnico de calidad. |
## | Envasado          |Fuerte |Registro del proceso final de empaque de un lote aprobado, incluyendo fecha y canal de destino. |
## | Asignacion_Tanque |Asociativa |Registra el volumen de leche transferido desde un silo hacia un tanque para un lote de producción. |
## | ConsumoInsumo     |Asociativa |Registra el consumo parcial de un lote de insumo en un lote de producción. |
## | UsoTanque         |Asociativa/temporal | Registra qué lote ocupó un tanque, con fecha y hora de inicio y finalización. |
## | Descarte          |Debil |Registra el descarte de un lote, con fecha, motivo y volumen descartado. |


## 3. Atributos por entidad

### Proveedor
## - PK_idProveedor 
## - nombre
## - tipoProveedor
## - identificacion
## - telefono
## - ubicación
## - estado

### LoteLeche
## - PK_idLoteleche
## - codigo
## - fechaRecepción
## - volumenInicialLitros
## - volumenDisponibleLitros
## - estadoLote
## - dictamenMicrobiológico.
## - proveedorOrigen


### Silo
## - PK_idSilo
## - codigo
## - tipoSilo
## - capacidadMaxima
## - volumenActual
## - estadoOperativo

### Tanque
## - PK_idTanque
## - codigo
## - tipoTanque
## - capacidadMaxima
## - volumenActual
## - estadoOperativo


### LoteProduccion
## - PK_idLoteProduccion
## - codigo
## - tipoProducto
## - fechaHoraInicio
## - fechaHoraFin
## - volumenPlanificadoLitros
## - volumenProducidoLitros
## - estado
## - supervisor

### Insumo
## - PK_idInsumo
## - codigo
## - fechaRecepcion
## - fechaCaducidad
## - cantidadInicial
## - cantidadDisponible
## - estado

### PruebaCalidad
## - PK_PruebaCalidad
## - fechaHora
## - tipoPrueba
## - parámetroMedido
## - valorObtenido
## - unidadMedida
## - valorMínimoPermitido
## - valorMáximoPermitido
## - resultado
## - origenRegistro
## - responsableRegistro


### Empleado
## - PK_idEmpleado
## - nombre
## - identificacion
## - cargo
## - estadoVinculacion

### Envasado
## - PK_idEnvasado
## - fechaHora_envasado
## - presentacion
## - cantidadEnvasada
## - destino
## - temperaturaEnvasado
## - temperaturaDespacho
## - estado   


### AsignacionTanque
## - PK_idAsignacion
## - fechaHora
## - volumenAsignado
## - siloOrigen
## - tanqueDestino
## - loteProduccion



### ConsumoInsumo
## - PK_ConsumoInsumo
## - fechaHoraConsumo
## - cantidad
## - loteInsumo
## - loteProduccion

### UsoTanque
## - PK_UsoTanque
## - fechaHoraInicio
## - fechaHoraFin
## - estado
## - tanque
## - loteProduccion


### Descarte
## - PK_Descarte
## - fechaHoraDescarte
## - motivo
## - volumenDescartado
## - observaciones
## - loteAfectado


## 4. Relaciones y cardinalidades



## 5. Relaciones M:N y entidades asociativas
## 6. Posibles especializaciones o generalizaciones
## 7. Reglas de negocio que afectan al modelo