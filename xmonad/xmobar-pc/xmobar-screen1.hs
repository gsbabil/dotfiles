Config { 
    font = "-*-terminus-medium-r-*-*-12-*-*-*-*-*-*-*",
    bgColor = "#121212",
    fgColor = "#AFAF87",
    position = Top,
    lowerOnStart = True,
    commands = [ 
        Run Date "%a %m-%d %H:%M:%S " "date" 10,
        Run StdinReader
    ],
    template = " %StdinReader% }{ <fc=#D0CFD0>%date%</fc>"
}
