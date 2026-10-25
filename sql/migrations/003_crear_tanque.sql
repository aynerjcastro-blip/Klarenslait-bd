begin;

create table tanque(
    id_tanque serial primary key,
    codigo varchar(20) not null 
	                constraint tanque_codigo_unico unique,
    tipo_tanque varchar(20) not null
	                     constraint tanque_tipo_tanque_valido 
						     check(tipo_tanque in ('Fermentacion', 'Mezcla')),
    capacidad_maxima numeric(12,2) not null
	                            constraint tanque_capacidad_maxima_mayor_que_cero
								    check(capacidad_maxima > 0),
    volumen_actual numeric(12,2) not null 
	                          constraint tanque_volumen_actual_no_negativo
							      check(volumen_actual >= 0),
     constraint tanque_volumen_actual_no_mayor_que_capacidad_maxima 
	    check(volumen_actual <= capacidad_maxima),
    estado_operativo varchar(20) not null 
	                          constraint tanque_estado_operativo_valido 
							      check(estado_operativo IN ('Operativo', 'En_mantenimiento', 'Fuera_de_servicio'))
);

commit;