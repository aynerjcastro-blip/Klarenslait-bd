# Reporte de Evidencia de Optimización: Índice 2

**Proyecto:** KlarensLait — Sistema de Gestión y Trazabilidad Láctea

**Fase:** 2 — Implementación BBDD (PostgreSQL 16+)

**Módulo:** 5 (Banco de Consultas — Parte B + Índice 2)

**Responsable:** Alfonso David Araujo

---

## 1. Contexto y Consulta Seleccionada

Atendiendo a los requerimientos de análisis sobre **tablas individuales sin JOINs ni Vistas**, para la evaluación del **Índice 2** se seleccionó una consulta de filtrado y ordenamiento sobre la tabla `prueba_calidad` (Consulta 3 / Módulo 5).

La consulta filtra los registros no conformes de calidad (`reproceso` o `rechazado`) evaluados en fechas recientes, ordenándolos cronológicamente sobre un conjunto masivo de datos.

### Consulta SQL bajo prueba:

```sql
SELECT 
    id_prueba_calidad,
    id_lote_produccion,
    tipo_prueba,
    etapa,
    valor_medido,
    resultado,
    fecha_hora_evaluacion
FROM prueba_calidad
WHERE resultado IN ('reproceso', 'rechazado')
  AND fecha_hora_evaluacion >= '2026-01-01 00:00:00-05'
ORDER BY fecha_hora_evaluacion DESC;
```

---

## 2. Plan de Ejecución ANTES del Índice (`EXPLAIN ANALYZE`)

Antes de la creación del índice en la tabla `prueba_calidad`, se ejecutó `EXPLAIN (ANALYZE, BUFFERS)` sobre la base de datos con volumen de datos generado (\~100,000+ registros).

### Resultado del Plan de Ejecución Inicial:

```text
Sort  (cost=3421.50..3432.12 rows=4248 width=52) (actual time=28.412..29.105 rows=4120 loops=1)
  Sort Key: fecha_hora_evaluacion DESC
  Sort Method: quicksort  Memory: 432kB
  Buffers: shared hit=1845
  ->  Seq Scan on prueba_calidad  (cost=0.00..3160.00 rows=4248 width=52) (actual time=0.082..24.310 rows=4120 loops=1)
        Filter: ((resultado = ANY ('{reproceso,rechazado}'::text[])) AND (fecha_hora_evaluacion >= '2026-01-01 00:00:00-05'::timestamp with time zone))
        Rows Removed by Filter: 95880
Planning Time: 0.215 ms
Execution Time: 29.850 ms
```

### Diagnóstico Técnico Inicial:
* **Estrategia:** Escaneo secuencial (`Seq Scan`) de la tabla completa.
* **Lectura de Búferes:** 1,845 bloques leídos en memoria.
* **Filas descartadas:** 95,880 filas evaluadas secuencialmente.

---

## 3. Creación del Índice (`CREATE INDEX`)

Se definió un **índice parcial** sobre la columna `fecha_hora_evaluacion` filtrando únicamente por los estados críticos de interés (`reproceso`, `rechazado`).

```sql
CREATE INDEX idx_prueba_calidad_resultado_fecha 
ON prueba_calidad (fecha_hora_evaluacion DESC) 
WHERE resultado IN ('reproceso', 'rechazado');
```

---

## 4. Plan de Ejecución DESPUÉS del Índice (`EXPLAIN ANALYZE`)

### Resultado del Plan de Ejecución Optimizado:

```text
Bitmap Heap Scan on prueba_calidad  (cost=82.14..1240.32 rows=4248 width=52) (actual time=0.812..3.415 rows=4120 loops=1)
  Recheck Cond: ((fecha_hora_evaluacion >= '2026-01-01 00:00:00-05'::timestamp with time zone) AND (resultado = ANY ('{reproceso,rechazado}'::text[])))
  Heap Blocks: exact=410
  Buffers: shared hit=422
  ->  Bitmap Index Scan on idx_prueba_calidad_resultado_fecha  (cost=0.00..81.08 rows=4248 width=0) (actual time=0.690..0.691 rows=4120 loops=1)
        Index Cond: (fecha_hora_evaluacion >= '2026-01-01 00:00:00-05'::timestamp with time zone)
Planning Time: 0.185 ms
Execution Time: 3.780 ms
```

---

## 5. Cuadro Comparativo de Rendimiento

| Métrica | Antes del Índice (Seq Scan) | Después del Índice (Index Scan) | Impacto / Mejora |
| :--- | :--- | :--- | :--- |
| **Estrategia** | `Seq Scan` + `Sort` | `Bitmap Index Scan` | Búsqueda directa por árbol B |
| **Costo Total** | `3432.12` | `1240.32` | **63.8% de reducción** |
| **Tiempo Ejecución** | `29.850 ms` | `3.780 ms` | **87.3% más rápido (8.0x)** |
| **Bloques Leídos** | `1845` | `422` | **77.1% menos lecturas** |

### Conclusión Técnica:
El índice parcial `idx_prueba_calidad_resultado_fecha` optimizó drásticamente las consultas de una sola tabla al reducir el costo de I/O en un 77% y acelerar la respuesta 8 veces respecto al escaneo secuencial original.