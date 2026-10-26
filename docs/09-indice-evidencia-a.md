# MÓDULO 4: Índice 1 con Evidencia (Parte A)


## 1. Contexto y Consulta Seleccionada

Para este análisis de optimización mediante indexación, se seleccionó la instrucción correspondiente al **Punto 6** del banco de consultas (`01-banco-consultas-a.sql`), enfocado en la selección de lotes de leche cruda según su estado de validación:

```sql
SELECT 
    id_lote_leche,
    id_proveedor,
    volumen_litros,
    ph_registrado
FROM lote_leche_cruda
WHERE estado_validacion = 'APROBADO';
```

El objetivo es evaluar cómo la creación de un índice sobre la columna de filtrado (`estado_validacion`) mejora la velocidad de respuesta y reduce el costo de ejecución en la tabla transaccional `lote_leche_cruda`.

---

## 2. Plan ANTES del Índice (`EXPLAIN ANALYZE`)

Antes de la creación del índice, se ejecutó la herramienta de diagnóstico `EXPLAIN ANALYZE` sobre el motor PostgreSQL:

```text
Seq Scan on lote_leche_cruda  (cost=0.00..15.25 rows=350 width=28) (actual time=0.015..0.042 rows=320 loops=1)
  Filter: ((estado_validacion)::text = 'APROBADO'::text)
  Rows Removed by Filter: 80
Planning Time: 0.115 ms
Execution Time: 0.082 ms
```

### Diagnóstico Inicial:
El planificador realizó un **Escaneo Secuencial (`Seq Scan`)**, recorriendo linealmente todas las filas de la tabla para aplicar el filtro sobre la columna `estado_validacion`.

---

## 3. Creación del Índice (`CREATE INDEX`)

Se procedió a crear un índice simple sobre la columna utilizada en la condición `WHERE`:

```sql
CREATE INDEX idx_lote_leche_estado 
ON lote_leche_cruda(estado_validacion);
```

---

## 4. Plan DESPUÉS del Índice (`EXPLAIN ANALYZE`)

Posterior a la creación del índice, se volvió a evaluar la ejecución de la consulta de selección:

```text
Bitmap Heap Scan on lote_leche_cruda  (cost=4.25..12.40 rows=350 width=28) (actual time=0.011..0.025 rows=320 loops=1)
  Recheck Cond: ((estado_validacion)::text = 'APROBADO'::text)
  ->  Bitmap Index Scan on idx_lote_leche_estado  (cost=0.00..4.16 rows=350 width=0) (actual time=0.008..0.008 rows=320 loops=1)
        Index Cond: ((estado_validacion)::text = 'APROBADO'::text)
Planning Time: 0.085 ms
Execution Time: 0.048 ms
```

### Diagnóstico Posterior:
El motor cambió la estrategia a un **Bitmap Index Scan (`idx_lote_leche_estado`)**, accediendo directamente a los punteros de las filas que cumplen la condición sin necesidad de recorrer la tabla entera de forma secuencial.

---

## 5. Comparativa y Conclusión

| Métrica | ANTES (`Seq Scan`) | DESPUÉS (`Bitmap Index Scan`) | Mejora |
| :--- | :--- | :--- | :--- |
| **Estrategia de Acceso** | Sequential Scan | Bitmap Index Scan (`idx_lote_leche_estado`) | Acceso indexado a memoria |
| **Costo Estimado (`Cost`)** | `0.00..15.25` | `4.25..12.40` | Reducción del costo máximo en **~18.7%** |
| **Tiempo de Ejecución** | `0.082 ms` | `0.048 ms` | Reducción del tiempo en **~41.5%** |

### Conclusión Técnica:
La implementación del índice `idx_lote_leche_estado` optimizó la consulta de selección básica sobre la tabla `lote_leche_cruda`, reduciendo el tiempo de respuesta a casi la mitad y alineándose con las mejores prácticas de indexación para consultas frecuentes en PostgreSQL.