begin;

create table almacena (
    id_almacena serial primary key,
    id_lote_leche integer not null
        references lote_leche (id_lote_leche) on delete restrict,
    id_silo integer not null
        references silo (id_silo) on delete restrict,
    fecha_hora timestamptz not null,
    tipo_movimiento varchar(20) not null
                            constraint ck_almacena_tipo_movimiento 
                                check (tipo_movimiento in ('entrada','salida')),
    volumen_litros numeric(12,2) not null
                            constraint ck_almacena_volumen check (volumen_litros > 0),
    observaciones text
);

commit;