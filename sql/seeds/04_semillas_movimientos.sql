-- ----------------------------------------------------------
-- ALMACENA
-- Coherencia por silo:
-- SIL-01: 5000 entrada - 1800 salida = 3200
-- SIL-02: 4000 entrada = 4000
-- SIL-03: 6000 entrada - 6000 salida = 0
-- SIL-04: 3500 entrada - 1700 salida = 1800
-- SIL-05: 4500 entrada - 4500 salida = 0
-- SIL-06: 5200 + 3800 entradas - 2600 - 3800 salidas = 6400
-- ----------------------------------------------------------
INSERT INTO almacena (
    id_almacena, 
    id_lote_leche, 
    id_silo, 
    fecha_hora, 
    tipo_movimiento, 
    volumen_litros, 
    observaciones
    )
VALUES
(1, 1, 1, '2026-07-25 06:20:00-05', 'Entrada', 5000.00, 'Recepcion de leche cruda de Finca La Esperanza del Cesar.'),
(2, 1, 1, '2026-08-10 09:30:00-05', 'Salida', 1800.00, 'Salida para asignacion a produccion de yogurt.'),

(3, 2, 2, '2026-08-04 05:50:00-05', 'Entrada', 4000.00, 'Recepcion de leche cruda de Ganaderia El Corral de Ares.'),

(4, 3, 3, '2026-08-12 06:15:00-05', 'Entrada', 6000.00, 'Recepcion de leche cruda de Agropecuaria Los Chenes SAS.'),
(5, 3, 3, '2026-08-20 10:00:00-05', 'Salida', 6000.00, 'Salida total para proceso productivo.'),

(6, 5, 4, '2026-09-03 06:30:00-05', 'Entrada', 3500.00, 'Recepcion de leche cruda de Finca La Esperanza del Cesar.'),
(7, 5, 4, '2026-09-12 08:45:00-05', 'Salida', 1700.00, 'Salida parcial para produccion de yogurt.'),

(8, 6, 5, '2026-09-15 06:00:00-05', 'Entrada', 4500.00, 'Recepcion de leche cruda de Ganaderia El Corral de Ares.'),
(9, 6, 5, '2026-09-24 09:15:00-05', 'Salida', 4500.00, 'Salida total antes del mantenimiento programado.'),

(10, 7, 6, '2026-10-02 06:20:00-05', 'Entrada', 5200.00, 'Recepcion de leche cruda de Agropecuaria Los Chenes SAS.'),
(11, 8, 6, '2026-10-18 05:55:00-05', 'Entrada', 3800.00, 'Recepcion de leche cruda de Distribuidora Caribe Lactea SAS.'),
(12, 7, 6, '2026-10-13 08:00:00-05', 'Salida', 2600.00, 'Salida parcial para produccion de yogurt.'),
(13, 8, 6, '2026-10-23 07:10:00-05', 'Salida', 3800.00, 'Salida para lote de yogurt en proceso.');

-- ----------------------------------------------------------
-- USO_TANQUE
-- Tanque 5 no tiene registros.
-- ----------------------------------------------------------
INSERT INTO uso_tanque (
    id_uso_tanque, 
    id_tanque, 
    id_lote_produccion, 
    fecha_hora_inicio, 
    fecha_hora_fin, 
    estado_uso)

VALUES
(1, 1, 2, '2026-08-14 07:20:00-05', '2026-08-14 17:10:00-05', 'Finalizado'),
(2, 2, 5, '2026-09-25 07:10:00-05', '2026-09-25 16:50:00-05', 'Finalizado'),
(3, 3, 7, '2026-10-14 07:10:00-05', '2026-10-14 17:40:00-05', 'Finalizado'),
(4, 4, 8, '2026-10-23 07:15:00-05', NULL, 'Activo');

-- ----------------------------------------------------------
-- CONSUMO_INSUMO
-- Los consumos no superan la cantidad inicial de cada lote.
-- ----------------------------------------------------------
INSERT INTO consumo_insumo (
    id_consumo_insumo, 
    id_lote_insumo, 
    id_lote_produccion, 
    cantidad_consumida, 
    fecha_hora_consumo)

VALUES
(1, 1, 1, 6.000, '2026-08-05 07:30:00-05'),
(2, 2, 1, 18.500, '2026-08-05 08:00:00-05'),
(3, 1, 2, 7.500, '2026-08-14 07:40:00-05'),
(4, 3, 2, 4.250, '2026-08-14 08:10:00-05'),
(5, 1, 3, 5.000, '2026-09-08 07:25:00-05'),
(6, 6, 3, 15.750, '2026-09-08 08:00:00-05'),
(7, 2, 5, 21.000, '2026-09-25 07:35:00-05'),
(8, 7, 5, 9.500, '2026-09-25 08:05:00-05'),
(9, 1, 6, 6.500, '2026-10-06 07:35:00-05'),
(10, 6, 6, 20.000, '2026-10-06 08:05:00-05'),
(11, 1, 7, 7.000, '2026-10-14 07:30:00-05'),
(12, 3, 7, 8.000, '2026-10-14 08:00:00-05');

-- ----------------------------------------------------------
-- ASIGNA
-- Volumenes inferiores al disponible del silo y capacidad del tanque.
-- ----------------------------------------------------------
INSERT INTO asigna (
    id_asigna, 
    id_silo_origen, 
    id_tanque_destino, 
    id_lote_produccion,
    volumen_asignado_litros, 
    fecha_hora_asignacion)
VALUES
(1, 1, 1, 2, 1800.00, '2026-08-14 07:15:00-05'),
(2, 4, 2, 5, 1700.00, '2026-09-25 07:05:00-05'),
(3, 6, 3, 7, 2600.00, '2026-10-14 07:05:00-05'),
(4, 6, 4, 8, 3800.00, '2026-10-23 07:10:00-05');

-- ----------------------------------------------------------
-- DESCARTE
-- ----------------------------------------------------------
INSERT INTO descarte (
    id_lote_produccion, 
    fecha_hora_descarte, 
    motivo, 
    volumen_descartado, 
    observaciones)
VALUES

(4, '2026-09-18 18:30:00-05','Acidez fuera del rango permitido en etapa de mezcla.',1150.00,'Lote rechazado por el laboratorio de calidad. Se dispone conforme al protocolo interno de residuos organicos.');