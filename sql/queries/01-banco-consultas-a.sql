

-- -------------------------------------------------------------------------
-- 1. CONSULTA DE PROVEEDORES ACTIVOS
-- Filtrar los proveedores que se encuentran con estado 'Activo' y son tipo Finca o Empresa.
-- -------------------------------------------------------------------------
SELECT
id_proveedor,
nombre,
ubicacion,
telefono,
tipo_proveedor
FROM proveedor
WHERE estado = 'Activo'
AND tipo_proveedor IN ('Finca', 'Empresa');


-- -------------------------------------------------------------------------
-- 2. CONSULTA DE SILOS DE ACOPIO OPERATIVOS
-- Seleccionar los silos de tipo 'Acopio' que se encuentran en estado 'operativo'.
-- Nota: en la tabla silo el CHECK usa minusculas ('operativo'), por eso el literal.
-- -------------------------------------------------------------------------
SELECT
id_silo,
codigo,
capacidad_maxima,
 volumen_actual,
estado_operativo
FROM silo
WHERE tipo_silo = 'Acopio'
AND estado_operativo = 'Operativo';


-- -------------------------------------------------------------------------
-- 3. CONSULTA DE LOTES DE LECHE PENDIENTES DE DICTAMEN
-- Identificar los lotes de leche cruda que tienen dictamen microbiologico pendiente.
-- Nota: el filtro por estado_lote = 'Recibido' refuerza la intencion (un lote
-- con dictamen 'Pendiente' no puede estar 'Disponible' ni 'Agotado' por los CHECK).
-- -------------------------------------------------------------------------
SELECT
id_lote_leche,
codigo,
fecha_recepcion,
volumen_inicial_litros,
id_proveedor_origen
FROM lote_leche
WHERE dictamen_microbiologico = 'Pendiente'
AND estado_lote = 'Recibido';


-- -------------------------------------------------------------------------
-- 4. CONSULTA DE LOTES DE PRODUCCION DE YOGURT EN PROCESO
-- Filtrar los lotes de produccion de la linea 'Yogurt' que estan 'En_proceso'.
-- -------------------------------------------------------------------------
SELECT
id_lote_produccion,
codigo,
volumen_planificado_litros,
fecha_hora_inicio,
id_supervisor
FROM lote_produccion
WHERE tipo_producto = 'Yogurt'
AND estado = 'En_proceso';


-- -------------------------------------------------------------------------
-- 5. CONSULTA DE ESTANDARES DE CALIDAD EN RECEPCION
-- Seleccionar los parametros normativos vigentes para la etapa de recepcion.
-- Criterio actual: "vigente" = sin fecha de fin (vigente_hasta IS NULL).
-- Alternativa si se cargan estandares con vigencia futura:
-- AND (vigente_hasta IS NULL OR vigente_hasta >= CURRENT_DATE)
-- -------------------------------------------------------------------------
SELECT
id_estandar,
tipo_producto,
parametro,
unidad_medida,
valor_minimo_permitido,
valor_maximo_permitido
FROM estandar_calidad
WHERE etapa = 'Recepcion'
AND vigente_hasta IS NULL;


-- -------------------------------------------------------------------------
-- 6. CONSULTA DE INSUMOS ACTIVOS DE CATEGORIA
-- Seleccionar los insumos activos que correspondan a cultivos lacteos o pulpa de fruta.
-- -------------------------------------------------------------------------
SELECT
id_insumo,
codigo,
categoria_insumo,
unidad_medida
FROM insumo
WHERE estado = 'Activo'
AND categoria_insumo IN ('Cultivo_lactico', 'Pulpa_fruta');


-- -------------------------------------------------------------------------
-- 7. CONSULTA DE REGISTROS DE ENVASADO ABIERTOS
-- Seleccionar los procesos de envasado en estado 'Abierto' con presentaciones especificas.
-- Nota: no se limita por fecha; si el volumen crece conviene añadir un rango
-- (p. ej. fecha_hora_envasado >= CURRENT_DATE - INTERVAL '30 days').
-- -------------------------------------------------------------------------
SELECT
id_envasado,
fecha_hora_envasado,
presentacion,
cantidad_envasada,
destino,
fecha_vencimiento
FROM envasado
WHERE estado = 'Abierto'
AND presentacion IN ('Bolsa_150g', 'Botella_1l');