Config { 
    font = "-*-terminus-medium-*-*-*-12-*-*-*-*-*-*-*",
    bgColor = "#121212",
    fgColor = "#AFAF87",
    position = Top,
    lowerOnStart = True,
    commands = [ 
        Run DynNetwork ["-t", "<dev> <fc=#387BAB><rx>kb/s</fc> <fc=#005F87><tx>kb/s</fc>", "-w", "4"] 15,
        Run Date "%a %m-%d %H:%M:%S " "date" 10,
        Run Com "/usr/bin/cut" ["-d", " ", "-f", "1-3", "/proc/loadavg"] "load" 50,
        Run StdinReader,
        Run Kbd [("us(altgr-intl)", "US"), ("gb_de", "GB")],
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
    template = " %StdinReader% <fc=#3F3F3F>| <fc=#D0CFD0>%mpd%</fc></fc> }{ <fc=#3F3F3F>%dynnetwork%</fc><fc=#3F3F3F> | KEY: <fc=#87FF00>%kbd%</fc> | %memory% | %cpu% | <fc=#B973FF>%load%</fc></fc><fc=#3F3F3F> | </fc><fc=#D0CFD0>%date%</fc>"
}
