-- -------------------------------------------------------------------------
-- 1. CONSULTA DE EMPLEADOS ACTIVOS POR CARGO Y ROL
-- Seleccionar el personal activo que desempeña el cargo de operario o técnico.
-- -------------------------------------------------------------------------
SELECT 
    id_empleado,
    identificacion,
    nombre,
    cargo,
    estado
FROM empleado
WHERE estado = 'Activo'
  AND cargo IN ('Operador_tanque', 'Tecnico_calidad');


-- -------------------------------------------------------------------------
-- 2. CONSULTA DE TANQUES EN ESTADO DE LIMPIEZA O MANTENIMIENTO
-- Seleccionar los tanques que no están disponibles por lavado o revisión.
-- -------------------------------------------------------------------------
SELECT 
    id_tanque,
    codigo,
    capacidad_maxima_litros,
    volumen_actual_litros,
    estado_operativo
FROM tanque
WHERE estado_operativo IN ('Lavado', 'Mantenimiento');


-- -------------------------------------------------------------------------
-- 3. CONSULTA DE LOTES DE INSUMO PRÓXIMOS A CADUCAR
-- Seleccionar los lotes de insumos activos con caducidad cercana o sin stock.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_insumo,
    codigo_lote_insumo,
    id_insumo,
    cantidad_inicial,
    cantidad_disponible,
    fecha_caducidad
FROM lote_insumo
WHERE cantidad_disponible < 50.00
  AND fecha_caducidad >= CURRENT_DATE;


-- -------------------------------------------------------------------------
-- 4. CONSULTA DE REGISTROS DE DESCARTE Y MERMAS SIGNIFICATIVAS
-- Filtrar las mermas de producción donde la pérdida superó los 100 litros.
-- -------------------------------------------------------------------------
SELECT 
    id_lote_produccion,
    volumen_descartado_litros,
    motivo_descarte,
    origen_descarte,
    fecha_hora_registro
FROM descarte
WHERE volumen_descartado_litros > 100.00;


-- -------------------------------------------------------------------------
-- 5. CONSULTA DE REGISTROS DE USO DE TANQUE ACTIVOS EN PLANTA
-- Seleccionar los usos de tanque que se encuentran en estado 'Activo'.
-- -------------------------------------------------------------------------
SELECT 
    id_uso_tanque,
    id_tanque,
    id_lote_produccion,
    fecha_hora_inicio,
    estado_uso
FROM uso_tanque
WHERE estado_uso = 'Activo'
  AND fecha_hora_fin IS NULL;


-- -------------------------------------------------------------------------
-- 6. CONSULTA DE PRUEBAS DE CALIDAD APROBADAS EN ETAPA DE ENVASADO
-- Seleccionar evaluaciones aprobadas de tipo fisicoquímico o microbiológico.
-- -------------------------------------------------------------------------
SELECT 
    id_prueba_calidad,
    id_lote_produccion,
    tipo_prueba,
    etapa,
    valor_medido,
    resultado
FROM prueba_calidad
WHERE etapa = 'Envasado'
  AND resultado = 'Aprobado';


-- -------------------------------------------------------------------------
-- 7. CONSULTA DE DESTINOS DE ENVASADO CANAL MAYORISTA O MINORISTA
-- Filtrar las entregas de producto terminado canalizadas a clientes masivos.
-- -------------------------------------------------------------------------
SELECT 
    id_envasado,
    id_lote_produccion,
    presentacion,
    cantidad_envasada,
    destino,
    fecha_vencimiento
FROM envasado
WHERE destino IN ('Mayorista', 'Minorista')
ORDER BY fecha_vencimiento ASC;