
-- ----------------------------------------------------------
-- LOTE_PRODUCCION
-- El lote 1 queda Aprobado y sin registros en envasado.
-- ----------------------------------------------------------
INSERT INTO lote_produccion (
    id_lote_produccion, 
    codigo, 
    tipo_producto, 
    volumen_planificado_litros,
    volumen_producido_litros, 
    fecha_hora_inicio, 
    fecha_hora_fin, 
    estado, 
    id_supervisor)
VALUES
-- Yogurt aprobado sin envasar: 
(1, 'LP-2026-08-001', 'Yogurt', 1500.00, 1420.00, '2026-08-05 07:00:00-05', '2026-08-05 16:30:00-05', 'Aprobado', 9),

-- Yogurt envasado
(2, 'LP-2026-08-002', 'Yogurt', 1800.00, 1725.00, '2026-08-14 07:15:00-05', '2026-08-14 17:00:00-05', 'Envasado', 10),

-- Yogurt aprobado para envasado 
(3, 'LP-2026-09-003', 'Yogurt', 1600.00, 1540.00, '2026-09-08 07:00:00-05', '2026-09-08 16:45:00-05', 'Aprobado', 9),

-- Yogurt rechazado y descartado
(4, 'LP-2026-09-004', 'Yogurt', 1200.00, 1150.00, '2026-09-18 07:30:00-05', '2026-09-18 18:00:00-05', 'Rechazado', 10),

-- Yogurt envasado
(5, 'LP-2026-09-005', 'Yogurt', 1700.00, 1650.00, '2026-09-25 07:00:00-05', '2026-09-25 16:40:00-05', 'Envasado', 9),

-- Yogurt envasado
(6, 'LP-2026-10-006', 'Yogurt', 2000.00, 1930.00, '2026-10-06 07:10:00-05', '2026-10-06 17:20:00-05', 'Envasado', 10),

-- Yogurt envasado
(7, 'LP-2026-10-007', 'Yogurt', 2500.00, 2420.00, '2026-10-14 07:00:00-05', '2026-10-14 17:30:00-05', 'Envasado', 9),

-- Yogurt en proceso
(8, 'LP-2026-10-008', 'Yogurt', 3800.00, NULL, '2026-10-23 07:00:00-05', NULL, 'En_proceso', 10);

-- ----------------------------------------------------------
-- PRUEBA_CALIDAD
-- Incluye valores fuera de rango con Rechazado y Reproceso.
-- ----------------------------------------------------------
INSERT INTO prueba_calidad (
    id_prueba_calidad, 
    fecha_hora, 
    tipo_prueba, 
    valor_obtenido, 
    resultado,
    origen_registro, 
    id_lote_produccion, 
    id_lote_leche, 
    id_responsable_registro, 
    id_estandar)
VALUES
-- Leche cruda: temperatura aprobada
(1, '2026-07-25 06:30:00-05', 'Fisicoquimica', 4.8000, 'Aprobado', 'Manual', NULL, 1, 5, 2),

-- Leche cruda: acidez aprobada
(2, '2026-08-04 06:00:00-05', 'Fisicoquimica', 16.2000, 'Aprobado', 'Manual', NULL, 2, 6, 3),

-- Leche cruda: microbiologia rechazada, coherente con lote 4
(3, '2026-08-19 06:20:00-05', 'Microbiologica', 185000.0000, 'Rechazado', 'Manual', NULL, 4, 7, 4),

-- Leche cruda: acidez fuera de rango, reproceso
(4, '2026-09-03 06:35:00-05', 'Fisicoquimica', 21.4000, 'Reproceso', 'Manual', NULL, 5, 8, 3),

-- Yogurt: pH en fermentacion dentro de rango
(5, '2026-08-05 12:00:00-05', 'Ph_linea', 4.5200, 'Aprobado', 'Sensor', 1, NULL, NULL, 6),

-- Yogurt: temperatura de fermentacion fuera de rango
(6, '2026-08-14 11:30:00-05', 'Temperatura_linea', 48.6000, 'Reproceso', 'Sensor', 2, NULL, NULL, 7),

-- Yogurt: viscosidad dentro de rango
(7, '2026-09-08 13:15:00-05', 'Fisicoquimica', 1850.0000, 'Aprobado', 'Manual', 3, NULL, 5, 9),

-- Yogurt: acidez fuera de rango, rechazada
(8, '2026-09-18 14:00:00-05', 'Fisicoquimica', 108.5000, 'Rechazado', 'Manual', 4, NULL, 6, 8),

-- Yogurt: temperatura de envasado aprobada
(9, '2026-09-25 18:10:00-05', 'Temperatura_linea', 5.2000, 'Aprobado', 'Sensor', 5, NULL, NULL, 10),

-- Yogurt: pH en fermentacion dentro de rango
(10, '2026-10-06 12:20:00-05', 'Ph_linea', 4.4100, 'Aprobado', 'Sensor', 6, NULL, NULL, 6),

-- Yogurt: temperatura de envasado fuera de rango
(11, '2026-10-14 18:05:00-05', 'Temperatura_linea', 9.7500, 'Reproceso', 'Sensor', 7, NULL, NULL, 10),

-- Yogurt: control de temperatura en proceso
(12, '2026-10-23 10:30:00-05', 'Temperatura_linea', 42.3000, 'Aprobado', 'Sensor', 8, NULL, NULL, 7);

-- ----------------------------------------------------------
-- ENVASADO
-- El lote de produccion 1 no tiene envasado.
-- ----------------------------------------------------------
INSERT INTO envasado (
    id_envasado, 
    fecha_hora_envasado, 
    presentacion, 
    cantidad_envasada, 
    destino,
    temperatura_envasado, 
    temperatura_despacho, 
    fecha_vencimiento,
    fecha_hora_despacho, 
    estado, 
    id_lote_produccion)
VALUES
(1, '2026-08-15 08:00:00-05', 'Bolsa_150g', 11000, 'Mayorista', 5.20, 4.80, '2026-09-14', '2026-08-16 07:30:00-05', 'Cerrado', 2),
(2, '2026-09-10 08:15:00-05', 'Botella_1l', 1500, 'Minorista', 4.90, 4.50, '2026-10-10', '2026-09-11 06:45:00-05', 'Cerrado', 3),
(3, '2026-09-26 08:00:00-05', 'Bolsa_150g', 10500, 'Venta_directa', 5.60, 5.10, '2026-10-26', NULL, 'Abierto', 5),
(4, '2026-10-07 08:20:00-05', 'Botella_1l', 1900, 'Mayorista', 4.80, 4.30, '2026-11-06', '2026-10-08 07:15:00-05', 'Cerrado', 6),
(5, '2026-10-15 08:10:00-05', 'Garrafa', 480, 'Minorista', 5.00, 4.60, '2026-11-14', NULL, 'Abierto', 7);