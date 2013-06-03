Config { 
    font = "-*-terminus-medium-*-*-*-12-*-*-*-*-*-*-*",
    bgColor = "#121212",
    fgColor = "#AFAF87",
    position = Top,
    lowerOnStart = True,
    commands = [ 
        Run DynNetwork ["-t", "<dev> <fc=#387BAB><rx>kb/s</fc> <fc=#005F87><tx>kb/s</fc>", "-w", "4"] 15,
        Run Date "%a %m-%d %H:%M:%S " "date" 10,
        Run Com "/usr/bin/cut" ["-d ' ' -f1-3 /proc/loadavg"] "load" 50,
        Run BatteryP ["BAT0"] [
                "-t", "<fc=#D0CFD0><acstatus></fc><left>", "-S", "True",
                "-L", "30", "-H", "70", "-p", "3",
                "-l", "#D74083", "-n", "#FF9926", "-h", "#93FF19",
                "--", "-O", "+", "-o", "-", "-f", "BAT0/subsystem/ADP0/online"
            ] 600,
        Run StdinReader,
        Run Memory ["-p", "2", "-c", "0", "-S", "True",
                 "-H", "80", "-h", "#D7005F", "-L", "50", "-l", "#87FF00", "-n", "#FF8700",
                 "-t", "RAM: <usedratio>"] 50,
        Run Cpu ["-p", "2", "-c", "0", "-S", "True",
                 "-H", "75", "-h", "#D7005F", "-L", "30", "-l", "#87FF00", "-n", "#FF8700",
                 "-t", "CPU: <total>"] 50,
        Run BufferedPipeReader "mpd"
            [ (  0, False, "/home/vehk/.mpdcron/pipes/pipe_player" ),
              ( 30, False, "/home/vehk/.mpdcron/pipes/pipe_mixer"  )
            ]
    ],
    template = " %StdinReader% <fc=#3F3F3F>| <fc=#D0CFD0>%mpd%</fc></fc> }{ <fc=#3F3F3F>%dynnetwork%</fc><fc=#3F3F3F> | %memory% | %cpu% | <fc=#B973FF>%load%</fc> | %battery%</fc><fc=#3F3F3F> | </fc><fc=#D0CFD0>%date%</fc>"
}
