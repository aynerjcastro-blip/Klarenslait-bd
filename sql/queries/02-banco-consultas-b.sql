-- -------------------------------------------------------------------------
-- 1. FILTRADO BÁSICO Y OPERADORES LÓGICOS CON RANGOS Y PATRONES
-- Tabla: lote_leche
-- Pregunta de negocio: Buscar lotes de leche cruda recibidos con volúmenes
-- significativos (entre 1,000 y 5,000 litros) que provengan de códigos específicos.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_leche,
    codigo_lote,
    volumen_inicial_litros,
    volumen_disponible_litros,
    fecha_recepcion,
    dictamen_microbiologico
FROM lote_leche
WHERE volumen_inicial_litros BETWEEN 1000.00 AND 5000.00
  AND dictamen_microbiologico IN ('aprobado', 'pendiente')
ORDER BY fecha_recepcion DESC;


-- -------------------------------------------------------------------------
-- 2. AGREGACIÓN CON GROUP BY Y HAVING
-- Tabla: lote_produccion
-- Pregunta de negocio: Calcular el volumen total producido y el promedio por tipo
-- de producto, mostrando únicamente aquellas líneas que superen los 2,000 litros acumulados.
-- -------------------------------------------------------------------------
SELECT 
    tipo_producto,
    COUNT(*) AS total_lotes_procesados,
    SUM(volumen_producido_litros) AS volumen_total_producido,
    ROUND(AVG(volumen_producido_litros), 2) AS volumen_promedio_lote,
    MAX(volumen_producido_litros) AS volumen_maximo_lote
FROM lote_produccion
GROUP BY tipo_producto
HAVING SUM(volumen_producido_litros) > 2000.00
ORDER BY volumen_total_producido DESC;


-- -------------------------------------------------------------------------
-- 3. FUNCIONES DE FECHA Y HORA (EXTRACT Y AGRUPAMIENTO TEMPORAL)
-- Tabla: prueba_calidad
-- Pregunta de negocio: Consolidar el volumen de evaluaciones de calidad realizadas
-- agrupadas por año y mes para analizar la carga operativa del laboratorio.
-- -------------------------------------------------------------------------
SELECT 
    EXTRACT(YEAR FROM fecha_hora_evaluacion) AS anio,
    EXTRACT(MONTH FROM fecha_hora_evaluacion) AS mes,
    COUNT(*) AS total_pruebas_evaluadas,
    COUNT(CASE WHEN resultado = 'aprobado' THEN 1 END) AS total_aprobadas,
    COUNT(CASE WHEN resultado IN ('reproceso', 'rechazado') THEN 1 END) AS total_no_conformes
FROM prueba_calidad
GROUP BY EXTRACT(YEAR FROM fecha_hora_evaluacion), EXTRACT(MONTH FROM fecha_hora_evaluacion)
ORDER BY anio DESC, mes DESC;


-- -------------------------------------------------------------------------
-- 4. LÓGICA CONDICIONAL DENTRO DE LA CONSULTA (EXPRESIÓN CASE)
-- Tabla: envasado
-- Pregunta de negocio: Clasificar cada registro de envasado según el volumen empacado
-- (Grande, Mediano, Pequeño) y segmentar el canal de destino.
-- -------------------------------------------------------------------------
SELECT 
    codigo_lote_envasado,
    volumen_envasado_litros,
    destino,
    fecha_envasado,
    CASE 
        WHEN volumen_envasado_litros >= 3000.00 THEN 'Lote de Gran Volumen'
        WHEN volumen_envasado_litros BETWEEN 1000.00 AND 2999.99 THEN 'Lote Mediano'
        ELSE 'Lote Menor / Pequeño'
    END AS Categoria_Volumen,
    CASE 
        WHEN destino = 'mayorista' THEN 'Canal Distribución Masiva'
        WHEN destino = 'minorista' THEN 'Canal Detallista / Tiendas'
        ELSE 'Venta Directa en Planta'
    END AS Tipo_Canal
FROM envasado
ORDER BY volumen_envasado_litros DESC;


-- -------------------------------------------------------------------------
-- 5. FUNCIONES DE VENTANA: RANKING (ROW_NUMBER Y DENSE_RANK)
-- Tabla: lote_insumo
-- Pregunta de negocio: Generar un ranking de los lotes de insumos más costosos o
-- de mayor volumen inicial dentro de cada categoría de insumo, sin usar JOIN.
-- -------------------------------------------------------------------------
SELECT 
    id_insumo,
    codigo_lote_insumo,
    cantidad_inicial,
    cantidad_disponible,
    fecha_recepcion,
    ROW_NUMBER() OVER (PARTITION BY id_insumo ORDER BY cantidad_inicial DESC) AS ranking_por_insumo,
    DENSE_RANK() OVER (ORDER BY cantidad_inicial DESC) AS ranking_general_planta
FROM lote_insumo
WHERE cantidad_disponible > 0
ORDER BY id_insumo, ranking_por_insumo;


-- -------------------------------------------------------------------------
-- 6. FUNCIONES DE VENTANA: TOTALES ACUMULADOS Y PAGINACIÓN
-- Tabla: descarte
-- Pregunta de negocio: Obtener los registros de descarte ordenados por fecha,
-- calculando el acumulado progresivo de volumen perdido en planta y paginando resultados.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_produccion,
    volumen_descartado_litros,
    motivo,
    fecha_hora_registro,
    SUM(volumen_descartado_litros) OVER (ORDER BY fecha_hora_registro ASC) AS acumulado_descarte_litros
FROM descarte
ORDER BY fecha_hora_registro ASC
LIMIT 10 OFFSET 0;


-- -------------------------------------------------------------------------
-- 7. CONSULTA ANALÍTICA LIBRE (PIVOTEO CONDICIONAL CON CASE Y AGREGACIÓN)
-- Tabla: uso_tanque
-- Pregunta de negocio: Analizar el estado operativo de los tanques midiendo el total
-- de usos activos, finalizados e interrumpidos por cada tanque de la planta.
-- -------------------------------------------------------------------------
SELECT 
    id_tanque,
    COUNT(*) AS total_usos_registrados,
    COUNT(CASE WHEN estado_uso = 'activo' THEN 1 END) AS usos_activos_actuales,
    COUNT(CASE WHEN estado_uso = 'finalizado' THEN 1 END) AS usos_completados,
    COUNT(CASE WHEN fecha_hora_fin IS NULL THEN 1 END) AS usos_sin_cierre_registrado
FROM uso_tanque
GROUP BY id_tanque
ORDER BY total_usos_registrados DESC;