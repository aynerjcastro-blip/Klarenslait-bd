-- Migración 001: proveedor
BEGIN;

CREATE TABLE proveedor (
    id_proveedor    INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre          VARCHAR(120) NOT NULL,
    ubicacion       VARCHAR(150) NOT NULL,
    telefono        VARCHAR(20),
    tipo_proveedor  VARCHAR(20)  NOT NULL,
    identificacion  VARCHAR(20)  NOT NULL,
    estado          VARCHAR(20)  NOT NULL DEFAULT 'activo',

    CONSTRAINT pk_proveedor
        PRIMARY KEY (id_proveedor),
    CONSTRAINT uq_proveedor_identificacion
        UNIQUE (identificacion),
    CONSTRAINT ck_proveedor_tipo_proveedor
        CHECK (tipo_proveedor IN ('persona', 'finca', 'empresa')),
    CONSTRAINT ck_proveedor_estado
        CHECK (estado IN ('activo', 'inactivo'))
);

COMMIT;
