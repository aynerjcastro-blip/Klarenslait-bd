# Reporte de Rendimiento y Análisis de Ejecución: Consulta Módulo 5

**Proyecto:** KlarensLait — Sistema de Gestión y Trazabilidad Láctea

**Fase:** 2 — Implementación BBDD (PostgreSQL 16+)

**Módulo:** 5 (Banco de Consultas — Parte B)

**Responsable:** Alfonso David Araujo

---
## 1. Contexto y Consulta Seleccionada

Atendiendo a las indicaciones de análisis sobre **tablas individuales sin JOINs ni Vistas**, para la evaluación del rendimiento de consultas del Módulo 5 se seleccionó la consulta de filtrado y ordenamiento sobre la tabla `prueba_calidad`.

La consulta filtra los registros no conformes de calidad (`reproceso` o `rechazado`) evaluados en fechas recientes, ordenándolos cronológicamente sobre el conjunto de datos de la tabla.

### Consulta SQL evaluada:
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

## 2. Plan de Ejecución (`EXPLAIN ANALYZE`)

Para evaluar la eficiencia del motor de búsqueda de PostgreSQL 16+ sobre la tabla `prueba_calidad`, se ejecutó el comando `EXPLAIN (ANALYZE, BUFFERS)` considerando un volumen masivo de registros en la base de datos (~100,000+ filas).

### Resultado del Plan de Ejecución:

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
---

## 3. Diagnóstico Técnico del Análisis

A partir de los resultados obtenidos por el planificador de consultas de PostgreSQL, se destacan los siguientes puntos de rendimiento:

- **Estrategia de Búsqueda:** El motor realiza un escaneo secuencial completo (`Seq Scan`) recorriendo la totalidad de las páginas de disco/memoria asignadas a la tabla `prueba_calidad`.
- **Carga de Trabajo e I/O:** Se leyeron 1,845 bloques en búfer de memoria (`shared hit=1845`) para procesar las 100,000+ filas existentes.
- **Eficiencia del Filtro:** El motor descartó un total de 95,880 filas (`Rows Removed by Filter`), reteniendo únicamente las 4,120 filas que cumplían con las condiciones lógicas de estado y fecha.
- **Método de Ordenamiento:** La ordenación resultante (`ORDER BY fecha_hora_evaluacion DESC`) se resolvió en memoria utilizando el algoritmo `quicksort` con un consumo de 432 kB de memoria RAM.
- **Tiempo Total de Ejecución:** El tiempo total desde la planificación hasta la entrega del resultado fue de **29.85 ms**, mostrando un comportamiento óptimo para la lectura secuencial de la tabla individual.