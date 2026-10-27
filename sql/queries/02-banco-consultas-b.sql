-- -------------------------------------------------------------------------
-- 1. CONSULTA DE FILTRADO DE EMPLEADOS POR CARGO Y ESTADO
-- Seleccionar el personal activo registrado con el cargo de operador de tanque.
-- -------------------------------------------------------------------------
Select 
    id_empleado,
    identificacion,
    nombre,
    cargo
from empleado
Where cargo = 'Operador_tanque';


-- -------------------------------------------------------------------------
-- 2. CONSULTA DE INSUMOS DISPONIBLES EN BODEGA POR UNIDAD DE MEDIDA
-- Filtrar los insumos registrados cuya unidad de medida sea litros o kilogramos.
-- -------------------------------------------------------------------------
Select 
    id_insumo,
    codigo,
    nombre,
    unidad_medida
from insumo
Where unidad_medida in ('Litros', 'Kg');


-- -------------------------------------------------------------------------
-- 3. CONSULTA DE ENVASADO POR CANAL DE DESTINO MAYORISTA Y VOLUMEN
-- Seleccionar los registros de envasado destinados a canal mayorista con volúmenes significativos.
-- -------------------------------------------------------------------------
Select 
    id_envasado,
    id_lote_produccion,
    codigo_lote_envasado,
    volumen_envasado_litros,
    destino,
    fecha_envasado
from envasado
Where destino = 'Mayorista'
  and volumen_envasado_litros >= 1000.00;


-- -------------------------------------------------------------------------
-- 4. CONSULTA DE REGISTROS DE DESCARTE Y MERMAS EN PLANTA
-- Filtrar los eventos de descarte que superen los 100 litros de pérdida.
-- -------------------------------------------------------------------------
Select 
    id_lote_produccion,
    volumen_descartado_litros,
    motivo,
    fecha_hora_registro
from descarte
Where volumen_descartado_litros > 100.00;


-- -------------------------------------------------------------------------
-- 5. CONSULTA DE TANQUES EN USO ACTIVO EN PLANTA
-- Seleccionar los registros de uso de tanque que se encuentran actualmente activos.
-- -------------------------------------------------------------------------
Select 
    id_uso_tanque,
    id_tanque,
    id_lote_produccion,
    fecha_hora_inicio,
    estado_uso
from uso_tanque
Where estado_uso = 'Activo'
  and fecha_hora_fin is null;


-- -------------------------------------------------------------------------
-- 6. CONSULTA DE PRUEBAS DE CALIDAD CON RESULTADO APROBADO EN ETAPA DE ENVASADO
-- Seleccionar las evaluaciones de laboratorio aprobadas durante la etapa de envasado.
-- -------------------------------------------------------------------------
Select 
    id_prueba_calidad,
    id_lote_produccion,
    tipo_prueba,
    etapa,
    valor_medido,
    resultado
from prueba_calidad
Where etapa = 'Envasado'
  and resultado = 'Aprobado';


-- -------------------------------------------------------------------------
-- 7. CONSULTA DE LOTES DE INSUMO PRÓXIMOS A CADUCAR O CON BAJA DISPONIBILIDAD
-- Seleccionar los lotes de insumos cuya cantidad disponible sea menor a 50 unidades/litros.
-- -------------------------------------------------------------------------
Select 
    id_lote_insumo,
    id_insumo,
    codigo_lote_insumo,
    cantidad_inicial,
    cantidad_disponible,
    fecha_caducidad
from lote_insumo
Where cantidad_disponible < 50.00
order by cantidad_disponible asc;