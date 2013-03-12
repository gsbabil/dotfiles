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
                "-t", "<acstatus><left>", "-S", "True",
                "-L", "30", "-H", "70", "-p", "3",
                "-l", "#D74083", "-n", "#FF9926", "-h", "#93FF19",
                "--", "-O", "+", "-o", "-", "-f", "BAT0/subsystem/ADP0/online"
            ] 600,
        Run StdinReader,
        Run BufferedPipeReader "mpd"
            [ (  0, False, "/home/vehk/.mpdcron/pipes/pipe_player" ),
              ( 30, False, "/home/vehk/.mpdcron/pipes/pipe_mixer"  )
            ]
    ],
    template = " %StdinReader% }{ <fc=#D0CFD0>%mpd%<fc=#3F3F3F> | </fc></fc><fc=#B973FF>%load%</fc><fc=#4F3F3F> | </fc>%battery%<fc=#3F3F3F> | </fc><fc=#D0CFD0>%date%</fc>"
}
