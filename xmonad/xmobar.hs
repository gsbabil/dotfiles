Config { 
    font = "-*-terminus-medium-r-*-*-12-*-*-*-*-*-*-*",
    bgColor = "#121212",
    fgColor = "#AFAF87",
    position = Top,
    lowerOnStart = True,
    commands = [ 
        Run Date "%a %y-%m-%d %H:%M:%S %Z [%z] " "date" 10,
        Run Com "/usr/bin/cut" ["-d ' ' -f1-3 /proc/loadavg"] "load" 50,
        Run BatteryP ["BAT0"] [
                "-t", "<acstatus><watts> [<left>%]",
                "-L", "10", "-H", "80", "-p", "3",
                "--", "-O", "<fc=green>On</fc> - ", "-o", "",
                "-L", "-15", "-H", "-5",
                "-l", "red", "-m", "blue", "-h", "green"
            ] 600,
        Run PipeReader ":/home/vehk/.xmonad/pipe_mpd" "mpdpipe",
        Run StdinReader
    ],
    template = " %StdinReader% }{ <fc=#D0CFD0>%mpdpipe%<fc=#3F3F3F> | </fc></fc>%load%<fc=#3F3F3F> | </fc>%battery%<fc=#3F3F3F> | </fc><fc=#D0CFD0>%date%</fc>"
}
