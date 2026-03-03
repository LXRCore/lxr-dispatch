--[[
    ██╗     ██╗  ██╗██████╗        ██╗ ██████╗ ██████╗      █████╗ ██╗     ███████╗██████╗ ████████╗███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║██╔═══██╗██╔══██╗    ██╔══██╗██║     ██╔════╝██╔══██╗╚══██╔══╝██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║██║   ██║██████╔╝    ███████║██║     █████╗  ██████╔╝   ██║   ███████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║██║   ██║██╔══██╗    ██╔══██║██║     ██╔══╝  ██╔══██╗   ██║   ╚════██║
    ███████╗██╔╝ ██╗██║  ██║      ██║╚██████╔╝██████╔╝    ██║  ██║███████╗███████╗██║  ██║   ██║   ███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝ ╚═════╝ ╚═════╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝

    🐺 LXR Job Alerts — Job-Based Alert & Ping System for RedM

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:    The Land of Wolves 🐺
    Developer: iBoss21 / The Lux Empire
    Website:   https://www.wolves.land
    Discord:   https://discord.gg/CrKcWdfd3A
    Store:     https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 3.1.0

    Framework Support:
    - LXR-Core  (Primary)
    - RSG-Core  (Primary)
    - VORP Core (Supported)
    - QBR-Core  (Optional)
    - QR-Core   (Optional)
    - Standalone (Fallback)

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 RESOURCE NAME PROTECTION — RUNTIME CHECK
-- ═══════════════════════════════════════════════════════════════════════════════

local REQUIRED_RESOURCE_NAME = "lxr-jobalerts"
local currentResourceName = GetCurrentResourceName()

if currentResourceName ~= REQUIRED_RESOURCE_NAME then
    error(string.format([[

        ═══════════════════════════════════════════════════════════════════════════════
        ❌ CRITICAL ERROR: RESOURCE NAME MISMATCH ❌
        ═══════════════════════════════════════════════════════════════════════════════

        Expected: %s
        Got:      %s

        This resource is branded and must maintain the correct name.
        Rename the folder to "%s" to continue.

        🐺 wolves.land — The Land of Wolves

        ═══════════════════════════════════════════════════════════════════════════════

    ]], REQUIRED_RESOURCE_NAME, currentResourceName, REQUIRED_RESOURCE_NAME))
end

Config = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER BRANDING & INFO ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.ServerInfo = {
    name      = 'The Land of Wolves 🐺',
    developer = 'iBoss21 / The Lux Empire',
    website   = 'https://www.wolves.land',
    discord   = 'https://discord.gg/CrKcWdfd3A',
    store     = 'https://theluxempire.tebex.io',
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Framework Priority (in order):
    1. LXR-Core  (Primary)
    2. RSG-Core  (Primary)
    3. VORP Core (Supported)
    4. QBR-Core  (Optional)
    5. QR-Core   (Optional)
    6. Standalone (Fallback)

    Set Config.Framework to one of the values below, or 'auto' for automatic detection:
    'lxr-core' | 'rsg-core' | 'vorp_core' | 'qbr-core' | 'qr-core' | 'standalone'
]]

Config.Framework = 'lxr-core'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ GENERAL ALERT SETTINGS ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.General = {
    messageTime = 40000,  -- How long the alert notification stays on screen (ms)
    blipTime    = 60000,  -- How long the map blip remains visible (ms)
    blipDelay   = 5000,   -- Delay before the blip appears on map (ms)
    radius      = 40.0,   -- Blip radius on the map
    alertIcon   = 'star', -- Default icon shape for alerts
    textureDict = 'generic_textures', -- Texture dictionary for icons
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ALERT DEFINITIONS █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Each alert entry accepts the following fields:
        name        (string)  – internal identifier
        command     (string)  – chat command players type (no slash)
        message     (string)  – notification text sent to on-duty job members
        originText  (string)  – confirmation text shown to the caller
        jobs        (table)   – list of job names that receive the alert
        jobGrades   (table)   – map of job name → allowed grade numbers
        icon        (string)  – icon shape (uses Config.General.alertIcon if omitted)
        blipHash    (number)  – native blip model hash
]]

Config.Alerts = {

    -- ── POLICE ──────────────────────────────────────────────────────────────────
    {
        name       = 'police',
        command    = 'alertpolice',
        message    = 'Police Alert: Backup Needed!',
        originText = 'Police have been notified',
        jobs       = { 'police', 'sheriff' },
        jobGrades  = {
            police  = { 0, 1, 2, 3 },
            sheriff = { 0, 1, 2, 3 },
        },
        icon     = 'shield',
        blipHash = -1282792512,
    },

    -- ── MEDIC / DOCTOR ───────────────────────────────────────────────────────────
    {
        name       = 'medic',
        command    = 'alertdoctor',
        message    = 'Medical Assistance Required!',
        originText = 'Doctors have been notified',
        jobs       = { 'medic', 'doctor' },
        jobGrades  = {
            medic  = { 0, 1, 2, 3 },
            doctor = { 0, 1, 2, 3 },
        },
        icon     = 'shield',
        blipHash = -1282792512,
    },

    -- ── BANKER (custom example) ──────────────────────────────────────────────────
    {
        name       = 'banker',
        command    = 'alertbanker',
        message    = 'Banker Alert: Taxes need to be done!',
        originText = 'Bankers have been notified',
        jobs       = { 'banker' },
        jobGrades  = {
            banker = { 0, 1, 2, 3 },
        },
        icon     = 'star',
        blipHash = -1282792512,
    },

    --[[
        ── ADD MORE ALERTS BELOW ────────────────────────────────────────────────
        Copy/paste a block above, change the fields, and add it to this table.
    ]]
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG SETTINGS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Debug = false -- Set to true to enable verbose server/client prints

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ STARTUP BANNER ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

CreateThread(function()
    Wait(500)
    print([[

        ═══════════════════════════════════════════════════════════════════════════════

            ██╗     ██╗  ██╗██████╗        ██╗ ██████╗ ██████╗
            ██║     ╚██╗██╔╝██╔══██╗      ██║██╔═══██╗██╔══██╗
            ██║      ╚███╔╝ ██████╔╝█████╗██║██║   ██║██████╔╝
            ██║      ██╔██╗ ██╔══██╗╚════╝██║██║   ██║██╔══██╗
            ███████╗██╔╝ ██╗██║  ██║      ██║╚██████╔╝██████╔╝
            ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝ ╚═════╝ ╚═════╝

             █████╗ ██╗     ███████╗██████╗ ████████╗███████╗
            ██╔══██╗██║     ██╔════╝██╔══██╗╚══██╔══╝██╔════╝
            ███████║██║     █████╗  ██████╔╝   ██║   ███████╗
            ██╔══██║██║     ██╔══╝  ██╔══██╗   ██║   ╚════██║
            ██║  ██║███████╗███████╗██║  ██║   ██║   ███████║
            ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝

        ═══════════════════════════════════════════════════════════════════════════════
        🐺 JOB ALERTS SYSTEM — SUCCESSFULLY LOADED
        ═══════════════════════════════════════════════════════════════════════════════

        Version:   3.1.0
        Server:    ]] .. Config.ServerInfo.name .. [[

        Framework: ]] .. Config.Framework .. [[

        Alerts:    ]] .. #Config.Alerts .. [[ registered

        ═══════════════════════════════════════════════════════════════════════════════

        Developer: iBoss21 / The Lux Empire
        Website:   https://www.wolves.land
        Discord:   https://discord.gg/CrKcWdfd3A

        ═══════════════════════════════════════════════════════════════════════════════

    ]])
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ END OF CONFIGURATION ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
