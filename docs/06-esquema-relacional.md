# Modelo Relacional

## 1. Relaciones (tablas) por entidad fuerte y débil

### PROVEEDOR

| Atributo | Tipo de llave |
|---|---|
| **ID Proveedor** | PK |
| Nombre | |
| Ubicación | |
| Teléfono | |
| Tipo Proveedor | |
| Identificación | |
| Estado | |

### LOTE LECHE

| Atributo | Tipo de llave |
|---|---|
| **ID Lote Leche** | PK |
| Código | |
| Dictamen Microbiológico | |
| Fecha Recepción | |
| Estado Lote | |
| Volumen Inicial Litros | |
| Volumen Disponible Litros | |
| ID Proveedor | FK → PROVEEDOR |

### SILO

| Atributo | Tipo de llave |
|---|---|
| **ID Silo** | PK |
| Código | |
| Tipo Silo | |
| Estado Operativo | |
| Volumen Actual | |
| Capacidad Máxima | |

### TANQUE

| Atributo | Tipo de llave |
|---|---|
| **ID Tanque** | PK |
| Código | |
| Tipo Tanque | |
| Capacidad Máxima | |
| Estado Operativo | |
| Volumen Actual | |

### INSUMO

| Atributo | Tipo de llave |
|---|---|
| **ID Insumo** | PK |
| Código | |
| Categoría Insumo | |
| Unidad Medida | |
| Estado | |

### LOTE INSUMO

| Atributo | Tipo de llave |
|---|---|
| **ID Lote Insumo** | PK |
| Código Lote Insumo | |
| Cantidad Inicial | |
| Cantidad Disponible | |
| Fecha Recepción | |
| Fecha Caducidad | |
| Estado | |
| ID Insumo | FK → INSUMO |

### LOTE PRODUCCIÓN

| Atributo | Tipo de llave |
|---|---|
| **ID Lote Producción** | PK |
| Código | |
| Tipo Producción | |
| Volumen Planificado Litros | |
| Volumen Producido Litros | |
| Fecha Hora Inicio | |
| Fecha Hora Fin | |
| Estado | |
| ID Empleado | FK → EMPLEADO |

### ENVASADO

| Atributo | Tipo de llave |
|---|---|
| **ID Envasado** | PK |
| Fecha Hora Envasado | |
| Presentación | |
| Cantidad Envasada | |
| Destino | |
| Temperatura Despacho | |
| Temperatura Envasado | |
| ID Lote Producción | FK → LOTE PRODUCCIÓN |

### EMPLEADO

| Atributo | Tipo de llave |
|---|---|
| **ID Empleado** | PK |
| Nombre | |
| Cargo | |
| Identificación | |
| Estado Vinculación | |

### PRUEBA CALIDAD

| Atributo | Tipo de llave |
|---|---|
| **ID Prueba Calidad** | PK |
| Fecha Hora | |
| Tipo Prueba | |
| Valor Obtenido | |
| Parámetro Medido | |
| Valor Mínimo Permitido | |
| Valor Máximo Permitido | |
| Resultado | |
| Unidad Medida | |
| Origen Registro | |
| ID Lote Producción | FK → LOTE PRODUCCIÓN |
| ID Empleado | FK → EMPLEADO |

### DESCARTE *(entidad débil)*

| Atributo | Tipo de llave |
|---|---|
| **ID Descarte** | PK |
| Fecha Hora Descarte | |
| Motivo | |
| Observaciones | |
| Volumen Descartado | |
| ID Lote Producción | FK → LOTE PRODUCCIÓN |

---

## 2. Tablas intermedias para relaciones M:N

### ALMACENA *(LOTE LECHE — SILO)*

| Atributo | Tipo de llave |
|---|---|
| **ID Almacenamiento** | PK |
| ID Lote Leche | FK → LOTE LECHE |
| ID Silo | FK → SILO |
| Fecha Hora | |
| Tipo Movimiento | |
| Volumen Litros | |
| Observaciones | |

### OCUPA *(TANQUE — LOTE PRODUCCIÓN)*

| Atributo | Tipo de llave |
|---|---|
| **ID Ocupación** | PK |
| ID Tanque | FK → TANQUE |
| ID Lote Producción | FK → LOTE PRODUCCIÓN |
| Fecha Hora Inicio | |
| Fecha Hora Fin | |
| Estado Uso | |

### CONSUME *(LOTE INSUMO — LOTE PRODUCCIÓN)*

| Atributo | Tipo de llave |
|---|---|
| **ID Lote Insumo** | PK, FK → LOTE INSUMO |
| **ID Lote Producción** | PK, FK → LOTE PRODUCCIÓN |
| Cantidad Consumida | |
| Fecha Hora Consumo | |

### ASIGNA *(SILO — TANQUE — LOTE PRODUCCIÓN, relación ternaria)*

| Atributo | Tipo de llave |
|---|---|
| **ID Asignación** | PK |
| ID Silo | FK → SILO |
| ID Tanque | FK → TANQUE |
| ID Lote Producción | FK → LOTE PRODUCCIÓN |
| Volumen Asignado Litros | |
| Fecha Hora Asignación | |
