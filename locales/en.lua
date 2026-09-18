--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DISPATCH — Locale: English (canonical)
     Developer   : iBoss21 | Brand : LXRCore | https://www.lxrcore.com
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

Locale.Register('en', {
    command = { law = 'Wire the law', doctor = 'Wire a doctor', message = 'What happened' },
    error = { cooldown = 'The telegraph clerk is still sending your last wire.', empty = 'Say what happened.', invalid = 'That could not be sent.' },
    info = { sent = 'Your wire went out.', routed = 'Riding to %{code}.' },
    call = { breakin = 'Lock forced at %{door}', shots = 'Shots fired in %{town}', country = 'the open country', citizen = 'Wire from %{name}' },
    ui = { dispatch = 'Dispatch', respond_newest = 'respond to the newest', responding = 'responding:', nobody = 'nobody responding', route = 'Route', respond = 'Respond', age_s = '%{n}s ago', age_m = '%{n}m ago' },
})
