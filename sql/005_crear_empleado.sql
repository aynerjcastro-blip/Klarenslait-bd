-- Migración 005: empleado
BEGIN;

CREATE TABLE empleado (
    id_empleado         INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre              VARCHAR(120) NOT NULL,
    cargo               VARCHAR(20)  NOT NULL,
    identificacion      VARCHAR(20)  NOT NULL,
    estado_vinculacion  VARCHAR(10)  NOT NULL DEFAULT 'activo',

    CONSTRAINT pk_empleado
        PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleado_identificacion
        UNIQUE (identificacion),
    CONSTRAINT ck_empleado_cargo
        CHECK (cargo IN ('operador_tanque', 'tecnico_calidad', 'supervisor')),
    CONSTRAINT ck_empleado_estado_vinculacion
        CHECK (estado_vinculacion IN ('activo', 'inactivo'))
);

COMMIT;
