-- Migración 002: silo
BEGIN;

CREATE TABLE silo (
    id_silo           BIGINT GENERATED ALWAYS AS IDENTITY,
    codigo            VARCHAR(30)   NOT NULL,
    tipo_silo         VARCHAR(50)   NOT NULL,
    capacidad_maxima  NUMERIC(12,2) NOT NULL,
    volumen_actual    NUMERIC(12,2) NOT NULL DEFAULT 0,
    estado_operativo  VARCHAR(30)   NOT NULL,

    CONSTRAINT pk_silo
        PRIMARY KEY (id_silo),
    CONSTRAINT uq_silo_codigo
        UNIQUE (codigo),
    CONSTRAINT ck_silo_capacidad_positiva
        CHECK (capacidad_maxima > 0),
    CONSTRAINT ck_silo_volumen_no_negativo
        CHECK (volumen_actual >= 0),
    CONSTRAINT ck_silo_volumen_dentro_de_capacidad
        CHECK (volumen_actual <= capacidad_maxima)
);

COMMIT;
