-- Migración 001: proveedor
BEGIN;

CREATE TABLE proveedor (
    id_proveedor    BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre          VARCHAR(150) NOT NULL,
    tipo_proveedor  VARCHAR(50)  NOT NULL,
    identificacion  VARCHAR(30)  NOT NULL,
    telefono        VARCHAR(30),
    ubicacion       VARCHAR(200),
    estado          VARCHAR(20)  NOT NULL,

    CONSTRAINT pk_proveedor
        PRIMARY KEY (id_proveedor),
    CONSTRAINT uq_proveedor_identificacion
        UNIQUE (identificacion)
);

COMMIT;
