-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◈ MONITORS (Dynamic & High-Refresh Rate)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local home = os.getenv("HOME")
local applied = false

-- Dynamically load monitors.conf if present (maintains compatibility with monitor_modes.sh)
local f = io.open(home .. "/.config/hypr/config/monitors.conf", "r")
if f then
    for line in f:lines() do
        local output, mode, pos, scale = line:match("^%s*monitor%s*=%s*([^,]+)%s*,%s*([^,]+)%s*,%s*([^,]+)%s*,%s*([^,%s#]+)")
        if output and mode and pos and scale then
            hl.monitor({
                output = output:match("^%s*(.-)%s*$"),
                mode = mode:match("^%s*(.-)%s*$"),
                position = pos:match("^%s*(.-)%s*$"),
                scale = tonumber(scale) or 1,
            })
            applied = true
        end
    end
    f:close()
end

if not applied then
    -- Hardware Native High-Refresh Rates (eDP-1 120Hz, HDMI-A-1 144Hz)
    hl.monitor({
        output = "eDP-1",
        mode = "1920x1080@120",
        position = "0x0",
        scale = 1,
    })
    hl.monitor({
        output = "HDMI-A-1",
        mode = "1920x1080@144",
        position = "1920x0",
        scale = 1,
    })
end
