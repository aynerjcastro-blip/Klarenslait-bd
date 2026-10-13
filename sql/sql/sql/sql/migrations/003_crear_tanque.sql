-- Migración 003: tanque
BEGIN;

CREATE TABLE tanque (
    id_tanque         BIGINT GENERATED ALWAYS AS IDENTITY,
    codigo            VARCHAR(30)   NOT NULL,
    tipo_tanque       VARCHAR(50)   NOT NULL,
    capacidad_maxima  NUMERIC(12,2) NOT NULL,
    volumen_actual    NUMERIC(12,2) NOT NULL DEFAULT 0,
    estado_operativo  VARCHAR(30)   NOT NULL,

    CONSTRAINT pk_tanque
        PRIMARY KEY (id_tanque),
    CONSTRAINT uq_tanque_codigo
        UNIQUE (codigo),
    CONSTRAINT ck_tanque_capacidad_positiva
        CHECK (capacidad_maxima > 0),
    CONSTRAINT ck_tanque_volumen_no_negativo
        CHECK (volumen_actual >= 0),
    CONSTRAINT ck_tanque_volumen_dentro_de_capacidad
        CHECK (volumen_actual <= capacidad_maxima)
);

COMMIT;
