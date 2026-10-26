
-- =========================================================================
-- PROYECTO KLARENSLAIT - FASE 2: IMPLEMENTACIÓN BBDD (POSTGRESQL 16+)
-- MÓDULO 5: Banco de Consultas — Parte B + Índice 2
-- Responsable (RP): Alfonso David Araujo
-- Archivo: sql/queries/02-banco-consultas-b.sql
-- Descripción: Script con 7 consultas de negocio de los Requisitos 8 al 15 (docs/02),
--              cumpliendo la variedad requerida para la entrega de la Fase 2.
-- =========================================================================

-- -------------------------------------------------------------------------
-- 1. CONSULTA DE 3 O MÁS TABLAS (Requisito 8: Trazabilidad completa de envasado)
-- Pregunta de negocio: Trazar desde cada lote envasado hacia atrás el lote de producción,
-- el tanque utilizado y la leche cruda de origen con su proveedor.
-- -------------------------------------------------------------------------
SELECT 
    env.id_envasado,
    env.codigo_lote_envasado,
    lp.codigo_lote AS codigo_lote_produccion,
    lp.tipo_producto,
    t.codigo_tanque,
    ll.codigo_lote AS codigo_lote_leche,
    p.nombre_razon_social AS proveedor_origen,
    env.fecha_envasado,
    env.volumen_envasado_litros,
    env.destino
FROM envasado env
JOIN lote_produccion lp ON env.id_lote_produccion = lp.id_lote_produccion
JOIN uso_tanque ut ON lp.id_lote_produccion = ut.id_lote_produccion
JOIN tanque t ON ut.id_tanque = t.id_tanque
JOIN almacena alm ON ut.id_tanque = alm.id_tanque
JOIN lote_leche ll ON alm.id_lote_leche = ll.id_lote_leche
JOIN proveedor p ON ll.id_proveedor = p.id_proveedor
ORDER BY env.fecha_envasado DESC;


-- -------------------------------------------------------------------------
-- 2. CONSULTA DE 3 O MÁS TABLAS (Requisito 9: Consumo de insumos por lote)
-- Pregunta de negocio: Obtener el detalle de insumos consumidos por cada lote de producción,
-- indicando la cantidad utilizada, el lote de insumo de origen y el proveedor.
-- -------------------------------------------------------------------------
SELECT 
    lp.codigo_lote AS codigo_lote_produccion,
    lp.tipo_producto,
    i.nombre AS nombre_insumo,
    li.codigo_lote_insumo,
    ci.cantidad_consumida,
    i.unidad_medida,
    prov.nombre_razon_social AS proveedor_insumo,
    ci.fecha_hora_registro
FROM consumo_insumo ci
JOIN lote_produccion lp ON ci.id_lote_produccion = lp.id_lote_produccion
JOIN lote_insumo li ON ci.id_lote_insumo = li.id_lote_insumo
JOIN insumo i ON li.id_insumo = i.id_insumo
JOIN proveedor prov ON li.id_proveedor = prov.id_proveedor
ORDER BY lp.codigo_lote, ci.fecha_hora_registro ASC;


-- -------------------------------------------------------------------------
-- 3. REUNIÓN EXTERNA CON EL PATRÓN "LOS QUE NO TIENEN" (LEFT JOIN ... IS NULL)
--    (Requisito 10: Lotes de producción aprobados sin registro de envasado ni descarte)
-- Pregunta de negocio: Identificar los lotes de producción aprobados que aún no han sido
-- envasados ni registrados como descartados (pendientes de salida/empaque).
-- -------------------------------------------------------------------------
SELECT 
    lp.id_lote_produccion,
    lp.codigo_lote,
    lp.tipo_producto,
    lp.volumen_producido_litros,
    lp.fecha_hora_inicio,
    lp.estado_lote
FROM lote_produccion lp
LEFT JOIN envasado env ON lp.id_lote_produccion = env.id_lote_produccion
LEFT JOIN descarte d ON lp.id_lote_produccion = d.id_lote_produccion
WHERE lp.estado_lote = 'aprobado'
  AND env.id_envasado IS NULL
  AND d.id_lote_produccion IS NULL;


-- -------------------------------------------------------------------------
-- 4. AGREGACIÓN CON GROUP BY Y HAVING
--    (Requisito 11: Volumen total producido y acumulado de descarte por tipo de producto)
-- Pregunta de negocio: Obtener el total de litros producidos y descartados por tipo
-- de producto, filtrando aquellos productos cuyo volumen total supere los 1,000 litros.
-- -------------------------------------------------------------------------
SELECT 
    lp.tipo_producto,
    COUNT(DISTINCT lp.id_lote_produccion) AS total_lotes,
    SUM(lp.volumen_producido_litros) AS volumen_total_producido,
    COALESCE(SUM(d.volumen_descartado_litros), 0) AS volumen_total_descartado,
    ROUND(
        (COALESCE(SUM(d.volumen_descartado_litros), 0) / SUM(lp.volumen_producido_litros)) * 100, 
        2
    ) AS porcentaje_descarte
FROM lote_produccion lp
LEFT JOIN descarte d ON lp.id_lote_produccion = d.id_lote_produccion
GROUP BY lp.tipo_producto
HAVING SUM(lp.volumen_producido_litros) > 1000.00
ORDER BY volumen_total_producido DESC;


-- -------------------------------------------------------------------------
-- 5. SUBCONSULTA O CTE (WITH ... AS)
--    (Requisito 12: Evaluaciones de calidad fuera de rango respecto a estándar vigente)
-- Pregunta de negocio: Detectar todas las pruebas de calidad cuyo valor medido
-- esté fuera del rango (mínimo o máximo) definido en el estándar de calidad vigente.
-- -------------------------------------------------------------------------
WITH EstandaresVigentes AS (
    SELECT 
        id_estandar_calidad,
        tipo_producto,
        parametro,
        etapa,
        valor_minimo_permitido,
        valor_maximo_permitido,
        unidad_medida
    FROM estandar_calidad
    WHERE vigente_hasta IS NULL
)
SELECT 
    pc.id_prueba_calidad,
    pc.tipo_prueba,
    pc.etapa,
    pc.valor_medido,
    ev.valor_minimo_permitido,
    ev.valor_maximo_permitido,
    ev.unidad_medida,
    pc.resultado,
    pc.fecha_hora_evaluacion,
    COALESCE(e.nombres || ' ' || e.apellidos, 'Automatizado / Sensor') AS evaluador
FROM prueba_calidad pc
JOIN EstandaresVigentes ev 
  ON pc.id_estandar_calidad = ev.id_estandar_calidad
LEFT JOIN empleado e ON pc.id_empleado = e.id_empleado
WHERE pc.valor_medido < ev.valor_minimo_permitido 
   OR pc.valor_medido > ev.valor_maximo_permitido
ORDER BY pc.fecha_hora_evaluacion DESC;


-- -------------------------------------------------------------------------
-- 6. VISTA CREADA Y LUEGO CONSULTADA
--    (Requisito 13: Rendimiento y eficiencia del proceso de envasado por lote)
-- -------------------------------------------------------------------------
-- Paso A: Creación de la vista de eficiencia de envasado
CREATE OR REPLACE VIEW vw_resumen_eficiencia_envasado AS
SELECT 
    lp.id_lote_produccion,
    lp.codigo_lote AS codigo_lote_produccion,
    lp.tipo_producto,
    lp.volumen_producido_litros,
    COALESCE(SUM(env.volumen_envasado_litros), 0) AS volumen_total_envasado,
    COALESCE(d.volumen_descartado_litros, 0) AS volumen_descartado,
    (lp.volumen_producido_litros - COALESCE(SUM(env.volumen_envasado_litros), 0) - COALESCE(d.volumen_descartado_litros, 0)) AS merma_litros,
    ROUND(
        (COALESCE(SUM(env.volumen_envasado_litros), 0) / NULLIF(lp.volumen_producido_litros, 0)) * 100,
        2
    ) AS porcentaje_eficiencia
FROM lote_produccion lp
LEFT JOIN envasado env ON lp.id_lote_produccion = env.id_lote_produccion
LEFT JOIN descarte d ON lp.id_lote_produccion = d.id_lote_produccion
GROUP BY lp.id_lote_produccion, lp.codigo_lote, lp.tipo_producto, lp.volumen_producido_litros, d.volumen_descartado_litros;

-- Paso B: Consulta sobre la vista filtrando mermas significativas o eficiencias bajo 95%
SELECT 
    codigo_lote_produccion,
    tipo_producto,
    volumen_producido_litros,
    volumen_total_envasado,
    merma_litros,
    porcentaje_eficiencia
FROM vw_resumen_eficiencia_envasado
WHERE porcentaje_eficiencia < 95.00 OR merma_litros > 50.00
ORDER BY porcentaje_eficiencia ASC;


-- -------------------------------------------------------------------------
-- 7. CONSULTA LIBRE DEL NEGOCIO
--    (Requisito 14/15: Historial operativo de tanques y asignación de personal)
-- Pregunta de negocio: Consultar el historial de uso de tanques por lote de producción,
-- detallando duraciones, empleados asignados en el turno y estado del tanque.
-- -------------------------------------------------------------------------
SELECT 
    t.codigo_tanque,
    ut.id_lote_produccion,
    lp.codigo_lote AS codigo_lote_produccion,
    ut.fecha_hora_inicio,
    ut.fecha_hora_fin,
    ROUND(EXTRACT(EPOCH FROM (COALESCE(ut.fecha_hora_fin, CURRENT_TIMESTAMP) - ut.fecha_hora_inicio)) / 3600.0, 2) AS horas_uso,
    ut.estado_uso,
    e.nombres || ' ' || e.apellidos AS operador_asignado,
    a.rol_desempenado
FROM uso_tanque ut
JOIN tanque t ON ut.id_tanque = t.id_tanque
JOIN lote_produccion lp ON ut.id_lote_produccion = lp.id_lote_produccion
LEFT JOIN asigna a ON ut.id_tanque = a.id_tanque 
                  AND ut.id_lote_produccion = a.id_lote_produccion
LEFT JOIN empleado e ON a.id_empleado = e.id_empleado
ORDER BY ut.fecha_hora_inicio DESC;