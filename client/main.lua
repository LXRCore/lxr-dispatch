--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DISPATCH — Client: cards, blips, routes, the shots reporter
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local D = LXRDispatch
local N = Citizen.InvokeNative
local calls = {}        -- id → call (public shape)
local blips = {}        -- id → { blip, radius }
local shown = true
local newest = nil

local function toast(title, desc, kind) if GetResourceState('lxr-nui') == 'started' then exports['lxr-nui']:Toast({ title = title, description = desc, type = kind or 'inform' }) else LXRCore.Notify(title, kind or 'inform') end end

local function page(action, payload)
    SendNUIMessage({ action = action, payload = payload, brand = LXRCore.Brand, lang = Config.Lang, locale = Lang.bundle(), shown = shown, respondKey = Config.Screen.respondKey })
end

local function list()
    local out = {}
    for _, c in pairs(calls) do out[#out + 1] = c end
    D.Sort(out)
    while #out > Config.Screen.maxCards do table.remove(out) end
    return out
end

local function addBlip(call)
    local b = call.blip
    if not b then return end
    local blip = N(0x554D9D53F696D002, 1664425300, call.coords.x, call.coords.y, call.coords.z)
    if not blip or blip == 0 then return end
    N(0x74F74D3207ED525C, blip, joaat(b.sprite or 'blip_ambient_sheriff'), true) if GetResourceState('lxr-mapcolor') == 'started' then pcall(function() N(0x662D364ABF16DE2F, blip, exports['lxr-mapcolor']:modifier('law')) end) end
    N(0x9CB1A1623062F402, blip, ('%s %s'):format(call.code or '', call.title or call.label))
    if b.colour then N(0x662D364ABF16DE2F, blip, joaat(b.colour)) end
    local radius
    if b.radius then
        radius = N(0x45F13B7E0A15C880, 1664425300, call.coords.x, call.coords.y, call.coords.z, b.radius + 0.0)
        if radius and radius ~= 0 and b.colour then N(0x662D364ABF16DE2F, radius, joaat(b.colour)) end
    end
    blips[call.id] = { blip = blip, radius = radius }
end

local function removeBlip(id)
    local e = blips[id]
    if not e then return end
    if e.blip then RemoveBlip(e.blip) end
    if e.radius then RemoveBlip(e.radius) end
    blips[id] = nil
end

local function route(call)
    if not call then return end
    SetNewWaypoint(call.coords.x, call.coords.y)
    toast(Lang:t('info.routed', { code = call.code or '' }), call.title, 'inform')
end

RegisterNetEvent('lxr-dispatch:client:call', function(call)
    calls[call.id] = call
    newest = call.id
    addBlip(call)
    if call.sound then PlaySoundFrontend(call.sound, 'Ledger_Sounds', true, 0) end
    if Config.Screen.toast then toast(('%s · %s'):format(call.code or '', call.title or call.label), call.message or call.town or '', 'warning') end
    page('calls', list())
end)
RegisterNetEvent('lxr-dispatch:client:update', function(call) if calls[call.id] then calls[call.id] = call page('calls', list()) end end)
RegisterNetEvent('lxr-dispatch:client:clear', function(id) calls[id] = nil removeBlip(id) if newest == id then newest = nil end page('calls', list()) end)
RegisterNetEvent('lxr-dispatch:client:sync', function(mine)
    for id in pairs(calls) do removeBlip(id) end
    calls = {}
    for _, c in ipairs(mine or {}) do calls[c.id] = c addBlip(c) end
    page('calls', list())
end)

-- respond / route / close from the page or the key
local function respond(id)
    local call = calls[id]
    if not call then return end
    TriggerServerEvent('lxr-dispatch:server:respond', id)
    if Config.Screen.routeOnRespond then route(call) end
end
RegisterNUICallback('respond', function(d, cb) respond(tonumber(d.id)) cb({}) end)
RegisterNUICallback('route', function(d, cb) route(calls[tonumber(d.id)]) cb({}) end)
RegisterNUICallback('close', function(d, cb) TriggerServerEvent('lxr-dispatch:server:clear', tonumber(d.id)) cb({}) end)

RegisterCommand(Config.Screen.listCommand, function() shown = not shown page('calls', list()) end, false)
RegisterCommand('dispatch_respond', function() if shown and newest and calls[newest] then respond(newest) end end, false)
RegisterKeyMapping('dispatch_respond', 'Respond to the newest call', 'keyboard', Config.Screen.respondKey)

-- shots in town: the client only says "I fired"; the server decides if it matters
CreateThread(function()
    while true do
        Wait(0)
        if Config.Auto.shots.enabled and LocalPlayer.state.isLoggedIn and IsPedShooting(PlayerPedId()) then
            TriggerServerEvent('lxr-dispatch:server:shots')
            Wait(Config.Auto.shots.cooldownMs)
        else
            Wait(250)
        end
    end
end)

RegisterNetEvent('lxr:client:loaded', function() Wait(1000) TriggerServerEvent('lxr-dispatch:server:sync') end)
AddEventHandler('onResourceStart', function(res) if res == GetCurrentResourceName() and LocalPlayer.state.isLoggedIn then TriggerServerEvent('lxr-dispatch:server:sync') end end)
RegisterNetEvent('lxr:client:unloaded', function() for id in pairs(calls) do removeBlip(id) end calls = {} page('calls', {}) end)
AddEventHandler('onResourceStop', function(res) if res == GetCurrentResourceName() then for id in pairs(calls) do removeBlip(id) end end end)

exports('Open', list)
exports('Respond', respond)
