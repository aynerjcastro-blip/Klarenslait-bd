begin;

create table estandar_calidad(
    id_estandar serial primary key,
    tipo_producto varchar(20) not null 
	                       constraint estandar_calidad_tipo_producto_valido
						       check(tipo_producto in ('Leche_cruda', 'Yogurt', 'Queso', 'Suero', 'Avena', 'Leche_uht')),
    parametro varchar(20) not null 
	                   constraint estandar_calidad_parametro_valido 
					       check(parametro in ('Ph', 'Temperatura', 'Acidez_dornic', 'Grasa', 'Viscosidad', 'Microorganismos')),
    etapa varchar(20) not null 
	               constraint estandar_calidad_etapa_valida
				       check(etapa in ('Recepcion', 'Fermentacion', 'Mezcla', 'Envasado')),
    unidad_medida varchar(20) not null 
                           constraint estandar_calidad_unidad_medida_valida 
						       check(unidad_medida in ('Adimensional', 'Grados_celsius', 'Grados_dornic', 'Porcentaje', 'Cp', 'Ufc_ml')),
    valor_minimo_permitido numeric(12,4) not null,
    valor_maximo_permitido numeric(12,4) not null,
    vigente_desde date not null,
    vigente_hasta date,
    constraint estandar_calidad_minimo_no_mayor_que_maximo
			check(valor_minimo_permitido <= valor_maximo_permitido),
    constraint estandar_calidad_vigente_hasta_no_anterior_a_desde 
		    check(vigente_hasta is null or vigente_hasta >= vigente_desde)
);

commit;