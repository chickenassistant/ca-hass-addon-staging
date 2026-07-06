# Homestead Hub — Home Assistant Add-on Repository

This repository hosts Home Assistant add-ons for
[Homestead Hub](https://github.com/homestead-assistant/hub), a local-first
homestead monitoring and automation platform (chickens, garden, pond).

## Installation

1. In Home Assistant, open **Settings → Add-ons → Add-on Store**.
2. Click the three-dot menu (top right) → **Repositories**.
3. Add this URL: `https://github.com/homestead-assistant/ha-addon`
4. Install **Homestead Hub** from the add-on store that appears.

For staging/test Home Assistant instances, add this URL instead:
`https://github.com/homestead-assistant/ha-addon-staging`. The staging
channel installs as **Homestead Hub (Staging)** and follows the
`ghcr.io/homestead-assistant/hub-addon-{arch}:staging` image tag.

## Add-ons

| Add-on              | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| Homestead Hub       | Local-first homestead monitoring and automation (CA/GA/PA).      |

---

Source code, issues, and pull requests:
<https://github.com/homestead-assistant/hub>.

This repository is automatically synced from
[`hub/addon/`](https://github.com/homestead-assistant/hub/tree/main/addon) by
a GitHub Action. Changes pushed here directly will be overwritten — edit
upstream instead.
