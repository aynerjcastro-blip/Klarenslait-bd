-- Migración 007: lote_insumo
BEGIN;

CREATE TABLE lote_insumo (
    id_lote_insumo       INTEGER GENERATED ALWAYS AS IDENTITY,
    codigo_lote_insumo   VARCHAR(30)   NOT NULL,
    cantidad_inicial     NUMERIC(12,3) NOT NULL,
    cantidad_disponible  NUMERIC(12,3) NOT NULL,
    fecha_recepcion      DATE          NOT NULL,
    fecha_caducidad      DATE          NOT NULL,
    estado               VARCHAR(12)   NOT NULL DEFAULT 'disponible',
    id_insumo            INTEGER       NOT NULL,
    id_proveedor         INTEGER       NOT NULL,

    CONSTRAINT pk_lote_insumo
        PRIMARY KEY (id_lote_insumo),
    CONSTRAINT uq_lote_insumo_codigo
        UNIQUE (codigo_lote_insumo),
    CONSTRAINT fk_lote_insumo_insumo
        FOREIGN KEY (id_insumo) REFERENCES insumo (id_insumo)
        ON DELETE RESTRICT,
    CONSTRAINT fk_lote_insumo_proveedor
        FOREIGN KEY (id_proveedor) REFERENCES proveedor (id_proveedor)
        ON DELETE RESTRICT,
    CONSTRAINT ck_lote_insumo_estado
        CHECK (estado IN ('disponible', 'agotado', 'vencido')),
    CONSTRAINT ck_lote_insumo_cantidad_inicial_positiva
        CHECK (cantidad_inicial > 0),
    CONSTRAINT ck_lote_insumo_cantidad_disponible_no_negativa
        CHECK (cantidad_disponible >= 0),
    CONSTRAINT ck_lote_insumo_disponible_no_supera_inicial
        CHECK (cantidad_disponible <= cantidad_inicial),
    CONSTRAINT ck_lote_insumo_caducidad_desde_recepcion
        CHECK (fecha_caducidad >= fecha_recepcion)
);

COMMIT;
