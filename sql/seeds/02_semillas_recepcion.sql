-- ----------------------------------------------------------
-- LOTE_LECHE
-- Estados disponibles: Recibido, Disponible, Agotado, Rechazado.
-- "Aprobado" se representa como Disponible + dictamen Aprobado.
-- ----------------------------------------------------------
INSERT INTO lote_leche (
    id_lote_leche, 
    codigo, 
    fecha_recepcion, 
    volumen_inicial_litros,
    volumen_disponible_litros, 
    dictamen_microbiologico, 
    estado_lote, 
    id_proveedor_origen)
VALUES
-- Lote aprobado y parcialmente consumido
(1, 'LL-2026-07-001', '2026-07-25 06:15:00-05', 5000.00, 3200.00, 'Aprobado', 'Disponible', 1),

-- Lote aprobado, sin consumo
(2, 'LL-2026-08-002', '2026-08-04 05:40:00-05', 4000.00, 4000.00, 'Aprobado', 'Disponible', 2),

-- Lote aprobado y agotado
(3, 'LL-2026-08-003', '2026-08-12 06:05:00-05', 6000.00, 0.00, 'Aprobado', 'Agotado', 3),

-- Lote rechazado por dictamen microbiologico
(4, 'LL-2026-08-004', '2026-08-19 05:55:00-05', 3500.00, 3500.00, 'Rechazado', 'Rechazado', 4),

-- Lote aprobado y parcialmente consumido
(5, 'LL-2026-09-005', '2026-09-03 06:20:00-05', 3500.00, 1800.00, 'Aprobado', 'Disponible', 1),

-- Lote aprobado y agotado
(6, 'LL-2026-09-006', '2026-09-15 05:50:00-05', 4500.00, 0.00, 'Aprobado', 'Agotado', 2),

-- Lote aprobado y parcialmente consumido
(7, 'LL-2026-10-007', '2026-10-02 06:10:00-05', 5200.00, 2600.00, 'Aprobado', 'Disponible', 3),

-- Lote aprobado reciente
(8, 'LL-2026-10-008', '2026-10-18 05:45:00-05', 3800.00, 3800.00, 'Aprobado', 'Disponible', 5);

-- ----------------------------------------------------------
-- LOTE_INSUMO
-- Incluye un lote Vencido y un lote Agotado.
-- ----------------------------------------------------------
INSERT INTO lote_insumo (
    id_lote_insumo, 
    codigo_lote_insumo, 
    cantidad_inicial, 
    cantidad_disponible,
    fecha_recepcion, 
    fecha_caducidad, 
    estado, 
    id_insumo, 
    id_proveedor)
VALUES
-- Cultivo lactico disponible
(1, 'LI-CUL-2026-001', 50.000, 32.000, '2026-07-28', '2027-01-25', 'Disponible', 1, 6),

-- Pulpa de mora disponible
(2, 'LI-PFR-2026-002', 180.000, 125.500, '2026-08-06', '2027-02-10', 'Disponible', 2, 6),

-- Saborizante de vainilla disponible
(3, 'LI-SAB-2026-003', 40.000, 26.750, '2026-08-14', '2027-03-01', 'Disponible', 3, 6),

-- Material de empaque agotado
(4, 'LI-EMP-2026-004', 12000.000, 0.000, '2026-08-22', '2028-08-22', 'Agotado', 4, 5),

-- Cultivo lactico vencido
(5, 'LI-CUL-2026-005', 25.000, 18.000, '2026-05-10', '2026-09-05', 'Vencido', 5, 6),

-- Pulpa de lulo disponible
(6, 'LI-PFR-2026-006', 220.000, 164.250, '2026-09-09', '2027-03-12', 'Disponible', 6, 6),

-- Saborizante de fresa parcialmente consumido
(7, 'LI-SAB-2026-007', 35.000, 12.500, '2026-09-21', '2027-04-18', 'Disponible', 3, 6),

-- Empaque disponible reciente
(8, 'LI-EMP-2026-008', 18000.000, 15400.000, '2026-10-06', '2028-10-06', 'Disponible', 4, 5);