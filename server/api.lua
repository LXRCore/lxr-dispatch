--[[
    ██╗     ██╗  ██╗██████╗        ██╗ ██████╗ ██████╗      █████╗ ██╗     ███████╗██████╗ ████████╗███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║██╔═══██╗██╔══██╗    ██╔══██╗██║     ██╔════╝██╔══██╗╚══██╔══╝██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║██║   ██║██████╔╝    ███████║██║     █████╗  ██████╔╝   ██║   ███████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║██║   ██║██╔══██╗    ██╔══██║██║     ██╔══╝  ██╔══██╗   ██║   ╚════██║
    ███████╗██╔╝ ██╗██║  ██║      ██║╚██████╔╝██████╔╝    ██║  ██║███████╗███████╗██║  ██║   ██║   ███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝ ╚═════╝ ╚═════╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝

    🐺 LXR Job Alerts — Server API (Public Exports)

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
-- 🐺 PUBLIC API — allows other resources to register custom alerts at runtime
-- ════════════════════════════════════════════════════════════════════════════════

--[[
    Usage (from another resource):

        local AlertClass = exports['lxr-jobalerts']:RegisterAlert({
            name       = 'myalert',
            command    = 'alertmyjob',
            message    = 'My Job Alert!',
            originText = 'My job has been notified',
            jobs       = { 'myjob' },
            jobGrades  = { myjob = { 0, 1, 2, 3 } },
            icon       = 'star',
            blipHash   = -1282792512,
        })

        -- To manually fire the alert for a player:
        AlertClass:SendAlert(playerSource)
]]

local _RegisterAlert = function(alert)
    local AlertClass = {}
    AlertClass.alert = alert

    RegisterAlert(alert)

    function AlertClass:SendAlert(src)
        AlertPlayer(src, self.alert)
    end

    return AlertClass
end

exports('RegisterAlert', _RegisterAlert)