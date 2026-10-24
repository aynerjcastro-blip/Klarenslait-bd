-- ----------------------------------------------------------
-- PROVEEDOR
-- El proveedor 1 no tendrá lotes de leche rechazados.
-- ----------------------------------------------------------
INSERT INTO proveedor (
    id_proveedor,
    nombre,
    ubicacion,
    telefono,
    tipo_proveedor,
    identificacion,
    estado)
VALUES
(1, 'Finca La Esperanza del Cesar', 'Vereda Los Venados, Valledupar, Cesar', '3007412589', 'Finca', '900458712-3', 'Activo'),
(2, 'Ganaderia El Corral de Ares', 'Vereda El Jardin, Valledupar, Cesar', '3012587463', 'Finca', '900369852-1', 'Activo'),
(3, 'Agropecuaria Los Chenes SAS', 'Km 12 via Valledupar-Badillo, Cesar', '6055748821', 'Empresa', '901254789-6', 'Activo'),
(4, 'Finca Villa Rosa del Sabana', 'Corregimiento La Mina, Valledupar, Cesar', '3126985471', 'Finca', '1024587963', 'Activo'),
(5, 'Distribuidora Caribe Lactea SAS', 'Calle 30A No. 12-45, Valledupar, Cesar', '6055852147', 'Empresa', '900784512-9', 'Activo'),
(6, 'Insumos del Valle del Cesar SAS', 'Carrera 19 No. 25-18, Valledupar, Cesar', '6055741236', 'Empresa', '901478523-4', 'Activo');

-- ----------------------------------------------------------
-- SILO: exactamente 6 registros
-- volumen_actual coincide con Entradas - Salidas de almacena
-- ----------------------------------------------------------
INSERT INTO silo (
    id_silo, 
    codigo, 
    tipo_silo, 
    capacidad_maxima, 
    volumen_actual, 
    estado_operativo)
VALUES
(1, 'SIL-REC-01', 'Recepcion', 20000.00, 3200.00, 'operativo'),
(2, 'SIL-REC-02', 'Recepcion', 15000.00, 4000.00, 'operativo'),
(3, 'SIL-ACO-01', 'Acopio',    25000.00,    0.00, 'operativo'),
(4, 'SIL-ACO-02', 'Acopio',    18000.00, 1800.00, 'operativo'),
(5, 'SIL-ACO-03', 'Acopio',    30000.00,    0.00, 'en_mantenimiento'),
(6, 'SIL-REC-03', 'Recepcion', 22000.00, 6400.00, 'operativo');

-- ----------------------------------------------------------
-- TANQUE: 5 registros; el tanque 5 no tendra historial de uso
-- ----------------------------------------------------------
INSERT INTO tanque (
    id_tanque, 
    codigo, 
    tipo_tanque, 
    capacidad_maxima, 
    volumen_actual, 
    estado_operativo)
VALUES
(1, 'TQ-FER-01', 'Fermentacion', 5000.00,    0.00, 'Operativo'),
(2, 'TQ-FER-02', 'Fermentacion', 6000.00,    0.00, 'Operativo'),
(3, 'TQ-FER-03', 'Fermentacion', 8000.00, 2600.00, 'Operativo'),
(4, 'TQ-MEZ-01', 'Mezcla',       7000.00, 3800.00, 'Operativo'),
(5, 'TQ-MEZ-02', 'Mezcla',       6500.00,    0.00, 'En_mantenimiento');

-- ----------------------------------------------------------
-- INSUMO
-- ----------------------------------------------------------
INSERT INTO insumo (
    id_insumo, 
    codigo, 
    categoria_insumo, 
    unidad_medida, 
    estado)
VALUES
(1, 'INS-CUL-001', 'Cultivo_lactico',  'Kg',     'Activo'),
(2, 'INS-PFR-001', 'Pulpa_fruta',      'Kg',     'Activo'),
(3, 'INS-SAB-001', 'Saborizante',      'L',      'Activo'),
(4, 'INS-EMP-001', 'Material_empaque', 'Unidad', 'Activo'),
(5, 'INS-CUL-002', 'Cultivo_lactico',  'G',      'Activo'),
(6, 'INS-PFR-002', 'Pulpa_fruta',      'Kg',     'Activo');

-- ----------------------------------------------------------
-- EMPLEADO
-- ----------------------------------------------------------
INSERT INTO empleado (
    id_empleado, 
    nombre, 
    cargo, 
    identificacion, 
    estado_vinculacion)
VALUES
(1,  'Yuliana Ariza Contreras',   'Operador_tanque', '1023654789', 'Activo'),
(2,  'Wilmer David Ospino Mestra', 'Operador_tanque', '1025874126', 'Activo'),
(3,  'Keiner Jose Mejia Arzuza',  'Operador_tanque', '1026985412', 'Activo'),
(4,  'Luisa Fernanda Paternina',  'Operador_tanque', '1032587419', 'Activo'),
(5,  'Andres Felipe Guerra Daza', 'Tecnico_calidad', '1024785963', 'Activo'),
(6,  'Maria Camila Ochoa Rincón', 'Tecnico_calidad', '1036985214', 'Activo'),
(7,  'Jhon Steven Campo Murgas',  'Tecnico_calidad', '1028547963', 'Activo'),
(8,  'Sara Lucia De la Hoz Ariza','Tecnico_calidad', '1032145987', 'Activo'),
(9,  'Ricardo Enrique Muvdi Lara','Supervisor',      '1012587469', 'Activo'),
(10, 'Diana Marcela Romero Ustariz','Supervisor',   '1014785236', 'Activo');

-- ----------------------------------------------------------
-- ESTANDAR_CALIDAD
-- Solo un registro vigente por producto/parametro/etapa.
-- ----------------------------------------------------------
INSERT INTO estandar_calidad (
    id_estandar, 
    tipo_producto, 
    parametro, 
    etapa, 
    unidad_medida,
    valor_minimo_permitido, 
    valor_maximo_permitido, 
    vigente_desde, 
    vigente_hasta)
VALUES
-- Historial cerrado: temperatura de leche cruda en recepcion
(1, 'Leche_cruda', 'Temperatura', 'recepcion', 'Grados_celsius', 2.0000, 7.0000, '2025-01-01', '2026-06-30'),

-- Estandares vigentes de leche cruda
(2, 'Leche_cruda', 'Temperatura', 'recepcion', 'Grados_celsius', 2.0000, 6.0000, '2026-07-01', NULL),
(3, 'Leche_cruda', 'Acidez_dornic', 'recepcion', 'Grados_dornic', 14.0000, 18.0000, '2026-07-01', NULL),
(4, 'Leche_cruda', 'Microorganismos', 'recepcion', 'Ufc_ml', 0.0000, 100000.0000, '2026-07-01', NULL),

-- Historial cerrado de yogurt en fermentacion
(5, 'Yogurt', 'Ph', 'Fermentacion', 'Adimensional', 4.4000, 4.8000, '2025-06-01', '2026-05-31'),

-- Estandares vigentes de yogurt
(6, 'Yogurt', 'Ph', 'Fermentacion', 'Adimensional', 4.3000, 4.7000, '2026-06-01', NULL),
(7, 'Yogurt', 'Temperatura', 'Fermentacion', 'Grados_celsius', 38.0000, 45.0000, '2026-06-01', NULL),
(8, 'Yogurt', 'Acidez_dornic', 'Mezcla', 'Grados_dornic', 75.0000, 95.0000, '2026-06-01', NULL),
(9, 'Yogurt', 'Viscosidad', 'Mezcla', 'Cp', 1200.0000, 2500.0000, '2026-06-01', NULL),
(10, 'Yogurt', 'Temperatura', 'Envasado', 'Grados_celsius', 2.0000, 8.0000, '2026-06-01', NULL),
(11, 'Yogurt', 'Microorganismos', 'Envasado', 'Ufc_ml', 0.0000, 10000.0000, '2026-06-01', NULL);