Config { 
    font = "-*-terminus-medium-r-*-*-12-*-*-*-*-*-*-*",
    bgColor = "#121212",
    fgColor = "#AFAF87",
    position = Top,
    lowerOnStart = True,
    commands = [ 
        Run Date "%a %y-%m-%d %H:%M:%S %Z [%z] " "date" 10,
        Run Com "/usr/bin/cut" ["-d ' ' -f1-3 /proc/loadavg"] "load" 50,
        Run StdinReader,
        Run BufferedPipeReader "mpd"
            [ (  0, False, "/home/vehk/.mpdcron/pipes/pipe_player" ),
              ( 30, False, "/home/vehk/.mpdcron/pipes/pipe_mixer"  )
            ]
    ],
    template = " %StdinReader% }{ <fc=#D0CFD0>%mpd%<fc=#3F3F3F> | </fc></fc><fc=#B973FF>%load%</fc><fc=#3F3F3F> | </fc><fc=#D0CFD0>%date%</fc>"
}
