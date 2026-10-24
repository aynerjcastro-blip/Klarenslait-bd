create table insumo(
    id_insumo serial primary key,
    codigo varchar(30) not null
	                constraint insumo_codigo_unico unique,
    categoria_insumo varchar(30) not null
	                          constraint insumo_categoria_insumo_valida 
							      check(categoria_insumo in ('Cultivo_lactico', 'Pulpa_fruta', 'Saborizante', 'Material_empaque')),
    unidad_medida varchar(20) not null
	                       constraint insumo_unidad_medida_valida 
						       check(unidad_medida in ('Kg', 'G', 'L', 'Ml', 'Unidad')),
    estado varchar(20) not null default 'Activo'
	                constraint insumo_estado_valido 
					    check(estado in ('Activo', 'Inactivo'))
)