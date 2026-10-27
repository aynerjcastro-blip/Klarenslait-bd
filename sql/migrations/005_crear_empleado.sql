begin;

create table empleado(
    id_empleado serial primary key,
    nombre varchar(120) not null,
    cargo varchar(30) not null
	               constraint empleado_cargo_valido
				       check(cargo in ('Operador_tanque', 'Tecnico_calidad', 'Supervisor')),
    identificacion varchar(20) not null 
	                        constraint empleado_identificacion_unica unique,
    estado_vinculacion varchar(20) not null default 'Activo'
	                            constraint empleado_estado_vinculacion_valido check(estado_vinculacion in ('Activo', 'Inactivo'))
);

commit;