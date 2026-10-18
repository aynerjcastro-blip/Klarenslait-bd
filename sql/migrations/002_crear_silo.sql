-- Migración 002: silo
BEGIN;

CREATE TABLE silo (
    id_silo           INTEGER GENERATED ALWAYS AS IDENTITY,
    codigo            VARCHAR(20)   NOT NULL,
    tipo_silo         VARCHAR(10)   NOT NULL,
    capacidad_maxima  NUMERIC(12,2) NOT NULL,
    volumen_actual    NUMERIC(12,2) NOT NULL DEFAULT 0,
    estado_operativo  VARCHAR(20)   NOT NULL,

    CONSTRAINT pk_silo
        PRIMARY KEY (id_silo),
    CONSTRAINT uq_silo_codigo
        UNIQUE (codigo),
    CONSTRAINT ck_silo_tipo_silo
        CHECK (tipo_silo IN ('recepcion', 'acopio')),
    CONSTRAINT ck_silo_estado_operativo
        CHECK (estado_operativo IN ('operativo', 'en_mantenimiento', 'fuera_de_servicio')),
    CONSTRAINT ck_silo_capacidad_positiva
        CHECK (capacidad_maxima > 0),
    CONSTRAINT ck_silo_volumen_no_negativo
        CHECK (volumen_actual >= 0),
    CONSTRAINT ck_silo_volumen_no_supera_capacidad
        CHECK (volumen_actual <= capacidad_maxima)
);

COMMIT;
