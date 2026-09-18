-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◈ MONITORS (Dynamic & High-Refresh Rate)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local home = os.getenv("HOME")
local applied = false

-- Dynamically load monitors.conf if present (maintains compatibility with monitor_modes.sh)
local f = io.open(home .. "/.config/hypr/config/monitors.conf", "r")
if f then
    for line in f:lines() do
        -- Check for disabled monitor (e.g. monitor = eDP-1, disable)
        local dis_output = line:match("^%s*monitor%s*=%s*([^,]+)%s*,%s*disable")
        if dis_output then
            hl.monitor({
                output = dis_output:match("^%s*(.-)%s*$"),
                disabled = true,
            })
            applied = true
        else
            -- Check for mirrored monitor (e.g. monitor = HDMI-A-1, preferred, auto, 1.0, mirror, eDP-1)
            local m_out, m_mode, m_pos, m_scale, m_target = line:match("^%s*monitor%s*=%s*([^,]+)%s*,%s*([^,]+)%s*,%s*([^,]+)%s*,%s*([^,]+)%s*,%s*mirror%s*,%s*([^,%s#]+)")
            if m_out and m_target then
                hl.monitor({
                    output = m_out:match("^%s*(.-)%s*$"),
                    mode = m_mode:match("^%s*(.-)%s*$"),
                    position = m_pos:match("^%s*(.-)%s*$"),
                    scale = tonumber(m_scale) or 1,
                    mirror = m_target:match("^%s*(.-)%s*$"),
                })
                applied = true
            else
                -- Standard monitor line (e.g. monitor = eDP-1, 1920x1080@120, 0x0, 1)
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
