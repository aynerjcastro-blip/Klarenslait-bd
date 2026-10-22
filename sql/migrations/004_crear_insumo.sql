-- Migración 004: insumo
BEGIN;

CREATE TABLE insumo (
    id_insumo         INTEGER GENERATED ALWAYS AS IDENTITY,
    codigo            VARCHAR(30) NOT NULL,
    categoria_insumo  VARCHAR(30) NOT NULL,
    unidad_medida     VARCHAR(20) NOT NULL,
    estado            VARCHAR(20) NOT NULL DEFAULT 'activo',

    CONSTRAINT pk_insumo
        PRIMARY KEY (id_insumo),
    CONSTRAINT uq_insumo_codigo
        UNIQUE (codigo),
    CONSTRAINT ck_insumo_categoria_insumo
        CHECK (categoria_insumo IN ('cultivo_lactico', 'pulpa_fruta', 'saborizante', 'material_empaque')),
    CONSTRAINT ck_insumo_unidad_medida
        CHECK (unidad_medida IN ('kg', 'g', 'l', 'ml', 'unidad')),
    CONSTRAINT ck_insumo_estado
        CHECK (estado IN ('activo', 'inactivo'))
);

COMMIT;
