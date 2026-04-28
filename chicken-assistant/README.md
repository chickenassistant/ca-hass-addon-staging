# Chicken Assistant

Local-first chicken coop monitoring and automation, packaged as a Home
Assistant add-on. Uses the same core image as the standalone Docker Compose
deployment — only the entrypoint differs.

## Requirements

This add-on assumes your HA install already has the infrastructure:

- **MQTT broker** — recommended for Zigbee2MQTT and Frigate ingestion. The easiest path is the official
  **Mosquitto broker** add-on; this add-on will auto-discover its host and
  credentials via Supervisor. Any external broker also works (configure
  manually via the options below). ZHA-only setups can run without MQTT.
- **Zigbee** — optional, via either path:
  - **Zigbee2MQTT** — publishes to MQTT; picked up automatically.
  - **ZHA** (Home Assistant native) — no MQTT layer. List the relevant
    entity IDs under `ha_entities` (see below); the add-on polls them
    through HA's REST API and stores them alongside MQTT-sourced data.
- **Z-Wave / cameras** — configure through their existing HA integrations
  or add-ons; Chicken Assistant consumes the MQTT topics they publish.

This add-on does **not** bundle a broker, Zigbee coordinator, or NVR. The
standalone Docker Compose deployment (`docker compose --profile bundled-mqtt`)
is the right choice if you want a self-contained stack without Home
Assistant.

## Configuration

Most users can leave admin credentials blank and create the first admin in
the Web UI. MQTT is auto-discovered when the Mosquitto add-on is running.

| Option            | Default        | Notes                                                 |
| ----------------- | -------------- | ----------------------------------------------------- |
| `session_secret`  | auto-generated | Leave blank to auto-generate a persistent secret.     |
| `admin_username`  | `admin`        | First-run admin account only.                         |
| `admin_password`  | _(empty)_      | Optional bootstrap password. Blank = create the first admin in the Web UI. |
| `mqtt_host`       | _(empty)_      | Blank = use Supervisor discovery (Mosquitto add-on).  |
| `mqtt_port`       | `0`            | `0` = use discovered port.                            |
| `mqtt_username`   | _(empty)_      |                                                       |
| `mqtt_password`   | _(empty)_      |                                                       |

Any non-empty MQTT option overrides Supervisor discovery, so you can point
the add-on at an external broker by filling in `mqtt_host` (and credentials
if needed). If no MQTT broker is found, the add-on still starts; MQTT-backed
device discovery remains disabled until a broker is configured.

## ZHA / native HA sensors

To ingest sensors that live in Home Assistant (ZHA entities, template
sensors, integrations, etc.), add entries to `ha_entities`. Each entry
describes how one HA entity maps to a Chicken Assistant sensor reading:

```yaml
ha_poll_interval: 30    # seconds between polls; 5–3600 allowed
ha_entities:
  - entity_id: sensor.coop_temperature
    device_id: coop_env_sensor
    sensor_type: temperature
    unit: "°C"          # optional — falls back to entity's unit_of_measurement
  - entity_id: sensor.nest_humidity
    device_id: nest_box_sensor
    sensor_type: humidity
```

Only numeric states are recorded. `unknown` / `unavailable` / non-numeric
states (e.g. binary sensors) are skipped. Polling starts automatically
when at least one mapping is present.

## Data persistence

State (SQLite database, generated session secret) lives under `/data`, which
Home Assistant preserves across add-on upgrades and reboots.

## Accessing the UI

Once started, open the add-on's Web UI from the Home Assistant sidebar, or
visit `http://<ha-host>:8080/`.
