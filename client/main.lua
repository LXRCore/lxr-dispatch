--[[
    ██╗     ██╗  ██╗██████╗        ██╗ ██████╗ ██████╗      █████╗ ██╗     ███████╗██████╗ ████████╗███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║██╔═══██╗██╔══██╗    ██╔══██╗██║     ██╔════╝██╔══██╗╚══██╔══╝██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║██║   ██║██████╔╝    ███████║██║     █████╗  ██████╔╝   ██║   ███████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║██║   ██║██╔══██╗    ██╔══██║██║     ██╔══╝  ██╔══██╗   ██║   ╚════██║
    ███████╗██╔╝ ██╗██║  ██║      ██║╚██████╔╝██████╔╝    ██║  ██║███████╗███████╗██║  ██║   ██║   ███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝ ╚═════╝ ╚═════╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝

    🐺 LXR Job Alerts — Client Main

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:    The Land of Wolves 🐺
    Developer: iBoss21 / The Lux Empire
    Website:   https://www.wolves.land
    Discord:   https://discord.gg/CrKcWdfd3A
    Store:     https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 ALERT DISPLAY HANDLER
-- ════════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('lxr:alertplayer')
AddEventHandler('lxr:alertplayer', function(msg, time, job, bliphash, x, y, z, shape, texturedir, radius, bliptime)

    -- Send the notification via the active framework's notification system
    if Config.Framework == 'lxr-core' then
        TriggerEvent('lxr-core:NotifyLeft', job, msg, texturedir, shape, time)
    elseif Config.Framework == 'rsg-core' then
        TriggerEvent('rsg-core:NotifyLeft', job, msg, texturedir, shape, time)
    elseif Config.Framework == 'qbr-core' then
        TriggerEvent('qbr-core:NotifyLeft', job, msg, texturedir, shape, time)
    elseif Config.Framework == 'qr-core' then
        TriggerEvent('qr-core:NotifyLeft', job, msg, texturedir, shape, time)
    elseif Config.Framework == 'vorp_core' then
        TriggerEvent('vorp:TipRight', msg, time)
    else
        -- Standalone fallback
        print('[lxr-jobalerts] Alert for ' .. tostring(job) .. ': ' .. tostring(msg))
    end

    if Config.Debug then
        print('[lxr-jobalerts] Blip: shape=' .. tostring(shape) .. '  textureDict=' .. tostring(texturedir))
    end

    -- Show the map blip at the caller's location
    local blip = Citizen.InvokeNative(0x45f13b7e0a15c880, bliphash, x, y, z, radius)
    Wait(bliptime)
    RemoveBlip(blip)
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 CHARACTER SELECT — REGISTER WITH ALERT GROUPS
-- ════════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function(charid)
    Wait(1000)
    TriggerServerEvent('bcc:alerts:register')
end)

-- LXR-Core / RSG-Core character load hook
AddEventHandler('lxr-core:Client:OnPlayerLoaded', function()
    TriggerServerEvent('bcc:alerts:register')
end)

AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('bcc:alerts:register')
end)
