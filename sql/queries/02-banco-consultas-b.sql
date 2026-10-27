-- =========================================================================
-- PROYECTO KLARENSLAIT - FASE 2: IMPLEMENTACIÓN BBDD (POSTGRESQL 16+)
-- MÓDULO 5: Banco de Consultas — Parte B (Consultas Básicas de Filtrado)
-- Responsable (RP): Alfonso David Araujo
-- Archivo: sql/queries/02-banco-consultas-b.sql
-- Descripción: Banco de 7 consultas individuales sobre el esquema de producción,
--              envasado, descartes, uso de tanques e insumos (complementario a la Parte A).
-- =========================================================================

-- -------------------------------------------------------------------------
-- 1. CONSULTA DE FILTRADO DE EMPLEADOS POR CARGO Y ESTADO
-- Seleccionar el personal activo registrado con el cargo de operador de tanque.
-- -------------------------------------------------------------------------
SELECT 
    id_empleado,
    identificacion,
    nombre,
    cargo
FROM empleado
WHERE cargo = 'operador_tanque';


-- -------------------------------------------------------------------------
-- 2. CONSULTA DE INSUMOS DISPONIBLES EN BODEGA POR UNIDAD DE MEDIDA
-- Filtrar los insumos registrados cuya unidad de medida sea litros o kilogramos.
-- -------------------------------------------------------------------------
SELECT 
    id_insumo,
    codigo,
    nombre,
    unidad_medida
FROM insumo
WHERE unidad_medida IN ('litros', 'kg');


-- -------------------------------------------------------------------------
-- 3. CONSULTA DE ENVASADO POR CANAL DE DESTINO MAYORISTA Y VOLUMEN
-- Seleccionar los registros de envasado destinados a canal mayorista con volúmenes significativos.
-- -------------------------------------------------------------------------
SELECT 
    id_envasado,
    id_lote_produccion,
    codigo_lote_envasado,
    volumen_envasado_litros,
    destino,
    fecha_envasado
FROM envasado
WHERE destino = 'mayorista'
  AND volumen_envasado_litros >= 1000.00;


-- -------------------------------------------------------------------------
-- 4. CONSULTA DE REGISTROS DE DESCARTE Y MERMAS EN PLANTA
-- Filtrar los eventos de descarte que superen los 100 litros de pérdida.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_produccion,
    volumen_descartado_litros,
    motivo,
    fecha_hora_registro
FROM descarte
WHERE volumen_descartado_litros > 100.00;


-- -------------------------------------------------------------------------
-- 5. CONSULTA DE TANQUES EN USO ACTIVO EN PLANTA
-- Seleccionar los registros de uso de tanque que se encuentran actualmente activos.
-- -------------------------------------------------------------------------
SELECT 
    id_uso_tanque,
    id_tanque,
    id_lote_produccion,
    fecha_hora_inicio,
    estado_uso
FROM uso_tanque
WHERE estado_uso = 'activo'
  AND fecha_hora_fin IS NULL;


-- -------------------------------------------------------------------------
-- 6. CONSULTA DE PRUEBAS DE CALIDAD CON RESULTADO APROBADO EN ETAPA DE ENVASADO
-- Seleccionar las evaluaciones de laboratorio aprobadas durante la etapa de envasado.
-- -------------------------------------------------------------------------
SELECT 
    id_prueba_calidad,
    id_lote_produccion,
    tipo_prueba,
    etapa,
    valor_medido,
    resultado
FROM prueba_calidad
WHERE etapa = 'envasado'
  AND resultado = 'aprobado';


-- -------------------------------------------------------------------------
-- 7. CONSULTA DE LOTES DE INSUMO PRÓXIMOS A CADUCAR O CON BAJA DISPONIBILIDAD
-- Seleccionar los lotes de insumos cuya cantidad disponible sea menor a 50 unidades/litros.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_insumo,
    id_insumo,
    codigo_lote_insumo,
    cantidad_inicial,
    cantidad_disponible,
    fecha_caducidad
FROM lote_insumo
WHERE cantidad_disponible < 50.00
ORDER BY cantidad_disponible ASC;