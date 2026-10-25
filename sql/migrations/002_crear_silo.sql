begin;

create table silo(
    id_silo serial primary key,
    codigo varchar(20) not null
                    constraint silo_codigo_unico unique,
    tipo_silo varchar(20) not null
                       constraint silo_tipo_silo_valido
                           check(tipo_silo in ('recepcion', 'acopio')),
    capacidad_maxima numeric(12,2) not null
                                constraint silo_capacidad_maxima_mayor_que_cero
                                    check(capacidad_maxima > 0),
    volumen_actual numeric(12,2) not null default 0
                              constraint silo_volumen_actual_no_negativo
                                  check(volumen_actual >= 0),
    estado_operativo varchar(20) not null
                              constraint silo_estado_operativo_valido
                                  check(estado_operativo in ('operativo', 'en_mantenimiento', 'fuera_de_servicio')),
     constraint silo_volumen_actual_no_mayor_que_capacidad_maxima
         check(volumen_actual <= capacidad_maxima)
);

commit;