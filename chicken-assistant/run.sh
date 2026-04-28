#!/bin/sh
# Home Assistant add-on entrypoint.
#
# Reads user options from /data/options.json, queries the Supervisor API for
# MQTT credentials, then execs the core server. Persistent state lives under
# /data so it survives add-on upgrades.
set -eu

OPT=/data/options.json

opt() {
  # opt <key> <default_json>  -> prints the value from options.json or default.
  jq -r --argjson d "$2" ".${1} // \$d | if type == \"string\" then . else tostring end" "$OPT"
}

# ── Core options ──────────────────────────────────────────────────────────
export ADMIN_USERNAME="$(opt admin_username '"admin"')"
export ADMIN_PASSWORD="$(opt admin_password '""')"

# HA persists add-on state under /data.
export DATA_DIR=/data
export DATABASE_PATH=/data/chickenassistant.db

if [ ! -s "$DATABASE_PATH" ] && [ -z "$ADMIN_PASSWORD" ]; then
  echo "addon: no admin_password set; first-run setup will create the initial admin account in the web UI." >&2
fi

# ── SESSION_SECRET ───────────────────────────────────────────────────────
# User-supplied (≥32 chars) wins; otherwise reuse or generate+persist one.
SESSION_SECRET_IN="$(opt session_secret '""')"
if [ "${#SESSION_SECRET_IN}" -ge 32 ]; then
  export SESSION_SECRET="$SESSION_SECRET_IN"
elif [ -s /data/.session_secret ]; then
  export SESSION_SECRET="$(cat /data/.session_secret)"
else
  head -c 36 /dev/urandom | base64 | tr -d '=+/\n' | head -c 48 > /data/.session_secret
  chmod 600 /data/.session_secret
  export SESSION_SECRET="$(cat /data/.session_secret)"
fi

# ── MQTT: Supervisor discovery, then user overrides ──────────────────────
MQTT_HOST=""
MQTT_PORT=""
MQTT_USERNAME=""
MQTT_PASSWORD=""

if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
  resp="$(curl -sS --max-time 5 \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    http://supervisor/services/mqtt 2>/dev/null || true)"
  if [ -n "$resp" ] && [ "$(echo "$resp" | jq -r '.result // ""')" = "ok" ]; then
    MQTT_HOST="$(echo "$resp" | jq -r '.data.host // ""')"
    MQTT_PORT="$(echo "$resp" | jq -r '.data.port // ""')"
    MQTT_USERNAME="$(echo "$resp" | jq -r '.data.username // ""')"
    MQTT_PASSWORD="$(echo "$resp" | jq -r '.data.password // ""')"
    echo "addon: MQTT discovered via Supervisor (${MQTT_HOST}:${MQTT_PORT})"
  fi
fi

# Any explicitly-set option overrides discovery.
override_host="$(opt mqtt_host '""')"
override_port="$(opt mqtt_port '0')"
override_user="$(opt mqtt_username '""')"
override_pass="$(opt mqtt_password '""')"

[ -n "$override_host" ]     && MQTT_HOST="$override_host"
[ "$override_port" != "0" ] && MQTT_PORT="$override_port"
[ -n "$override_user" ]     && MQTT_USERNAME="$override_user"
[ -n "$override_pass" ]     && MQTT_PASSWORD="$override_pass"

if [ -z "$MQTT_HOST" ]; then
  echo "addon: no MQTT broker found — Z2M device discovery disabled. Install Mosquitto or set mqtt_host to enable." >&2
fi
: "${MQTT_PORT:=1883}"

export MQTT_HOST MQTT_PORT MQTT_USERNAME MQTT_PASSWORD

# ── Home Assistant native ingestion (for ZHA etc.) ───────────────────────
# Empty ha_entities skips the poller entirely; homeassistant_api: true in
# config.yaml grants the token we pass here.
export HA_URL="http://supervisor/core/api"
export HA_TOKEN="${SUPERVISOR_TOKEN:-}"
export HA_POLL_INTERVAL="$(opt ha_poll_interval '30')"
export HA_ENTITIES="$(jq -c '.ha_entities // []' "$OPT")"
if [ "$HA_ENTITIES" != "[]" ]; then
  echo "addon: Home Assistant entity polling enabled (${HA_POLL_INTERVAL}s interval)"
fi

cd /app
exec ./server
