#!/usr/bin/env bash
# Pruebas de humo de un ambiente desplegado.
# Uso: ./scripts/smoke-test.sh <url-app> <url-api>
set -euo pipefail

APP_URL="${1:?Uso: smoke-test.sh <url-app> <url-api>}"
API_URL="${2:?Uso: smoke-test.sh <url-app> <url-api>}"
APP_URL="${APP_URL%/}"
API_URL="${API_URL%/}"

fail() { echo "FALLO: $*" >&2; exit 1; }

health=$(curl -fsS -m 90 "$API_URL/actuator/health") || fail "no responde $API_URL/actuator/health"
echo "$health" | grep -q '"status":"UP"' || fail "health no está UP: $health"
echo "OK  API health UP"

summary=$(curl -fsS -m 60 "$API_URL/api/dashboard/summary") || fail "no responde $API_URL/api/dashboard/summary"
echo "$summary" | grep -q '"precipitationTotalMm"' || fail "respuesta inesperada del resumen: $summary"
echo "OK  API consulta la base de datos"

curl -fsS -m 30 -o /dev/null "$APP_URL/" || fail "no responde $APP_URL"
bundle=$(curl -fsS -m 30 "$APP_URL/" | grep -o 'assets/index-[^"]*\.js' | head -n 1)
[ -n "$bundle" ] || fail "no se encontró el bundle JavaScript en $APP_URL"
curl -fsS -m 30 "$APP_URL/$bundle" | grep -qF "$API_URL" || fail "el frontend no apunta a $API_URL"
echo "OK  frontend publicado y apuntando a su API"

cors=$(curl -fsS -m 60 -o /dev/null -D - -H "Origin: $APP_URL" "$API_URL/api/dashboard/summary" | tr -d '\r' | grep -i '^access-control-allow-origin:' || true)
echo "$cors" | grep -qiF "$APP_URL" || fail "CORS de la API no permite $APP_URL"
echo "OK  CORS permite el frontend del ambiente"

echo "Pruebas de humo superadas para $APP_URL"
