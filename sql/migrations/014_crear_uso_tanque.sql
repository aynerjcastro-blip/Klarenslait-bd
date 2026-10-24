begin;

create table uso_tanque (
    id_uso_tanque serial primary key,
    id_tanque integer not null
        references tanque (id_tanque) on delete restrict,
    id_lote_produccion integer not null
        references lote_produccion (id_lote_produccion) on delete restrict,
    fecha_hora_inicio timestamptz not null,
    fecha_hora_fin timestamptz,
    estado_uso varchar(20) not null default 'Activo'
                        constraint ck_uso_tanque_estado_uso 
                            check (estado_uso in ('Activo','Finalizado')),
    constraint ck_uso_tanque_fechas
        check (fecha_hora_fin is null or fecha_hora_fin >= fecha_hora_inicio),
    -- estado_uso es un dato derivado: 'Activo' si y solo si fecha_hora_fin está vacía (docs/07, 4.2).
    constraint ck_uso_tanque_estado_coherente
        check ((estado_uso = 'Activo') = (fecha_hora_fin is null))
);

-- rn-06: un solo uso activo por tanque.
create unique index uq_uso_tanque_activo_por_tanque
    on uso_tanque (id_tanque) where fecha_hora_fin is null;

-- un lote está en un solo tanque a la vez.
create unique index uq_uso_tanque_activo_por_lote
    on uso_tanque (id_lote_produccion) where fecha_hora_fin is null;

commit;