import System.IO
import System.Exit
import Control.Monad (liftM2)

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Renamed
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile
import XMonad.Util.Run(spawnPipe, safeSpawn)
import XMonad.Util.EZConfig(additionalKeys)
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

terminal' = "/usr/bin/urxvtc"
dmenu = "dmenu_run -i -fn '-*-terminus-medium-r-*-*-16-*-*-*-*-*-*-*' -p 'Run:'"

workspaces' = ["1:hub","2:web","3:irc","4:src","5:img"] ++ map show [6..9]
 
manageHook' = composeOne [ 
    isFullscreen -?> doFullFloat,

    (className =? "Firefox" <&&> resource =? "DTA") -?> doShift "9",
    (className =? "Firefox" <&&> resource =? "Download") -?> doShift "9",
    className =? "Firefox" -?> doShift "2:web",

    className =? "Sxiv" -?> viewShift "5:img",
    className =? "mplayer2" -?> doFloat,

    (className =? "URxvt" <&&> resource =? "float") -?> doFloat,
    (className =? "URxvt" <&&> resource =? "irc") -?> doShift "3:irc",
    (className =? "URxvt" <&&> resource =? "hub") -?> doShift "1:hub",

    -- Any other window will be swapped down
    return True -?> doF W.swapDown
    ]
    where
        viewShift = doF . liftM2 (.) W.greedyView W.shift

layout' = onWorkspace "5:img" (full ||| tile) $ tile ||| mtile ||| full
    where
        rt = ResizableTall 1 (2/100) (1/2) []
        tile = renamed [Replace "[]="] $ smartBorders rt
        mtile = renamed [Replace "M[]="] $ smartBorders $ Mirror rt
        full = renamed [Replace "[]"] $ noBorders Full 

normalBorderColor'  = "#282828"
focusedBorderColor' = "#D0CFD0"
fontName' = "-*-terminus-medium-r-*-*-12-*-*-*-*-*-*-*"
xmobarTitleColor = "#FFB6B0"
xmobarCurrentWorkspaceColor = "#CEFFAC"
borderWidth' = 1


modMask' = mod4Mask
 
keys' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  [ 
    ((modMask, xK_Return), safeSpawn (XMonad.terminal conf) []),
    ((modMask, xK_BackSpace), safeSpawn (XMonad.terminal conf) ["-name", "float"]),

    ((modMask .|. controlMask, xK_l), safeSpawn ("i3lock") ["-c","000000"]),
    ((modMask, xK_p), spawn dmenu),

    ((modMask .|. controlMask, xK_k), safeSpawn ("amixer") ["-q","set","Master","playback","2+db"]),
    ((modMask .|. controlMask, xK_j), safeSpawn ("amixer") ["-q","set","Master","playback","2-db"]),

    ((modMask, xK_d), safeSpawn ("dmnt") ["-dn"]),
    ((modMask .|. shiftMask, xK_d), safeSpawn ("dmnt") ["-dnu"]),

    ((modMask, xK_u), safeSpawn ("dmnt") ["-n"]),
    ((modMask .|. shiftMask, xK_u), safeSpawn ("dmnt") ["-nu"]),

    ((modMask, xK_p), safeSpawn ("scrot") ["-e","mv $f ~/etc/scrot/"]),

    ((modMask .|. shiftMask, xK_c), kill),

    ((modMask, xK_space), sendMessage NextLayout),
    ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),
    ((modMask, xK_n), refresh),

    ((modMask, xK_j), windows W.focusDown),
    ((modMask, xK_k), windows W.focusUp  ),
    ((modMask, xK_m), windows W.focusMaster  ),

    ((modMask .|. shiftMask, xK_Return), windows W.swapMaster),
    ((modMask .|. shiftMask, xK_j), windows W.swapDown  ),
    ((modMask .|. shiftMask, xK_k), windows W.swapUp    ),

    ((modMask, xK_h), sendMessage Shrink),
    ((modMask, xK_l), sendMessage Expand),

    ((modMask, xK_t), withFocused $ windows . W.sink),

    ((modMask, xK_comma), sendMessage (IncMasterN 1)),
    ((modMask, xK_period), sendMessage (IncMasterN (-1))),

    ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess)),
    ((modMask, xK_q), restart "xmonad" True)
  ]
  ++
 
  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++

  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
 
 
customPP = defaultPP { ppCurrent = xmobarColor "#A6E22E" "",
                       ppHidden = xmobarColor "#AFAF87" "",
                       ppUrgent = xmobarColor "#D7005F" "" . wrap "[" "]",
                       ppLayout = xmobarColor "#AE81FF" "",
                       ppTitle  = xmobarColor "#D0CFD0" "" . shorten 80,
                       ppSep    = xmobarColor "#3F3F3F" "" " | "
                     }

startupHook' = do
    safeSpawn ("~/.xmonad/startup") []

main = do
  xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobar.hs"
  xmonad $ uhook defaults {
      logHook = dynamicLogWithPP $ customPP
      {
          ppOutput = hPutStrLn xmproc
      }
      , manageHook = manageDocks <+> manageHook'
  }
  where
      uhook = withUrgencyHookC NoUrgencyHook uconf 
      uconf = UrgencyConfig { suppressWhen = Focused, remindWhen = Dont }

defaults = defaultConfig {
    -- simple stuff
    terminal           = terminal',
    focusFollowsMouse  = True,
    borderWidth        = borderWidth',
    modMask            = modMask',
    workspaces         = workspaces',
    normalBorderColor  = normalBorderColor',
    focusedBorderColor = focusedBorderColor',
 
    -- key bindings
    keys               = keys',
 
    -- hooks, layouts
    layoutHook         = smartBorders $ avoidStruts $ layout',
    manageHook         = manageHook',
    startupHook        = startupHook'
}
