<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# lxr-dispatch — The wire between the town and its trades, for LXRCore

Anything can raise a call — a picked lock, shots in the street, a citizen at
the telegraph, a doctor needed — and the server hands it to the people on
duty for that kind of call: a card on their screen, a blip on their map, a
route when they take it. Calls expire, responders are tracked, and every
call is an event other resources can hear.

![The call stack](docs/img/calls.png)

## What it does

* **Kinds** — `Config.Kinds`: who hears it (job types from the core
  registry, explicit jobs, off duty or not), ten-code, priority, time to
  live, blip (sprite, colour, optional radius), sound.
* **Raise** — `exports['lxr-dispatch']:Raise({ kind, coords, title, message,
  src, meta })` or the server-only event `lxr-dispatch:server:raise`. Clients
  can never raise a call directly.
* **Automatic** — `lxr:doors:picked` becomes a break-in; shots fired inside
  a town (`Config.Auto.towns`) become `10-71` with a per-player cooldown;
  lawmen on duty are exempt.
* **Citizens** — `/law <message>` and `/doctor <message>` wire a call from
  where the player stands, with a cooldown.
* **Cards** — a kit stack (`/calls` toggles it): code, label, town, age,
  title, message, responders; Route / Respond / close; one key responds to
  the newest call.
* **Sync** — late joiners and duty changes receive the open calls they may hear.
* **Events** — `lxr:dispatch:raised (call, hearers)`, `responded (id, src)`,
  `cleared (id, reason)`.

## Install

```cfg
ensure lxr-core
ensure lxr-nui
ensure lxr-dispatch
```

## Configuration

`config.lua` — `Config.Lang`, `Config.Kinds`, `Config.Auto` (doors, shots,
towns), `Config.Citizen`, `Config.Screen`, `Config.Security`.

## API

| Name | Side | Purpose |
|---|---|---|
| `Raise(spec)` · `Clear(id, reason)` · `Open()` | server | raise, close, list |
| `lxr-dispatch:server:raise` (spec) | server | the same as an event |
| `Open()` · `Respond(id)` | client | the local stack |

## Licence

© 2026 iBoss21 / LXRCore — All Rights Reserved. See `LICENSE`.
