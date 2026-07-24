--[[
                                       
     Awesome WM configuration template 
     github.com/copycat-killer         
                                       
--]]

-- {{{ Required libraries
local awesome, client, screen, tag = awesome, client, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err) })
    in_error = false
  end)
end
-- }}}

-- {{{ Autostart windowless processes
local function run_once(cmd_arr)
  for _, cmd in ipairs(cmd_arr) do
    -- pgrep -x matches the process name, so strip any leading path from the command
    local name = cmd:match("^%S+"):match("[^/]+$")
    awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", name, cmd))
  end
end

run_once({ "~/keyboard.sh", "xset s off -dpms", "numlockx &", "xss-lock -- i3lock &", "/usr/bin/lxpolkit" })
-- }}}

-- {{{ Variable definitions
local chosen_theme = "powerarrow-dark"
local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "alacritty"
local editor       = os.getenv("EDITOR") or "nano"
local gui_editor   = "gvim"
local browser      = "firefox"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
awful.layout.layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  --awful.layout.suit.tile.left,
  --awful.layout.suit.tile.bottom,
  --awful.layout.suit.tile.top,
  --awful.layout.suit.fair,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.spiral,
  --awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  --awful.layout.suit.max.fullscreen,
  --awful.layout.suit.magnifier,
  --awful.layout.suit.corner.nw,
  --awful.layout.suit.corner.ne,
  --awful.layout.suit.corner.sw,
  --awful.layout.suit.corner.se,
  --lain.layout.cascade,
  --lain.layout.cascade.tile,
  --lain.layout.centerwork,
  --lain.layout.centerwork.horizontal,
  --lain.layout.termfair,
  --lain.layout.termfair.center,
}
awful.util.taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)
awful.util.tasklist_buttons = gears.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
      -- This will also un-minimize
      -- the client, if needed
      c:emit_signal("request::activate", "tasklist", { raise = true })
    end
  end),
  awful.button({}, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
  end))

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)
-- }}}

-- {{{ Menu
local myawesomemenu = {
  { "hotkeys", function() return false, hotkeys_popup.show_help end },
  { "manual", terminal .. " -e man awesome" },
  { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end }
}
awful.util.mymainmenu = freedesktop.menu.build({
  icon_size = beautiful.menu_height or 16,
  before = {
    { "Awesome", myawesomemenu, beautiful.awesome_icon },
    -- other triads can be put here
  },
  after = {
    { "Open terminal", terminal },
    -- other triads can be put here
  }
})
--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
  awful.button({}, 3, function() awful.util.mymainmenu:toggle() end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- where can be 'left' 'right' 'top' 'bottom' 'center' 'topleft' 'topright' 'bottomleft' 'bottomright' nil
local function snap_edge(c, where, geom)
  local sw       = c.screen.workarea --screen workarea
  local workarea = { x_min = sw.x, x_max = sw.x + sw.width, y_min = sw.y, y_max = sw.y + sw.height }
  local cg       = geom or c:geometry()
  local border   = c.border_width
  local cs       = c:struts()
  cs['left']     = 0
  cs['top']      = 0
  cs['bottom']   = 0
  cs['right']    = 0
  if where ~= nil then
    c:struts(cs) -- cancel struts when snapping to edge
  end
  if where == 'right' then
    cg.width  = sw.width / 2 - 2 * border
    cg.height = sw.height
    cg.x      = workarea.x_max - cg.width
    cg.y      = workarea.y_min
  elseif where == 'left' then
    cg.width  = sw.width / 2 - 2 * border
    cg.height = sw.height
    cg.x      = workarea.x_min
    cg.y      = workarea.y_min
  elseif where == 'bottom' then
    cg.width  = sw.width
    cg.height = sw.height / 2 - 2 * border
    cg.x      = workarea.x_min
    cg.y      = workarea.y_max - cg.height
    awful.placement.center_horizontal(c)
  elseif where == 'top' then
    cg.width  = sw.width
    cg.height = sw.height / 2 - 2 * border
    cg.x      = workarea.x_min
    cg.y      = workarea.y_min
    awful.placement.center_horizontal(c)
  elseif where == 'topright' then
    cg.width  = sw.width / 2 - 2 * border
    cg.height = sw.height / 2 - 2 * border
    cg.x      = workarea.x_max - cg.width
    cg.y      = workarea.y_min
  elseif where == 'topleft' then
    cg.width  = sw.width / 2 - 2 * border
    cg.height = sw.height / 2 - 2 * border
    cg.x      = workarea.x_min
    cg.y      = workarea.y_min
  elseif where == 'bottomright' then
    cg.width  = sw.width / 2 - 2 * border
    cg.height = sw.height / 2 - 2 * border
    cg.x      = workarea.x_max - cg.width
    cg.y      = workarea.y_max - cg.height
  elseif where == 'bottomleft' then
    cg.width  = sw.width / 2 - 2 * border
    cg.height = sw.height / 2 - 2 * border
    cg.x      = workarea.x_min
    cg.y      = workarea.y_max - cg.height
  elseif where == 'center' then
    awful.placement.centered(c)
    return
  elseif where == nil then
    c:struts(cs)
    c:geometry(cg)
    return
  end
  c.floating = true
  if c.maximized then c.maximized = false end
  c:geometry(cg)
  awful.placement.no_offscreen(c)
  return
end

-- {{{ Key bindings
local globalkeys = gears.table.join(
-- Take a screenshot
-- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
  awful.key({}, "Print",
    function()
      awful.spawn.with_shell(
        "scrot -u ~/screenshots/%Y-%m-%d-%T-screenshot.png -e 'xclip -selection clipboard -target image/png -i $f'")
    end,
    { description = "screenshot focused window", group = "screenshot" }),
  --awful.key({ }, "Print", function() awful.spawn.with_shell("gscreenshot -c -f ~/screenshots/%Y-%m-%d-%T-screenshot.png") end),
  awful.key({ modkey, altkey }, "l", function() awful.spawn.with_shell("xbacklight -set 0 && i3lock") end,
    { description = "lock screen", group = "awesome" }),

  awful.key({ "Shift" }, "Print",
    function()
      awful.spawn.with_shell(
        "sleep 0.2 && scrot -s ~/screenshots/%Y-%m-%d-%T-screenshot.png -e 'xclip -selection clipboard -target image/png -i $f'")
    end,
    { description = "screenshot selection", group = "screenshot" }),
  awful.key({ modkey }, "Print", function() awful.spawn.with_shell("sleep 0.2 && flameshot gui") end,
    { description = "flameshot gui", group = "screenshot" }),
  --awful.key({ "Shift" }, "Print", function() awful.spawn.with_shell("gscreenshot -s -c -f ~/screenshots/%Y-%m-%d-%T-screenshot.png") end),
  awful.key({}, "XF86MonBrightnessDown", function() awful.spawn.with_shell("xbacklight -dec 1") end),
  awful.key({}, "XF86MonBrightnessUp", function() awful.spawn.with_shell("xbacklight -inc 1") end),

  -- Hotkeys
  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),
  -- Tag browsing (skips empty tags)
  awful.key({ modkey, }, "Escape", awful.tag.history.restore,
    { description = "go back", group = "tag" }),
  awful.key({ modkey }, "Left", function() lain.util.tag_view_nonempty(-1) end,
    { description = "view previous nonempty", group = "tag" }),
  awful.key({ modkey }, "Right", function() lain.util.tag_view_nonempty(1) end,
    { description = "view next nonempty", group = "tag" }),

  -- Default client focus
  awful.key({ altkey }, "k",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "focus next by index", group = "client" }
  ),
  awful.key({ altkey }, "j",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "focus previous by index", group = "client" }
  ),

  -- By direction client focus
  awful.key({ modkey }, "j",
    function()
      awful.client.focus.bydirection("down")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey }, "k",
    function()
      awful.client.focus.bydirection("up")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey }, "h",
    function()
      awful.client.focus.bydirection("left")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey }, "l",
    function()
      awful.client.focus.bydirection("right")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey, }, "w", function() awful.util.mymainmenu:show() end,
    { description = "show main menu", group = "awesome" }),

  -- Layout manipulation
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
    { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
    { description = "swap with previous client by index", group = "client" }),
  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
    { description = "focus the next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
    { description = "focus the previous screen", group = "screen" }),
  awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey, }, "Tab",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    { description = "go back", group = "client" }),

  -- Show/Hide Wibox
  awful.key({ modkey }, "b", function()
    for s in screen do
      s.mywibox.visible = not s.mywibox.visible
      if s.mybottomwibox then
        s.mybottomwibox.visible = not s.mybottomwibox.visible
      end
    end
  end, { description = "toggle wibox", group = "awesome" }),

  -- On the fly useless gaps change
  awful.key({ altkey, "Control" }, "+", function() lain.util.useless_gaps_resize(1) end,
    { description = "increase useless gaps", group = "layout" }),
  awful.key({ altkey, "Control" }, "-", function() lain.util.useless_gaps_resize(-1) end,
    { description = "decrease useless gaps", group = "layout" }),

  -- Dynamic tagging
  awful.key({ modkey, "Shift" }, "n", function() lain.util.add_tag() end,
    { description = "add new tag", group = "tag" }),
  awful.key({ modkey, "Shift" }, "r", function() lain.util.rename_tag() end,
    { description = "rename tag", group = "tag" }),
  -- awful.key({ modkey, "Shift" }, "Left", function() lain.util.move_tag(-1) end), -- move to previous tag
  -- awful.key({ modkey, "Shift" }, "Right", function() lain.util.move_tag(1) end), -- move to next tag
  awful.key({ modkey, "Shift" }, "d", function() lain.util.delete_tag() end,
    { description = "delete tag", group = "tag" }),

  -- Standard program
  awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    { description = "reload awesome", group = "awesome" }),
  --[[awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),]] --

  awful.key({ altkey, "Shift" }, "l", function() awful.tag.incmwfact(0.05) end,
    { description = "increase master width factor", group = "layout" }),
  awful.key({ altkey, "Shift" }, "h", function() awful.tag.incmwfact(-0.05) end,
    { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
    { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
    { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
    { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
    { description = "decrease the number of columns", group = "layout" }),
  awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
    { description = "select next", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
    { description = "select previous", group = "layout" }),

  awful.key({ modkey, "Control" }, "n",
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal("request::activate", "key.unminimize", { raise = true })
      end
    end,
    { description = "restore minimized", group = "client" }),

  -- Dropdown application
  --awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end),

  -- Widgets popups
  --awful.key({ altkey, }, "c", function () lain.widget.calendar.show(7) end),
  --awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end),
  --awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end),

  -- ALSA volume control
  -- os.execute blocks the whole WM until amixer returns; spawn asynchronously
  -- and refresh the widget once the command has finished.
  awful.key({}, "XF86AudioRaiseVolume",
    function()
      awful.spawn.easy_async(string.format("amixer -q set %s 5%%+ unmute", beautiful.volume.channel),
        function() beautiful.volume.update() end)
    end),
  awful.key({}, "XF86AudioLowerVolume",
    function()
      awful.spawn.easy_async(string.format("amixer -q set %s 5%%- unmute", beautiful.volume.channel),
        function() beautiful.volume.update() end)
    end),
  awful.key({}, "XF86AudioMute",
    function()
      awful.spawn.easy_async(
        string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel),
        function() beautiful.volume.update() end)
    end),
  awful.key({ altkey, "Control" }, "m",
    function()
      awful.spawn.easy_async(string.format("amixer -q set %s 100%%", beautiful.volume.channel),
        function() beautiful.volume.update() end)
    end),
  awful.key({ altkey, "Control" }, "0",
    function()
      awful.spawn.easy_async(string.format("amixer -q set %s 0%%", beautiful.volume.channel),
        function() beautiful.volume.update() end)
    end),

  awful.key({}, "XF86AudioPlay", function() awful.spawn.with_shell("playerctl play-pause") end),
  awful.key({}, "XF86AudioNext", function() awful.spawn.with_shell("playerctl next") end),
  awful.key({}, "XF86AudioPrev", function() awful.spawn.with_shell("playerctl previous") end),

  -- MPD control
  awful.key({ altkey, "Control" }, "Up",
    function()
      awful.spawn.with_shell("mpc toggle")
      beautiful.mpd.update()
    end),
  awful.key({ altkey, "Control" }, "Down",
    function()
      awful.spawn.with_shell("mpc stop")
      beautiful.mpd.update()
    end),
  awful.key({ altkey, "Control" }, "Left",
    function()
      awful.spawn.with_shell("mpc prev")
      beautiful.mpd.update()
    end),
  awful.key({ altkey, "Control" }, "Right",
    function()
      awful.spawn.with_shell("mpc next")
      beautiful.mpd.update()
    end),
  --[[awful.key({ altkey }, "0",
        function ()
            local common = { text = "MPD widget ", position = "top_middle", timeout = 2 }
            if beautiful.mpd.timer.started then
                beautiful.mpd.timer:stop()
                common.text = common.text .. lain.util.markup.bold("OFF")
            else
                beautiful.mpd.timer:start()
                common.text = common.text .. lain.util.markup.bold("ON")
            end
            naughty.notify(common)
        end),
--]]
  -- Copy primary to clipboard (terminals to gtk)
  -- (needs a shell: awful.spawn does not understand pipes)
  awful.key({ modkey }, "c", function() awful.spawn.with_shell("xsel | xsel -i -b") end,
    { description = "copy primary to clipboard", group = "hotkeys" }),
  -- Copy clipboard to primary (gtk to terminals)
  awful.key({ modkey }, "v", function() awful.spawn.with_shell("xsel -b | xsel") end,
    { description = "copy clipboard to primary", group = "hotkeys" }),

  -- User programs
  awful.key({ modkey }, "e", function() awful.spawn(gui_editor) end,
    { description = "run gui editor", group = "launcher" }),
  awful.key({ modkey }, "q", function() awful.spawn(browser) end,
    { description = "run browser", group = "launcher" }),

  -- Default
  -- Menubar
  awful.key({ modkey }, "d", function() menubar.show() end,
    { description = "show the menubar", group = "launcher" }),
  -- dmenu
  --[[awful.key({ modkey }, "d", function ()
        awful.spawn(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
        beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
		end),
        --]]

  --[[awful.key({ modkey, altkey, "Shift"}, "End", function()

        local scr = awful.screen.focused()
        awful.prompt.run({prompt = "Power Off (type 'yes' to confirm)? "},
        awful.screen.focused().mypromptbox.widget,
        function (t)
            if string.lower(t) == 'yes' then
                awesome.emit_signal("exit", nil)
                awful.util.spawn("poweroff")
            end
        end,
        function (t, p, n)
            return awful.completion.generic(t, p, n, {'no', 'NO', 'yes', 'YES'})
        end) end,
        {description = "shutdown", group = "launcher"}),
--]]




  awful.key({ modkey, altkey, "Shift" }, "End", function()
    awful.prompt.run({ prompt = "Power Off (type 'yes' to confirm)? " },
      awful.screen.focused().mypromptbox.widget,
      function(t)
        if string.lower(t) == 'yes' then
          awesome.emit_signal("exit", nil)
          awful.spawn("poweroff")
        elseif string.lower(t) == 'reboot' then
          awesome.emit_signal("exit", nil)
          awful.spawn("reboot")
        elseif string.lower(t) == 'hibernate' then
          awful.spawn("systemctl hibernate")
        elseif string.lower(t) == 'suspend' then
          awful.spawn("systemctl suspend")
        elseif string.lower(t) == 'both' then
          awful.spawn("systemctl hybrid-sleep")
        end
      end,
      function(t, p, n)
        return awful.completion.generic(t, p, n, { 'yes', 'YES', 'reboot', 'hibernate', 'both', 'suspend' })
      end)
  end,
    { description = "shutdown", group = "launcher" }),

  awful.key({ modkey, altkey, "Shift" }, "m", function()
    awful.prompt.run({ prompt = "which monitor? " },
      awful.screen.focused().mypromptbox.widget,
      function(t)
        if string.lower(t) == 'v' then
          awful.spawn.with_shell("sleep 0.5 && xrandr --output eDP1 --primary --output DP1 --auto --right-of eDP1")
        elseif string.lower(t) == 'h' then
          awful.spawn.with_shell("sleep 0.5 && xrandr --output eDP1 --primary --output HDMI2 --auto --right-of eDP1")
        elseif string.lower(t) == 'x' then
          awful.spawn.with_shell("sleep 0.5 && xrandr --output DP1 --auto --off")
        elseif string.lower(t) == 'y' then
          awful.spawn.with_shell("sleep 0.5 && xrandr --output HDMI2 --auto --off")
        elseif string.lower(t) == 'o' then
          awful.spawn.with_shell("sleep 0.5 && xrandr --output HDMI2 --primary --auto --output eDP1 --auto --off")
        elseif string.lower(t) == 'f' then
          awful.spawn.with_shell("sleep 0.5 && xrandr --output eDP1 --auto --primary --output HDMI2 --auto --off")
        end
      end,
      function(t, p, n)
        return awful.completion.generic(t, p, n, { 'v', 'h', 'x', 'y', 'o', 'f' })
      end)
  end,
    { description = "change screen layout", group = "launcher" }),

  awful.key({ modkey }, "x",
    function()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    { description = "lua execute prompt", group = "awesome" })

)

local clientkeys = gears.table.join(
  awful.key({ altkey, "Shift" }, "m", lain.util.magnify_client,
    { description = "magnify client", group = "client" }),
  awful.key({ modkey, }, "f",
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end,
    { description = "close", group = "client" }),
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
    { description = "toggle floating", group = "client" }),
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
    { description = "move to master", group = "client" }),
  awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
    { description = "move to screen", group = "client" }),
  awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
    { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey, }, "n",
    function(c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end,
    { description = "minimize", group = "client" }),
  awful.key({ modkey, }, "m",
    function(c)
      c.maximized = not c.maximized
      c:raise()
    end,
    { description = "maximize", group = "client" }),
  awful.key({ modkey, "Shift" }, "Down", function(c) snap_edge(c, 'bottom') end,
    { description = "snap to bottom edge", group = "client" }),
  awful.key({ modkey, "Shift" }, "Left", function(c) snap_edge(c, 'left') end,
    { description = "snap to left edge", group = "client" }),
  awful.key({ modkey, "Shift" }, "Right", function(c) snap_edge(c, 'right') end,
    { description = "snap to right edge", group = "client" }),
  awful.key({ modkey, "Shift" }, "Up", function(c) snap_edge(c, 'top') end,
    { description = "snap to top edge", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = gears.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      { description = "move focused client to tag #" .. i, group = "tag" }),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

local clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = {},
    properties = { border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
      size_hints_honor = false
    }
  },

  -- Titlebars
  { rule_any = { type = { "dialog", "normal" } },
    properties = { titlebars_enabled = false } },

  { rule = { class = "Gimp", role = "gimp-image-window" },
    properties = { maximized = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- Custom
  if beautiful.titlebar_fun then
    beautiful.titlebar_fun(c)
    return
  end

  -- Default
  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({}, 1, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.move(c)
    end),
    awful.button({}, 3, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c, { size = 16 }):setup {
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout  = wibox.layout.fixed.horizontal
    },
    { -- Middle
      { -- Title
        align  = "center",
        widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout  = wibox.layout.flex.horizontal
    },
    { -- Right
      awful.titlebar.widget.floatingbutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton(c),
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
  end
end)

-- No border for maximized clients
local function update_border_width(c)
  c.border_width = c.maximized and 0 or beautiful.border_width
end

client.connect_signal("property::maximized", update_border_width)

client.connect_signal("focus",
  function(c)
    update_border_width(c)
    if not c.maximized and #awful.screen.focused().clients > 1 then
      c.border_color = beautiful.border_focus
    end
  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
