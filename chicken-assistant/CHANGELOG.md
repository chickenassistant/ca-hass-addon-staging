# Changelog

## Unreleased

- Detects Home Assistant add-on mode so onboarding, integrations, remote
  access, and system status copy use Home Assistant-native guidance.
- Adds Supervisor-aware service status rendering when Supervisor API access is
  available.
- Records binary Home Assistant entity states such as `on`, `off`, `open`,
  `closed`, `wet`, and `dry` as `1`/`0` readings for automations.
- Adds translated add-on option labels and descriptions for the Home Assistant
  configuration UI.

## 0.1.1

- Adds support for the in-app first-run setup flow when `admin_password` is
  left blank.
- Treats MQTT as recommended rather than mandatory so ZHA-only Home Assistant
  setups can start without a broker.
- Improves startup logs for admin bootstrap, MQTT discovery, and HA entity
  polling.

## 0.1.0

- Initial release as a Home Assistant add-on.
- Wraps `ghcr.io/chickenassistant/core` with a Supervisor-aware entrypoint
  that translates user options into env vars and persists state under `/data`.
- Requires an MQTT broker (`services: [mqtt:need]`). Credentials are
  discovered automatically when the HA Mosquitto add-on is installed;
  individual `mqtt_*` options override discovery.
- Requests `homeassistant_api: true` so the add-on can poll HA entity
  states directly (ZHA integration).
- New `ha_entities` option maps HA entities (ZHA sensors, template
  sensors, etc.) onto Chicken Assistant sensor readings; `ha_poll_interval`
  controls the cadence. The polling pipeline reuses the same persistence
  layer as the MQTT ingestion path.
- Auto-generates `SESSION_SECRET` on first run when unset.
