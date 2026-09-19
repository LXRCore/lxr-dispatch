# Changelog

## 3.0.1 — 2026-09-19
* Route to a call draws a GPS route on the map (`START_GPS_MULTI_ROUTE`), cleared within 25 m of the call or when it is closed — `SetNewWaypoint` is GTA V only and was a nil call.

## 3.0.0 — 2026-09-18

Rebuilt on the LXRCore v3 native API (repository renamed from lxr-jobalerts). Nothing of the earlier build remains.

* Kinds of call with job-type routing, ten-codes, priorities, expiry, blips and radius
* Automatic calls from lxr-doors and shots in town; citizen wires /law and /doctor
* Card stack on the LXR UI Kit with route / respond / close, responders tracked, sync on duty change
* Locales EN / KA, offline tests
