-- =========================================================================
-- MÓDULO 4: BANCO DE CONSULTAS — PARTE A
-- Proyecto: Sistema de Gestión y Calidad - Lácteos Klarens (Klarenslait-bd)
-- Responsable Principal: Sebastián Ramos
-- Revisores: Juan Guerra y Alfonso Araujo
-- Adaptado estrictamente a los esquemas y restricciones reales de las tablas.
-- =========================================================================

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
-- Nota: en la tabla silo el CHECK usa minúsculas ('operativo'), por eso el literal.
-- -------------------------------------------------------------------------
SELECT 
    id_silo,
    codigo,
    capacidad_maxima,
    volumen_actual,
    estado_operativo
FROM silo
WHERE tipo_silo = 'Acopio' 
  AND estado_operativo = 'operativo';


-- -------------------------------------------------------------------------
-- 3. CONSULTA DE LOTES DE LECHE PENDIENTES DE DICTAMEN
-- Identificar los lotes de leche cruda que tienen dictamen microbiológico pendiente.
-- Nota: el filtro por estado_lote = 'Recibido' refuerza la intención (un lote
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
-- 4. CONSULTA DE LOTES DE PRODUCCIÓN DE YOGURT EN PROCESO
-- Filtrar los lotes de producción de la línea 'Yogurt' que están 'En_proceso'.
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
-- 5. CONSULTA DE ESTÁNDARES DE CALIDAD EN RECEPCIÓN
-- Seleccionar los parámetros normativos vigentes para la etapa de recepción.
-- Criterio actual: "vigente" = sin fecha de fin (vigente_hasta IS NULL).
-- Alternativa si se cargan estándares con vigencia futura:
--   AND (vigente_hasta IS NULL OR vigente_hasta >= CURRENT_DATE)
-- -------------------------------------------------------------------------
SELECT 
    id_estandar,
    tipo_producto,
    parametro,
    unidad_medida,
    valor_minimo_permitido,
    valor_maximo_permitido
FROM estandar_calidad
WHERE etapa = 'recepcion' 
  AND vigente_hasta IS NULL;


-- -------------------------------------------------------------------------
-- 6. CONSULTA DE INSUMOS ACTIVOS DE CATEGORÍA
-- Seleccionar los insumos activos que correspondan a cultivos lácteos o pulpa de fruta.
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
-- Seleccionar los procesos de envasado en estado 'Abierto' con presentaciones específicas.
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