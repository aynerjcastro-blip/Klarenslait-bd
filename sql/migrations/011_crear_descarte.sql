begin;

create table descarte (
    id_lote_produccion integer not null primary key
        references lote_produccion (id_lote_produccion) on delete restrict,
    fecha_hora_descarte timestamptz not null,
    motivo varchar(200) not null,
    volumen_descartado numeric(12,2) not null
                                    constraint ck_descarte_volumen check (volumen_descartado > 0),
    observaciones text
);

commit;