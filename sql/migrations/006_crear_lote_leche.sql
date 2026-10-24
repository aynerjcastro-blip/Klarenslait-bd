create table lote_leche(
    id_lote_leche serial primary key,
    codigo varchar(30) not null 
	                constraint lote_leche_codigo_unico unique,
    fecha_recepcion timestamptz not null,
    volumen_inicial_litros numeric(12,2) not null
	                                  constraint lote_leche_volumen_inicial_mayor_que_cero
									      check(volumen_inicial_litros > 0),
    volumen_disponible_litros numeric(12,2) not null
	                                     constraint lote_leche_volumen_disponible_no_negativo
										     check(volumen_disponible_litros >= 0),
    dictamen_microbiologico varchar(20) not null default 'Pendiente' 
	                                 constraint lote_leche_dictamen_valido
									     check(dictamen_microbiologico in ('Pendiente', 'Aprobado', 'Rechazado')),
    estado_lote varchar(20) not null default 'Recibido' 
	                     constraint lote_leche_estado_lote_valido
						     check(estado_lote in ('Recibido', 'Disponible', 'Agotado', 'Rechazado')),
    id_proveedor_origen integer not null 
	                     references proveedor(id_proveedor) on delete restrict,
    constraint lote_leche_volumen_disponible_no_mayor_que_inicial
	           check(volumen_disponible_litros <= volumen_inicial_litros),
	constraint lote_leche_disponible_exige_dictamen_aprobado
	           check(not (estado_lote = 'Disponible' and dictamen_microbiologico != 'Aprobado')),
	constraint lote_leche_disponible_exige_litros
	           check(not (estado_lote = 'Disponible' and volumen_disponible_litros <= 0)),
	constraint lote_leche_agotado_exige_cero_litros
	           check(not (estado_lote = 'Agotado' and volumen_disponible_litros != 0)),
	constraint lote_leche_dictamen_rechazado_exige_estado_rechazado
	           check(not (dictamen_microbiologico = 'Rechazado' and estado_lote != 'Rechazado'))
)