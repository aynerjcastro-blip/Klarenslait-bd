begin;

create table lote_produccion (
    id_lote_produccion serial primary key,
    codigo varchar(30) not null
                    constraint uq_lote_produccion_codigo unique,
    tipo_producto varchar(20) not null
                            constraint ck_lote_produccion_tipo_producto
                                check (tipo_producto in ('yogurt','queso','suero','avena','leche_uht')),
    volumen_planificado_litros numeric(12,2) not null
                                            constraint ck_lote_produccion_volumen_planificado
                                                check (volumen_planificado_litros > 0),
    volumen_producido_litros numeric(12,2)
                                        constraint ck_lote_produccion_volumen_producido
                                            check (volumen_producido_litros >= 0),
    fecha_hora_inicio timestamptz not null,
    fecha_hora_fin timestamptz,
    estado varchar(20) not null default 'en_proceso'
                    constraint ck_lote_produccion_estado
                        check (estado in ('en_proceso','aprobado','rechazado','envasado','descartado')),
    id_supervisor integer not null
        references empleado (id_empleado) on delete restrict,
    constraint ck_lote_produccion_fechas
        check (fecha_hora_fin is null or fecha_hora_fin >= fecha_hora_inicio)
);

commit;