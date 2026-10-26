#!/usr/bin/env bash
# Espera a que la API reporte en /actuator/info el commit indicado.
# Render construye la imagen Docker al recibir el deploy hook y tarda varios
# minutos; mientras tanto sigue respondiendo la versión anterior.
# Uso: ./scripts/wait-for-api.sh <url-api> <commit> [minutos-maximos]
set -euo pipefail

API_URL="${1:?Uso: wait-for-api.sh <url-api> <commit> [minutos-maximos]}"
EXPECTED_COMMIT="${2:?Uso: wait-for-api.sh <url-api> <commit> [minutos-maximos]}"
MAX_MINUTES="${3:-20}"
API_URL="${API_URL%/}"

echo "Esperando a que $API_URL publique el commit $EXPECTED_COMMIT (máximo $MAX_MINUTES min)..."
deadline=$(( $(date +%s) + MAX_MINUTES * 60 ))
deployed=""
while [ "$(date +%s)" -lt "$deadline" ]; do
  deployed=$(curl -fsS -m 60 "$API_URL/actuator/info" 2>/dev/null | sed -n 's/.*"commit":"\([^"]*\)".*/\1/p' || true)
  if [ "$deployed" = "$EXPECTED_COMMIT" ]; then
    echo "OK  API en el commit $deployed"
    exit 0
  fi
  echo "    versión actual: ${deployed:-sin respuesta}; reintento en 20 s"
  sleep 20
done

echo "FALLO: la API sigue en el commit '${deployed:-desconocido}' después de $MAX_MINUTES minutos" >&2
exit 1
