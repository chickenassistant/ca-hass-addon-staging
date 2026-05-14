# Chicken Assistant

Local-first chicken coop monitoring and automation, packaged as a Home
Assistant add-on. Uses the same core image as the standalone Docker Compose
deployment — only the entrypoint differs.

## Recommended Setup

This add-on assumes your HA install already has the infrastructure:

- **MQTT broker** — recommended for Zigbee2MQTT, Frigate, and MQTT device ingestion. The easiest path is the official
  **Mosquitto broker** add-on; this add-on will auto-discover its host and
  credentials via Supervisor. Any external broker also works (configure
  manually via the options below). ZHA-only setups can run without MQTT.
- **Zigbee** — optional, via either path:
  - **Zigbee2MQTT** — publishes to MQTT; picked up automatically.
  - **ZHA** (Home Assistant native) — no MQTT layer. Map the relevant
    Home Assistant entities from the Chicken Assistant settings UI, or seed
    startup mappings under `ha_entities`.
- **Z-Wave / cameras** — configure through their existing HA integrations
  or add-ons; Chicken Assistant consumes the Home Assistant entities or MQTT
  topics they publish.

This add-on does **not** bundle a broker, Zigbee coordinator, or NVR. The
standalone Docker Compose deployment (`docker compose --profile bundled-mqtt`)
is the right choice if you want a self-contained stack without Home
Assistant.

## Configuration

Most users can leave admin credentials blank and create the first admin in
the Web UI. MQTT is auto-discovered when the Mosquitto add-on is running.
The add-on UI shows whether MQTT came from Supervisor discovery, manual
override options, or is unavailable.

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
sensors, integrations, etc.), open Chicken Assistant and go to
**Settings → Home Assistant → Add mapping**. The entity picker suggests a
Chicken Assistant device ID, sensor type, and unit from the selected entity.

You can also seed mappings from add-on options with `ha_entities`. Each entry
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
  - entity_id: binary_sensor.coop_door_contact
    device_id: coop_door
    sensor_type: door_state
```

Numeric states are recorded directly. Common binary/text states are converted
to `1` or `0`, including `on`/`off`, `open`/`closed`,
`detected`/`clear`, and `wet`/`dry`. `unknown` and `unavailable` states are
skipped. Polling starts automatically when at least one mapping is present.

## Onboarding

On first run, Chicken Assistant opens an onboarding checklist that adapts to
Home Assistant add-on mode:

- Create the first Chicken Assistant admin account.
- Connect a data source through Home Assistant-managed ZHA, Zigbee2MQTT,
  Z-Wave JS, or MQTT devices.
- Map useful Home Assistant entities into Chicken Assistant readings.
- Assign device roles, add cameras, and create automations.

In add-on mode, Zigbee2MQTT and Z-Wave JS lifecycle stays with Home
Assistant add-ons/integrations. Chicken Assistant consumes their MQTT topics
or mapped Home Assistant entities rather than trying to start Docker Compose
services.

## Remote Access

For Home Assistant users, remote access should normally go through Home
Assistant Ingress. If Home Assistant Cloud / Nabu Casa remote access is
enabled, open Home Assistant remotely and select Chicken Assistant from the
sidebar. Chicken Assistant does not need its own public port for that path.

The direct web port (`8080`) remains available for local-network access. When
using the direct port, Chicken Assistant's own login still protects the app.
Through Ingress, Home Assistant authenticates access to the add-on panel and
Chicken Assistant also keeps its local app-level users.

## Push Notifications

Browser push subscriptions are available from the Chicken Assistant settings
UI. Behavior can vary by browser and by whether the app is opened through
Ingress, a direct local URL, or a mobile browser. Home Assistant-native mobile
notifications are a future integration path.

## Data persistence

State (SQLite database, generated session secret) lives under `/data`, which
Home Assistant preserves across add-on upgrades and reboots.

## Accessing the UI

Once started, open the add-on's Web UI from the Home Assistant sidebar, or
visit `http://<ha-host>:8080/`.
