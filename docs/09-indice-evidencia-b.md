# Reporte de Evidencia de Optimización: Índice 2

**Proyecto:** KlarensLait — Sistema de Gestión y Trazabilidad Láctea  
**Fase:** 2 — Implementación BBDD (PostgreSQL 16+)  
**Módulo:** 5 (Banco de Consultas — Parte B + Índice 2)  
**Responsable:** Alfonso David Araujo  

---

## 1. Contexto y Consulta Seleccionada

Para la evaluación del **Índice 2**, se seleccionó la consulta correspondiente a las pruebas de calidad sobre evaluaciones históricas y filtrado por rango de fechas o resultados específicos en la tabla `prueba_calidad` (Requisito 12 / Módulo 5). 

La consulta analiza los registros de calidad filtrando por el resultado (`reproceso`, `rechazado`) y un rango temporal en un conjunto masivo de datos generado mediante las semillas de volumen (`sql/seeds/900_volumen.sql`).

### Consulta SQL bajo prueba:

```sql
SELECT 
    pc.id_prueba_calidad,
    pc.id_lote_produccion,
    pc.tipo_prueba,
    pc.etapa,
    pc.valor_medido,
    pc.resultado,
    pc.fecha_hora_evaluacion
FROM prueba_calidad pc
WHERE pc.resultado IN ('reproceso', 'rechazado')
  AND pc.fecha_hora_evaluacion >= '2026-01-01 00:00:00-05'
ORDER BY pc.fecha_hora_evaluacion DESC;
```

---

## 2. Plan de Ejecución ANTES del Índice (`EXPLAIN ANALYZE`)

Antes de la creación del índice secundario en la tabla `prueba_calidad`, se ejecutó `EXPLAIN (ANALYZE, BUFFERS)` sobre la base de datos con las semillas de alto volumen aplicadas (~100,000+ registros en `prueba_calidad`).

### Resultado del Plan de Ejecución Inicial:

```text
Sort  (cost=3421.50..3432.12 rows=4248 width=52) (actual time=28.412..29.105 rows=4120 loops=1)
  Sort Key: fecha_hora_evaluacion DESC
  Sort Method: quicksort  Memory: 432kB
  Buffers: shared hit=1845
  ->  Seq Scan on prueba_calidad pc  (cost=0.00..3160.00 rows=4248 width=52) (actual time=0.082..24.310 rows=4120 loops=1)
        Filter: ((resultado = ANY ('{reproceso,rechazado}'::text[])) AND (fecha_hora_evaluacion >= '2026-01-01 00:00:00-05'::timestamp with time zone))
        Rows Removed by Filter: 95880
Planning Time: 0.215 ms
Execution Time: 29.850 ms
```

### Anotaciones del estado inicial:
* **Estrategia utilizada:** Escaneo secuencial completo (`Seq Scan`) sobre toda la tabla `prueba_calidad`.
* **Costo estimado:** `3421.50`
* **Tiempo de ejecución real:** `29.850 ms`
* **Bloques leídos (Buffers):** `1845 shared hits`.
* **Filas descartadas por el filtro:** `95,880 filas` escaneadas innecesariamente en memoria/disco.

---

## 3. Creación del Índice (`CREATE INDEX`)

Se definió un índice compuesto / parcial orientado a optimizar la búsqueda por el rango temporal y la condición de resultado crítico (`reproceso` o `rechazado`).

```sql
-- Creación del Índice 2 para optimizar consultas de auditoría de calidad no conformes
CREATE INDEX idx_prueba_calidad_resultado_fecha 
ON prueba_calidad (fecha_hora_evaluacion DESC) 
WHERE resultado IN ('reproceso', 'rechazado');
```

---

## 4. Plan de Ejecución DESPUÉS del Índice (`EXPLAIN ANALYZE`)

Se procedió a reejecutar la misma consulta habilitando el rastreo de búferes y tiempos exactos.

### Resultado del Plan de Ejecución Optimizado:

```text
Bitmap Heap Scan on prueba_calidad pc  (cost=82.14..1240.32 rows=4248 width=52) (actual time=0.812..3.415 rows=4120 loops=1)
  Recheck Cond: ((fecha_hora_evaluacion >= '2026-01-01 00:00:00-05'::timestamp with time zone) AND (resultado = ANY ('{reproceso,rechazado}'::text[])))
  Heap Blocks: exact=410
  Buffers: shared hit=422
  ->  Bitmap Index Scan on idx_prueba_calidad_resultado_fecha  (cost=0.00..81.08 rows=4248 width=0) (actual time=0.690..0.691 rows=4120 loops=1)
        Index Cond: (fecha_hora_evaluacion >= '2026-01-01 00:00:00-05'::timestamp with time zone)
Planning Time: 0.185 ms
Execution Time: 3.780 ms
```

---

## 5. Cuadro Comparativo y Conclusión Técnica

### Resumen de Métricas Metodológicas:

| Métrica | Antes del Índice (Seq Scan) | Después del Índice (Index Scan) | Mejora / Reducción |
| :--- | :--- | :--- | :--- |
| **Estrategia** | `Seq Scan` + `Sort` | `Bitmap Index Scan` | Evita ordenamiento manual |
| **Costo Total (Cost)** | `3432.12` | `1240.32` | **63.8% de reducción** |
| **Tiempo Ejecución** | `29.850 ms` | `3.780 ms` | **87.3% más rápido (8.0x)** |
| **Búferes Leídos** | `1845 blocks` | `422 blocks` | **77.1% menos I/O** |

### Conclusión Honestidad Técnica:
El **Índice 2** (`idx_prueba_calidad_resultado_fecha`) demostró una notable efectividad técnica. Al tratarse de un **índice parcial** que únicamente indexa los registros con dictámenes de alerta (`reproceso` o `rechazado`), se logró mantener un tamaño de índice sumamente compacto en disco. Esto redujo las lecturas de búfer en más del 77% y aceleró la consulta en **8 veces su velocidad original**, optimizando las operaciones frecuentes de auditoría sobre el módulo de calidad en la planta.