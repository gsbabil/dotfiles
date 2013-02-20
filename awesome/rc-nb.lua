-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local vicious = require("vicious")
-- Orglendar
local cal = require("cal")
-- Rodentbane
-- local rodentbane = require("rodentbane")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, an error happened!",
        text = err })
        in_error = false
    end)
end
-- }}}

--autostart
awful.util.spawn_with_shell(awful.util.getdir("config") .. "/autostart")

-- function aliases
local exec = function(cmd) awful.util.spawn(cmd, false) end

-- highlight function
function hi_string(string, color)
    tag="<span color=\""..color.."\">"
    tagend="</span>"
    return tag..string..tagend
end

-- naughty config
--naughty.config.default_preset.icon_size     = 125
--naughty.config.default_preset.border_width  = 2
--naughty.config.default_preset.hover_timeout = nil

-- keys for keyboard navigation of menus
awful.menu.menu_keys = {
    up    = { "k", "Up" },
    down  = { "j", "Down" },
    exec  = { "l", "Return", "Right" },
    enter = { "l", "Return", "Right" },
    back  = { "h", "Left" },
    close = { "q", "Escape" },
}

-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/zenburn/theme.lua")

gears.wallpaper.maximized("/home/vehk/.current_wallpaper", s, true)

terminal = "urxvtc"
terminal_float = "urxvtc -name float"
editor = "vim"
editor_cmd = editor

modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    --awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- {{{ Tags
tags = {
    names1 = { "1:hub", "2:www", "3:irc", "4:src", "5:ssh", 6, 7, 8, "9:dl" },
}

tags[1] = awful.tag(tags.names1, 1, layouts[1])

awful.tag.setproperty(tags[1][3], "mwfact", 0.6)
awful.tag.setproperty(tags[1][9], "layout", awful.layout.suit.tile.bottom)

-- }}}

-- {{{ Menu
menu_awesome = {
    { "lock", "i3lock -c000000" },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}

menu_mux = {
    { "hub", "urxvtc -name hub -e bash -c '~/bin/attach hub'" },
    { "irc", "urxvtc -name irc -e bash -c '~/bin/attach irc'" },
    { "ssh", "urxvtc -name ssh -e bash -c '~/bin/attach ssh'" },
    { "fs", "urxvtc -name fs -e bash -c '~/bin/attach fs'" },
}

menu_main = awful.menu({
    items = { 
        { "awesome", menu_awesome, beautiful.awesome_icon },
        { "tmux", menu_mux },
        { "terminal", terminal },
        { "firefox-nv", "optirun firefox" },
        { "firefox-in", "firefox" },
    }
})

mylauncher = awful.widget.launcher({ 
    image = beautiful.awesome_icon,
    menu  = menu_main
})
-- }}}

-- {{{ Wibox
clock = wibox.widget.textbox()
vicious.register(clock, vicious.widgets.date, " %a %y-%m-%d %H:%M:%S %Z [%z] ", 1)
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mystatusbar = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag)
--awful.button({ }, 4, awful.tag.viewnext),
--awful.button({ }, 5, awful.tag.viewprev)
)

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
    if c == client.focus then
        c.minimized = true
    else
        if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
end),
awful.button({ }, 3, function ()
    if instance then
        instance:hide()
        instance = nil
    else
        instance = awful.menu.clients({ width=250 })
    end
end),
awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
end),
awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end)
)
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(clock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

padding = wibox.widget.textbox()
padding:set_text(" ")

uptimewidget = wibox.widget.textbox()

vicious.register(uptimewidget, vicious.widgets.uptime,
function (widget, args)
    load1 = hi_string(args[4], beautiful.fg_normal)
    load5 = hi_string(args[5], beautiful.fg_focus)
    load15 = hi_string(args[6], beautiful.fg_urgent)

    ld = string.format("[%s %s %s]",load1,load5,load15)

    return ld
end,5)

-- Create mpd widget
mpdwidget = wibox.widget.textbox()

-- Register widget
--vicious.register(mpdwidget, vicious.widgets.mpd,
--function (widget, args)
--state = args["{state}"]
--if state == "Play" or state == "Pause" then
--artist = args["{Artist}"]
--title = args["{Title}"]

--artist_f = hi_string(artist, beautiful.fg_focus)
--title_f  = hi_string(title, beautiful.fg_urgent)

--return string.format("%s - %s", artist_f, title_f)
--end
--return ""
--end,3)

function mpdcron (mpdinf)
    local mpdtext = ""
    if (mpdinf.state == "play" or mpdinf.state == "pause") then
        artist = awful.util.escape(mpdinf.artist)
        title = awful.util.escape(mpdinf.title)

        artist_f = hi_string(artist, beautiful.fg_focus)
        title_f  = hi_string(title, beautiful.fg_urgent)

        mpdtext = string.format("%s - %s", artist_f, title_f)
    else
        mpdtext = ""
    end

    mpdwidget:set_markup(mpdtext)
end

cpugraph = awful.widget.graph()
--cpugraph:set_width(120)
--cpugraph:set_height(16)
--cpugraph:set_background_color(beautiful.fg_off_widget)

--vicious.register(cpugraph, vicious.widgets.cpu,
--function (widget, args )
--cpus = args[1]

--return cpus
--end,2)

batwidget = wibox.widget.textbox()

vicious.register(batwidget, vicious.widgets.bat,
function (widget, args)
    status = hi_string(args[1], beautiful.fg_focus)
    color = args[2] >= 65 and beautiful.fg_normal or args[2] >= 35 and beautiful.fg_focus or beautiful.fg_urgent
    percentage = (args[2] == 100) and "" or " "..hi_string(args[2].."%", color)
    remaining = (args[3] == "N/A") and "" or " "..hi_string(args[3], beautiful.fg_normal)

    return string.format("[%s%s%s]", status, percentage, args[2] <=50 and remaining or "")
end, 10, "BAT0")

-- volume widgets
volwidget = wibox.widget.textbox()

vicious.register(volwidget, vicious.widgets.volume,
function (widget, args)
    volume = hi_string(string.format("%02d", args[1]).."%", beautiful.fg_focus)
    local label = { ["♫"] = "", ["♩"] = "M" }
    str = string.format("[%s]", label[args[2]] == "M" and hi_string("MUT", beautiful.fg_urgent) or volume)
    return str
end, 2, "Master")

volwidget:buttons(awful.util.table.join(
    awful.button({ }, 4, function () exec("mpc -q volume +2", false) end),
    awful.button({ }, 5, function () exec("mpc -q volume -2", false) end)
))
--fs widgets
fstmpwidget = wibox.widget.textbox()

--vicious.register(fstmpwidget, vicious.widgets.fs,
--function (widget, args)
--tmp_p = hi_string(args["{/tmp used_p}"] .. "%", beautiful.fg_urgent)
--shm_p = hi_string(args["{/dev/shm used_p}"] .. "%", beautiful.fg_urgent)
--var_p = hi_string(args["{/var used_p}"] .. "%", beautiful.fg_urgent)
--home_p = hi_string(args["{/home used_p}"] .. "%", beautiful.fg_urgent)
--root_p = hi_string(args["{/ used_p}"] .. "%", beautiful.fg_urgent)

--tmp = hi_string("/tmp: ", beautiful.fg_focus)
--shm = hi_string("/shm: ", beautiful.fg_focus)
--var = hi_string("/var: ", beautiful.fg_focus)
--home = "/home: " 

--return "/root: "..root_p.." "..home..home_p.."  "..tmp..tmp_p.." "..shm..shm_p.." "..var..var_p

--end, 10)

-- Initialize widget
netwidget = wibox.widget.textbox()
-- Register widget
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
    down_f = args["{enp3s0 down_kb}"] .. "kb "
    up_f = args["{enp3s0 up_kb}"] .. "kb"
    down = hi_string(down_f, beautiful.fg_urgent)
    up = hi_string(up_f, beautiful.fg_focus)
    wlan_down_f = args["{wlp2s0 down_kb}"] .. "kb "
    wlan_up_f = args["{wlp2s0 up_kb}"] .. "kb"
    wlan_down = hi_string(wlan_down_f, beautiful.fg_urgent)
    wlan_up = hi_string(wlan_up_f, beautiful.fg_focus)

    tap_string = ""
    if (args["{tap0 carrier}"]) then
        tap_down_f = args["{tap0 down_kb}"] .. "kb "
        tap_up_f = args["{tap0 up_kb}"] .. "kb"
        tap_down = hi_string(tap_down_f, beautiful.fg_urgent)
        tap_up = hi_string(tap_up_f, beautiful.fg_focus)
        tap_string = " | [vpn " .. tap_down .. tap_up .. "]"
    end
    return "[" .. down .. up .. "] | [" .. wlan_down .. wlan_up .. "]".. tap_string
end, 2)

mystatusbar = awful.wibox({ position = "bottom", screen = 1 })

local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(padding)
left_layout:add(uptimewidget)
left_layout:add(padding)
left_layout:add(netwidget)
left_layout:add(padding)

local right_layout = wibox.layout.fixed.horizontal()
right_layout:add(mpdwidget)
right_layout:add(padding)
right_layout:add(volwidget)
right_layout:add(padding)
right_layout:add(batwidget)

local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_right(right_layout)

mystatusbar:set_widget(layout)
-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () menu_main:toggle() end)
-- awful.button({ }, 4, awful.tag.viewnext),
-- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
awful.key({ modkey, "Shift"   }, "b", awful.tag.history.restore),

awful.key({ modkey,           }, "j",
function ()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "k",
function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "w", function () menu_main:show({keygrabber=true}) end),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
awful.key({ modkey,           }, ";", function () awful.screen.focus_relative(1) end),
awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
awful.key({ modkey,           }, "b",
function ()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
end),

-- Tag movement
awful.key({ modkey,           }, "[", awful.tag.viewprev ),
awful.key({ modkey,           }, "]", awful.tag.viewnext ),

-- Standard program
awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal_float) end),
awful.key({ modkey, "Control" }, "r", awesome.restart),
awful.key({ modkey, "Shift"   }, "q", awesome.quit),

awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

awful.key({ modkey, "Control" }, "n", awful.client.restore),

-- Music Player Daemon and audio volume controls
awful.key({}, "XF86AudioRaiseVolume", function () exec("amixer -q set Master playback 2+db") end),
awful.key({}, "XF86AudioLowerVolume",  function () exec("amixer -q set Master playback 2-db") end),
awful.key({}, "XF86AudioMute", function () exec("amixer -q set Master toggle") end),

awful.key({}, "XF86AudioNext", function () exec("mpc next") end),
awful.key({}, "XF86AudioPrev", function () exec("mpc prev") end),
awful.key({}, "XF86AudioPlay", function () exec("mpc toggle") end),

-- Misc
awful.key({ modkey }, "F12", function () awful.util.spawn("i3lock --color 000000") end),

-- Prompt
awful.key({ modkey },            "p",     function () mypromptbox[mouse.screen]:run() end),

-- dmenu prompt
awful.key({ modkey },            "r",     function ()
    awful.util.spawn("dmenu_run -b -i -fn '-*-terminus-medium-r-*-*-16-*-*-*-*-*-*-*' -p 'Run command:' -nb '" ..
    beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. 
    "' -sb '" .. beautiful.bg_focus .. 
    "' -sf '" .. beautiful.fg_focus .. "'") 
end),

-- mount/umount prompt (https://github.com/vehk/dmenu-scripts)
awful.key({ modkey },            "d",     function () awful.util.spawn("dmnt -dn") end),
awful.key({ modkey, "Shift" },   "d",     function () awful.util.spawn("dmnt -dnu") end),
awful.key({ modkey },            "m",     function () awful.util.spawn("dmnt -n") end),
awful.key({ modkey, "Shift" },   "m",     function () awful.util.spawn("dmnt -nu") end),

-- take screenshots with scrot
awful.key( {}, "Print", function() awful.util.spawn("scrot -e 'mv $f ~/etc/scrot/ 2>/dev/null'") end),

-- get rid of this pesky rodent
-- awful.key( { modkey }, "b", function() rodentbane.start() end),

awful.key({ modkey }, "q", function ()
    -- If you want to always position the menu on the same place set coordinates
    local cmenu = awful.menu.clients({ theme = { width=500 }}, { keygrabber=true, coords={x=525, y=330} })
end),

awful.key({ modkey }, "x",
function ()
    awful.prompt.run({ prompt = "Run Lua code: " },
    mypromptbox[mouse.screen].widget,
    awful.util.eval, nil,
    awful.util.getdir("cache") .. "/history_eval")
end),

awful.key( {}, "XF86TouchpadToggle", function() exec("touchctrl") end)
)

clientkeys = awful.util.table.join(
awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
awful.key({ modkey, "Shift"   }, "f",  awful.client.floating.toggle                     ),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky            end),
awful.key({ modkey,           }, "n",
function (c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end),
awful.key({ modkey, "Shift" }, "x",
function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
    keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewonly(tags[screen][i])
        end
    end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewtoggle(tags[screen][i])
        end
    end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.movetotag(tags[client.focus.screen][i])
        end
    end),
    awful.key({ modkey }, "F" .. i,
    function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.toggletag(tags[client.focus.screen][i])
        end
    end))
end

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
    properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = true,
        size_hints_honor = false,
        keys = clientkeys,
        maximized_vertical = false,
        maximized_horizontal = false,
        buttons = clientbuttons 
    } 
},
{ rule = { class = "mplayer2" },
properties = { floating = true, ontop = true } },
{ rule = { class = "mplayer" },
properties = { floating = true, ontop = true } },
{ rule = { class = "pinentry" },
properties = { floating = true } },
{ rule = { class = "feh" },
properties = { floating = true } },
{ rule = { class = "Sxiv" },
properties = { floating = true } },
{ rule = { class = "Gifview" },
properties = { floating = true } },
{ rule = { class = "URxvt", instance = "hub" },
properties = { tag = tags[1][1] } },
{ rule = { class = "URxvt", instance = "ssh" },
properties = { tag = tags[1][5] } },
{ rule = { class = "URxvt", instance = "irc" },
properties = { tag = tags[1][3] } },
{ rule = { class = "URxvt", instance = "float" },
properties = { floating = true } },
{ rule = { class = "Firefox" },
properties = { tag = tags[1][2], focus = false } },
{ rule = { class = "Firefox", instance = "DTA" },
properties = { tag = tags[1][9] } },
{ rule = { class = "Firefox", instance = "Download" },
properties = { floating = true } },
{ rule = { instance = "plugin-container" },
properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    c:connect_signal("property::sticky", function(c)
        if c.sticky then
            c.border_color = beautiful.border_sticky
        else
            if c.focus then
                c.border_color = beautiful.border_focus
            else
                c.border_color = beautiful.border_normal
            end
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
        ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) 
    if c.sticky then
        c.border_color = beautiful.border_sticky_focus
    else
        c.border_color = beautiful.border_focus
    end

end)

client.connect_signal("unfocus", function(c)
    if c.sticky then
        c.border_color = beautiful.border_sticky
    else
        c.border_color = beautiful.border_normal
    end

end)
-- }}}
