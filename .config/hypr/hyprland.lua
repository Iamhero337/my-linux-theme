-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◈ HYPRLAND LUA CONFIGURATION (v0.56+ / v0.57 Ready)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local config_dir = os.getenv("HOME") .. "/.config/hypr"
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

-- Flush local module cache on reload to ensure live edits take effect
for mod, _ in pairs(package.loaded) do
    if mod:match("^lua%.") then
        package.loaded[mod] = nil
    end
end

-- Load modular configuration components
require("lua.env")
require("lua.monitors")
require("lua.settings")
require("lua.autostart")
require("lua.rules")
require("lua.keybindings")
