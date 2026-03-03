--[[
    ██╗     ██╗  ██╗██████╗        ██╗ ██████╗ ██████╗      █████╗ ██╗     ███████╗██████╗ ████████╗███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║██╔═══██╗██╔══██╗    ██╔══██╗██║     ██╔════╝██╔══██╗╚══██╔══╝██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║██║   ██║██████╔╝    ███████║██║     █████╗  ██████╔╝   ██║   ███████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║██║   ██║██╔══██╗    ██╔══██║██║     ██╔══╝  ██╔══██╗   ██║   ╚════██║
    ███████╗██╔╝ ██╗██║  ██║      ██║╚██████╔╝██████╔╝    ██║  ██║███████╗███████╗██║  ██║   ██║   ███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝ ╚═════╝ ╚═════╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝

    🐺 LXR Job Alerts — Server Main

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
-- 🐺 FRAMEWORK BOOTSTRAP
-- ════════════════════════════════════════════════════════════════════════════════

local Framework = Config.Framework
local CoreObject = nil
local VorpCore   = nil

if Framework == 'lxr-core' then
    CoreObject = exports['lxr-core']:GetCoreObject()
elseif Framework == 'rsg-core' then
    CoreObject = exports['rsg-core']:GetCoreObject()
elseif Framework == 'qbr-core' then
    CoreObject = exports['qbr-core']:GetCoreObject()
elseif Framework == 'qr-core' then
    CoreObject = exports['qr-core']:GetCoreObject()
elseif Framework == 'vorp_core' then
    TriggerEvent('getCore', function(core)
        VorpCore = core
    end)
else
    print('[lxr-jobalerts] ⚠  Framework "' .. tostring(Framework) .. '" not recognised — running standalone.')
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 HELPERS
-- ════════════════════════════════════════════════════════════════════════════════

-- Returns { job, grade } for a connected player, using the active framework.
local function GetPlayerJobData(_source)
    if Framework == 'vorp_core' and VorpCore then
        local user = VorpCore.getUser(_source)
        if user then
            local char = user:getUsedCharacter()
            return char:getJob(), char:getJobGrade()
        end
    elseif CoreObject then
        local Player = CoreObject.Functions.GetPlayer(_source)
        if Player then
            return Player.PlayerData.job.name, Player.PlayerData.job.grade.level
        end
    end
    return nil, nil
end

local function DumpTable(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. DumpTable(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 ALERT GROUPS  (job → grade → { src = player, … })
-- ════════════════════════════════════════════════════════════════════════════════

local AlertsGroups = {}

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 CORE ALERT LOGIC
-- ════════════════════════════════════════════════════════════════════════════════

function AlertPlayer(src, alert)
    local pos = GetEntityCoords(GetPlayerPed(src))

    Wait(Config.General.blipDelay)

    for _, job in pairs(alert.jobs) do
        for _, jg in pairs(alert.jobGrades[job]) do
            if AlertsGroups[job] and AlertsGroups[job][tostring(jg)] then
                for _, person in pairs(AlertsGroups[job][tostring(jg)]) do
                    TriggerClientEvent(
                        'lxr:alertplayer',
                        person.src,
                        alert.message,
                        Config.General.messageTime,
                        job,
                        alert.blipHash,
                        pos.x, pos.y, pos.z,
                        alert.icon or Config.General.alertIcon,
                        Config.General.textureDict,
                        Config.General.radius,
                        Config.General.blipTime
                    )
                end
            end
        end
    end
end

function RegisterAlert(alert)
    for _, job in pairs(alert.jobs) do
        if not AlertsGroups[job] then
            AlertsGroups[job] = {}
        end
        for _, jobgrade in pairs(alert.jobGrades[job]) do
            if not AlertsGroups[job][tostring(jobgrade)] then
                AlertsGroups[job][tostring(jobgrade)] = {}
            end
        end
    end

    if alert.command then
        RegisterCommand(alert.command, function(source, args, rawCommand)
            AlertPlayer(source, alert)
        end)
    end

    if Config.Debug then
        print('[lxr-jobalerts] Alert registered: ' .. tostring(alert.name))
    end
end

function AddUserToAlerts(_source, job, jobgrade)
    local j  = job
    local jg = jobgrade

    if j == nil or jg == nil then
        j, jg = GetPlayerJobData(_source)
    end

    if j == nil then return end

    if AlertsGroups[j] and AlertsGroups[j][tostring(jg)] then
        AlertsGroups[j][tostring(jg)][tostring(_source)] = {
            src   = _source,
            job   = j,
            grade = jg,
        }
        if Config.Debug then
            print('[lxr-jobalerts] Player ' .. _source .. ' added to alert group: ' .. j .. ' [' .. tostring(jg) .. ']')
        end
    end
end

function RemoveUserFromAlert(_source)
    local job, grade = GetPlayerJobData(_source)
    if not job then return end

    if AlertsGroups[job] and AlertsGroups[job][tostring(grade)] then
        AlertsGroups[job][tostring(grade)][tostring(_source)] = nil
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 EVENT HANDLERS
-- ════════════════════════════════════════════════════════════════════════════════

-- VORP: job changed
AddEventHandler('vorp:setJob', function(_source, job, jobgrade)
    RemoveUserFromAlert(_source)
    AddUserToAlerts(_source, job, jobgrade)
end)

-- LXR-Core / RSG-Core: job changed (player data update event)
AddEventHandler('lxr-core:Server:SetJob', function(_source, job, grade)
    RemoveUserFromAlert(_source)
    AddUserToAlerts(_source, job, grade)
end)

AddEventHandler('RSGCore:Server:SetJob', function(_source, job, grade)
    RemoveUserFromAlert(_source)
    AddUserToAlerts(_source, job, grade)
end)

-- Register player into alert groups on character select
RegisterServerEvent('bcc:alerts:register')
AddEventHandler('bcc:alerts:register', function()
    AddUserToAlerts(source)
end)

-- Remove player from alert groups on disconnect
AddEventHandler('playerDropped', function(reason)
    RemoveUserFromAlert(source)
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- 🐺 BOOT — REGISTER CONFIG-DEFINED ALERTS
-- ════════════════════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    for _, alert in ipairs(Config.Alerts) do
        RegisterAlert(alert)
    end
end)
