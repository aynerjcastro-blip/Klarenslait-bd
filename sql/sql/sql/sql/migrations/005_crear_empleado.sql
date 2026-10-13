-- Migración 005: empleado
BEGIN;

CREATE TABLE empleado (
    id_empleado         BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre              VARCHAR(150) NOT NULL,
    identificacion      VARCHAR(30)  NOT NULL,
    cargo               VARCHAR(30)  NOT NULL,
    estado_vinculacion  VARCHAR(20)  NOT NULL,

    CONSTRAINT pk_empleado
        PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleado_identificacion
        UNIQUE (identificacion),
    CONSTRAINT ck_empleado_cargo
        CHECK (cargo IN ('operador_tanque', 'tecnico_calidad', 'supervisor'))
);

COMMIT;
