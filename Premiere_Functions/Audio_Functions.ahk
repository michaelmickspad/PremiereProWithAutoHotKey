#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force ; Only one version of this script may run at a time
#MaxHotkeysPerInterval, 2000
#WinActivateForce

; Required External Scripts
#Include %A_ScriptDir%\Essential_Functions.ahk

/*
 * DESCRIPTION:
 */

; Global Variables
global CONFIG_FILEPATH := "PremiereWithAHKConfig.ini"
global POPULATED_AUDIO_GLOBALS := False

; Required Custom Keybinds for Script Functions
global REMOVE_IN_OUT_POINTS := "DEFAULT"
global ADJUST_GAIN := "DEFAULT"
global AUDIO_CHANNELS := "DEFAULT"

populateAudioGlobals()
{
    ; Grabs the data set by the python script from the configuration file and adjusts the
    ; values of the global variables of the script accordingly
    ; Outputs to a temporary variable first because ini file reading to global can be
    ; iffy at times
    ; Also all of the keys in the config are the command names in the .kys file

    IniRead, removeInOutCmd,   %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.clear.inandout
    IniRead, adjustGainCmd,    %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.clip.audiooptions.gain
    IniRead, audioChannelsCmd, %CONFIG_FILEPATH%, Premiere_Keybinds, cmd.clip.audiooptions.sourcechannelmappings
    ;TODO: Add in the rest of the function

    missingCommandName := ""

    ; Added Error Checking
    Switch "ERROR"
    {
        case removeInOutCmd: missingCommandName := "Remove In and Out Points"
        case adjustGainCmd: missingCommandName := "Adjust Clip Gain"
        case audioChannelsCmd: missingCommandName := "Open Audio Channels"
    }

    ; If missingCommandName is set, that means the user doesn't have a required shortcut
    ; for this function, and we shouldn't attempt to continue
    if (missingCommandName != "")
    {
        ; I hate some of the janky BS in AutoHotKey
        ; I just want to concatenate a string! WHY IS THIS SO DIFFICULT?!?!?
        ; A PERIOD SHOULD NOT BE A CONCATENATION OPERATOR
        errorMsg1 := "ERROR: No command specified for " missingCommandName " Command"
        errorMsg2 := " which is required to run this command.`n`nPlease run the setup"
        errorMsg3 := " script and specify your Premiere Pro keybindings.`n`nPress OK to"
        errorMsg4 := " close the automation program."
        errorMsg := errorMsg1 . errorMsg2 . errorMsg3 . errorMsg4
        MsgBox % errorMsg
        ExitApp
    }

    ; Everything has been validated, set the global variables
    REMOVE_IN_OUT_POINTS := removeInOutCmd
    ADJUST_GAIN := adjustGainCmd
    AUDIO_CHANNELS := audioChannelsCmd

    POPULATED_AUDIO_GLOBALS := True
} ; end of populateAudioGlobals()


; INCOMPLETE - DO NOT USE
insertSFX(leSound)
{
    ; Checks to make sure that Premiere is active, and if not, does not allow the
    ; function to run, and just ends immediately
    ifWinNotActive ahk_exe Adobe Premiere Pro.exe
    {
        Return False ; Failed
    }

    ; Do not run unless the values for the keybinds are populated
    if (POPULATED_AUDIO_GLOBALS == False)
    {
        populateEssentialGlobals()
    }

    ; Checking to see if the user has the function for keyshower, and if so, runs it
    if IsFunc("Keyshower")
    {
        func := Func("Keyshower")
        retCode := func.Call(leSound, "insertSFX")
    }

    CoordMode, Pixel, Screen
    CoordMode, Mouse, Screen
    CoordMode, Caret, Screen

    ; Temporarily blocks the mouse and keyboard inputs while the function is running
    BlockInput, SendAndMouse
    BlockInput, MouseMove
    BlockInput, On

    ; No delay between inputs sent by this function
    SetKeyDelay, 0

    MouseGetPos, xPos, yPos
    SendInput % REMOVE_IN_OUT_POINTS
    Sleep 10
    ;TODO: Figure out what source assignment is and then come back here to finish this
} ; end of insertSFX()


addGain(amount := 7)
{
    ; Adds gain to whatever audio clip is currently selected
    SendInput % ADJUST_GAIN
    Sleep 5
    Send % amount
    Sleep 5
    SendInput, {enter}
} ; end of addGain()


; INCOMPLETE - DO NOT USE
audioMonoMaker(track)
{
    ; This function opens the Auto Channels box for the selected track and changed it to
    ; mono instead of stereo

    ;TODO: Holy fuck, there are a lot of issues in this function, go through piece by
    ;piece and correct the issues

    ; Does not allow the function to run until the hotkey that activated it is RELEASED
    ; Forcing this wait allows for the function to run unimpeded by other user inputs
    KeyWait, %A_PriorHotkey%

    ; Checks to make sure that Premiere is active, and if not, does not allow the
    ; function to run, and just ends immediately
    ifWinNotActive ahk_exe Adobe Premiere Pro.exe
    {
        Return False ; Failed
    }

    ; Do not run unless the values for the display scaling are populated
    if (POPULATED_ESSENTIAL_GLOBALS == False)
    {
        populateEssentialGlobals()
    }

    ; Do not run unless the values for the audio keybinds are populated
    if (POPULATED_AUDIO_GLOBALS == False)
    {
        populateAudioGlobals()
    }

    CoordMode, Mouse, Screen
    CoordMode, Pixel, Screen

    ; Temporarily blocks the mouse and keyboard inputs while the function is running
    BlockInput, SendAndMouse
    BlockInput, MouseMove
    BlockInput, On

    ; Checking to see if the user has the function for keyshower, and if so, runs it
    if IsFunc("Keyshower")
    {
        func := Func("Keyshower")
        retCode := func.Call(leSound, "insertSFX")
    }

    addPixels := 0 ; Defaults to left Audio Track

    if (track == "right")
    {
        addPixels := 36
    }

    ; Open the Audio Channels
    SendInput % AUDIO_CHANNELS
    Sleep 15

    MouseGetPos, xPosAudio, yPosAudio

    ;TODO!!!! THIS IS HOW THE ORIGINAL SCRIPT DOES THIS, THIS IS HIGHLY SPECIFIC TO
    ; TARAN'S MACHINE AND NEEDS TO BE UPDATED SOMEHOW TO BE MORE DYNAMIC
    ; Moves the mouse onto the expected location of the "okay" box
    ; It will have a specific white color when the cursor hovers over it, and that will
    ; allow us to know that the panel has appeared
    MouseMove, 2222, 1625, 0

    ; Wait for the position underneath the mouse to turn to the white we expect
    ; but break the function and notify the user if this happens to fail
    emergencyBreak := 0
    panelFound := False
    while (not panelFound && emergencyBreak < 10)
    {
        emergencyBreak++
        Sleep 50
        MouseGetPos, currMouseX, currMouseY
        PixelGetColor, currPixelColor, currMouseX, currMouseY, RGB
        ; I hate that this is a string, why can't AHK just be normal?
        ; I should probably look into AHKv2
        ToolTip, Waiting Value = %emergencyBreak%`npixel color = %currPixelColor%
        ; Checking for the distinctive white of the button
        if (currPixelColor == "0xE8E8E8")
        {
            ToolTip, ; Clear currently active ToolTip
            panelFound := True
        }
    }

    if (not panelFound)
    {
        ; We were unsuccessful in finding the panel, return control to the user and then
        ; stop attempting to run the function beyond this
        BlockInput, off
	    BlockInput, MouseMoveOff

        ToolTip ; Clear previous tooltips

        errorMsg1 := "Unable to determine if the panel has appeared, please check script "
        errorMsg2 := "function audioMonoMaker() as it relies on screen pixel values"
        errorMsg := errorMsg1 . errorMsg2
        MsgBox % errorMsg

        Return False ; Failed
    }

    ; Panel was found, now we need to do... something?
    ; There's not *too* much description in this function's comments for this
    ; TODO: Test this function and write a better description here

    CoordMode, Mouse, Client
    CoordMode, Pixel, Client

    if (DISPLAY_SCALING_VALUE == 150)
    {
        MouseMove, 165 + addPixels, 295, 0
    }
    else if (DISPLAY_SCALING_VALUE == 100)
    {
        ;TODO: FIGURE THIS OUT
        MsgBox, Taran did not provide 100% scaling information, test this yourself
        Return False ; Failed
    }
    else
    {
        MsgBox, Display Scaling Value not set properly, please run setup script
        Return False ; Failed
    }

    ;TODO: Check and make sure that this is the default panel brightness in Premiere
    ;and if it's not, maybe make a global variable for "ARE_YOU_TARAN"
    ; IMPORTANT COLOR INFORMATION
    ; Note: These will differ based on your UI brightness set in premiere
    ;       While my goal is to allow easier configuration of the scripts to reduce manual
    ;       code adjustments by the end user, this is one where you're on your own if you
    ;       change the value
    ;       Default Brightness for All Panels is 313131 and/or 2B2B2B
    ; 2b2b2b or 464646 = color of empty box
	; cdcdcd = color when cursor is over the box
	; 9a9a9a = color when cursor NOT over the box

    Sleep 50
    MouseGetPos, currMouseX, currMouseY
    ;TODO: Figure out why Taran stopped using the RGB flag
    PixelGetColor, currPixelColor, currMouseX, currMouseY

    if (currPixelColor == "0x1d1d1d" || currPixelColor = "0x333333")
    {
        ; This is the color of the empty checkbox
        ;TODO: Next comment is Taran's, figure out what he meant
        ; The coordinated should NOT lead to a position where the gray of the checkmark would be
        ;TODO: I think this is clicking the button, but figure out the purpose and add a better comment here
        MouseClick, L, , , 1
        Sleep 10
    }
    else if (currPixelColor == "0xb9b9b9")
    {
        ; This is the color of the checkmark
        ; We are currently on top of the box, and have found a checkmark already inside
        ; We do nothing here since we already have a checkmark
    }

    ;TODO: What is it doing here???
    ; I think this is moving to the next box to click below, but I'm unsurue, add comments
    Sleep 5
    MouseMove, 165 + addPixels, 329, 0
    Sleep 30
    MouseGetPos, currMouseX, currMouseY ; Originally set as kolor2, but don't need the differentiation it seems
    Sleep 10
    PixelGetColor, currPixelColor, currMouseX, currMouseY ; Originally set as kolor2, but don't need the differentiation it seems

    if (currPixelColor == "0x1d1d1d" || currPixelColor == "0x333333")
    {
        ; This is the color of the empty checkbox
        ; The box is currently empty
        MouseClick, L, , , 1
        Sleep 10
    }
    else if (currPixelColor == "0xb9b9b9")
    {
        ; Do nothing, we already have a checkmark in the box
    }

    ; TODO: What is it doing here???
    Sleep 5
    SendInput, {Enter}

    ; Now that we're done, move the mouse back to it's starting position and
    ; return control to the user
    CoordMode, Mouse, Screen
    CoordMode, Pixel, Screen
    MouseMove, xPosAudio, yPosAudio, 0
    BlockInput, Off
    BlockInput, MouseMoveOff
    ToolTip, ; Remove any potential leftover tooltips
} ; end of audioMonoMaker()