# 🐺 LXR Job Alerts

> **wolves.land — The Land of Wolves** | Developer: iBoss21 / The Lux Empire
>
> Website: [wolves.land](https://www.wolves.land) · Discord: [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A) · Store: [theluxempire.tebex.io](https://theluxempire.tebex.io)

---

A production-grade, job-based alert & ping system for RedM servers, fully compatible with multiple frameworks and ready for Tebex escrow.

## Features

1. **Commands** players can use to alert on-duty job members with a map blip.
2. **Pre-configured alerts** for Police (`/alertpolice`) and Doctor (`/alertdoctor`).
3. **Fully customisable** per alert:
   - Custom notification message
   - Target jobs & grade levels
   - Blip icon, hash, radius, and timing
4. **Multi-framework support** — configure once in `config.lua`.
5. **Add unlimited custom alerts** directly in `config.lua`.
6. **Public API export** — other resources can register alerts at runtime.

## Framework Support

| Framework   | Status    |
|-------------|-----------|
| LXR-Core    | ✅ Primary |
| RSG-Core    | ✅ Primary |
| VORP Core   | ✅ Supported |
| QBR-Core    | ✅ Optional |
| QR-Core     | ✅ Optional |
| Standalone  | ✅ Fallback |

Set your framework in `config.lua`:

```lua
Config.Framework = 'lxr-core'
-- Options: 'lxr-core' | 'rsg-core' | 'vorp_core' | 'qbr-core' | 'qr-core' | 'standalone'
```

## Installation

1. Download/clone this resource.
2. Place the `lxr-jobalerts` folder inside your `resources` directory.
3. Add `ensure lxr-jobalerts` to your `server.cfg`.
4. Set `Config.Framework` in `config.lua` to match your server.
5. Restart your server.

## Usage

### Police Alert
Type `/alertpolice` — all online players with the `police` or `sheriff` job (any grade) receive a notification and a map blip at your location.

### Doctor / Medic Alert
Type `/alertdoctor` — all online `medic` / `doctor` players are alerted.

### Banker Alert (example custom alert)
Type `/alertbanker` — all online `banker` players are alerted.

## Adding Custom Alerts

Open `config.lua` and add an entry to `Config.Alerts`:

```lua
{
    name       = 'myjob',
    command    = 'alertmyjob',
    message    = 'My Job Alert: Assistance Required!',
    originText = 'My job has been notified',
    jobs       = { 'myjob' },
    jobGrades  = {
        myjob = { 0, 1, 2, 3 },
    },
    icon     = 'star',
    blipHash = -1282792512,
},
```

## Runtime API (for other resources)

```lua
local AlertClass = exports['lxr-jobalerts']:RegisterAlert({
    name      = 'myalert',
    command   = 'alertmyjob',
    message   = 'Alert!',
    originText = 'Job notified',
    jobs      = { 'myjob' },
    jobGrades = { myjob = { 0, 1, 2, 3 } },
    icon      = 'star',
    blipHash  = -1282792512,
})

-- Manually fire the alert for a player source:
AlertClass:SendAlert(playerSource)
```

---

© 2026 iBoss21 / The Lux Empire | [wolves.land](https://www.wolves.land) | All Rights Reserved
