
-- -------------------------------------------------------------------------
-- 1. CONSULTA DE 3 O MÁS TABLAS 

-- -------------------------------------------------------------------------
SELECT 
    lp.id_lote_produccion,
    lp.tipo_producto,
    llc.id_lote_leche,
    s.codigo_silo,
    p.nombre AS nombre_proveedor,
    lp.fecha_produccion
FROM lote_produccion lp
JOIN lote_leche_cruda llc ON lp.id_lote_leche = llc.id_lote_leche
JOIN silo_acopio s ON llc.id_silo = s.id_silo
JOIN proveedor p ON llc.id_proveedor = p.id_proveedor;


-- -------------------------------------------------------------------------
-- 2. CONSULTA DE 3 O MÁS TABLAS 
-- -------------------------------------------------------------------------
SELECT 
    cc.id_control,
    lp.tipo_producto,
    cc.resultado,
    cc.porcentaje_azucares,
    p.nombre AS proveedor_asociado,
    cc.fecha_analisis
FROM control_calidad cc
JOIN lote_produccion lp ON cc.id_lote_produccion = lp.id_lote_produccion
JOIN lote_leche_cruda llc ON lp.id_lote_leche = llc.id_lote_leche
JOIN proveedor p ON llc.id_proveedor = p.id_proveedor;


-- -------------------------------------------------------------------------
-- 3. REUNIÓN EXTERNA CON EL PATRÓN "LOS QUE NO TIENEN" (LEFT JOIN ... IS NULL)

-- -------------------------------------------------------------------------
SELECT 
    p.id_proveedor,
    p.nombre,
    p.telefono,
    p.estado
FROM proveedor p
LEFT JOIN lote_leche_cruda llc ON p.id_proveedor = llc.id_proveedor
WHERE llc.id_lote_leche IS NULL;


-- -------------------------------------------------------------------------
-- 4. AGREGACIÓN CON GROUP BY Y HAVING
-- -------------------------------------------------------------------------
SELECT 
    s.codigo_silo,
    s.capacidad_litros,
    SUM(llc.volumen_litros) AS volumen_total_recibido,
    COUNT(llc.id_lote_leche) AS total_lotes_recibidos
FROM silo_acopio s
JOIN lote_leche_cruda llc ON s.id_silo = llc.id_silo
GROUP BY s.id_silo, s.codigo_silo, s.capacidad_litros
HAVING SUM(llc.volumen_litros) > 5000.00;


-- -------------------------------------------------------------------------
-- 5. SUBCONSULTA O CTE (WITH ... AS)

-- -------------------------------------------------------------------------
WITH PromedioVolumen AS (
    SELECT AVG(volumen_litros) AS media_volumen FROM lote_leche_cruda
)
SELECT 
    llc.id_lote_leche,
    llc.volumen_litros,
    llc.ph_registrado,
    llc.temperatura_c,
    pv.media_volumen AS promedio_general
FROM lote_leche_cruda llc
CROSS JOIN PromedioVolumen pv
WHERE llc.volumen_litros > pv.media_volumen;


-- -------------------------------------------------------------------------
-- 6. VISTA CREADA Y LUEGO CONSULTADA

-- -------------------------------------------------------------------------
-- Paso A: Creación de la vista
CREATE OR REPLACE VIEW vw_lotes_leche_aprobados AS
SELECT 
    id_lote_leche,
    id_proveedor,
    volumen_litros,
    ph_registrado,
    temperatura_c,
    fecha_recepcion
FROM lote_leche_cruda
WHERE estado_validacion = 'APROBADO';

-- Paso B: Consulta posterior sobre la vista creada
SELECT 
    id_lote_leche,
    id_proveedor,
    volumen_litros,
    ph_registrado
FROM vw_lotes_leche_aprobados
WHERE ph_registrado BETWEEN 6.50 AND 6.70;


-- -------------------------------------------------------------------------
-- 7. CONSULTA LIBRE DEL NEGOCIO
-- -------------------------------------------------------------------------
SELECT 
    lp.tipo_producto,
    COUNT(cc.id_control) AS total_analisis_exitosos,
    ROUND(AVG(cc.porcentaje_azucares), 2) AS promedio_azucares
FROM control_calidad cc
JOIN lote_produccion lp ON cc.id_lote_produccion = lp.id_lote_produccion
WHERE cc.resultado = 'APROBADO' 
  AND cc.presencia_patogenos = FALSE
GROUP BY lp.tipo_producto
ORDER BY total_analisis_exitosos DESC;