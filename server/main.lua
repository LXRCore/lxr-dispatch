--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DISPATCH — Server: the wire
     ═══════════════════════════════════════════════════════════════════════════
     Raise(def) is the one entry point (export, event, or the automatic
     sources). The server decides who hears it, keeps the open calls,
     tracks responders and expires them. Nothing a client sends is trusted
     beyond "I am here and I want to respond".
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local D = LXRDispatch
local RES = GetCurrentResourceName()
local calls, order = {}, {}      -- id → call, and ids in raise order
local nextId = 0
local buckets, lastShot, lastCitizen = {}, {}, {}

local function limited(src)
    local b = buckets[src]
    local now = GetGameTimer()
    if not b or now - b.at > Config.Security.rateLimit.windowMs then b = { at = now, n = 0 } buckets[src] = b end
    b.n = b.n + 1
    return b.n > Config.Security.rateLimit.burst
end
local function player(src) return LXRCore.Functions.GetPlayer(src) end
local function jobOf(P)
    local j = P.PlayerData.job or {}
    local def = LXRShared.Jobs and LXRShared.Jobs[j.name]
    return { name = j.name, type = def and def.type, onduty = j.onduty }
end

local function hearers(def)
    local out = {}
    for src, P in pairs(LXRCore.Players) do
        if D.Hears(def, jobOf(P)) then out[#out + 1] = src end
    end
    return out
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📣 RAISE
-- ═══════════════════════════════════════════════════════════════════════════════
---@param spec table { kind, coords, title?, message?, src?, meta? }
local function raise(spec)
    if type(spec) ~= 'table' then return nil end
    local def = D.Kind(spec.kind)
    if not def or not spec.coords then return nil end
    if #order >= Config.Security.maxCallsOpen then
        local old = table.remove(order, 1)
        calls[old] = nil
        TriggerClientEvent('lxr-dispatch:client:clear', -1, old)
    end
    nextId = nextId + 1
    local c = vector3(spec.coords.x, spec.coords.y, spec.coords.z)
    local town = D.Town(c)
    local call = {
        id = nextId, kind = spec.kind, code = def.code, label = def.label, title = spec.title or def.label, message = spec.message,
        coords = { x = c.x, y = c.y, z = c.z }, priority = def.priority or 3, at = os.time(), ttl = def.ttl or 300, town = town and town.label,
        responders = {}, blip = def.blip, sound = def.sound, src = spec.src, meta = spec.meta,
    }
    calls[call.id] = call
    order[#order + 1] = call.id
    local to = hearers(def)
    for _, src in ipairs(to) do TriggerClientEvent('lxr-dispatch:client:call', src, D.Public(call)) end
    LXRCore.Emit('lxr:dispatch:raised', nil, D.Public(call), #to)
    if Config.Debug.log then LXRCore.Log.info('dispatch', ('%s #%d → %d'):format(spec.kind, call.id, #to), { town = call.town, src = spec.src }) end
    return call.id
end

local function clear(id, reason)
    local call = calls[id]
    if not call then return false end
    calls[id] = nil
    for i, v in ipairs(order) do if v == id then table.remove(order, i) break end end
    TriggerClientEvent('lxr-dispatch:client:clear', -1, id)
    LXRCore.Emit('lxr:dispatch:cleared', nil, id, reason)
    return true
end

CreateThread(function()
    while true do
        Wait(1000)
        local now = os.time()
        for id, call in pairs(calls) do
            if now - call.at > call.ttl then clear(id, 'expired') end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🤝 RESPOND
-- ═══════════════════════════════════════════════════════════════════════════════
RegisterNetEvent('lxr-dispatch:server:respond', function(id)
    local src = source
    if limited(src) then return end
    local P, call = player(src), calls[tonumber(id) or -1]
    if not P or not call then return end
    if not D.Hears(D.Kind(call.kind), jobOf(P)) then return end
    for _, r in ipairs(call.responders) do if r.src == src then return end end
    local ci = P.PlayerData.charinfo
    call.responders[#call.responders + 1] = { src = src, name = ci.firstname .. ' ' .. ci.lastname }
    for _, s in ipairs(hearers(D.Kind(call.kind))) do TriggerClientEvent('lxr-dispatch:client:update', s, D.Public(call)) end
    LXRCore.Emit('lxr:dispatch:responded', nil, call.id, src)
end)

RegisterNetEvent('lxr-dispatch:server:clear', function(id)
    local src = source
    if limited(src) then return end
    local P, call = player(src), calls[tonumber(id) or -1]
    if not P or not call or not D.Hears(D.Kind(call.kind), jobOf(P)) then return end
    clear(call.id, 'closed')
end)

-- late joiners / duty changes get the open calls they may hear
local function sync(src)
    local P = player(src)
    if not P then return end
    local job = jobOf(P)
    local mine = {}
    for _, id in ipairs(order) do
        local call = calls[id]
        if call and D.Hears(D.Kind(call.kind), job) then mine[#mine + 1] = D.Public(call) end
    end
    TriggerClientEvent('lxr-dispatch:client:sync', src, mine)
end
RegisterNetEvent('lxr-dispatch:server:sync', function() if not limited(source) then sync(source) end end)
AddEventHandler('lxr:duty:changed', function(src) sync(src) end)
AddEventHandler('lxr:job:changed', function(src) sync(src) end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔔 AUTOMATIC SOURCES
-- ═══════════════════════════════════════════════════════════════════════════════
if Config.Auto.doorsPicked then
    AddEventHandler('lxr:doors:picked', function(id, src, coords, town)
        raise({ kind = Config.Auto.doorsPicked, coords = coords, title = Lang:t('call.breakin', { door = id }), src = src })
    end)
end

RegisterNetEvent('lxr-dispatch:server:shots', function()
    local src = source
    if not Config.Auto.shots.enabled or limited(src) then return end
    local P = player(src)
    if not P then return end
    local job = jobOf(P)
    for _, t in ipairs(Config.Auto.shots.exemptJobTypes or {}) do if job.type == t and job.onduty then return end end
    local now = GetGameTimer()
    if now - (lastShot[src] or 0) < Config.Auto.shots.cooldownMs then return end
    local ped = GetPlayerPed(src)
    if ped == 0 then return end
    local pos = GetEntityCoords(ped)
    local town = D.Town(pos)
    if Config.Auto.shots.townsOnly and not town then return end
    lastShot[src] = now
    raise({ kind = Config.Auto.shots.kind, coords = pos, title = Lang:t('call.shots', { town = town and town.label or Lang:t('call.country') }), src = src })
end)

-- citizens at the telegraph
local function citizenCall(kind, cmdName)
    LXR.Commands.Register({ name = cmdName, help = Lang:t('command.' .. cmdName), permission = 'user', args = { { name = 'message', help = Lang:t('command.message') } },
        handler = function(src, args)
            local P = player(src)
            if not P then return end
            local now = GetGameTimer()
            if now - (lastCitizen[src] or 0) < Config.Citizen.cooldownMs then return LXRCore.Notify(src, Lang:t('error.cooldown'), 'error') end
            local msg = D.CleanMessage(table.concat(args, ' '))
            if msg == '' then return LXRCore.Notify(src, Lang:t('error.empty'), 'error') end
            lastCitizen[src] = now
            local ped = GetPlayerPed(src)
            local ci = P.PlayerData.charinfo
            local id = raise({ kind = kind, coords = GetEntityCoords(ped), title = Lang:t('call.citizen', { name = ci.firstname .. ' ' .. ci.lastname }), message = msg, src = src })
            LXRCore.Notify(src, Lang:t(id and 'info.sent' or 'error.invalid'), id and 'success' or 'error')
        end })
end
if Config.Citizen.enabled then
    citizenCall('lawcall', Config.Citizen.lawCommand)
    citizenCall('doctorcall', Config.Citizen.doctorCommand)
end

CreateThread(function()
    local n = 0 for _ in pairs(Config.Kinds) do n = n + 1 end
    if Config.Debug.printBanner then print(('^1[lxr-dispatch]^7 v%s — %d kinds of call'):format(GetResourceMetadata(RES, 'version', 0), n)) end
end)
AddEventHandler('playerDropped', function() buckets[source] = nil lastShot[source] = nil lastCitizen[source] = nil end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📤 EXPORTS
-- ═══════════════════════════════════════════════════════════════════════════════
exports('Raise', raise)
exports('Clear', function(id, reason) return clear(tonumber(id), reason or 'export') end)
exports('Open', function() local out = {} for _, id in ipairs(order) do if calls[id] then out[#out + 1] = D.Public(calls[id]) end end return out end)
-- server-side event for other resources (not a net event: clients cannot reach it)
AddEventHandler('lxr-dispatch:server:raise', function(spec) raise(spec) end)
