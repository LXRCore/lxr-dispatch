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

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

fx_version 'cerulean'
game       'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name        'lxr-jobalerts'
author      'iBoss21 / The Lux Empire (wolves.land)'
description 'Job-based alert & ping system for RedM — LXR-Core, RSG-Core, VORP Core, QBR-Core, QR-Core compatible.'
version     '3.1.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/main.lua',
    'server/api.lua'
}

client_scripts {
    'client/main.lua',
}
