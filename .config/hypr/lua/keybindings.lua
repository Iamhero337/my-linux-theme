-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◈ KEYBINDINGS (Ultra-Responsive, Standardized & Native Lua Dispatchers)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local home = os.getenv("HOME")
local mainMod = "SUPER"

local function qs_toggle(name)
    return hl.dsp.exec_cmd("bash " .. home .. "/.config/hypr/scripts/qs_manager.sh toggle " .. name)
end

-- ── Passthru Submap for Quickshell overlays ──
hl.define_submap("passthru", function()
    hl.bind("SUPER + SHIFT + CTRL + ALT + F35", hl.dsp.exec_cmd("true"))
end)

-- ── Mouse Binds ──
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Window Navigation & Management ──
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind("ALT + F4",                hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + G",         hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab",       hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev())
hl.bind(mainMod .. " + S",         hl.dsp.layout("togglesplit"))

-- Focus navigation (Arrow keys + Vim keys)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }))

-- Move active window (Arrow keys + Vim keys)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))

-- Resize active window (Repeating)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y = 50, relative = true }),  { repeating = true })

-- ── Applications & Launchers ──
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Space",  qs_toggle("applauncher"))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd("vivaldi"))
hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd("telegram-desktop || Telegram"))
hl.bind(mainMod .. " + W",      qs_toggle("wallpaper"))
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd("bash " .. home .. "/.config/hypr/scripts/toggle_kde_clipboard.sh"))

-- ── Quickshell Popups & Overlays ──
hl.bind(mainMod .. " + SHIFT + S", qs_toggle("settings"))
hl.bind(mainMod .. " + SHIFT + Q", qs_toggle("music"))
hl.bind(mainMod .. " + SHIFT + M", qs_toggle("monitors"))
hl.bind(mainMod .. " + SHIFT + V", qs_toggle("volume"))
hl.bind(mainMod .. " + SHIFT + N", qs_toggle("network"))
hl.bind(mainMod .. " + SHIFT + C", qs_toggle("calendar"))
hl.bind(mainMod .. " + SHIFT + G", qs_toggle("gpu"))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + P", qs_toggle("monitors"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("bash " .. home .. "/.config/waybar/scripts/toggle.sh"))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd("bash " .. home .. "/.config/hypr/scripts/reload.sh"))

-- ── System, Lock & Power ──
hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("bash " .. home .. "/.config/hypr/scripts/exit.sh"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("bash " .. home .. "/.config/hypr/scripts/lock.sh"))
hl.bind("XF86PowerOff",            hl.dsp.exec_cmd("bash " .. home .. "/.config/hypr/scripts/lock.sh"), { locked = true })

-- ── Screenshots ──
hl.bind("Print",                       hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh --full"), { locked = true })
hl.bind("SHIFT + Print",               hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh"),        { locked = true })
hl.bind(mainMod .. " + Print",         hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh --edit"), { locked = true })
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh --full --edit"), { locked = true })

-- ── Hardware Keys ──
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                         { locked = true, repeating = true })

hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })

-- ── Workspaces (Instant Native Switching) ──
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ── Shortcut Manager ──
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("python3 " .. home .. "/.local/share/hypr-shortcuts/shortcut_manager.py"))
