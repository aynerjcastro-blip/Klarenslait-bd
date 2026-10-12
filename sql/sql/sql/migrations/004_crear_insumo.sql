-- Migración 004: insumo
BEGIN;

CREATE TABLE insumo (
    id_insumo         BIGINT GENERATED ALWAYS AS IDENTITY,
    codigo            VARCHAR(30) NOT NULL,
    categoria_insumo  VARCHAR(50) NOT NULL,
    unidad_medida     VARCHAR(20) NOT NULL,
    estado            VARCHAR(20) NOT NULL,

    CONSTRAINT pk_insumo
        PRIMARY KEY (id_insumo),
    CONSTRAINT uq_insumo_codigo
        UNIQUE (codigo)
);

COMMIT;
