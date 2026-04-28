# Chicken Assistant — Home Assistant Add-on Repository

This repository hosts Home Assistant add-ons for
[Chicken Assistant](https://github.com/chickenassistant/core), a local-first
chicken coop monitoring and automation platform.

## Installation

1. In Home Assistant, open **Settings → Add-ons → Add-on Store**.
2. Click the three-dot menu (top right) → **Repositories**.
3. Add this URL: `https://github.com/chickenassistant/ca-hass-addon`
4. Install **Chicken Assistant** from the add-on store that appears.

For staging/test Home Assistant instances, add this URL instead:
`https://github.com/chickenassistant/ca-hass-addon-staging`. The staging
channel installs as **Chicken Assistant (Staging)** and follows the
`ghcr.io/chickenassistant/chicken-assistant-addon-{arch}:staging` image tag.

## Add-ons

| Add-on              | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| Chicken Assistant   | Local-first chicken coop monitoring and automation.              |

---

Source code, issues, and pull requests:
<https://github.com/chickenassistant/core>.

This repository is automatically synced from
[`core/addon/`](https://github.com/chickenassistant/core/tree/main/addon) by
a GitHub Action. Changes pushed here directly will be overwritten — edit
upstream instead.
