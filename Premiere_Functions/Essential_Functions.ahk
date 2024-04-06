#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force ; Only one version of this script may run at a time
#MaxHotkeysPerInterval, 2000
#WinActivateForce

/*
 * DESCRIPTION:
 * 
 * This script holds the essential functions for the Premiere Pro with AutoHotKey project
 * User functions will call functions in this script, no user input will be taken here
 *
 * More niche functions will be stored in a different script, these are the primary
 * essential functions that are most likely to be used
 */

; Global Variables
global CONFIG_FILEPATH := "PremiereWithAHKConfig.ini"
global POPULATED_ESSENTIAL_GLOBALS := False
global DISPLAY_SCALING_VALUE := -1

; Required Custom Keybinds for Script Functions
; Value of "DEFAULT" will be overridden
; The values for these are stored in the .ini config file, but the reason we store these
; as global values is because AHK is an absolute MESS and this helps a lot with
; readability in comparison to doing an IniRead command every time these need to be used
global SHUTTLE_STOP          := "DEFAULT"
global FOCUS_TIMELINE        := "DEFAULT"
global FOCUS_PROJECT         := "DEFUALT"
global FOCUS_SOURCE_MONITOR  := "DEFAULT"
global FOCUS_PROGRAM_MONITOR := "DEFAULT"
global FOCUS_EFFECT_CONTROLS := "DEFAULT"
global FOCUS_EFFECTS         := "DEFAULT"
global SEARCH_BOX            := "DEFAULT"
global CREATE_MARKER         := "DEFAULT"

debugTest()
{
    ; This function is a dumping ground for making sure stuff works
    
    IniRead, debugTestCmd, %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.set.marker
    MsgBox % debugTestCmd
    ;SendInput, %debugTestCmd%
} ; end of debugTest()


populateEssentialGlobals()
{
    ; Grabs the data set by the python script from the configuration file and adjusts the
    ; values of the global variables of the script accordingly
    ; Outputs to a temporary variable first because ini file reading to global can be
    ; iffy at times
    ; Also all of the keys in the config are the command names in the .kys file
    IniRead, shuttleStopCmd,   %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.transport.shuttle.stop
    IniRead, focusTimelineCmd, %CONFIG_FILEPATH%, Premiere_Keybinds, uif.window.Timelines
    IniRead, focusProjectCmd,  %CONFIG_FILEPATH%, Premiere_Keybinds, uif.window.Projects
    IniRead, focusSorMonCmd,   %CONFIG_FILEPATH%, Premiere_Keybinds, uif.window.Source Monitors
    IniRead, focusProMonCmd,   %CONFIG_FILEPATH%, Premiere_Keybinds, uif.window.program monitors
    IniRead, focusEffCtrlCmd,  %CONFIG_FILEPATH%, Premiere_Keybinds, uif.window.Effect Controls
    IniRead, focusEffectsCmd,  %CONFIG_FILEPATH%, Premiere_Keybinds, uif.window.Effects
    IniRead, searchBoxCmd,     %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.select.find.box
    IniRead, createMarkerCmd,  %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.set.marker

    missingCommandName := ""

    ; Added Error Checking
    Switch "ERROR"
    {
        case shuttleStopCmd:    missingCommandName := "Shuttle Stop"
        case focusTimelineCmd:  missingCommandName := "Focus Timeline"
        case focusProjectCmd:   missingCommandName := "Focus Project"
        case focusSorMonCmd:    missingCommandName := "Focus Source Monitor"
        case focusProMonCmd:    missingCommandName := "Focus Program Monitor"
        case focusEffCtrlCmd:   missingCommandName := "Focus Effect Controls"
        case focusEffectsCmd:   missingCommandName := "Focus Effects"
        case searchBoxCmd:      missingCommandName := "Open Search Box"
        case createMarkerCmd:   missingCommandName := "Create Marker"
    }

    ; If missingCommandName is set, that means the user doesn't have a required shortcut
    ; for this function, and we shouldn't attempt to continue
    if (missingCommandName != "")
    {
        ; I hate some of the janky BS in AutoHotKey
        ; I just want to concatenate a string! WHY IS THIS SO DIFFICULT?!?!?
        ; A PERIOD SHOULD NOT BE A CONCATENATION OPERATOR
        errorMsg1 := "ERROR: No command specified for " missingCommandName " Command"
        errorMsg2 := " which is required for functions in this script.`n`nPlease run the"
        errorMsg3 := " setup script and specify your Premiere Pro keybindings.`n`nPress"
        errorMsg4 := " OK to close the automation program."
        errorMsg := errorMsg1 . errorMsg2 . errorMsg3 . errorMsg4
        MsgBox % errorMsg
        ExitApp
    }

    ; Everything has been validated, set the global variables
    SHUTTLE_STOP          := shuttleStopCmd
    FOCUS_TIMELINE        := focusTimelineCmd
    FOCUS_PROJECT         := focusProjectCmd
    FOCUS_SOURCE_MONITOR  := focusSorMonCmd
    FOCUS_PROGRAM_MONITOR := focusProMonCmd
    FOCUS_EFFECT_CONTROLS := focusEffCtrlCmd
    FOCUS_EFFECTS         := focusEffectsCmd
    SEARCH_BOX            := searchBoxCmd
    CREATE_MARKER         := createMarkerCmd

    ; While it's not a keybind, since we're populating globals, this is where we also
    ; populate the display scaling value
    IniRead, scalingVal, %CONFIG_FILEPATH%, Windows_Configs, display scaling

    if (scalingVal != 100 && scalingVal != 150)
    {
        errorMsg1 := "ERROR: Windows display settings not set properly, please run "
        errorMsg2 := "the setup script and specify what resolution scaling you are "
        errorMsg3 := "running on your system. Bear in mind that this script only "
        errorMsg4 := "supports 100% and 150% resolution scaling."
        errorMsg := errorMsg1 . errorMsg2 . errorMsg3 . errorMsg4
        MsgBox % errorMsg
        ExitApp
    }

    DISPLAY_SCALING_VALUE := scalingVal
    POPULATED_ESSENTIAL_GLOBALS := True
} ; end of populateEssentialGlobals()


effectsPanelFindBox()
{
    ; Puts the cursor into the search box in the effects panel
    prFocus("effects")
    Sleep 15
    ; Conducts keyboard shortcut to break up the search box
    Sendinput % SEARCH_BOX
    Sleep 5
} ; end of effectsPanelFindBox()


searchForEffect(effectName := "lol", callingFromPreset := False)
{
    ; This function was renamed from "effectsPanelType" to a more descriptive name

    ; Searches for an item in the effects panel, but does not apply the effect to the
    ; clip. To apply an effect to a selected clip, use preset()

    ; Brings the search bar in the effects panel into focus
    effectsPanelFindBox()

    ; Deletes any text that may be present in the search box.
    Sendinput, +{backspace} ; SHIFT + BACKSPACE
    Sleep, 10

    ; Sometimes premiere can be slow to find the box, so if it is, we start a loop
    ; to ensure that the search box is actually selected
    if (A_CaretX = "")
    {
        ; No Caret (Blinking vertical line) can be found.
        waitLimit  := 40
        waitTime   := 0
        foundCaret := False
        while not foundCaret && waitTime < waitLimit
        {
            waitTime++
            sleep 33
            if (A_CaretX <> "")
            {
                foundCaret := True
            }
        }

        if (foundCaret == False)
        {
            ; This is how Taran had it, but it's REALLY bad, find a way to improve it
            ; so it doesn't just leave the user stranded
            errorMsg1 := "FAILED TO FIND SEARCH BOX CARET"
            errorMsg2 += "`nIf your cursor will not move, please press the preset"
            errorMsg3 += " shortcut button again to remove this tooltip, and refesh"
            errorMsg4 += "  script using icon in the taskbar."
            errorMsg5 += "`nPremiere likely tried to autosave at a bad time"
            errorMsg := errorMsg1 . errorMsg2 . errorMsg3 . errorMsg4 . errorMsg5
            ToolTip, %errorMsg%
            Sleep 20
            Return False ; Failed
        }

        ; Remove any previous tooltip
        ToolTip,
    }

    ; If calling from preset() function, conduct the required mouse movements
    ; If we're not calling from preset(), we can just send the input of the effect name
    ; because we don't care where the cursor is
    if (callingFromPreset)
    {
        ; Move the cursor into the place of the caret (Works on all monitors since
        ; this is done entirely with keybaord shortcuts, and AHK can find the caret)
        MouseMove, %A_CaretX%, %A_CaretY%, 0
        Sleep 5 ; Give Windows a chance to catch up just in case

        ; Move the cursor onto the magnifying glass next to the search box
        if (DISPLAY_SCALING_VALUE == 100)
        {
            MouseMove, -15, 10, 0, R
        }
        else if (DISPLAY_SCALING_VALUE == 150)
        {
            MouseMove, -25, 10, 0, R
        }
        else
        {
            ; Invalid display scaling value was set, just fail now
            Return False ; Failed
        }
    }

    ; Types the effect name to conduct the search
    ; It is not required to press Enter
    Sendinput, %effectName%
    Sleep 10

    ; Re-selects the field in case you want to type anything different
    if (callingFromPreset == False)
    {
        Sendinput % SEARCH_BOX
        Sleep 10
    }

    Return True ; Successful
} ; end of searchForEffect()


preset(effectName)
{
    ; This function applies an effect to a clip in the timeline
    ; The user must have their cursor over the clip they want to apply the clip to

    ; Does not allow the function to run until the hotkey that activated it is RELEASED
    ; Forcing this wait allows for the function to run unimpeded by other user inputs
    KeyWait, %A_PriorHotkey%

    ; Checks to make sure that Premiere is active, and if not, does not allow the
    ; function to run, and just ends immediately
    ifWinNotActive ahk_exe Adobe Premiere Pro.exe
    {
        Return False ; Failed
    }

    ; Do not run unless the values for the keybinds are populated
    if (POPULATED_ESSENTIAL_GLOBALS == False)
    {
        populateEssentialGlobals()
    }

    ; The coordinate modes need to be set since the pixel distances within the Premiere
    ; Pro Window are consistent
    CoordMode, Pixel, Window
    CoordMode, Mouse, Window
    CoordMode, Caret, Window

    ; Temporarily blocks the mouse and keyboard inputs while the function is running
    BlockInput, SendAndMouse
    BlockInput, MouseMove
    BlockInput, On

    ; No delay between inputs sent by this function
    SetKeyDelay, 0

    ; Stop playing the video (Don't want the clips to move)
    ; Shuttle stop doesn't always work on just one, so run it twice
    SendInput % SHUTTLE_STOP
    Sleep 10
    SendInput % SHUTTLE_STOP
    Sleep 5

    ; The curosr should be on top of the clip, so storing the mouse position is the
    ; the clip's position
    MouseGetPos, clipXPos, clipYPos

    ; Middle click to bring the panel under the cursor to focus (this should be the
    ; timeline)
    ; Important if you were doing work on another panel and then moved your mouse over
    ; your timeline without explicitly activating it
    SendInput, {mButton}
    Sleep 5

    ; Search for an effect and put the cursor on the magnifying glass
    successfulSearch := searchForEffect(effectName, True)

    if (successfulSearch == False)
    {
        ; The search was unsuccessful, give the user control back, display an error,
        ; and then stop running the function
        BlockInput, MouseMoveOff
        BlockInput, Off
        ; Display an error message with a timeout so it notifies the user but goes away
        ; after 1 full second
        MsgBox, 0, Premiere with AHK, Error with Search, handing back control, 1
        Return False ; Failed
    }

    ; Move the mouse from the magnifying glass to the effect that was searched
    ; Effect MUST be placed in unique folder inside of the "presets" folder
    Sleep 5
    if (DISPLAY_SCALING_VALUE == 100)
    {
        MouseMove, 41, 63, 0, R
    }
    else if (DISPLAY_SCALING_VALUE == 150)
    {
        MouseMove, 62, 95, 0, R
    }
    else
    {
        ; Failed Search. Unknown scaling didn't exit the function for some reason
        ; Making the error message a variable here because otherwise the syntax
        ; highlighting is going to make me go insane
        errorMsg := "How in the FUCK did you get here? It was supposed to exit already"
        MsgBox % errorMsg
        ExitApp ; Close AHK, something went VERY wrong
    }
    Sleep 5

    ; There is a bug in Premiere where there are sometimes duplicated displays of single
    ; presets, the following function is meant to handle that case
    handleDuplicatePresetBug()

    ; Click and drag the found preset onto the originally selected clip
    MouseClickDrag, Left, , , clipXPos, clipYPos, 0
    Sleep 5
    ; Bring the timeline back into focus
    SendInput, {mButton}

    ; Relinquish control to the user once again
    BlockInput, MouseMoveOff
    BlockInput, Off

    ; Checks if the user has loaded the script that contains the cropClick function
    ; and if so, runs that function
    handleCropClick(effectName)

    Return True ; Successful
} ; end of preset()


DrakeynPreset(item)
{
    ; This is an alternative to the preset function taken from the following link:
    ; https://github.com/Drakeyn/AdobeMacros/blob/master/Premiere%20Pro/Functions/ApplyPreset.ahk
    ; However, while this wasn't written by Taran, there are still a lot of coding issues
    ; that need to be fixed up in this
    ; If this proves to be more reliable than the preset() function, then it will replace
    ; preset() entirely
    ; Both are still being tested with the new coding setup
    
    ; TODO: Implement this functionality
    ; For the time being, just pass it through to the original preset
    preset(item)
} ; end of DrakeynPreset


handleDuplicatePresetBug()
{
    ; To fix the duplicate preset bug, the user has to interact with the effects panel
    ; to get the display to go back to normal, so this function accounts for that

    ; Get the AHK Class and window ID of the current panel
    MouseGetPos, iconX, iconY, windowID, classNN
    Sleep 5
    WinGetClass, class, ahk_id %windowID%
    ; dpg = "Duplicate Preset Bug"
    ; "SubWindow" is a placeholder value that will not be used again
    ControlGetPos, dpgX, dpgY, dpgW, dpgH, %classNN%, ahk_class %class%, SubWindow, SubWindow

    ; Move the mouse to roughly the center of the effects panel
    ; Clicking here will clear the displayed presets from any duplication errors, and then
    ; we can move the mouse back to the starting position.
    ; This can also go heavily wrong here if AHK never moved the cursor to the effects
    ; panel and the cursor is on the timeline, but if that happens... CTRL + Z
    MouseMove, dpgW/4, dpgH/2, 0, R
    Sleep 5
    MouseClick, Left, , , 1
    Sleep 5
    MouseMove, iconX, iconY, 0
    Sleep 5
} ; end of handleDuplicatePresetBug()


handleCropClick(effectName)
{
    ; The cropClick function is stored in a different script, but if the user has
    ; decided to load that script, we need to run the cropClick function
    IfInString, effectName, CROP
    {
        ; This checks to see if you have the function named "cropClick"
        if IsFunc("cropClick")
        {
            func := Func("cropClick")
            sleep 320 ; Wait because this could take a while to appear in Premiere
            retCode := func.Call()
        }
    }
} ; end of handleCropClick()


prFocus(panel)
{
    ; This function allows you to "focus" specific panels in Premiere, and will actually
    ; bring them into focus instead of cycling through potential options like the default
    ; keyboard shortcuts will

    ; For this function to work, you MUST Go to Premiere's Keyboard Shortcuts panel, and
    ; have keyboard shortcuts set for the following commands:

    ; PREMIERE COMMAND
    ; Application > Window > Timeline
    ; Application > Window > Project  (Sets the focus onto a BIN.)
    ; Application > Window > Source Monitor
    ; Application > Window > Program Monitor
    ; Application > Window > Effect Controls
    ; Application > Window > Effects  (NOT the Effect Controls panel!)


    ; EXPLANATION: In Premiere, many shortucts will only work if a specific panel is in
    ; focus. So running this function ensures that they will be in focus to do other
    ; commands specific to that panel.

    ; AHK has no way to tell which panel is in focus
    ; If a panel is ALREADY in focus, and you send the shortcut to bring it into focus
    ; again, that panel might then switch to a different sequence in the case of the
    ; timeline or program monitor,, or a different item in the
    ; case of the Source panel. IT's a nightmare!

    ; Therefore, we must start with a clean slate. For that, I chose the EFFECTS panel.
    ; Sending its focus shortcut multiple times, has no ill effects.

    ; Do not run unless the values for the keybinds are populated
    if (POPULATED_ESSENTIAL_GLOBALS == False)
    {
        populateEssentialGlobals()
    }

    SendInput % FOCUS_EFFECTS
    ; Bring focus to the effects panel... OR, if any panel had been maximized (using the
    ; `~ key by default) this will unmaximize that panel, but sadly, that panel will
    ; still be the one in focus.
    ; Note that if the effects panel is ALREADY maximized, then sending the shortcut to
    ; switch to it will NOT un-maximize it.
    Sleep 12 ; Waiting for Premiere to actaully do the above.
    ; Bring focus to the effects panel AGAIN. Just in case some panel somewhere was
    ; maximized, THIS will now guarantee that the Effects panel is ACTAULLY in focus.
    SendInput % FOCUS_EFFECTS
    sleep 5 ; Waiting for Premiere to actaully do the above.
    ; The switch case has no option for the effects panel because we currently already
    ; have it opened

    Switch [panel]
    {
        Case "timeline":        SendInput % FOCUS_TIMELINE
        Case "program":         SendInput % FOCUS_PROGRAM_MONITOR
        Case "source":          SendInput % FOCUS_SOURCE_MONITOR
        Case "project":         SendInput % FOCUS_PROJECT
        Case "effect controls": SendInput % FOCUS_EFFECT_CONTROLS
    }
    ; We don't have a case for focusing the Effects panel since we already brought it
    ; into focus to prepare to bring something else to focus
    Return
} ; end of prFocus()


marker()
{
    ; Stops the timeline and places a marker at the playhead
    SendInput % SHUTTLE_STOP
    Sleep 5
    SendInput % CREATE_MARKER
} ; end of marker()


kbShortcutsFindBox()
{
    ;TODO: Check to see if this is still needed because it seems to be specific to
    ; the 2017 version of the software

} ; end of kbShortcutsFindBox()