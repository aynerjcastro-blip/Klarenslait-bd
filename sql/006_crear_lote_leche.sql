-- Migración 006: lote_leche
BEGIN;

CREATE TABLE lote_leche (
    id_lote_leche              INTEGER GENERATED ALWAYS AS IDENTITY,
    codigo                     VARCHAR(30)   NOT NULL,
    fecha_recepcion            TIMESTAMPTZ   NOT NULL,
    volumen_inicial_litros     NUMERIC(12,2) NOT NULL,
    volumen_disponible_litros  NUMERIC(12,2) NOT NULL,
    dictamen_microbiologico    VARCHAR(10)   NOT NULL DEFAULT 'pendiente',
    estado_lote                VARCHAR(10)   NOT NULL DEFAULT 'recibido',
    id_proveedor_origen        INTEGER       NOT NULL,

    CONSTRAINT pk_lote_leche
        PRIMARY KEY (id_lote_leche),
    CONSTRAINT uq_lote_leche_codigo
        UNIQUE (codigo),
    CONSTRAINT fk_lote_leche_proveedor
        FOREIGN KEY (id_proveedor_origen) REFERENCES proveedor (id_proveedor)
        ON DELETE RESTRICT,
    CONSTRAINT ck_lote_leche_dictamen
        CHECK (dictamen_microbiologico IN ('pendiente', 'aprobado', 'rechazado')),
    CONSTRAINT ck_lote_leche_estado_lote
        CHECK (estado_lote IN ('recibido', 'disponible', 'agotado', 'rechazado')),
    CONSTRAINT ck_lote_leche_volumen_inicial_positivo
        CHECK (volumen_inicial_litros > 0),
    CONSTRAINT ck_lote_leche_volumen_disponible_no_negativo
        CHECK (volumen_disponible_litros >= 0),
    CONSTRAINT ck_lote_leche_disponible_no_supera_inicial
        CHECK (volumen_disponible_litros <= volumen_inicial_litros),
    CONSTRAINT ck_lote_leche_disponible_exige_dictamen_aprobado
        CHECK (estado_lote <> 'disponible' OR dictamen_microbiologico = 'aprobado'),
    CONSTRAINT ck_lote_leche_disponible_con_litros
        CHECK (estado_lote <> 'disponible' OR volumen_disponible_litros > 0),
    CONSTRAINT ck_lote_leche_agotado_sin_litros
        CHECK (estado_lote <> 'agotado' OR volumen_disponible_litros = 0),
    CONSTRAINT ck_lote_leche_dictamen_rechazado_implica_rechazado
        CHECK (dictamen_microbiologico <> 'rechazado' OR estado_lote = 'rechazado')
);

COMMIT;
