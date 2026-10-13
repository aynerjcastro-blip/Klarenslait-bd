# Esquema Relacional

Derivado del Módulo 4 (entidades, atributos y relaciones), con los dominios, supuestos y reglas del Módulo 3 (versión corregida, segunda ronda) y las justificaciones del diagrama EER (Módulo 5).

**Nombres:** tablas y atributos en minúscula con guion bajo, como en el diagrama, porque PostgreSQL guarda en minúscula los nombres sin comillas y así las consultas no necesitan comillas. Toda clave foránea lleva el prefijo `id`. Las claves primarias van <u>subrayadas</u>. En cada clave foránea se indica la tabla y el atributo al que apunta.

---

## 1. Tablas por entidad

### proveedor

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_proveedor</u> | PK | |
| nombre | | |
| tipo_proveedor | | |
| identificacion | | Única |
| telefono | | |
| ubicacion | | |
| estado | | |

### lote_leche

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_lote_leche</u> | PK | |
| codigo | | Único |
| fecha_recepcion | | |
| volumen_inicial_litros | | |
| volumen_disponible_litros | | |
| estado_lote | | Dominio del Módulo 3 (1.2) |
| dictamen_microbiologico | | Dominio del Módulo 3 (1.2) |
| id_proveedor_origen | FK → proveedor(id_proveedor) | Obligatoria (R01) |

### silo

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_silo</u> | PK | |
| codigo | | Único |
| tipo_silo | | |
| capacidad_maxima | | |
| volumen_actual | | |
| estado_operativo | | |

### tanque

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_tanque</u> | PK | |
| codigo | | Único |
| tipo_tanque | | |
| capacidad_maxima | | |
| volumen_actual | | |
| estado_operativo | | |

### insumo

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_insumo</u> | PK | |
| codigo | | Único |
| categoria_insumo | | |
| unidad_medida | | |
| estado | | |

### lote_insumo

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_lote_insumo</u> | PK | |
| codigo_lote_insumo | | Único |
| fecha_recepcion | | |
| fecha_caducidad | | |
| cantidad_inicial | | |
| cantidad_disponible | | |
| estado | | |
| id_insumo | FK → insumo(id_insumo) | Obligatoria (R06) |
| id_proveedor | FK → proveedor(id_proveedor) | Obligatoria (R12) |

### empleado

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_empleado</u> | PK | |
| nombre | | |
| identificacion | | Única |
| cargo | | Dominio del Módulo 3 (1.5) |
| estado_vinculacion | | |

### estandar_calidad

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_estandar</u> | PK | |
| parametro | | ph, temperatura, acidez_dornic, grasa, viscosidad o microorganismos (Módulo 3, 1.6) |
| tipo_producto | | |
| unidad_medida | | Unidad del parámetro; viene de prueba_calidad (decisión D8) |
| etapa | | Obligatoria: recepcion, fermentacion, mezcla o envasado (Módulo 3, 1.6) |
| valor_minimo_permitido | | |
| valor_maximo_permitido | | |

Un mismo parámetro y producto puede tener rangos distintos según la etapa. Por ejemplo, la temperatura tiene un límite en la fermentación y otro distinto en el envasado. Por eso la unicidad es sobre (parametro, tipo_producto, etapa) y no solo sobre (parametro, tipo_producto). La etapa es NOT NULL: con valor nulo la unicidad no impediría duplicados.

### lote_produccion

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_lote_produccion</u> | PK | |
| codigo | | Único |
| tipo_producto | | yogurt, queso, suero, avena o leche_uht (Módulo 3, 1.6) |
| fecha_hora_inicio | | |
| fecha_hora_fin | | |
| volumen_planificado_litros | | |
| volumen_producido_litros | | |
| estado | | en_proceso, aprobado, rechazado, envasado o descartado (Módulo 3, 1.1) |
| id_supervisor | FK → empleado(id_empleado) | Obligatoria (R04) |

### envasado

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_envasado</u> | PK | |
| fecha_hora_envasado | | |
| fecha_vencimiento | | |
| fecha_hora_despacho | | |
| presentacion | | |
| cantidad_envasada | | |
| destino | | Obligatorio: mayorista, minorista o venta_directa (RN-11) |
| temperatura_envasado | | |
| temperatura_despacho | | |
| estado | | abierto o cerrado (Módulo 3, 1.6) |
| id_lote_produccion | FK → lote_produccion(id_lote_produccion) | Obligatoria (R09) |

### prueba_calidad

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_prueba_calidad</u> | PK | |
| fecha_hora | | |
| tipo_prueba | | microbiologica, fisicoquimica, ph_linea o temperatura_linea (Módulo 3, 1.4) |
| valor_obtenido | | |
| resultado | | aprobado, rechazado o reproceso (Módulo 3) |
| origen_registro | | sensor o manual (ver nota abajo) |
| id_lote_leche | FK → lote_leche(id_lote_leche) | Opcional (R11) |
| id_lote_produccion | FK → lote_produccion(id_lote_produccion) | Opcional (R07) |
| id_estandar | FK → estandar_calidad(id_estandar) | Obligatoria (R13) |
| id_responsable_registro | FK → empleado(id_empleado) | Opcional (R08) |

**Restricción CHECK (exclusividad):** exactamente una de las dos llaves, id_lote_leche o id_lote_produccion, debe tener valor. Una prueba pertenece a un lote de leche o a uno de producción, nunca a ambos ni a ninguno.

prueba_calidad no guarda valor_minimo_permitido, valor_maximo_permitido, parametro_medido ni unidad_medida: el rango, el parámetro y la unidad se obtienen por la relación R13 con estandar_calidad.

**Nota sobre origen_registro:** el Módulo 3 usaba Operario para toda prueba hecha por una persona, ya sea un operador de tanque o un técnico de calidad, y ese valor no coincide con ningún cargo. Para resolverlo, origen_registro toma los valores sensor y manual (hecha por una persona), y el cargo se llama operador_tanque.

### descarte *(entidad débil)*

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_lote_produccion</u> | PK, FK → lote_produccion(id_lote_produccion) | Clave del lote (R10) |
| fecha_hora_descarte | | Obligatorio |
| motivo | | Obligatorio |
| volumen_descartado | | Obligatorio, mayor que 0 |
| observaciones | | |

Un lote genera como máximo un descarte, así que no hace falta clave parcial: la clave completa es la clave foránea del lote.

---

## 2. Tablas intermedias (relaciones asociativas)

Las cuatro llevan clave primaria propia, como las define el Módulo 4. Los atributos propios son los del diagrama.

### almacena *(silo — lote_leche)*

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_almacena</u> | PK | |
| id_silo | FK → silo(id_silo) | |
| id_lote_leche | FK → lote_leche(id_lote_leche) | |
| fecha_hora | | |
| tipo_movimiento | | entrada o salida (Módulo 3, 1.6) |
| volumen_litros | | |
| observaciones | | El grupo decidió conservarlo |

### uso_tanque *(tanque — lote_produccion)*

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_uso_tanque</u> | PK | |
| id_tanque | FK → tanque(id_tanque) | |
| id_lote_produccion | FK → lote_produccion(id_lote_produccion) | |
| fecha_hora_inicio | | |
| fecha_hora_fin | | Vacía mientras el uso está activo (RN-06) |
| estado_uso | | activo o finalizado (Módulo 3, 1.6) |

### consumo_insumo *(lote_produccion — lote_insumo)*

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_consumo_insumo</u> | PK | |
| id_lote_insumo | FK → lote_insumo(id_lote_insumo) | |
| id_lote_produccion | FK → lote_produccion(id_lote_produccion) | |
| fecha_hora_consumo | | |
| cantidad_consumida | | |

### asigna *(silo — tanque — lote_produccion, relación ternaria)*

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_asigna</u> | PK | |
| id_silo_origen | FK → silo(id_silo) | |
| id_tanque_destino | FK → tanque(id_tanque) | |
| id_lote_produccion | FK → lote_produccion(id_lote_produccion) | |
| fecha_hora_asignacion | | |
| volumen_asignado_litros | | |

### Por qué cada una lleva clave propia

| Tabla | Justificación |
|---|---|
| almacena | El mismo lote puede entrar y salir del mismo silo varias veces; la pareja de FK no identifica el movimiento. |
| uso_tanque | Un lote puede volver a usar el mismo tanque en otro momento; cada uso tiene su propio inicio y fin. |
| consumo_insumo | Un lote de insumo se consume parcialmente y varias veces en el mismo lote de producción. |
| asigna | Pueden repetirse las mismas tres entidades en asignaciones distintas, con fecha y volumen propios. |

---

## 3. Restricciones CHECK y reglas de integridad

| Tabla | Regla | Origen |
|---|---|---|
| prueba_calidad | Exactamente una de id_lote_leche o id_lote_produccion tiene valor | Módulo 4 (R07 y R11) |
| prueba_calidad | tipo_prueba: microbiologica, fisicoquimica, ph_linea o temperatura_linea | Módulo 3 (1.4) |
| prueba_calidad | origen_registro: sensor o manual. Si es sensor, id_responsable_registro es nulo y tipo_prueba es ph_linea o temperatura_linea; si es manual, id_responsable_registro no es nulo | RN-09 |
| prueba_calidad | Los tipos ph_linea y temperatura_linea exigen id_lote_produccion | RN-13 |
| estandar_calidad | valor_minimo_permitido menor o igual a valor_maximo_permitido | RN-04 |
| estandar_calidad | etapa NOT NULL: recepcion, fermentacion, mezcla o envasado | Decisión del grupo (D9) y Módulo 3 (1.6) |
| estandar_calidad | parametro: ph, temperatura, acidez_dornic, grasa, viscosidad o microorganismos | Módulo 3 (1.6) |
| estandar_calidad | Único (parametro, tipo_producto, etapa) | Decisión del grupo (D9) y RN-04 (un rango por parámetro, producto y etapa) |
| descarte | motivo, volumen_descartado y fecha_hora_descarte obligatorios; volumen_descartado mayor que 0 | RN-05 |
| uso_tanque | Índice único parcial sobre id_tanque donde fecha_hora_fin es nula: un solo uso activo por tanque | RN-06 |
| tanque | capacidad_maxima mayor que 0; volumen_actual entre 0 y capacidad_maxima | RN-07 (parte declarativa) |
| silo | capacidad_maxima mayor que 0; volumen_actual entre 0 y capacidad_maxima | Dominio: capacidades y volúmenes positivos, y volumen_actual no mayor que la capacidad (RN-07 solo habla del tanque) |
| lote_insumo | 0 menor o igual a cantidad_disponible, y esta menor o igual a cantidad_inicial | RN-10 |
| lote_insumo | fecha_caducidad mayor o igual a fecha_recepcion | RN-02 |
| lote_leche | dictamen_microbiologico: pendiente, aprobado o rechazado | Módulo 3 (1.2) |
| lote_leche | estado_lote: recibido, disponible, agotado o rechazado | Módulo 3 (1.2) |
| lote_leche | Un lote disponible exige dictamen aprobado y litros; un dictamen rechazado implica estado rechazado; agotado implica 0 litros | Módulo 3 (1.2) |
| lote_produccion | estado: en_proceso, aprobado, rechazado, envasado o descartado | Módulo 3 (1.1) |
| lote_produccion | tipo_producto: yogurt, queso, suero, avena o leche_uht | Módulo 3 (1.6) |
| prueba_calidad | resultado: aprobado, rechazado o reproceso | Módulo 3 (1.1) |
| empleado | cargo: operador_tanque, tecnico_calidad o supervisor | Módulo 3 (1.5) |
| envasado | destino obligatorio: mayorista, minorista o venta_directa | RN-11 |
| envasado | fecha_vencimiento obligatoria y posterior a fecha_hora_envasado; fecha_hora_despacho, si existe, no anterior a fecha_hora_envasado | RN-11 y supuesto 27 |
| envasado | estado: abierto o cerrado | Módulo 3 (1.6) |
| uso_tanque | estado_uso: activo o finalizado | Módulo 3 (1.6) |
| almacena | tipo_movimiento: entrada o salida | Módulo 3 (1.6) |

Todos los valores literales van en minúscula, sin tildes ni espacios, tal como se escriben en cada CHECK. Los dominios de los demás campos de estado y de tipo no están definidos en los módulos entregados; quedan pendientes del diccionario de datos.

---

## 4. Política de borrado por clave foránea

Todas las claves foráneas usan **RESTRICT**. No hay CASCADE ni SET NULL, por estas razones del Módulo 3:

- La conservación mínima de 365 días (supuesto 17 y RN-08) prohíbe borrar lotes y pruebas dentro del plazo.
- Quien autorizó un lote no puede perderse (supuesto 10): un empleado se desactiva con estado_vinculacion, no se borra.
- RN-09 exige que una prueba de operario tenga responsable; un SET NULL violaría ese CHECK.

| # | Clave foránea | Política | Justificación |
|---|---|---|---|
| 1 | lote_leche.id_proveedor_origen → proveedor(id_proveedor) | RESTRICT | No se pierde el origen de la leche; el proveedor se desactiva con estado. |
| 2 | lote_insumo.id_insumo → insumo(id_insumo) | RESTRICT | Un insumo con lotes registrados es parte del historial de producción. |
| 3 | lote_insumo.id_proveedor → proveedor(id_proveedor) | RESTRICT | Debe poder responderse qué proveedor entregó cada insumo. |
| 4 | lote_produccion.id_supervisor → empleado(id_empleado) | RESTRICT | Cada lote conserva quién lo autorizó; el empleado no se elimina mientras tenga lotes (supuesto 10). |
| 5 | envasado.id_lote_produccion → lote_produccion(id_lote_produccion) | RESTRICT | El envasado y la cadena de frío son registros regulatorios que se conservan (RN-08). |
| 6 | descarte.id_lote_produccion → lote_produccion(id_lote_produccion) | RESTRICT | RN-08 incluye a descarte entre las FK hacia el lote que no se borran en el plazo de conservación. |
| 7 | prueba_calidad.id_lote_leche → lote_leche(id_lote_leche) | RESTRICT | Las pruebas de recepción son evidencia de calidad y se conservan 365 días desde fecha_recepcion (RN-08). |
| 8 | prueba_calidad.id_lote_produccion → lote_produccion(id_lote_produccion) | RESTRICT | RN-08: lotes y pruebas se conservan 365 días desde el cierre del lote. |
| 9 | prueba_calidad.id_estandar → estandar_calidad(id_estandar) | RESTRICT | Borrar un estándar dejaría pruebas sin su rango de referencia. |
| 10 | prueba_calidad.id_responsable_registro → empleado(id_empleado) | RESTRICT | RN-09 exige responsable en las pruebas de operario. |
| 11 | almacena.id_silo → silo(id_silo) | RESTRICT | Los movimientos de acopio de un silo son su historial de trazabilidad. |
| 12 | almacena.id_lote_leche → lote_leche(id_lote_leche) | RESTRICT | Debe poder rastrearse por qué silos pasó cada lote de leche. |
| 13 | uso_tanque.id_tanque → tanque(id_tanque) | RESTRICT | No se borra un tanque con historial de uso, porque la fermentación se mide con ese historial. |
| 14 | uso_tanque.id_lote_produccion → lote_produccion(id_lote_produccion) | RESTRICT | Los tanques que usó un lote forman parte de su historial, que se conserva 365 días. |
| 15 | consumo_insumo.id_lote_insumo → lote_insumo(id_lote_insumo) | RESTRICT | Debe poder rastrearse en qué lotes se usó cada lote de insumo. |
| 16 | consumo_insumo.id_lote_produccion → lote_produccion(id_lote_produccion) | RESTRICT | El consumo de insumos es trazabilidad del lote y se conserva con él. |
| 17 | asigna.id_silo_origen → silo(id_silo) | RESTRICT | Cada asignación documenta de qué silo salió la leche, y la trazabilidad llega hasta el silo (supuesto 19). |
| 18 | asigna.id_tanque_destino → tanque(id_tanque) | RESTRICT | Registra a qué tanque llegó la leche; sin él no se puede reconstruir dónde se procesó el lote ni validar la capacidad (RN-07). |
| 19 | asigna.id_lote_produccion → lote_produccion(id_lote_produccion) | RESTRICT | El lote y sus asignaciones se conservan 365 días desde el cierre (RN-08); no deben desaparecer juntos. |

Las 19 claves foráneas del esquema tienen política y justificación propia.

---

## 5. Del diagrama al esquema

| Código | Relación | Cardinalidad | Implementación |
|---|---|---|---|
| R01 | suministra | proveedor (1,1) — lote_leche (0,N) | FK obligatoria lote_leche.id_proveedor_origen → proveedor(id_proveedor) |
| R02 | almacena | silo (0,N) — lote_leche (0,N) | Tabla almacena |
| R03 | ocupa | lote_produccion (0,N) — tanque (1,N) | Tabla uso_tanque |
| R04 | supervisa | empleado (1,1) — lote_produccion (0,N) | FK obligatoria lote_produccion.id_supervisor → empleado(id_empleado) |
| R05 | consume | lote_produccion (0,N) — lote_insumo (0,N) | Tabla consumo_insumo |
| R06 | identifica | insumo (1,1) — lote_insumo (0,N) | FK obligatoria lote_insumo.id_insumo → insumo(id_insumo) |
| R07 | tiene | lote_produccion (0,1) — prueba_calidad (0,N) | FK opcional prueba_calidad.id_lote_produccion → lote_produccion(id_lote_produccion), con el CHECK |
| R08 | registra | empleado (0,1) — prueba_calidad (0,N) | FK opcional prueba_calidad.id_responsable_registro → empleado(id_empleado) |
| R09 | envasa | lote_produccion (1,1) — envasado (0,N) | FK obligatoria envasado.id_lote_produccion → lote_produccion(id_lote_produccion) |
| R10 | genera | lote_produccion (1,1) — descarte (0,1) | PK de descarte que es FK a lote_produccion(id_lote_produccion) |
| R11 | analiza | lote_leche (0,1) — prueba_calidad (0,N) | FK opcional prueba_calidad.id_lote_leche → lote_leche(id_lote_leche), con el CHECK |
| R12 | provee | proveedor (1,1) — lote_insumo (0,N) | FK obligatoria lote_insumo.id_proveedor → proveedor(id_proveedor) |
| R13 | evalua | estandar_calidad (1,1) — prueba_calidad (0,N) | FK obligatoria prueba_calidad.id_estandar → estandar_calidad(id_estandar) |
| — | asigna (ternaria) | silo (0,N), tanque (0,N), lote_produccion (1,N) | Tabla asigna con tres FK |

**Mínimos (1,N) que no se pueden expresar con una FK:** un lote de producción debe tener al menos un registro en uso_tanque y al menos uno en asigna, y cada asigna necesita un uso_tanque activo del mismo tanque y lote. Se controlan con triggers (sección 7).

---

## 6. Revisión de normalización hasta 3FN

| Tabla | Resultado | Comentario |
|---|---|---|
| proveedor, silo, tanque, insumo, empleado | Cumple 3FN | Todo atributo depende solo de la clave. |
| lote_leche | Cumple 3FN | volumen_disponible_litros se puede calcular (inicial menos lo usado); se conserva como estado operativo y debe mantenerse coherente. |
| lote_insumo | Cumple 3FN | Fechas y cantidades varían por recepción, por eso viven aquí y no en insumo. cantidad_disponible se puede calcular igual que arriba. |
| estandar_calidad | Cumple 3FN, con una salvedad | El rango depende de (parametro, tipo_producto, etapa), no de ninguna prueba. Salvedad: unidad_medida depende de parametro, que no es la clave, así que en sentido estricto es una dependencia transitiva. Se acepta por ser un catálogo pequeño; la solución estricta sería una tabla parametro. |
| lote_produccion | Cumple 3FN | tipo_producto queda como atributo (el alcance es solo yogur). |
| envasado | Cumple 3FN | Todos los datos describen el envasado. |
| descarte | Cumple 3FN | La clave es la del lote y el resto depende solo de ella. |
| almacena, uso_tanque, consumo_insumo, asigna | Cumplen 3FN | Los atributos describen el evento completo, no a una sola de las entidades. |
| prueba_calidad | Cumple 3FN | Se quitaron parametro_medido y unidad_medida (decisión D8, opción a): dependían de id_estandar y no de la prueba. Quedan solo atributos de la prueba y sus FK. |

**Sobre prueba_calidad:**

1. **parametro_medido** dependía de id_estandar, porque estandar_calidad ya tiene parametro: era una dependencia transitiva (prueba, estándar, parámetro). Se eliminó y se lee desde estandar_calidad.
2. **unidad_medida** dependía del parámetro, no de la prueba. Se movió a estandar_calidad.
3. **resultado** se puede calcular de valor_obtenido frente al rango. No es una dependencia transitiva; se guarda como registro histórico, por si el rango cambia después.

**Atributos calculables:** volumen_actual de silo y de tanque también se puede calcular, igual que volumen_disponible_litros de lote_leche, a partir de los movimientos registrados (almacena y asigna). Se conservan como estado operativo y deben mantenerse coherentes con esos movimientos.

---

## 7. Triggers y mecanismos de las reglas de negocio

Son los mecanismos que no se pueden expresar solo con CHECK o claves foráneas, tal como los define el Módulo 3 (marcados [E3]) más los que piden las correcciones.

| Regla | Tabla y momento | Qué verifica | Si no se cumple |
|---|---|---|---|
| RN-01 | BEFORE INSERT en almacena | lote_leche.dictamen_microbiologico del id_lote_leche debe ser aprobado | Rechaza el registro: la leche sin dictamen aprobado no entra a un silo |
| RN-01 (dictamen derivado, D12) | AFTER INSERT en prueba_calidad con id_lote_leche y tipo_prueba microbiologica | Deriva el dictamen del lote de leche (Módulo 3, 1.2): sin pruebas queda pendiente; cualquier prueba rechazado da rechazado; ninguna rechazado y al menos una aprobado da aprobado | Actualiza lote_leche.dictamen_microbiologico; si queda rechazado, estado_lote pasa a rechazado. El dictamen no se edita a mano |
| RN-02 | BEFORE INSERT en consumo_insumo | La fecha de fecha_hora_consumo debe ser menor o igual a lote_insumo.fecha_caducidad | Rechaza el consumo de un insumo vencido |
| RN-03 | BEFORE INSERT en envasado | lote_produccion.estado del id_lote_produccion debe ser aprobado | Rechaza el envasado de un lote que no está aprobado |
| RN-03 (cierre del envasado, D11) | BEFORE UPDATE de estado en lote_produccion | El paso a envasado exige al menos un envasado cerrado y ninguno abierto, y lo hace el Supervisor al cerrar el envasado. Después el lote ya no admite más registros de envasado | Rechaza el cambio de estado |
| RN-04 | No lleva trigger en el Módulo 3. Una vista sobre prueba_calidad y estandar_calidad | Detecta las mediciones de un parámetro fuera de [valor_minimo_permitido, valor_maximo_permitido] durante 15 minutos o más seguidos | No bloquea nada: la vista muestra la alerta. La parte declarativa es el CHECK de mínimo menor o igual a máximo en estandar_calidad |
| RN-06 | Trigger de respaldo en uso_tanque | Valida el traslado entre tanques: al abrir el uso del tanque de mezcla se cierra el del tanque de fermentación | Rechaza el uso que dejaría dos usos activos. La parte declarativa es el índice único parcial |
| RN-07 | BEFORE INSERT en asigna | Suma volumen_asignado_litros de las asignaciones del lote activo a ese tanque, más la nueva; no puede superar tanque.capacidad_maxima | Rechaza la asignación |
| RN-08 | BEFORE DELETE en lote_produccion y en prueba_calidad | Compara la fecha actual con el inicio del plazo más 365 días. Lote de producción y sus pruebas: desde el cierre (fecha_hora_envasado del último envasado, o fecha_hora_descarte si fue descartado). Pruebas de un lote de leche, que no tiene cierre de producción: desde lote_leche.fecha_recepcion (supuesto 17) | Rechaza el borrado antes de cumplirse el plazo. Se refuerza con las FK en RESTRICT y un rol de la aplicación sin privilegio DELETE |
| RN-09 | BEFORE INSERT en prueba_calidad | Lee empleado.cargo del id_responsable_registro según tipo_prueba: las pruebas de laboratorio (microbiologica, fisicoquimica) solo las registra un tecnico_calidad; la validación manual en línea (ph_linea, temperatura_linea), un operador_tanque o un tecnico_calidad; la medición del sensor no lleva empleado | Rechaza el registro. La parte declarativa es el CHECK entre origen_registro e id_responsable_registro |
| RN-10 | BEFORE INSERT en consumo_insumo | cantidad_consumida no puede superar lote_insumo.cantidad_disponible; si es válida, se descuenta de cantidad_disponible | Rechaza el consumo; el CHECK entre 0 e inicial lo respalda |
| RN-12 | BEFORE INSERT en asigna | Existe un uso_tanque con el mismo id_tanque_destino e id_lote_produccion y fecha_hora_fin nula | Rechaza la asignación sin uso activo del tanque |
| Estándar de la prueba | BEFORE INSERT en prueba_calidad | Si la prueba es de un lote de producción, estandar_calidad.tipo_producto debe ser igual a lote_produccion.tipo_producto. Si es de un lote de leche, la etapa del estándar debe ser recepcion | Rechaza la prueba |
| Mínimos (1,N) de lote_produccion | Trigger de restricción diferido (DEFERRABLE INITIALLY DEFERRED) sobre lote_produccion, al confirmar la transacción | El lote tiene al menos un uso_tanque y al menos una asigna | Rechaza la confirmación; lote, uso_tanque y asigna se insertan en la misma transacción |

### Transiciones de estado

Un trigger BEFORE UPDATE de la columna de estado rechaza cualquier cambio que no esté en esta tabla. Las de lote_produccion son las del Módulo 3 (1.1). Las de lote_leche se derivan de las definiciones del Módulo 3 (1.2), que no lista transiciones.

| Tabla | De | A |
|---|---|---|
| lote_produccion.estado | en_proceso | aprobado, rechazado, descartado |
| lote_produccion.estado | aprobado | envasado |
| lote_produccion.estado | rechazado | descartado |
| lote_leche.estado_lote | recibido | disponible, rechazado |
| lote_leche.estado_lote | disponible | agotado |

---

## 8. Diferencias entre módulos que el equipo debe resolver

| Tema | Lo que dicen los módulos | Lo que usa este esquema |
|---|---|---|
| Parámetro y unidad de la prueba | Módulos 4 y 5 y el diagrama los guardan en prueba_calidad | Se quitaron de prueba_calidad (D8, opción a) por la 3FN; el diagrama y el Módulo 4 deben actualizarse |
| Etapa en estandar_calidad | Módulo 3 define sus valores (recepcion, fermentacion, mezcla, envasado); Módulos 4 y 5 y el diagrama no tienen el atributo | Atributo etapa NOT NULL |
| unidad_medida en estandar_calidad | Módulos 4 y 5 y el diagrama no la tienen ahí | Se agregó (D8) |
| tipo_producto en estandar_calidad | Está en el Módulo 5 y en el diagrama; no en la lista de atributos del Módulo 4 | Se incluyó |
| Nombre de tipo_producto | Módulo 3 (1.6) lo llama tipo_produccion; Módulo 4 y diagrama, tipo_producto | tipo_producto |
| fecha de despacho | Módulo 3 (supuesto 27) usa fecha_despacho; Módulo 4 y diagrama, fecha_hora_despacho | fecha_hora_despacho |
| FK hacia empleado | Módulo 3 usa id_empleado; el Módulo 4 usa supervisor y responsableRegistro | id_supervisor e id_responsable_registro, para distinguir las dos relaciones |
| Observaciones de Almacena | Módulo 5 y diagrama las tienen; Módulo 4, parte 1, no | Se incluyeron |
| Columnas de las FK nuevas | Módulo 4 y el diagrama muestran R12 y R13 pero no las columnas id_proveedor en lote_insumo ni id_estandar en prueba_calidad | Se agregaron |
| Nombres de tablas intermedias | Módulos 3 y 5 usan almacena, ocupa y consume; Módulo 4, UsoTanque y ConsumoInsumo | almacena, uso_tanque, consumo_insumo y asigna |
| Atributos de las asociativas | Módulo 4 los escribe distinto al diagrama (cantidad, estado, fechaHora) | Los del diagrama: cantidad_consumida, estado_uso, fecha_hora_asignacion |
| Valor Operario | Módulo 3 usa Operario en origen_registro y cargos con espacios y tildes (Operador de tanque, Técnico de calidad) | origen_registro: sensor o manual; cargos operador_tanque, tecnico_calidad y supervisor |
| Valores literales | Módulo 3 escribe en proceso y venta directa con espacios | en_proceso y venta_directa, sin tildes ni espacios |
| RN-02 | Módulo 3 permite consumir hasta la fecha de caducidad inclusive | CHECK fecha_caducidad mayor o igual a fecha_recepcion |
| Envasado.estado | Módulo 5 deja sus valores al diccionario (Módulo 7); Módulo 3 los define | abierto y cerrado, del Módulo 3 |

Esta tabla se actualiza cuando los Módulos 3, 4 y 5 queden corregidos.
