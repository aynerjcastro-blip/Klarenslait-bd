create table lote_insumo(
    id_lote_insumo serial primary key,
    codigo_lote_insumo varchar(30) not null
                                constraint lote_insumo_codigo_unico unique,
    cantidad_inicial numeric(12,3) not null
	                            constraint lote_insumo_cantidad_inicial_mayor_que_cero 
								    check(cantidad_inicial > 0),
    cantidad_disponible numeric(12,3) not null 
                               constraint lote_insumo_cantidad_disponible_no_negativa 
							       check(cantidad_disponible >= 0),
    fecha_recepcion date not null,
    fecha_caducidad date not null,
    estado varchar(20) not null default 'Disponible'
	                constraint lote_insumo_estado_valido 
					    check(estado in ('Disponible', 'Agotado', 'Vencido')),
    id_insumo integer not null
	                     references insumo(id_insumo) on delete restrict,
    id_proveedor integer not null 
                         references proveedor(id_proveedor) on delete restrict,
	constraint lote_insumo_cantidad_disponible_no_mayor_que_inicial
			   check(cantidad_disponible <= cantidad_inicial),
	constraint lote_insumo_caducidad_no_anterior_a_recepcion
			   check(fecha_caducidad >= fecha_recepcion)
)