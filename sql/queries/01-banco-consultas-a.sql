
-- -------------------------------------------------------------------------
-- 1. CONSULTA DE SELECCIÓN Y PROYECCIÓN BÁSICA EN PROVEEDORES
-- Filtrar los proveedores que se encuentran con estado activo en el sistema.
-- -------------------------------------------------------------------------
SELECT 
    id_proveedor,
    nombre,
    contacto,
    telefono
FROM proveedor
WHERE estado = 'ACTIVO';


-- -------------------------------------------------------------------------
-- 2. CONSULTA DE FILTRADO POR RANGO NUMÉRICO EN SILOS DE ACOPIO
-- Seleccionar los tanques de acopio cuya capacidad total supere los 15,000 litros.
-- -------------------------------------------------------------------------
SELECT 
    id_silo,
    codigo_silo,
    capacidad_litros,
    estado
FROM silo_acopio
WHERE capacidad_litros > 15000.00;


-- -------------------------------------------------------------------------
-- 3. CONSULTA DE SELECCIÓN CON MÚLTIPLES CONDICIONES LÓGICAS
-- Identificar los lotes de leche cruda que cumplen con parámetros óptimos 
-- de volumen y temperatura de refrigeración.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_leche,
    id_proveedor,
    volumen_litros,
    temperatura_c,
    estado_validacion
FROM lote_leche_cruda
WHERE volumen_litros >= 3000.00 
  AND temperatura_c <= 4.50;


-- -------------------------------------------------------------------------
-- 4. CONSULTA DE CLASIFICACIÓN POR TIPO DE PRODUCTO EN PRODUCCIÓN
-- Filtrar los registros de lotes correspondientes estrictamente a la línea de yogurt.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_produccion,
    tipo_producto,
    fecha_produccion,
    volumen_producido_litros
FROM lote_produccion
WHERE tipo_producto = 'YOGURT';


-- -------------------------------------------------------------------------
-- 5. CONSULTA DE ANÁLISIS DE CALIDAD CON RECHAZOS Y PATÓGENOS
-- Seleccionar los controles de calidad que resultaron rechazados por presencia de patógenos.
-- -------------------------------------------------------------------------
SELECT 
    id_control,
    id_lote_produccion,
    resultado,
    presencia_patogenos,
    fecha_analisis
FROM control_calidad
WHERE resultado = 'RECHAZADO' 
  AND presencia_patogenos = TRUE;


-- -------------------------------------------------------------------------
-- 6. CONSULTA DE FILTRADO DE MATERIA PRIMA POR ESTADO DE VALIDACIÓN
-- Seleccionar los lotes de leche cruda que han sido aprobados en la recepción.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_leche,
    id_proveedor,
    volumen_litros,
    ph_registrado
FROM lote_leche_cruda
WHERE estado_validacion = 'APROBADO';


-- -------------------------------------------------------------------------
-- 7. CONSULTA DE FILTRADO POR UMBRAL DE ACIDEZ (pH) EN MATERIA PRIMA
-- Seleccionar lotes de leche cruda cuyos niveles de pH se encuentren fuera 
-- del rango normativo estándar (menores a 6.40 o mayores a 6.80).
-- -------------------------------------------------------------------------
SELECT 
    id_lote_leche,
    id_proveedor,
    ph_registrado,
    fecha_recepcion
FROM lote_leche_cruda
WHERE ph_registrado < 6.40 
   OR ph_registrado > 6.80;