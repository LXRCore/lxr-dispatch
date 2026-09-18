--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DISPATCH — Offline tests: kinds, hearing, towns, locale parity
     Requires a sibling checkout of lxr-core (../lxr-core).
     Usage (from the lxr-dispatch folder):  lua tests/run.lua [--mock out.js en|ka]
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = os.getenv('LXR_CORE_PATH') or '../lxr-core'
package.path = CORE .. '/?.lua;' .. package.path
local ok = pcall(function() require('tests.lib.fxshim') end)
if not ok then print('lxr-core shim not found at ' .. CORE .. ' (set LXR_CORE_PATH)') os.exit(2) end
local Shim = require('tests.lib.fxshim')

for _, f in ipairs({ 'shared/main.lua', 'shared/locale.lua', 'locales/en.lua', 'config.lua', 'shared/jobs.lua' }) do Shim.load(CORE .. '/' .. f) end
Config = nil
Locale = nil
Shim.load('shared/locale.lua')
Shim.load('locales/en.lua')
Shim.load('locales/ka.lua')
Shim.load('config.lua')
Shim.load('shared/rules.lua')
local D = LXRDispatch

local passed, failed = 0, 0
local function test(name, fn)
    local okT, err = xpcall(fn, debug.traceback)
    if okT then passed = passed + 1 print('  ^ ok   ' .. name) else failed = failed + 1 print('  x FAIL ' .. name .. '\n' .. err) end
end
local function eq(a, b, msg) if a ~= b then error((msg or 'eq') .. ': expected ' .. tostring(b) .. ' got ' .. tostring(a), 2) end end

print('lxr-dispatch offline tests')

test('every kind names real job types or jobs and has a code, ttl, priority, blip', function()
    local types = {}
    for _, j in pairs(LXRShared.Jobs) do types[j.type] = true end
    for name, k in pairs(Config.Kinds) do
        assert(k.code and k.ttl and k.priority and k.blip and k.label, name .. ' incomplete')
        for _, t in ipairs(k.jobTypes or {}) do assert(types[t], name .. ' unknown job type ' .. t) end
        for j in pairs(k.jobs or {}) do assert(LXRShared.Jobs[j], name .. ' unknown job ' .. j) end
        assert(k.priority >= 1 and k.priority <= 3)
    end
    assert(Config.Kinds[Config.Auto.doorsPicked], 'doorsPicked kind exists')
    assert(Config.Kinds[Config.Auto.shots.kind], 'shots kind exists')
end)

test('who hears: type, explicit job, duty, off duty', function()
    local shots = D.Kind('shots')
    assert(D.Hears(shots, { name = 'vallaw', onduty = true }), 'sheriff on duty hears shots (type from registry)')
    assert(not D.Hears(shots, { name = 'vallaw', onduty = false }), 'off duty hears nothing')
    assert(not D.Hears(shots, { name = 'valdoc', onduty = true }), 'doctors do not hear shots')
    assert(D.Hears(D.Kind('wounded'), { name = 'valdoc', onduty = true }))
    assert(D.Hears(D.Kind('escape'), { name = 'prison', onduty = true }), 'explicit job')
    assert(D.Hears(D.Kind('shots'), { name = 'usmarshal', type = 'federal', onduty = true }))
    assert(not D.Hears(nil, { name = 'vallaw', onduty = true }))
end)

test('towns and the open country', function()
    assert(D.Town(vector3(-300.0, 790.0, 118.0)).label == 'Valentine')
    assert(D.Town({ x = 0, y = 0, z = 0 }) == nil)
end)

test('sorting and messages', function()
    local list = D.Sort({ { priority = 3, at = 10 }, { priority = 1, at = 5 }, { priority = 1, at = 9 } })
    eq(list[1].at, 9) eq(list[2].at, 5) eq(list[3].priority, 3)
    eq(D.CleanMessage('  hello <world>\n  there  '), 'hello world there')
    eq(#D.CleanMessage(string.rep('a', 500)), Config.Citizen.maxLength)
end)

test('locale parity', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing = {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
end)

print(('%d passed, %d failed'):format(passed, failed))

if arg and arg[1] == '--mock' and arg[2] then
    Config.Lang = arg[3] or 'en'
    local now = os.time()
    local calls = {
        { id = 3, kind = 'robbery', code = '10-90', label = 'Robbery', title = 'Valentine Savings Bank', message = 'Three riders, masks, shots inside.', town = 'Valentine', priority = 1, at = now - 40, responders = { { name = 'Deputy Cole' } } },
        { id = 2, kind = 'shots', code = '10-71', label = 'Shots fired', title = 'Shots fired in Valentine', town = 'Valentine', priority = 2, at = now - 190, responders = {} },
        { id = 1, kind = 'lawcall', code = '10-16', label = 'Call for the law', title = 'Wire from Mary Beth Gaskill', message = 'Drunk cowboy will not leave the saloon.', town = 'Valentine', priority = 3, at = now - 400, responders = {} },
    }
    local f = assert(io.open(arg[2], 'w'))
    f:write('window.__LXR_MOCK__ = ' .. json.encode({ action = 'calls', payload = calls, shown = true, respondKey = Config.Screen.respondKey, lang = Config.Lang, locale = Lang.bundle(), brand = { name = 'The Land of Wolves', theme = 'night' } }) .. ';\n')
    f:close()
    print('mock written to ' .. arg[2])
end
os.exit(failed == 0 and 0 or 1)
