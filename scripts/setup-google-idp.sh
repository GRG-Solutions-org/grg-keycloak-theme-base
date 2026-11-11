#!/usr/bin/env bash
# Registra Google como Identity Provider de un realm de Keycloak, para
# que el login tambien permita "Ingresar con Google" (pedido de
# Guille, 2026-11-11: "todo login debe permitir loguearse con correo
# gmail"). Pensado para ser copiado/incluido (no instalado como paquete
# -- Keycloak no tiene gestor de paquetes para esto) en el
# setup-keycloak.sh de cada app.
#
# Requiere un UNICO OAuth Client de Google Cloud Console compartido
# entre todas las apps GRG (se le agregan redirect URIs, una por cada
# realm, no hace falta un client por app) -- ver README.md de este
# repo para el paso a paso de como crearlo.
#
# Uso (desde el setup-keycloak.sh de la app, ya con $TOKEN y $KC_URL
# definidos igual que para el resto del script):
#
#   GOOGLE_CLIENT_ID="..." \
#   GOOGLE_CLIENT_SECRET="..." \
#   bash setup-google-idp.sh "$KC_URL" "$REALM" "$TOKEN"
#
# El redirect URI a autorizar en Google Cloud Console para este realm es:
#   $KC_URL/realms/$REALM/broker/google/endpoint

set -euo pipefail

KC_URL="$1"
REALM="$2"
TOKEN="$3"

if [ -z "${GOOGLE_CLIENT_ID:-}" ] || [ -z "${GOOGLE_CLIENT_SECRET:-}" ]; then
  echo "Faltan GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET como variables de entorno." >&2
  echo "Redirect URI a autorizar en Google Cloud Console:" >&2
  echo "  $KC_URL/realms/$REALM/broker/google/endpoint" >&2
  exit 1
fi

AUTH="Authorization: Bearer $TOKEN"

echo "Registrando Identity Provider 'google' en el realm '$REALM'..."
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$KC_URL/admin/realms/$REALM/identity-provider/instances" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d "{
    \"alias\": \"google\",
    \"providerId\": \"google\",
    \"enabled\": true,
    \"trustEmail\": true,
    \"config\": {
      \"clientId\": \"$GOOGLE_CLIENT_ID\",
      \"clientSecret\": \"$GOOGLE_CLIENT_SECRET\",
      \"defaultScope\": \"openid email profile\",
      \"useJwksUrl\": \"true\"
    }
  }"

echo "Listo. Redirect URI que debe estar autorizado en Google Cloud Console:"
echo "  $KC_URL/realms/$REALM/broker/google/endpoint"
echo ""
echo "AVISO: el boton 'Ingresar con Google' que arma Keycloak todavia no"
echo "se probo visualmente contra ningun realm real -- la primera vez"
echo "que se use, revisar el HTML real igual que se hizo con el resto"
echo "del tema (ver base.css, seccion #kc-social-providers)."
