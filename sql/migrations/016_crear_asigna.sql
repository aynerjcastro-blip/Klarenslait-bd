begin;

create table asigna (
    id_asigna serial primary key,
    id_silo_origen integer not null
        references silo (id_silo) on delete restrict,
    id_tanque_destino integer not null
        references tanque (id_tanque) on delete restrict,
    id_lote_produccion integer not null
        references lote_produccion (id_lote_produccion) on delete restrict,
    volumen_asignado_litros numeric(12,2) not null
                                        constraint ck_asigna_volumen 
                                            check (volumen_asignado_litros > 0),
    fecha_hora_asignacion timestamptz not null
);

commit;