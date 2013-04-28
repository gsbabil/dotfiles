Config { 
    font = "-*-terminus-medium-r-*-*-12-*-*-*-*-*-*-*",
    bgColor = "#121212",
    fgColor = "#AFAF87",
    position = Top,
    lowerOnStart = True,
    commands = [ 
        Run Network "enp5s0" ["-t", "<dev> <fc=#387BAB><rx>kb/s</fc> <fc=#005F87><tx>kb/s</fc>", "-w", "4"] 15,
        Run Memory [] 50,
        Run Date "%a %y-%m-%d %H:%M:%S %Z [%z] " "date" 10,
        Run StdinReader
    ],
    template = " %StdinReader% }{ <fc=#3F3F3F> %enp5s0% |</fc> <fc=#B973FF>%memory%</fc> <fc=#3F3F3F>|</fc> <fc=#D0CFD0>%date%</fc>"
}
