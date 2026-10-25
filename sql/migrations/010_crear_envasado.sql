begin;

create table envasado (
    id_envasado serial primary key,
    fecha_hora_envasado timestamptz not null,
    presentacion varchar(30) not null
                            constraint ck_envasado_presentacion 
                                check (presentacion in ('Bolsa_150g','Botella_1l','Garrafa')),
    cantidad_envasada integer not null
                            constraint ck_envasado_cantidad check (cantidad_envasada > 0),
    destino varchar(20) not null
                        constraint ck_envasado_destino 
                            check (destino in ('Mayorista','Minorista','Venta_directa')),
    temperatura_envasado numeric(5,2),
    temperatura_despacho numeric(5,2),
    fecha_vencimiento date not null,
    fecha_hora_despacho timestamptz,
    estado varchar(20) not null default 'Abierto'
                    constraint ck_envasado_estado check (estado in ('Abierto','Cerrado')),
    id_lote_produccion integer not null
        references lote_produccion (id_lote_produccion) on delete restrict,
    constraint ck_envasado_vencimiento
        check (fecha_vencimiento > (fecha_hora_envasado at time zone 'America/Bogota')::date),
    constraint ck_envasado_despacho
        check (fecha_hora_despacho is null or fecha_hora_despacho >= fecha_hora_envasado)
);

commit;