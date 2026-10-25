begin;

create table consumo_insumo (
    id_consumo_insumo serial primary key,
    id_lote_insumo integer not null
        references lote_insumo (id_lote_insumo) on delete restrict,
    id_lote_produccion integer not null
        references lote_produccion (id_lote_produccion) on delete restrict,
    cantidad_consumida numeric(12,3) not null
                                constraint ck_consumo_insumo_cantidad check (cantidad_consumida > 0),
    fecha_hora_consumo timestamptz not null
);

commit;