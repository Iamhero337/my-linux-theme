-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◈ WINDOW & LAYER RULES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ─────────────────────────────
-- Layer rules (OSD / overlays)
-- ─────────────────────────────
hl.layer_rule({
    name = "vol-osd-noanim",
    match = { namespace = "volume_osd" },
    no_anim = true,
})
hl.layer_rule({
    name = "bright-osd-noanim",
    match = { namespace = "brightness_osd" },
    no_anim = true,
})
hl.layer_rule({
    name = "hyprpicker-noanim",
    match = { namespace = "hyprpicker" },
    no_anim = true,
})
hl.layer_rule({
    name = "qsdock-noanim",
    match = { namespace = "qsdock" },
    no_anim = true,
})
hl.layer_rule({
    name = "lock-blur",
    match = { namespace = "ext-session-lock" },
    blur = true,
})

-- ─────────────────────────────
-- Window rules
-- ─────────────────────────────

-- CS2 Low Latency
hl.window_rule({
    name = "cs2-immediate",
    match = { class = "cs2" },
    immediate = true,
})

-- App Launcher
hl.window_rule({
    name = "applauncher-float",
    match = { title = "app-launcher" },
    float = true,
    center = true,
    size = "1200 600",
})

-- Polkit KDE Authentication Agent
hl.window_rule({
    name = "polkit-float",
    match = { class = ".*polkit-kde.*" },
    float = true,
    center = true,
    dim_around = true,
})

-- Kitty Terminal Aesthetics
hl.window_rule({
    name = "kitty-style",
    match = { class = "kitty" },
    opacity = 0.94,
    rounding = 12,
})

-- Shortcut Manager Floating Windows
hl.window_rule({
    name = "shortcuts-float",
    match = { class = ".*shortcut.*" },
    float = true,
    center = true,
    size = "950 680",
})
