local home = os.getenv("HOME")

----------------
--- MONITORS ---
----------------
hl.monitor({ output = "DP-1", mode = "3440x1440@165", position = "1920x0", scale = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080", position = "0x0", scale = 1 })

-------------------
--- MY PROGRAMS ---
-------------------
local terminal = "kitty"
local menu = "rofi -show drun"
local fileManager = "dolphin"

-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------
-- hl.env("XCURSOR_SIZE", "24")
-- hl.env("XCURSOR_THEME", "Breeze Light")
-- hl.env("HYPRCURSOR_SIZE", "24")
-- hl.env("HYPRCURSOR_THEME", "Breeze Light")

-- Forçar o cursor padrão (Breeze)
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "breeze_cursors")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-----------------
--- AUTOSTART ---
-----------------
hl.on("hyprland.start", function()
    hl.exec_cmd(home .. "/.config/waybar/launch-waybar.sh & swaync") -- & swww-daemon
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    -- hl.exec_cmd("swww img " .. home .. "/wall.png")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("hyprctl setcursor Sweet-cursors-hyprcursor 30")
    -- hl.exec_cmd("hyprctl setcursor Adwaita 1")
    hl.exec_cmd("hyprctl setcursor breeze_cursors 24")
    hl.exec_cmd("transmission-gtk")
end)

--------------------------------
--- LOOK, FEEL & INPUT CONFIG ---
--------------------------------
hl.config({
    cursor = {
        -- 2 = auto: keep hardware cursors, but switch them off while a game is tearing
        no_hardware_cursors = 2,
        default_monitor = "DP-1",
    },

    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
        resize_on_border = false,
        allow_tearing = true,
        layout = "dwindle",
        snap = {
            enabled = true,
        },
    },

    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        blur = {
            enabled = true,
            size = 2, -- 12
            passes = 4,
            new_optimizations = true,
            -- xray = true,
            -- vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
        -- force_split = 2,
        smart_split = true,
    },

    master = {
        new_on_active = "after",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = false,
        vrr = 3,
    },

    render = {
        direct_scanout = 2,
    },

    input = {
        kb_layout = "us",
        kb_variant = "intl",
        -- kb_model = "",
        -- kb_options = "",
        -- kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        -- accel_profile = "flat",
        -- touchpad = {
        --     natural_scroll = false,
        -- },
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

------------------
--- ANIMATIONS ---
------------------
hl.curve("custom-1", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "custom-1" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "custom-1" })

-------------------
--- KEYBINDINGS ---
-------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + CTRL + Q", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + M", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + L", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(home .. "/.config/hypr/print.sh"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd([[grimblast --notify save area ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H:%M:%S).png]]))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd([[grimblast --notify save screen ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H:%M:%S).png]]))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

--------------------------------
--- SPLIT-MONITOR-WORKSPACES ---
--------------------------------
-- Ensure you have cloned https://github.com/zjeffer/split-monitor-workspaces
-- into ~/.config/hypr/plugins/split-monitor-workspaces

package.path = package.path .. ";" .. home .. "/.config/hypr/?.lua;" .. home .. "/.config/hypr/?/init.lua"
local smw_ok, smw = pcall(require, "plugins.split-monitor-workspaces")

if smw_ok then
    smw.setup({
        workspace_count = 6,
        keep_focused = false,
        enable_notifications = false,
        enable_persistent_workspaces = true,
    })

    for i = 1, 6 do
        local n = tostring(i)
        hl.bind(mainMod .. " + " .. n, smw.workspace(n))
        hl.bind(mainMod .. " + SHIFT + " .. n, smw.move_to_workspace_silent(n))
    end

    -- Move active window to the next monitor (equivalent to split-changemonitor, next)
    -- Uses smw's function if present, otherwise falls back to Hyprland's native monitor move
    local change_mon = smw.move_to_monitor or smw.changemonitor
    if change_mon then
        hl.bind(mainMod .. " + O", change_mon("next"))
    else
        hl.bind(mainMod .. " + O", hl.dsp.window.move({ monitor = "+1" }))
    end

    -- Cycle workspaces on the current monitor (m+1 / m-1 cycles monitor-local workspaces)
    local cycle_ws = smw.cycle_workspace or smw.cycle_workspaces
    if cycle_ws then
        hl.bind(mainMod .. " + mouse_down", cycle_ws(1))
        hl.bind(mainMod .. " + mouse_up", cycle_ws(-1))
        hl.bind(mainMod .. " + ALT + left", cycle_ws(-1))
        hl.bind(mainMod .. " + ALT + right", cycle_ws(1))
    else
        hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
        hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "m-1" }))
        hl.bind(mainMod .. " + ALT + left", hl.dsp.focus({ workspace = "m-1" }))
        hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "m+1" }))
    end
end

-- Media & Volume Binds (locked = true keeps working on hyprlock, repeating = true allows holding)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -m"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next(), { repeating = true })

-- Switch windows around
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Resize windows
local resizeAmount = 30
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -resizeAmount, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = resizeAmount, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -resizeAmount, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = resizeAmount, relative = true }), { repeating = true })

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + F", hl.dsp.window.fullscreen())

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------
-- hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
    match = { class = "^(kitty)$" },
    suppress_event = "maximize fullscreen",
})
-- hl.window_rule({ match = { title = "(Rofi)" }, stay_focused = true })

hl.window_rule({
    match = { title = "Bruno" },
    float = true,
    center = true,
    size = { 1600, 1200 },
})
-- hl.window_rule({ match = { title = "Robo 3T - (.*)" }, float = true })

hl.window_rule({
    match = { title = ".*- KeePassXC.*" },
    float = true,
    center = true,
    size = { 900, 900 },
})


-- Games (Steam / gamescope)
hl.window_rule({
    match = { class = [[^(steam_app_\d+|gamescope)$]] },
    content = "game",
    immediate = true,
    no_blur = true,
    opacity = "1.0 override 1.0 override",
})

-- XIVLauncher and FFXIV
hl.window_rule({
    match = { class = [[^(XIVLauncher\.Core|ffxiv_dx11\.exe|ffxiv\.exe)$]] },
    content = "game",
    immediate = true,
    no_blur = true,
    opacity = "1.0 override 1.0 override",
})

hl.window_rule({
    match = { class = "^(transmission-gtk)$" },
    workspace = "6 silent",
})
-- hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0.4, blur = true, dim_around = true, animation = "popin 80%" })
-- hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
