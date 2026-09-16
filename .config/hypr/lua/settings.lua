-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◈ SETTINGS & ANIMATIONS (Gorgeous, Responsive, Ultra-Snappy)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local colors = require("lua.colors")

hl.config({
    general = {
        border_size = 2,
        gaps_in = 4,
        gaps_out = 4,
        float_gaps = 6,
        resize_on_border = true,
        extend_border_grab_area = 30,
        hover_icon_on_border = true,
        col = {
            active_border = colors.active_border,
            inactive_border = colors.inactive_border,
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 8,
        active_opacity = 1.0,
        inactive_opacity = 0.98,
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
        },
        shadow = {
            enabled = false,
        },
    },

    input = {
        kb_layout = "us, ru",
        kb_options = "grp:alt_shift_toggle",
        accel_profile = "flat",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
        },
    },

    misc = {
        focus_on_activate = true,
        font_family = "JetBrains Mono",
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 1,
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true,
    },

    render = {
        direct_scanout = true,
    },

    cursor = {
        no_hardware_cursors = true,
        enable_hyprcursor = false,
        sync_gsettings_theme = true,
    },

    dwindle = {
        preserve_split = true,
    },

    animations = {
        enabled = true,
    },
})

-- Touchpad 4-finger swipe gesture for workspace switching
hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace",
})

-- ── Ultra-Snappy & Buttery-Smooth Animation Physics ──
hl.curve("snappySpring", { type = "spring", mass = 0.75, stiffness = 320, dampening = 27 })
hl.curve("quickPop",     { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })
hl.curve("fastDecel",    { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("snappyExit",   { type = "bezier", points = { {0.2, 0}, {0.0, 1} } })

-- Leaf Animations (Tuned for instant responsiveness without floatiness)
hl.animation({ leaf = "global",            enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "border",            enabled = true, speed = 4.5, bezier = "quickPop" })
hl.animation({ leaf = "windows",           enabled = true, speed = 3.2, spring = "snappySpring" })
hl.animation({ leaf = "windowsIn",         enabled = true, speed = 2.8, spring = "snappySpring", style = "popin 88%" })
hl.animation({ leaf = "windowsOut",        enabled = true, speed = 1.8, bezier = "snappyExit",   style = "popin 90%" })
hl.animation({ leaf = "fadeIn",            enabled = true, speed = 1.6, bezier = "fastDecel" })
hl.animation({ leaf = "fadeOut",           enabled = true, speed = 1.3, bezier = "linear" })
hl.animation({ leaf = "layers",            enabled = true, speed = 3.0, bezier = "quickPop" })
hl.animation({ leaf = "layersIn",          enabled = true, speed = 2.6, bezier = "quickPop",    style = "fade" })
hl.animation({ leaf = "layersOut",         enabled = true, speed = 1.6, bezier = "snappyExit",  style = "fade" })
hl.animation({ leaf = "workspaces",        enabled = true, speed = 2.6, bezier = "fastDecel",   style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2.6, bezier = "quickPop",    style = "fade" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.8, bezier = "snappyExit",  style = "fade" })
