# Esquema Relacional

Derivado del Módulo 4 (entidades, atributos y relaciones), con las decisiones y reglas del Módulo 3 y las justificaciones del diagrama EER (Módulo 5). Los nombres de tablas y atributos son los del Módulo 4. Las claves primarias van en **negrita**.

**Ajustes de escritura sobre los nombres del Módulo 4:** se quitaron tildes y separadores para que todos sigan el mismo estilo camelCase (por ejemplo fechaRecepción pasa a fechaRecepcion, y PK idProveedor se escribe solo idProveedor). Los nombres no cambian de significado.

---

## 1. Tablas por entidad

### Proveedor

| Atributo | Llave | Nota |
|---|---|---|
| **idProveedor** | PK | |
| nombre | | |
| tipoProveedor | | |
| identificacion | | Única |
| telefono | | |
| ubicacion | | |
| estado | | |

### LoteLeche

| Atributo | Llave | Nota |
|---|---|---|
| **idLoteLeche** | PK | |
| codigo | | Único |
| fechaRecepcion | | |
| volumenInicialLitros | | |
| volumenDisponibleLitros | | |
| estadoLote | | Dominio del Módulo 3 (1.2) |
| dictamenMicrobiologico | | Dominio del Módulo 3 (1.2) |
| proveedorOrigen | FK → Proveedor | Obligatoria (R01) |

### Silo

| Atributo | Llave | Nota |
|---|---|---|
| **idSilo** | PK | |
| codigo | | Único |
| tipoSilo | | |
| capacidadMaxima | | |
| volumenActual | | |
| estadoOperativo | | |

### Tanque

| Atributo | Llave | Nota |
|---|---|---|
| **idTanque** | PK | |
| codigo | | Único |
| tipoTanque | | |
| capacidadMaxima | | |
| volumenActual | | |
| estadoOperativo | | |

### Insumo

| Atributo | Llave | Nota |
|---|---|---|
| **idInsumo** | PK | |
| codigo | | Único |
| categoriaInsumo | | |
| unidadDeMedida | | |
| estado | | |

### LoteInsumo

| Atributo | Llave | Nota |
|---|---|---|
| **idLoteInsumo** | PK | |
| codigoLoteInsumo | | Único |
| fechaRecepcion | | |
| fechaCaducidad | | |
| cantidadInicial | | |
| cantidadDisponible | | |
| estado | | |
| idInsumo | FK → Insumo | Obligatoria (R06) |
| idProveedor | FK → Proveedor | Obligatoria (R12) |

### Empleado

| Atributo | Llave | Nota |
|---|---|---|
| **idEmpleado** | PK | |
| nombre | | |
| identificacion | | Única |
| cargo | | Dominio del Módulo 3 (1.5) |
| estadoVinculacion | | |

### EstandarCalidad

| Atributo | Llave | Nota |
|---|---|---|
| **idEstandar** | PK | |
| parametro | | |
| tipoProducto | | Ver nota abajo |
| valorMinimoPermitido | | |
| valorMaximoPermitido | | |

Se propone una restricción de unicidad sobre (parametro, tipoProducto): un solo rango por parámetro y producto.

### LoteProduccion

| Atributo | Llave | Nota |
|---|---|---|
| **idLoteProduccion** | PK | |
| codigo | | Único |
| tipoProducto | | |
| fechaHoraInicio | | |
| fechaHoraFin | | |
| volumenPlanificadoLitros | | |
| volumenProducidoLitros | | |
| estado | | Dominio del Módulo 3 (1.1) |
| supervisor | FK → Empleado | Obligatoria (R04) |

### Envasado

| Atributo | Llave | Nota |
|---|---|---|
| **idEnvasado** | PK | |
| fechaHoraEnvasado | | |
| fechaVencimiento | | |
| fechaHoraDespacho | | |
| presentacion | | |
| cantidadEnvasada | | |
| destino | | Obligatorio; mayorista, minorista o venta directa (RN-11) |
| temperaturaEnvasado | | |
| temperaturaDespacho | | |
| estado | | |
| idLoteProduccion | FK → LoteProduccion | Obligatoria (R09) |

### PruebaCalidad

| Atributo | Llave | Nota |
|---|---|---|
| **idPruebaCalidad** | PK | |
| fechaHora | | |
| tipoPrueba | | |
| parametroMedido | | Ver observación 1 de la sección 6 |
| valorObtenido | | |
| unidadMedida | | Ver observación 2 de la sección 6 |
| resultado | | aprobado, rechazado o reproceso (Módulo 3) |
| origenRegistro | | Sensor u Operario |
| idLoteLeche | FK → LoteLeche | Opcional (R11) |
| idLoteProduccion | FK → LoteProduccion | Opcional (R07) |
| idEstandar | FK → EstandarCalidad | Obligatoria (R13) |
| responsableRegistro | FK → Empleado | Opcional (R08) |

**Restricción CHECK (exclusividad):** exactamente una de las dos llaves, idLoteLeche o idLoteProduccion, debe tener valor. Una prueba pertenece a un lote de leche o a uno de producción, nunca a ambos ni a ninguno.

PruebaCalidad no guarda valorMinimoPermitido ni valorMaximoPermitido: el rango se obtiene por la relación R13 con EstandarCalidad.

### Descarte *(entidad débil)*

| Atributo | Llave | Nota |
|---|---|---|
| **idLoteProduccion** | PK, FK → LoteProduccion | Clave del lote (R10) |
| fechaHoraDescarte | | Obligatorio |
| motivo | | Obligatorio |
| volumenDescartado | | Obligatorio, mayor que 0 |
| observaciones | | |

Un lote genera como máximo un descarte, así que no hace falta clave parcial: la clave completa es la clave foránea del lote.

---

## 2. Tablas intermedias (relaciones asociativas)

Las cuatro llevan clave primaria propia, como las define el Módulo 4.

### Almacena *(Silo — LoteLeche)*

| Atributo | Llave | Nota |
|---|---|---|
| **idAlmacena** | PK | |
| idSilo | FK → Silo | |
| idLoteLeche | FK → LoteLeche | |
| fechaHoraMovimiento | | |
| tipoMovimiento | | |
| volumenLitros | | |

### UsoTanque *(Tanque — LoteProduccion)*

| Atributo | Llave | Nota |
|---|---|---|
| **idUsoTanque** | PK | |
| tanque | FK → Tanque | |
| loteProduccion | FK → LoteProduccion | |
| fechaHoraInicio | | |
| fechaHoraFin | | Vacía mientras el uso está activo |
| estado | | |

### ConsumoInsumo *(LoteProduccion — LoteInsumo)*

| Atributo | Llave | Nota |
|---|---|---|
| **idConsumoInsumo** | PK | |
| loteInsumo | FK → LoteInsumo | |
| loteProduccion | FK → LoteProduccion | |
| fechaHoraConsumo | | |
| cantidad | | |

### Asigna *(Silo — Tanque — LoteProduccion, relación ternaria)*

| Atributo | Llave | Nota |
|---|---|---|
| **idAsigna** | PK | |
| siloOrigen | FK → Silo | |
| tanqueDestino | FK → Tanque | |
| loteProduccion | FK → LoteProduccion | |
| fechaHora | | |
| volumenAsignado | | |

### Por qué cada una lleva clave propia

| Tabla | Justificación |
|---|---|
| Almacena | El mismo lote puede entrar y salir del mismo silo varias veces; la pareja de FK no identifica el movimiento. |
| UsoTanque | Un lote puede volver a usar el mismo tanque en otro momento; cada uso tiene su propio inicio y fin. |
| ConsumoInsumo | Un lote de insumo se consume parcialmente y varias veces en el mismo lote de producción. |
| Asigna | Pueden repetirse las mismas tres entidades en asignaciones distintas, con fecha y volumen propios. |

---

## 3. Restricciones CHECK y reglas de integridad

| Tabla | Regla | Origen |
|---|---|---|
| PruebaCalidad | Exactamente una de idLoteLeche o idLoteProduccion tiene valor | Módulo 4 (R07 y R11) |
| PruebaCalidad | Si origenRegistro es Sensor, responsableRegistro es nulo; si es Operario, no es nulo | RN-09 |
| EstandarCalidad | valorMinimoPermitido menor o igual a valorMaximoPermitido | RN-04 |
| Descarte | motivo, volumenDescartado y fechaHoraDescarte obligatorios; volumenDescartado mayor que 0 | RN-05 |
| UsoTanque | Índice único parcial sobre tanque donde fechaHoraFin es nula: un solo uso activo por tanque | RN-06 |
| Tanque y Silo | capacidadMaxima mayor que 0; volumenActual entre 0 y capacidadMaxima | RN-07 |
| LoteInsumo | 0 menor o igual a cantidadDisponible, y esta menor o igual a cantidadInicial | RN-10 |
| LoteInsumo | fechaCaducidad posterior a fechaRecepcion | RN-02 |
| LoteLeche | dictamenMicrobiologico: pendiente, aprobado o rechazado | Módulo 3 (1.2) |
| LoteLeche | estadoLote: recibido, disponible, agotado o rechazado | Módulo 3 (1.2) |
| LoteLeche | Un lote disponible exige dictamen aprobado y litros; un dictamen rechazado implica estado rechazado; agotado implica 0 litros | Módulo 3 (1.2) |
| LoteProduccion | estado: en proceso, aprobado, rechazado, envasado o descartado | Módulo 3 (1.1) |
| PruebaCalidad | resultado: aprobado, rechazado o reproceso | Módulo 3 (1.1) |
| Empleado | cargo: Operador de tanque, Técnico de calidad o Supervisor | Módulo 3 (1.5) |
| Envasado | destino obligatorio: mayorista, minorista o venta directa | RN-11 |

Los dominios de los demás campos de estado y de tipo no están definidos en los módulos entregados; quedan pendientes del diccionario de datos.

Reglas que se validan fuera del esquema declarativo (triggers o aplicación): transiciones del estado del lote, capacidad del tanque sumando asignaciones (RN-07), consumo de insumo vencido (RN-02) y envasado solo de lotes aprobados (RN-03).

---

## 4. Política de borrado por clave foránea

Todas las claves foráneas usan **RESTRICT**. No hay CASCADE ni SET NULL, por estas razones del Módulo 3:

- La conservación mínima de 365 días (supuesto 17 y RN-08) prohíbe borrar lotes y pruebas dentro del plazo.
- Quien autorizó un lote no puede perderse (supuesto 10): un empleado se desactiva con estadoVinculacion, no se borra.
- RN-09 exige que una prueba de operario tenga responsable; un SET NULL violaría ese CHECK.

| # | Clave foránea | Política | Justificación |
|---|---|---|---|
| 1 | LoteLeche.proveedorOrigen → Proveedor | RESTRICT | No se pierde el origen de la leche; el proveedor se desactiva con estado. |
| 2 | LoteInsumo.idInsumo → Insumo | RESTRICT | Un insumo con lotes registrados es parte del historial de producción. |
| 3 | LoteInsumo.idProveedor → Proveedor | RESTRICT | Debe poder responderse qué proveedor entregó cada insumo. |
| 4 | LoteProduccion.supervisor → Empleado | RESTRICT | Cada lote conserva quién lo autorizó; el empleado no se elimina mientras tenga lotes. |
| 5 | Envasado.idLoteProduccion → LoteProduccion | RESTRICT | Registro regulatorio y de cadena de frío (RN-08). |
| 6 | Descarte.idLoteProduccion → LoteProduccion | RESTRICT | RN-08 incluye a Descarte entre las FK hacia el lote que no se borran en el plazo de conservación. |
| 7 | PruebaCalidad.idLoteLeche → LoteLeche | RESTRICT | Las pruebas son evidencia de calidad; no se borran con el lote. |
| 8 | PruebaCalidad.idLoteProduccion → LoteProduccion | RESTRICT | RN-08: lotes y pruebas se conservan 365 días. |
| 9 | PruebaCalidad.idEstandar → EstandarCalidad | RESTRICT | Borrar un estándar dejaría pruebas sin su rango de referencia. |
| 10 | PruebaCalidad.responsableRegistro → Empleado | RESTRICT | RN-09 exige responsable en las pruebas de operario. |
| 11 | Almacena.idSilo → Silo | RESTRICT | Los movimientos de acopio son historial de trazabilidad. |
| 12 | Almacena.idLoteLeche → LoteLeche | RESTRICT | Debe poder rastrearse por qué silos pasó cada lote de leche. |
| 13 | UsoTanque.tanque → Tanque | RESTRICT | No se borra un tanque con historial de uso. |
| 14 | UsoTanque.loteProduccion → LoteProduccion | RESTRICT | El uso de tanques es parte del historial del lote. |
| 15 | ConsumoInsumo.loteInsumo → LoteInsumo | RESTRICT | Debe poder rastrearse en qué lotes se usó cada lote de insumo. |
| 16 | ConsumoInsumo.loteProduccion → LoteProduccion | RESTRICT | El consumo de insumos es trazabilidad del lote. |
| 17 | Asigna.siloOrigen → Silo | RESTRICT | Las asignaciones documentan de qué silo salió la leche del lote. |
| 18 | Asigna.tanqueDestino → Tanque | RESTRICT | Misma razón. |
| 19 | Asigna.loteProduccion → LoteProduccion | RESTRICT | Misma razón. |

Las 19 claves foráneas del esquema tienen política.

---

## 5. Del diagrama al esquema

| Código | Relación | Cardinalidad | Implementación |
|---|---|---|---|
| R01 | suministra | Proveedor (1,1) — LoteLeche (0,N) | FK obligatoria LoteLeche.proveedorOrigen |
| R02 | almacena | Silo (0,N) — LoteLeche (0,N) | Tabla Almacena |
| R03 | ocupa | LoteProduccion (0,N) — Tanque (1,N) | Tabla UsoTanque |
| R04 | supervisa | Empleado (1,1) — LoteProduccion (0,N) | FK obligatoria LoteProduccion.supervisor |
| R05 | consume | LoteProduccion (0,N) — LoteInsumo (0,N) | Tabla ConsumoInsumo |
| R06 | identifica | Insumo (1,1) — LoteInsumo (0,N) | FK obligatoria LoteInsumo.idInsumo |
| R07 | tiene | LoteProduccion (0,1) — PruebaCalidad (0,N) | FK opcional PruebaCalidad.idLoteProduccion, con el CHECK |
| R08 | registra | Empleado (0,1) — PruebaCalidad (0,N) | FK opcional PruebaCalidad.responsableRegistro |
| R09 | envasa | LoteProduccion (1,1) — Envasado (0,N) | FK obligatoria Envasado.idLoteProduccion |
| R10 | genera | LoteProduccion (1,1) — Descarte (0,1) | PK de Descarte que es FK al lote |
| R11 | analiza | LoteLeche (0,1) — PruebaCalidad (0,N) | FK opcional PruebaCalidad.idLoteLeche, con el CHECK |
| R12 | provee | Proveedor (1,1) — LoteInsumo (0,N) | FK obligatoria LoteInsumo.idProveedor |
| R13 | evalua | EstandarCalidad (1,1) — PruebaCalidad (0,N) | FK obligatoria PruebaCalidad.idEstandar |
| — | Asigna (ternaria) | Silo (0,N), Tanque (0,N), LoteProduccion (1,N) | Tabla Asigna con tres FK |

---

## 6. Revisión de normalización hasta 3FN

| Tabla | Resultado | Comentario |
|---|---|---|
| Proveedor, Silo, Tanque, Insumo, Empleado | Cumple 3FN | Todo atributo depende solo de la clave. |
| LoteLeche | Cumple 3FN | volumenDisponibleLitros se puede calcular (inicial menos lo usado); se conserva como estado operativo y debe mantenerse coherente. |
| LoteInsumo | Cumple 3FN | Fechas y cantidades varían por recepción, por eso viven aquí y no en Insumo. cantidadDisponible se puede calcular igual que arriba. |
| EstandarCalidad | Cumple 3FN | El rango depende de (parametro, tipoProducto), no de ninguna prueba. Sacarlo de PruebaCalidad eliminó la dependencia transitiva que había. |
| LoteProduccion | Cumple 3FN | tipoProducto queda como atributo (el alcance es solo yogur). |
| Envasado | Cumple 3FN | Todos los datos describen el envasado. |
| Descarte | Cumple 3FN | La clave es la del lote y el resto depende solo de ella. |
| Almacena, UsoTanque, ConsumoInsumo, Asigna | Cumplen 3FN | Los atributos describen el evento completo, no a una sola de las entidades. |
| PruebaCalidad | Cumple, con observaciones | Ver abajo. |

**Observaciones sobre PruebaCalidad:**

1. **parametroMedido** depende de idEstandar, porque EstandarCalidad ya tiene su atributo parametro. Es una dependencia transitiva (prueba, estándar, parámetro) que duplica el dato. En 3FN se quita de PruebaCalidad y se lee desde EstandarCalidad.
2. **unidadMedida** depende del parámetro (el pH no tiene unidad y la acidez sí), no de la prueba. Lo natural es llevarla a EstandarCalidad.
3. **resultado** se puede derivar de valorObtenido frente al rango. Se justifica guardarlo como registro histórico, por si el rango cambia después.

Se dejaron en PruebaCalidad porque así están en el Módulo 4. La corrección corresponde al equipo.

---

## 7. Diferencias entre módulos que el equipo debe resolver

| Tema | Módulo 3 | Módulos 4 y 5 |
|---|---|---|
| Límites del rango | RN-04 los guarda en cada prueba | Están en EstandarCalidad, no en PruebaCalidad |
| Relación Tiene | Supuesto 3: cada prueba pertenece a exactamente un lote (1,1) | R07: (0,1), porque una prueba puede ser de un lote de leche |
| Atributos de las FK nuevas | Sin mención | El Módulo 4 lista R12 y R13 pero no las columnas idProveedor en LoteInsumo ni idEstandar en PruebaCalidad; se agregaron con esos nombres |
| tipoProducto en EstandarCalidad | Sin mención | Está en el Módulo 5, no en la lista de atributos del Módulo 4; se incluyó |
| Nombres de tablas intermedias | Almacena, Ocupa, Consume | El Módulo 4 usa UsoTanque y ConsumoInsumo; se usaron esos |
