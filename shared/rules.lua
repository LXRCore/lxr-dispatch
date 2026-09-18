--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DISPATCH — Shared rules: who hears a call, where it happened
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRDispatch = LXRDispatch or {}
local D = LXRDispatch

function D.Kind(kind) return Config.Kinds[kind] end

---Does a job record hear calls of this kind (job = { name, type, onduty }).
function D.Hears(def, job)
    if not def or not job or not job.name then return false end
    if not job.onduty and not def.offDuty then return false end
    if def.jobs and def.jobs[job.name] ~= nil then return true end
    local jtype = job.type or (LXRShared.Jobs and LXRShared.Jobs[job.name] and LXRShared.Jobs[job.name].type)
    for _, t in ipairs(def.jobTypes or {}) do if t == jtype then return true end end
    return false
end

---The town a position lies in, or nil for the open country.
function D.Town(pos)
    for _, t in ipairs(Config.Auto.towns) do
        if #(vector3(pos.x, pos.y, pos.z) - t.coords) <= t.radius then return t end
    end
    return nil
end

---Sort key: priority first, then newest.
function D.Sort(calls)
    table.sort(calls, function(a, b)
        if a.priority ~= b.priority then return a.priority < b.priority end
        return a.at > b.at
    end)
    return calls
end

---Trim a citizen's message.
function D.CleanMessage(s)
    s = tostring(s or ''):gsub('[%c<>]', ''):gsub('%s+', ' ')
    s = s:sub(1, Config.Citizen.maxLength)
    return s:match('^%s*(.-)%s*$')
end

---A call's public shape (what clients see).
function D.Public(call)
    return { id = call.id, kind = call.kind, code = call.code, label = call.label, title = call.title, message = call.message, coords = call.coords, priority = call.priority, at = call.at, ttl = call.ttl, town = call.town, responders = call.responders, blip = call.blip, sound = call.sound }
end
