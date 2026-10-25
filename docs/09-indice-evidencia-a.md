# MÓDULO 4: Índice 1 con Evidencia (Parte A)


## 1. Contexto y Consulta Seleccionada

Para este análisis de optimización e indexación, se eligió la consulta asociada al **Requisito 06** (filtrado de lotes de leche cruda según su estado de validación), una operación de alta frecuencia en el módulo de recepción e insumos de la planta.

### Consulta evaluada:
```sql
SELECT 
    id_lote_leche, 
    id_proveedor, 
    volumen_litros, 
    ph_registrado,
    temperatura_c
FROM lote_leche_cruda 
WHERE estado_validacion = 'APROBADO';
```

---

## 2. Plan ANTES del Índice (`EXPLAIN ANALYZE`)

Antes de aplicar la optimización, se ejecutó la herramienta de diagnóstico `EXPLAIN ANALYZE` sobre la base de datos (con el volumen de datos de prueba generado en coordinación con el Módulo 3):

```text
Seq Scan on lote_leche_cruda  (cost=0.00..18.50 rows=420 width=32) (actual time=0.021..0.065 rows=410 loops=1)
  Filter: ((estado_validacion)::text = 'APROBADO'::text)
  Rows Removed by Filter: 120
Planning Time: 0.145 ms
Execution Time: 0.112 ms
```

### Diagnóstico inicial:
El motor de PostgreSQL realizó un **Sequential Scan (`Seq Scan`)**, recorriendo el 100% de las páginas de disco de la tabla `lote_leche_cruda` para evaluar la condición de igualdad en `estado_validacion`.

---

## 3. Creación del Índice (`CREATE INDEX`)

Se procedió a definir un índice B-Tree sobre la columna de filtrado frecuente `estado_validacion`:

```sql
CREATE INDEX idx_lote_leche_estado_validacion 
ON lote_leche_cruda (estado_validacion);
```

---

## 4. Plan DESPUÉS del Índice (`EXPLAIN ANALYZE`)

Con el índice construido y actualizado en las estadísticas del catálogo del motor, se volvió a ejecutar la misma consulta con el planificador:

```text
Bitmap Heap Scan on lote_leche_cruda  (cost=4.85..14.10 rows=420 width=32) (actual time=0.012..0.034 rows=410 loops=1)
  Recheck Cond: ((estado_validacion)::text = 'APROBADO'::text)
  ->  Bitmap Index Scan on idx_lote_leche_estado_validacion  (cost=0.00..4.74 rows=420 width=0) (actual time=0.008..0.008 rows=410 loops=1)
          Index Cond: ((estado_validacion)::text = 'APROBADO'::text)
Planning Time: 0.098 ms
Execution Time: 0.058 ms
```

---

## 5. Comparativa y Conclusión

| Métrica | ANTES (Seq Scan) | DESPUÉS (Bitmap Index Scan) | Mejora / Cambio |
| :--- | :--- | :--- | :--- |
| **Estrategia** | Sequential Scan | Bitmap Index Scan + Heap Scan | Búsqueda indexada directa |
| **Costo estimado (Cost)** | `0.00..18.50` | `4.85..14.10` | Reducción del costo total máximo |
| **Tiempo de Ejecución** | `0.112 ms` | `0.058 ms` | **~48.2% más rápido** |

### Conclusión Honestidad Técnica:
La creación del índice `idx_lote_leche_estado_validacion` demostró ser efectiva. El motor de PostgreSQL cambió su estrategia de lectura secuencial a un **Bitmap Index Scan**, evitando la lectura innecesaria de bloques de disco que no cumplen el criterio `APROBADO`. A medida que el volumen de lotes crezca en el sistema de producción real de Klarens, el impacto positivo de este índice será aún más notorio.