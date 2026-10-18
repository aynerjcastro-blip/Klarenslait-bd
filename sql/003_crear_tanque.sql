-- Migración 003: tanque
BEGIN;

CREATE TABLE tanque (
    id_tanque         INTEGER GENERATED ALWAYS AS IDENTITY,
    codigo            VARCHAR(20)   NOT NULL,
    tipo_tanque       VARCHAR(15)   NOT NULL,
    capacidad_maxima  NUMERIC(12,2) NOT NULL,
    volumen_actual    NUMERIC(12,2) NOT NULL DEFAULT 0,
    estado_operativo  VARCHAR(20)   NOT NULL,

    CONSTRAINT pk_tanque
        PRIMARY KEY (id_tanque),
    CONSTRAINT uq_tanque_codigo
        UNIQUE (codigo),
    CONSTRAINT ck_tanque_tipo_tanque
        CHECK (tipo_tanque IN ('fermentacion', 'mezcla')),
    CONSTRAINT ck_tanque_estado_operativo
        CHECK (estado_operativo IN ('operativo', 'en_mantenimiento', 'fuera_de_servicio')),
    CONSTRAINT ck_tanque_capacidad_positiva
        CHECK (capacidad_maxima > 0),
    CONSTRAINT ck_tanque_volumen_no_negativo
        CHECK (volumen_actual >= 0),
    CONSTRAINT ck_tanque_volumen_no_supera_capacidad
        CHECK (volumen_actual <= capacidad_maxima)
);

COMMIT;
