# Esquema Relacional

Derivado del Módulo 4 (entidades, atributos y relaciones), con las decisiones y reglas del Módulo 3 y las justificaciones del diagrama EER (Módulo 5).

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
| parametro | | |
| tipo_producto | | |
| etapa | | Etapa o contexto en que aplica el rango (ver abajo) |
| valor_minimo_permitido | | |
| valor_maximo_permitido | | |

Un mismo parámetro y producto puede tener rangos distintos según la etapa. Por ejemplo, la temperatura es 45 °C en la fermentación y 6 °C en la cadena de frío. Por eso la unicidad es sobre (parametro, tipo_producto, etapa) y no solo sobre (parametro, tipo_producto).

### lote_produccion

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_lote_produccion</u> | PK | |
| codigo | | Único |
| tipo_producto | | |
| fecha_hora_inicio | | |
| fecha_hora_fin | | |
| volumen_planificado_litros | | |
| volumen_producido_litros | | |
| estado | | Dominio del Módulo 3 (1.1) |
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
| destino | | Obligatorio; mayorista, minorista o venta directa (RN-11) |
| temperatura_envasado | | |
| temperatura_despacho | | |
| estado | | |
| id_lote_produccion | FK → lote_produccion(id_lote_produccion) | Obligatoria (R09) |

### prueba_calidad

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_prueba_calidad</u> | PK | |
| fecha_hora | | |
| tipo_prueba | | |
| parametro_medido | | Ver observación 1 de la sección 6 |
| valor_obtenido | | |
| unidad_medida | | Ver observación 2 de la sección 6 |
| resultado | | aprobado, rechazado o reproceso (Módulo 3) |
| origen_registro | | Sensor u Operario (ver nota abajo) |
| id_lote_leche | FK → lote_leche(id_lote_leche) | Opcional (R11) |
| id_lote_produccion | FK → lote_produccion(id_lote_produccion) | Opcional (R07) |
| id_estandar | FK → estandar_calidad(id_estandar) | Obligatoria (R13) |
| id_responsable_registro | FK → empleado(id_empleado) | Opcional (R08) |

**Restricción CHECK (exclusividad):** exactamente una de las dos llaves, id_lote_leche o id_lote_produccion, debe tener valor. Una prueba pertenece a un lote de leche o a uno de producción, nunca a ambos ni a ninguno.

prueba_calidad no guarda valor_minimo_permitido ni valor_maximo_permitido: el rango se obtiene por la relación R13 con estandar_calidad.

**Nota sobre origen_registro:** el Módulo 3 usa el valor Operario para toda validación o prueba hecha por una persona, ya sea un Operador de tanque o un Técnico de calidad. El valor no coincide con el nombre del cargo; el equipo debe decidir si lo deja así o lo renombra.

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
| tipo_movimiento | | |
| volumen_litros | | |
| observaciones | | El grupo decidió conservarlo |

### uso_tanque *(tanque — lote_produccion)*

| Atributo | Llave | Nota |
|---|---|---|
| <u>id_uso_tanque</u> | PK | |
| id_tanque | FK → tanque(id_tanque) | |
| id_lote_produccion | FK → lote_produccion(id_lote_produccion) | |
| fecha_hora_inicio | | |
| fecha_hora_fin | | Vacía mientras el uso está activo |
| estado_uso | | |

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
| prueba_calidad | Si origen_registro es Sensor, id_responsable_registro es nulo; si es Operario, no es nulo | RN-09 |
| estandar_calidad | valor_minimo_permitido menor o igual a valor_maximo_permitido | RN-04 |
| estandar_calidad | Único (parametro, tipo_producto, etapa) | Revisión del Módulo 6 |
| descarte | motivo, volumen_descartado y fecha_hora_descarte obligatorios; volumen_descartado mayor que 0 | RN-05 |
| uso_tanque | Índice único parcial sobre id_tanque donde fecha_hora_fin es nula: un solo uso activo por tanque | RN-06 |
| tanque | capacidad_maxima mayor que 0; volumen_actual entre 0 y capacidad_maxima | RN-07 (parte declarativa) |
| silo | capacidad_maxima mayor que 0; volumen_actual entre 0 y capacidad_maxima | Dominio: capacidades y volúmenes positivos, y volumen_actual no mayor que la capacidad (RN-07 solo habla del tanque) |
| lote_insumo | 0 menor o igual a cantidad_disponible, y esta menor o igual a cantidad_inicial | RN-10 |
| lote_insumo | fecha_caducidad posterior a fecha_recepcion | RN-02 |
| lote_leche | dictamen_microbiologico: pendiente, aprobado o rechazado | Módulo 3 (1.2) |
| lote_leche | estado_lote: recibido, disponible, agotado o rechazado | Módulo 3 (1.2) |
| lote_leche | Un lote disponible exige dictamen aprobado y litros; un dictamen rechazado implica estado rechazado; agotado implica 0 litros | Módulo 3 (1.2) |
| lote_produccion | estado: en proceso, aprobado, rechazado, envasado o descartado | Módulo 3 (1.1) |
| prueba_calidad | resultado: aprobado, rechazado o reproceso | Módulo 3 (1.1) |
| empleado | cargo: Operador de tanque, Técnico de calidad o Supervisor | Módulo 3 (1.5) |
| envasado | destino obligatorio: mayorista, minorista o venta directa | RN-11 |

Los dominios de los demás campos de estado y de tipo no están definidos en los módulos entregados; quedan pendientes del diccionario de datos.

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
| 7 | prueba_calidad.id_lote_leche → lote_leche(id_lote_leche) | RESTRICT | Las pruebas de recepción son evidencia de calidad y no se borran con el lote de leche. |
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

---

## 6. Revisión de normalización hasta 3FN

| Tabla | Resultado | Comentario |
|---|---|---|
| proveedor, silo, tanque, insumo, empleado | Cumple 3FN | Todo atributo depende solo de la clave. |
| lote_leche | Cumple 3FN | volumen_disponible_litros se puede calcular (inicial menos lo usado); se conserva como estado operativo y debe mantenerse coherente. |
| lote_insumo | Cumple 3FN | Fechas y cantidades varían por recepción, por eso viven aquí y no en insumo. cantidad_disponible se puede calcular igual que arriba. |
| estandar_calidad | Cumple 3FN | El rango depende de (parametro, tipo_producto, etapa), no de ninguna prueba. Sacarlo de prueba_calidad eliminó la dependencia transitiva que había. |
| lote_produccion | Cumple 3FN | tipo_producto queda como atributo (el alcance es solo yogur). |
| envasado | Cumple 3FN | Todos los datos describen el envasado. |
| descarte | Cumple 3FN | La clave es la del lote y el resto depende solo de ella. |
| almacena, uso_tanque, consumo_insumo, asigna | Cumplen 3FN | Los atributos describen el evento completo, no a una sola de las entidades. |
| prueba_calidad | Cumple, con observaciones | Ver abajo. |

**Observaciones sobre prueba_calidad:**

1. **parametro_medido** depende de id_estandar, porque estandar_calidad ya tiene su atributo parametro. Es una dependencia transitiva (prueba, estándar, parámetro) que duplica el dato. En 3FN se quita de prueba_calidad y se lee desde estandar_calidad.
2. **unidad_medida** depende del parámetro (el pH no tiene unidad y la acidez sí), no de la prueba. Lo natural es llevarla a estandar_calidad.
3. **resultado** se puede derivar de valor_obtenido frente al rango. Se justifica guardarlo como registro histórico, por si el rango cambia después.

Se dejaron en prueba_calidad porque así están en el Módulo 4. La corrección corresponde al equipo.

---

## 7. Triggers de las reglas RN-01, RN-04, RN-08 y RN-09

Son los mecanismos que el Módulo 3 define para estas reglas y que no se pueden expresar solo con CHECK o claves.

| Regla | Tabla y momento | Qué verifica | Si no se cumple |
|---|---|---|---|
| RN-01 | BEFORE INSERT en almacena | Consulta lote_leche.dictamen_microbiologico del id_lote_leche que se va a almacenar; debe ser aprobado | Rechaza el registro: la leche sin dictamen aprobado no entra a un silo |
| RN-04 | No lleva trigger en el Módulo 3. Una vista sobre prueba_calidad y estandar_calidad | Detecta las mediciones de un parámetro fuera de [valor_minimo_permitido, valor_maximo_permitido] durante 15 minutos o más seguidos (supuesto 23) | No bloquea nada: la vista muestra la alerta. La parte declarativa es el CHECK de mínimo menor o igual a máximo en estandar_calidad |
| RN-08 | BEFORE DELETE en lote_produccion y en prueba_calidad | Compara la fecha actual con la fecha de cierre del lote más 365 días (cierre: fecha_hora_envasado del último envasado, o fecha_hora_descarte si fue descartado) | Rechaza el borrado antes de cumplirse el plazo. Se refuerza con las FK en RESTRICT y un rol de la aplicación sin privilegio DELETE |
| RN-09 | BEFORE INSERT en prueba_calidad | Lee empleado.cargo del id_responsable_registro según tipo_prueba: una prueba de laboratorio solo la registra un Técnico de calidad; una validación manual en línea, un Operador de tanque o un Técnico de calidad; la medición del sensor no lleva empleado | Rechaza el registro. La parte declarativa es el CHECK entre origen_registro e id_responsable_registro |

---

## 8. Diferencias entre módulos que el equipo debe resolver

| Tema | Módulo 3 | Módulos 4 y 5 |
|---|---|---|
| Límites del rango | RN-04 los guarda en cada prueba | Están en estandar_calidad, no en prueba_calidad |
| Etapa del estándar | Sin mención | Falta un atributo de etapa o contexto en EstandarCalidad; se agregó etapa y debe incorporarse al diagrama y al Módulo 4 |
| Relación Tiene | Supuesto 3: cada prueba pertenece a exactamente un lote (1,1) | R07: (0,1), porque una prueba puede ser de un lote de leche |
| Observaciones de Almacena | El grupo decidió conservarlas | No aparecen en el Módulo 4, parte 1; se incluyeron en almacena |
| Columnas de las FK nuevas | Sin mención | El Módulo 4 lista R12 y R13 pero no las columnas id_proveedor en lote_insumo ni id_estandar en prueba_calidad; se agregaron |
| tipo_producto en estandar_calidad | Sin mención | Está en el Módulo 5, no en la lista de atributos del Módulo 4; se incluyó |
| Nombres de tablas intermedias | almacena, ocupa, consume | El Módulo 4 usa UsoTanque y ConsumoInsumo; se usaron uso_tanque y consumo_insumo |
| Atributos de las asociativas | Sin mención | El Módulo 4 los escribe distinto al diagrama (cantidad, estado, fechaHora); se usaron los del diagrama (cantidad_consumida, estado_uso, fecha_hora_asignacion) |
| Valor Operario | origen_registro usa Operario | El cargo se llama Operador de tanque; Operario cubre también al Técnico de calidad |
