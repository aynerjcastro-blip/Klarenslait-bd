create table proveedor(
    id_proveedor serial primary key,
    nombre varchar(120) not null,
    ubicacion varchar(150) not null,
    telefono varchar(20),
    tipo_proveedor varchar(20) not null 
                           constraint proveedor_tipo_proveedor_valido 
						       check(tipo_proveedor in ('Persona','Finca','Empresa')),
    identificacion varchar(20) not null
                            constraint proveedor_identificacion_unica unique,
    estado varchar(20) not null default 'Activo'
                    constraint proveedor_estado_valido 
						check(estado in ('Activo','Inactivo'))
)