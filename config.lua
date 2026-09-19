--[[
    ██╗     ██╗  ██╗██████╗       ██████╗ ██╗███████╗██████╗  █████╗ ████████╗ ██████╗██╗  ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██║██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██║  ██║██║███████╗██████╔╝███████║   ██║   ██║     ███████║
    ██║      ██╔██╗ ██╔══██╗╚════╝██║  ██║██║╚════██║██╔═══╝ ██╔══██║   ██║   ██║     ██╔══██║
    ███████╗██╔╝ ██╗██║  ██║      ██████╔╝██║███████║██║     ██║  ██║   ██║   ╚██████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═════╝ ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝

    LXR Core - Dispatch

    The wire between the town and its trades. Anything can raise a call —
    a picked lock, shots in the street, a citizen at a telegraph, a doctor
    needed — and the server hands it to the people on duty for that kind of
    call: a card on their screen, a blip on their map, a route when they
    take it. Calls expire, responders are tracked, and every call is an
    event other resources can hear.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/GAhk8cgXe9
    GitHub:      https://github.com/LXRCore

    Version: 3.0.0
    Performance Target: 0.00 ms idle (event-driven; one 1 s expiry tick on the server)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ KINDS OF CALL ═════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
-- jobTypes / jobs: who hears it (job types from the core registry: leo, federal, medical …)
-- offDuty: also reach those off duty · ttl: seconds the call stays open · priority 1 (highest) – 3
-- blip: sprite name + colour modifier · sound: frontend sound on arrival · code: the ten-code shown
Config.Kinds = {
    shots     = { label = 'Shots fired',       code = '10-71', jobTypes = { 'leo', 'federal' }, priority = 2, ttl = 240, blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_1', radius = 60.0 }, sound = 'Attack_Alert' },
    breakin   = { label = 'Break-in',          code = '10-62', jobTypes = { 'leo', 'federal' }, priority = 2, ttl = 300, blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_1' }, sound = 'Attack_Alert' },
    robbery   = { label = 'Robbery',           code = '10-90', jobTypes = { 'leo', 'federal' }, priority = 1, ttl = 420, blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_1' }, sound = 'Attack_Alert' },
    assault   = { label = 'Assault',           code = '10-31', jobTypes = { 'leo', 'federal' }, priority = 2, ttl = 240, blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_1' } },
    lawcall   = { label = 'Call for the law',  code = '10-16', jobTypes = { 'leo', 'federal' }, priority = 3, ttl = 300, blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_4' }, citizen = true },
    wounded   = { label = 'Wounded',           code = '10-52', jobTypes = { 'medical' }, priority = 1, ttl = 420, blip = { sprite = 'blip_ambient_doctor', colour = 'BLIP_MODIFIER_MP_COLOR_1' }, sound = 'Attack_Alert' },
    doctorcall = { label = 'Call for a doctor', code = '10-52', jobTypes = { 'medical' }, priority = 2, ttl = 300, blip = { sprite = 'blip_ambient_doctor', colour = 'BLIP_MODIFIER_MP_COLOR_4' }, citizen = true },
    backup    = { label = 'Officer needs help', code = '10-78', jobTypes = { 'leo', 'federal' }, priority = 1, ttl = 300, blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_1' }, sound = 'Attack_Alert' },
    escape    = { label = 'Prisoner escape',   code = '10-98', jobTypes = { 'leo', 'federal' }, jobs = { prison = 0 }, priority = 1, ttl = 600, blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_1' }, sound = 'Attack_Alert' },
    fire      = { label = 'Fire',              code = '10-70', jobTypes = { 'leo', 'medical' }, priority = 2, ttl = 300, blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_2' } },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ AUTOMATIC CALLS ═══════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Auto = {
    doorsPicked = 'breakin',       -- lxr:doors:picked → this kind (false to disable)
    shots = { enabled = true, kind = 'shots', cooldownMs = 60000, townsOnly = true, exemptJobTypes = { 'leo', 'federal' } },
    -- towns: shots outside these circles raise nothing (hunting happens)
    towns = {
        { label = 'Valentine',   coords = vector3(-300.0, 790.0, 118.0), radius = 220.0 },
        { label = 'Rhodes',      coords = vector3(1320.0, -1300.0, 77.0), radius = 220.0 },
        { label = 'Saint Denis', coords = vector3(2650.0, -1230.0, 52.0), radius = 520.0 },
        { label = 'Blackwater',  coords = vector3(-800.0, -1300.0, 43.0), radius = 260.0 },
        { label = 'Strawberry',  coords = vector3(-1790.0, -380.0, 160.0), radius = 180.0 },
        { label = 'Annesburg',   coords = vector3(2930.0, 1340.0, 45.0), radius = 200.0 },
        { label = 'Armadillo',   coords = vector3(-3680.0, -2610.0, -13.0), radius = 200.0 },
        { label = 'Tumbleweed',  coords = vector3(-5500.0, -2940.0, -1.0), radius = 200.0 },
        { label = 'Van Horn',    coords = vector3(2980.0, 545.0, 45.0), radius = 180.0 },
    },
}

-- citizens raise calls by telegraph: /law and /doctor with a message (cooldown per citizen)
Config.Citizen = { enabled = true, lawCommand = 'law', doctorCommand = 'doctor', cooldownMs = 90000, maxLength = 120 }

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ON SCREEN ═════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Screen = {
    toast = true,                  -- also a kit toast on arrival
    maxCards = 5,                  -- calls kept on the card stack
    listCommand = 'calls',         -- toggle the card stack
    respondKey = 'G',              -- respond to the newest call while the stack is shown (control label)
    respondHash = 0x760A9C6F,
    routeOnRespond = true,         -- set a waypoint when responding
    blipTtlScale = 1.0,            -- blip lifetime = ttl × this
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SECURITY ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Security = { rateLimit = { windowMs = 5000, burst = 6 }, maxCallsOpen = 40 }

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG ═════════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Debug = { printBanner = true, log = false }
