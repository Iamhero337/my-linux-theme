-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◈ ENVIRONMENT VARIABLES (NVIDIA + Ubuntu Wayland + Theming)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local env_vars = {
    -- Hardware Acceleration (Intel Raptor Lake UHD iGPU for Display & Video Decode)
    LIBVA_DRIVER_NAME = "iHD",
    XDG_SESSION_TYPE = "wayland",
    AQ_DRM_DEVICES = "/dev/dri/card2:/dev/dri/card1",
    __GL_VRR_ALLOWED = "1",
    ELECTRON_OZONE_PLATFORM_HINT = "auto",
    MOZ_ENABLE_WAYLAND = "1",

    -- Qt Theming & Scaling
    QT_QPA_PLATFORM = "wayland;xcb",
    QT_QPA_PLATFORMTHEME = "kde",
    QT_QUICK_CONTROLS_STYLE = "org.kde.desktop",
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
    QT_AUTO_SCREEN_SCALE_FACTOR = "1",

    -- GTK & Cursor
    GTK_THEME = "adw-gtk3-dark",
    XCURSOR_THEME = "Bibata-Modern-Classic",
    XCURSOR_SIZE = "24",
    HYPRCURSOR_THEME = "Bibata-Modern-Classic",
    HYPRCURSOR_SIZE = "24",
    GDK_BACKEND = "wayland,x11,*",

    -- Locale
    LC_ALL = "en_US.UTF-8",
    LANG = "en_US.UTF-8",
}

for k, v in pairs(env_vars) do
    hl.env(k, v)
end
