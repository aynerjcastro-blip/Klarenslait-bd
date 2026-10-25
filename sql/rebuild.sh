#!/usr/bin/env bash
# sql/rebuild.sh — borra y recrea la base de KlarensLait desde cero.
#
# Ejecuta en orden: sql/migrations/*.sql y luego sql/seeds/*.sql.
# La conexión sale de variables de entorno; no se guarda ninguna credencial en el repositorio:
#   PGUSER (obligatoria)   PGPASSWORD (opcional si usa ~/.pgpass)
#   PGHOST (def. localhost)  PGPORT (def. 5432)  KLARENS_DB (def. klarenslait)
#
# Uso:  ./sql/rebuild.sh [--yes] [--sin-volumen]
#   --yes          no pide confirmación antes de borrar la base
#   --sin-volumen  omite las semillas de volumen (archivos sql/seeds/9*.sql)
set -euo pipefail

SQL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB="${KLARENS_DB:-klarenslait}"
export PGHOST="${PGHOST:-localhost}"
export PGPORT="${PGPORT:-5432}"
export PGCLIENTENCODING=UTF8

YES=0
SIN_VOLUMEN=0
for arg in "$@"; do
    case "$arg" in
        --yes) YES=1 ;;
        --sin-volumen) SIN_VOLUMEN=1 ;;
        -h|--help) sed -n '2,13p' "${BASH_SOURCE[0]}"; exit 0 ;;
        *) echo "Opción desconocida: $arg" >&2; exit 2 ;;
    esac
done

fail() { echo "ERROR: $*" >&2; exit 1; }

command -v psql >/dev/null 2>&1 || fail "no se encuentra psql en el PATH."
: "${PGUSER:?Defina PGUSER (y PGPASSWORD o ~/.pgpass) antes de ejecutar este script.}"
[[ "$DB" =~ ^[a-z_][a-z0-9_]*$ ]] || fail "KLARENS_DB debe ir en minúscula, con letras, números y guion bajo."
case "$DB" in postgres|template0|template1) fail "no se permite recrear la base '$DB'." ;; esac

if [[ "$YES" -ne 1 ]]; then
    read -r -p "Se BORRARÁ y recreará la base '$DB' en $PGHOST:$PGPORT. ¿Continuar? [s/N] " resp
    [[ "$resp" =~ ^[sS]$ ]] || { echo "Cancelado."; exit 0; }
fi

echo "==> Recreando la base '$DB'"
psql -v ON_ERROR_STOP=1 -q -d postgres -c "DROP DATABASE IF EXISTS \"$DB\" WITH (FORCE)"
psql -v ON_ERROR_STOP=1 -q -d postgres -c "CREATE DATABASE \"$DB\""

run_dir() {
    local dir="$1" etiqueta="$2" omitir_volumen="$3" count=0 f
    if [[ ! -d "$dir" ]]; then
        echo "==> $etiqueta: no existe $dir, se omite."
        return 0
    fi
    echo "==> $etiqueta"
    while IFS= read -r f; do
        if [[ "$omitir_volumen" -eq 1 && "$(basename "$f")" == 9* ]]; then
            echo "    (omitido) $(basename "$f")"
            continue
        fi
        echo "    $(basename "$f")"
        psql -v ON_ERROR_STOP=1 -q -d "$DB" -f "$f"
        count=$((count + 1))
    done < <(find "$dir" -maxdepth 1 -type f -name '*.sql' | LC_ALL=C sort)
    echo "    $count archivo(s) aplicado(s)"
}

run_dir "$SQL_DIR/migrations" "Migraciones" 0
run_dir "$SQL_DIR/seeds" "Semillas" "$SIN_VOLUMEN"

echo "==> Resumen"
psql -d "$DB" -At -c "SELECT count(*) || ' tablas en el esquema public' FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE'"
echo "Listo: la base '$DB' quedó reconstruida desde cero."