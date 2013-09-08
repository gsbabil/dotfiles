import System.IO
import System.Exit
import Control.Monad (liftM2)

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.Renamed
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile
import XMonad.Actions.CycleWS
import XMonad.Actions.PhysicalScreens
import XMonad.Util.Scratchpad
import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.XMonad
import XMonad.Prompt.RunOrRaise
import XMonad.Util.Run(spawnPipe, safeSpawn)
import XMonad.Util.EZConfig(additionalKeys)
import qualified XMonad.Hooks.EwmhDesktops as E
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.List (isInfixOf)

terminal' = "/usr/bin/urxvtc"
dmenu = "dmenu_run -i -fn '-*-terminus-medium-r-*-*-16-*-*-*-*-*-*-*' -p 'Run:'"

workspaces' = ["1:hub","2:web","3:irc","4:src","5:ssh","6:rt","7:dl","8:fs","9:fs"]
 
manageHook' = composeOne [ 
    isFullscreen -?> doFullFloat,

    (className =? "Firefox" <&&> resource =? "DTA")      -?> doShift "7:dl",
    (className =? "Firefox" <&&> resource =? "Download") -?> doShift "7:dl",
    className  =? "Firefox"                              -?> doShift "2:web",

    (className =? "URxvt" <&&> resource =? "irc") -?> doShift "3:irc",
    (className =? "URxvt" <&&> resource =? "hub") -?> doShift "1:hub",
    (className =? "URxvt" <&&> resource =? "ssh") -?> doShift "5:ssh",
    (className =? "URxvt" <&&> resource =? "rt") -?> doShift "6:rt",

    -- Avoid the master window but otherwise manage new windows normally
    isDialog -?> doF avoidMaster,

    -- Any other window will be swapped down
    return True -?> doF W.swapDown
    ]

avoidMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
avoidMaster = W.modify' $ \c -> case c of
     W.Stack t [] (r:rs) ->  W.Stack t [r] rs
     otherwise           -> c

layout' = avoidStrutsOn [U] (full ||| tile ||| tab) ||| full'
    where
        rt    = ResizableTall 1 (2/100) (1/2) []
        tile  = renamed [Replace "[]="]  $ smartBorders rt
        full  = renamed [Replace "[]"]   $ noBorders Full
        full' = renamed [Replace "[]F"]  $ noBorders Full
        tab   = renamed [Replace "[T]"]  $ tabbedBottom shrinkText tabconfig

normalBorderColor'          = "#282828"
focusedBorderColor'         = "#D0CFD0"
fontName'                   = "-*-terminus-medium-r-*-*-12-*-*-*-*-*-*-*"
xmobarTitleColor            = "#FFB6B0"
xmobarCurrentWorkspaceColor = "#CEFFAC"
borderWidth'                = 1

modMask' = mod4Mask

keys' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  [ 
    ((modMask, xK_Return), safeSpawn (XMonad.terminal conf) []),

    ((modMask, xK_o), scratchpadSpawnAction conf),
    ((modMask, xK_0), toggleOrView "NSP"),

    ((modMask .|. controlMask, xK_l), safeSpawn ("i3lock") ["-c","000000"]),
    ((modMask, xK_p), spawn dmenu),

    ((modMask .|. controlMask, xK_k), safeSpawn ("amixer") ["-q","set","Master","playback","4+db"]),
    ((modMask .|. controlMask, xK_j), safeSpawn ("amixer") ["-q","set","Master","playback","4-db"]),

    ((modMask, xK_i), safeSpawn ("dmnt") ["-dn"]),
    ((modMask .|. shiftMask, xK_i), safeSpawn ("dmnt") ["-dnu"]),

    ((modMask, xK_u), safeSpawn ("dmnt") ["-n"]),
    ((modMask .|. shiftMask, xK_u), safeSpawn ("dmnt") ["-nu"]),

    ((modMask, xK_m), safeSpawn ("dmpd") []),
    ((modMask, xK_y), safeSpawn ("dtmx") []),

    ((modMask, xK_g), windowPromptGoto promptConfig),
    ((modMask, xK_b), windowPromptBring promptConfig),
    ((modMask, xK_x), xmonadPrompt promptConfig),

    ((modMask .|. shiftMask, xK_p), safeSpawn ("scrot") ["-e","mv $f ~/etc/scrot/"]),

    ((modMask .|. shiftMask, xK_c), kill),

    ((modMask, xK_space), sendMessage NextLayout),
    ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),
    ((modMask, xK_n), refresh),

    ((modMask, xK_j), windows W.focusDown),
    ((modMask, xK_k), windows W.focusUp  ),
    ((modMask .|. shiftMask, xK_m), windows W.focusMaster  ),

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

  -- mod-[1..9], Switch to workspace N or, if already there,
  -- go to last selected workspace
  [((modMask, k), toggleOrDoSkip ["NSP"] W.greedyView $ i)
      | (i, k) <- zip (workspaces') [xK_1 .. xK_9]]
  ++

  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.shift, shiftMask)]]
  ++

  --
  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  --
  [((modMask .|. mask, key), f sc)
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
      , (f, mask) <- [(viewScreen, 0), (sendToScreen, shiftMask)]]
 
customPP = defaultPP { ppCurrent = xmobarColor "#A6E22E" "",
                       ppHidden  = \x -> if x == "NSP" then "" else x,
                       ppVisible = xmobarColor "#D0CFD0" "" . wrap "(" ")",
                       ppUrgent  = xmobarColor "#D7005F" "" . wrap "[" "]",
                       ppLayout  = xmobarColor "#AE81FF" "",
                       ppTitle   = \s -> "",
                       ppSep     = xmobarColor "#3F3F3F" "" " | "
                     }

startupHook' = do
    safeSpawn ("/home/vehk/.xmonad/startup") []

tabconfig = defaultTheme {
    inactiveColor = "#121112",
    inactiveBorderColor = "#282828",
    inactiveTextColor = "#AFAF87",
    activeTextColor = "#D0CFD0",
    activeColor = "#202020",
    urgentTextColor = "#D7005F",
    urgentColor = "#121112",
    urgentBorderColor = "#D74083",
    decoHeight = 16,
    fontName = "-*-terminus-medium-r-*-*-12-*-*-*-*-*-*-*"
    }

promptConfig = defaultXPConfig {
    font     = "-*-terminus-medium-r-*-*-16-*-*-*-*-*-*-*",
    bgColor  = "#121112",
    promptBorderWidth = 0,
    fgColor  = "#D0CFD0",
    fgHLight = "#D7005F",
    bgHLight = "#121112",
    position = Top,
    searchPredicate = isInfixOf,
    showCompletionOnTab = True,
    alwaysHighlight = True
}

main = do
  xmproc  <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
  xmproc1 <- spawnPipe "xmobar -x1 ~/.xmonad/xmobar1.hs"
  xmonad $ E.ewmh $ uhook defaults {
      logHook = dynamicLogWithPP $ customPP
      {
          ppOutput = \x -> hPutStrLn xmproc x >> hPutStrLn xmproc1 x
      }
      , manageHook = scratch <+> manageDocks <+> manageHook'
  }
  where
      uhook   = withUrgencyHookC NoUrgencyHook uconf
      uconf   = UrgencyConfig { suppressWhen = Focused, remindWhen = Dont }
      scratch = scratchpadManageHookDefault

defaults = defaultConfig {
    -- simple stuff
    terminal           = terminal',
    focusFollowsMouse  = True,
    borderWidth        = borderWidth',
    modMask            = modMask',
    workspaces         = workspaces',
    normalBorderColor  = normalBorderColor',
    focusedBorderColor = focusedBorderColor',
    handleEventHook    = handleEventHook defaultConfig <+> E.fullscreenEventHook,
 
    -- key bindings
    keys               = keys',
 
    -- hooks, layouts
    layoutHook         = smartBorders $ layout',
    manageHook         = manageHook',
    startupHook        = startupHook'
}

