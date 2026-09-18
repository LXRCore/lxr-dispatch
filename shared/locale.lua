--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-DISPATCH — Locale Engine (shared)
     ═══════════════════════════════════════════════════════════════════════════
     Lang:t('key', { var = 1 }) with %{var} placeholders. Locale files call
     Locale.Register('en', {...}); Config.Lang selects the bundle, English is
     the fallback. Lang.bundle() returns the flat table sent to the NUI.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

Locale = Locale or {}
Locale.Bundles = Locale.Bundles or {}

local function flatten(tbl, prefix, out)
    out = out or {}
    for k, v in pairs(tbl) do
        local key = prefix and (prefix .. '.' .. k) or k
        if type(v) == 'table' then flatten(v, key, out) else out[key] = v end
    end
    return out
end

function Locale.Register(lang, phrases)
    Locale.Bundles[lang] = Locale.Bundles[lang] or {}
    for k, v in pairs(flatten(phrases)) do Locale.Bundles[lang][k] = v end
end

Lang = Lang or {}

local function current()
    local cfg = rawget(_G, 'Config')
    return (cfg and cfg.Lang or 'en'):lower()
end

function Lang.t(self, key, vars)
    if type(self) == 'string' then vars, key = key, self end
    local b = Locale.Bundles[current()]
    local str = b and b[key]
    if str == nil then
        local fb = Locale.Bundles.en
        str = fb and fb[key]
    end
    if str == nil then return key end
    if type(vars) == 'table' then
        str = str:gsub('%%{([%w_]+)}', function(n) return vars[n] ~= nil and tostring(vars[n]) or ('%{' .. n .. '}') end)
    end
    return str
end

function Lang.bundle()
    local out = {}
    for k, v in pairs(Locale.Bundles.en or {}) do out[k] = v end
    for k, v in pairs(Locale.Bundles[current()] or {}) do out[k] = v end
    return out
end
