begin;

create table prueba_calidad (
    id_prueba_calidad serial primary key,
    fecha_hora timestamptz not null,
    tipo_prueba varchar(25) not null
                        constraint ck_prueba_calidad_tipo_prueba
                            check (tipo_prueba in ('Microbiologica','Fisicoquimica','Ph_linea','Temperatura_linea')),
    valor_obtenido numeric(12,4) not null,
    resultado varchar(20) not null
                        constraint ck_prueba_calidad_resultado
                            check (resultado in ('Aprobado','Rechazado','Reproceso')),
    origen_registro varchar(20) not null
                                constraint ck_prueba_calidad_origen
                                    check (origen_registro in ('Sensor','Manual')),
    id_lote_produccion integer
        references lote_produccion (id_lote_produccion) on delete restrict,
    id_lote_leche integer
        references lote_leche (id_lote_leche) on delete restrict,
    id_responsable_registro integer
        references empleado (id_empleado) on delete restrict,
    id_estandar integer not null
        references estandar_calidad (id_estandar) on delete restrict,
    constraint ck_prueba_calidad_un_solo_lote
        check (num_nonnulls(id_lote_produccion, id_lote_leche) = 1),
    constraint ck_prueba_calidad_linea_exige_lote_produccion
        check (tipo_prueba not in ('Ph_linea','Temperatura_linea') or id_lote_produccion is not null),
    constraint ck_prueba_calidad_sensor_sin_responsable
        check (origen_registro <> 'Sensor'
               or (id_responsable_registro is null and tipo_prueba in ('Ph_linea','Temperatura_linea'))),
    constraint ck_prueba_calidad_manual_con_responsable
        check (origen_registro <> 'Manual' or id_responsable_registro is not null)
);

commit;