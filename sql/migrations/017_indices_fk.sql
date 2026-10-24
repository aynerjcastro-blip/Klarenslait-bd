begin;

create index ix_lote_produccion_id_supervisor on lote_produccion (id_supervisor);

create index ix_envasado_id_lote_produccion on envasado (id_lote_produccion);

create index ix_prueba_calidad_id_lote_produccion on prueba_calidad (id_lote_produccion);
create index ix_prueba_calidad_id_lote_leche on prueba_calidad (id_lote_leche);
create index ix_prueba_calidad_id_responsable on prueba_calidad (id_responsable_registro);
create index ix_prueba_calidad_id_estandar on prueba_calidad (id_estandar);

create index ix_almacena_id_lote_leche on almacena (id_lote_leche);
create index ix_almacena_id_silo on almacena (id_silo);

create index ix_uso_tanque_id_tanque on uso_tanque (id_tanque);
create index ix_uso_tanque_id_lote_produccion on uso_tanque (id_lote_produccion);

create index ix_consumo_insumo_id_lote_insumo on consumo_insumo (id_lote_insumo);
create index ix_consumo_insumo_id_lote_produccion on consumo_insumo (id_lote_produccion);

create index ix_asigna_id_silo_origen on asigna (id_silo_origen);
create index ix_asigna_id_tanque_destino on asigna (id_tanque_destino);
create index ix_asigna_id_lote_produccion on asigna (id_lote_produccion);

commit;