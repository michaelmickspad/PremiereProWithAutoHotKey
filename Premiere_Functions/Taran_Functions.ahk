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
 * This script holds the functions that are unchanged from Taran's original code.
 * These functions were placed here if it didn't seem to have a set in stone purpose that
 * I could discern, was marked as probably obsolete, or had notes from Taran saying
 * something along the lines of "I highly recommend you do not use this function", and I
 * didn't have the time to make it less finnicky.
 *
 * I have cleaned up some of the syntax, but for the most part, these are the exact same
 * as the original script, so if you have a use for these functions, you will need to
 * manually go through them and replace any of Taran's keyboard shortcuts with your own.
 *
 * Despite the fact that these functions will probably see little to no use, I still
 * wanted to include them in the codebase in case someone actually does get use out of
 * them.
 *
 */



; I kind of want to fix this one up and allow it to be used because it seems very useful,
; but it will require a large expansion to the user configuration prompting to locate the
; correct positions
; Might also want to ask if the user is on windows 10 or 11, because 11 will make taking
; screenshots with ahk a lot easier
tracklocker()
{
    ; Locks the video and audio layers V1 and A1.
    ; Not recommended because it requires a ton of very carefully taken screenshots in
    ; order to work
    ;TODO: This function actually seems REALLY useful for my workflow, run some tests and
    ; see if there's a way to actually make this better
    
    ;sleep 15 ;modifiers?
    BlockInput, on
    BlockInput, MouseMove
    MouseGetPos xPosCursor, yPosCursor

    xPos = 400
    yPos = 1050 ;the coordinates of roughly where my timeline usually is located on the screen (a 4k screen.)
    CoordMode Pixel ;, screen  ; IDK why, but it works like this...
    CoordMode Mouse, screen
    ; CoordMode, mouse, window
    ; CoordMode, pixel, window
    ; coordmode, Caret, window
    ;you might need to take your own screenshot (look at mine to see what is needed) and save as .png. Mine are done with default UI brightness, plus 150% UI scaling in Wondows.
    ;msgbox, workingDir is %A_WorkingDir%
    ImageSearch, FoundX, FoundY, xPos, yPos, xPos+600, yPos+1000, *5 %A_WorkingDir%\v1_ALT_unlocked_targeted_2019_ui100.png
    if ErrorLevel = 1
        ImageSearch, FoundX, FoundY, xPos, yPos, xPos+600, yPos+1000, *5 %A_WorkingDir%\v1_unlocked_targeted_2019_ui100.png
    ; if ErrorLevel = 1
        ; ImageSearch, FoundX, FoundY, xPos, yPos, xPos+600, yPos+1000, *5 %A_WorkingDir%\v1_unlocked_untargeted_2018.png
    ; if ErrorLevel = 1
        ; ImageSearch, FoundX, FoundY, xPos, yPos, xPos+600, yPos+1000, *5 %A_WorkingDir%\v1_ALT_unlocked_untargeted_2018.png
    if ErrorLevel = 1
        {
        ;msgbox, we made it to try 2
        tippy("NO UNLOCK WAS FOUND")
        goto try2
        }
    if ErrorLevel = 2
        {
        tippy("Could not conduct the search!")
        goto resetlocker
        }
    if ErrorLevel = 0
        {
        ;tooltip, The icon was found at %FoundX%x%FoundY%.
        ;msgbox, The icon was found at %FoundX%x%FoundY%.
        MouseMove, FoundX+10, FoundY+10, 0
        sleep 5
        click left
        MouseMove, FoundX+10, FoundY+60, 0 ;moves downwards and onto where A1 should be...
        click left ;clicks on Audio track 1 as well.
        sleep 10
        goto resetlocker
        }
        
    try2:
    tippy("we are now on try 2")
    ; ImageSearch, FoundX_LOCK, FoundY_LOCK, xPos, yPos, xPos+600, yPos+1000, *2 %A_WorkingDir%\v1_ALT_locked_targeted_2018.1.png

        
    if ErrorLevel = 1
        {
        tippy("try 2 part 1")
        ImageSearch, FoundX_LOCK, FoundY_LOCK, xPos, yPos, xPos+600, yPos+1000, *5 %A_WorkingDir%\v1_ALT_locked_targeted_2019_ui100.png
        }
    if ErrorLevel = 1
        {
        tippy("ALT LOCKED TARGETED V1 could not be found on the screen")
        ImageSearch, FoundX_LOCK, FoundY_LOCK, xPos, yPos, xPos+600, yPos+1000, *5 %A_WorkingDir%\IDK_2.png
        }
    ; if ErrorLevel = 1
        ; {
        ; tippy("ALT LOCKED TARGETED V1 could not be found on the screen")
        ; ImageSearch, FoundX_LOCK, FoundY_LOCK, xPos, yPos, xPos+600, yPos+1000, %A_WorkingDir%\v1_ALT_locked_untargeted.png
        ; }
    if ErrorLevel = 2
        {
        tippy("Could not conduct search #2")
        goto resetlocker
        }
        
    if ErrorLevel = 0
        {
        ;tippy("found a locked lock")
        MouseMove, FoundX_LOCK+10, FoundY_LOCK+10, 0
        sleep 5
        click left ;clicks on Video track 1
        MouseMove, FoundX_LOCK+10, FoundY_LOCK+60, 0
        click left ;clicks on Audio track 1 as well.
        sleep 10
        goto resetlocker
        }
    ;msgbox, , , num enter, 0.5;msgbox, , , num enter, 0.5
    resetlocker:
    MouseMove, xPosCursor, yPosCursor, 0
    blockinput, off
    blockinput, MouseMoveOff
    sleep 10
} ; End of trackLocker()


; I fixed the indenting of any code that wasn't commented out, but commented out code
; still has indenting issues, I might fix them later
monitorKeys(whichMonitor,shortcut,useSpace := 1)
{
    ;this function has proven to be shockingly robust.
    keywait, %A_priorhotkey% ;hopefully that doesn't break it.
    ;msgbox,,, useSpace is %useSpace%,1
    if WinActive("ahk_exe Adobe Premiere Pro.exe") ;AHA, it is better to use the EXE, because if you are in a secondary monitor window, then the CLASS is not active even though the EXE still is, mildly interesssstting.
    {
        ;IDK if I need to set a coordmode here?
        ; coordmode, pixel, Window
        ; coordmode, mouse, Window
        ; coordmode, Caret, Window
        if (whichMonitor = "source")
        {
            x := "1800"
            y := "500"
            ;;tooltip, source here
            ;coordinates that are very likely to be within my Source Monitor's usual area
        }
        else
        {
            x := "3300"
            y := "500"
            ;;tooltip, program here
            whichMonitor = "program" ;just in case it was not defined properly, it becomes "program" by default.
            ;coordinates that are very likely to be within my Program Monitor's usual area
        }
        ; tooltip, x y is %x% %y%
        ; sleep, 500

        ;testing some sheeit
        x := "1800"
        y := "500"

        ActiveHwnd := WinExist("A")
        windowWidth := CoordGetControl(x,y, ActiveHwnd)

        ; tooltip, ActiveHwnd is %ActiveHwnd%
        ; sleep, 500
        ; tooltip, windowWidth is %windowWidth%
        ; sleep, 500


        if (windowWidth < 2000) ;this means that the monitor is NOT maximized
        {
            ;tooltip, windowwidth is less than 2000
            ; sleep 500
            if (whichMonitor = "source")
            {
                prFocus("source") ;keep in mind, this FIRST brings focus to the Effects panel
                ;tooltip, u in SOURCE LAND
                ; sleep 500
            }
            else
            {
                prFocus("program") ;keep in mind, this FIRST brings focus to the Effects panel
                ;tooltip, u in program LAND
            }
            sleep 20
        }

        sleep 30 ;sometimes these shortcuts don't "take" without a bit of delay.
        sendinput, %shortcut%
        ;so, the above would be translated to   sendinput, ^+2   or something like that.

        ; if (shortcut = "^{numpad3}") or if (shortcut = "^+1")
        ; {
        ; sleep 30
        ; sendinput, %shortcut%
        ; ;Premiere 12.0.1 is SLOOOWWW to react to these shortcuts in particular. (Source monitor resolution to 1/4) and (program monitor res to 1/1) So I gotta WAIT AROUND and send this TWICE.
        ; }

        ; if (shortcut = "^{numpad2}")
            ; {
            ; send, {CTRL UP}
            ; sleep 10
            ; send, {CTRL DOWN}
            ; sleep 10
            ; send, {CTRL UP}
            ; sleep 10
            ; }



        ;THE CODE BELOW IS SUPER OPTIONAL
        if (windowWidth > 2000) ;if the monitor in question IS maximized...
        {
            ;tooltip, %shortcut% boy
            ; Then it's not obvious which monitor it is, and it's possible that I misremembered,
            ; and pressed the wrong button. Therefore, I will ALSO send the shortcut that
            ; corresponds to the alternative monitor.

            ; Also, it's possible that the window is not in focus. I want to send a middle
            ; click to it without moving the mouse, since coordinates arent well supported
            ; on other monitors. For this, controlfocus or controlclick MIGHT work...

            ;ControlClick , x1800 y500, WinTitle, WinText, MIDDLE, 1, Pos

            if (shortcut = "^{numpad1}")
            {
                ;sleep 30
                sendinput, ^+1
            }
            if (shortcut = "^{numpad2}")
            {
                sendinput, ^+2
            }
            if (shortcut = "^{numpad5}")
            {
                ;sleep 30
                ;tooltip, yeah ctrl numpad 5
                sendinput, ^+2
            }
            if (shortcut = "^{numpad3}")
            {
                SendInput, ^+3
            }
            if (shortcut = "^+1")
            {
                ;tooltip, taran whyyy
                sendinput, ^{numpad1}
            }
            if (shortcut = "^+2")
            {
                ;sleep 30
                sendinput, ^{numpad2}
            }
            if (shortcut = "^+3")
            {
                ;sleep 30
                sendinput, ^{numpad3}
            }
            ;and now for the safe margins
            if (shortcut = "^!+[")
            {
                sendinput, ^!+]
            }
            if (shortcut = "^!+]")
            {
                sendinput, ^!+[
            }

        }
        ;THE CODE ABOVE IS SUPER OPTIONAL


        ;i might have to comment this back in vvvvv
        if (windowWidth < 2000) ;again, if the monitor in question is NOT already maximized...
        {
            if not (whichMonitor = "source") ;stay on the source (program?) monitor if it is active
            {
                prFocus("timeline")
                ;tooltip, this is why
            }
        }
        ;;; that ^^^^^

        ;if (useSpace = "0")
            ;tooltip, we are NOT NOT NOT spacing
        ;;optional:
        if (useSpace = "1")
        {
            ;tooltip, we are spacing
            sendinput, {space} ;if playing/paused, pause/play the video.
            sleep 50
            sendinput, {space} ;if playing/paused, pause/play the video.
            ;;this allows the new playback resolution to take effect.
        }
    }
    ;if you are not in Premiere Pro, the function is skipped

    ; if not WinActive("ahk_exe Adobe Premiere Pro.exe")
        ; msgbox,,, pr is not active,1
        ; ; ;if you use the ahk_class, even if you have an active Premiere window on another monitor, unless it is the MAIN monitor, it doesn't count.
} ; end of monitorKeys() 


; The indenting on this one is awful and I don't exactly know what this function does,
; so I'll come back to it at some point in the future but that day is not today
Target(v1orA1, onOff, allNoneSolo := 0, numberr := 0)
{
    ;;TARGET or UNTARGET any arbitrary track.
    ;it doesn't work well, and I don't really use it.
    
    ;tooltip, now in TARGET function
    ; BlockInput, on
    ; BlockInput, MouseMove
    ; MouseGetPos xPosCursor, yPosCursor
    prFocus("timeline") ;brings focus to the timeline.
    wrenchMarkerX := 400
    wrenchMarkerY := 800 ;the upper left corner for where to begin searching for the timeline WRENCH and MARKER icons -- the only unique and reliable visual i can use for coordinates.
    targetdistance := 98 ;Distance from the edge of the marker Wrench to the left edge of the track targeting graphics
    CoordMode Pixel ;, screen  ; IDK why, but it only works like this...
    CoordMode Mouse, screen

    ;tooltip, starting
    ImageSearch, xTime, yTime, wrenchMarkerX, wrenchMarkerY, wrenchMarkerX+600, wrenchMarkerY+1000, %A_WorkingDir%\timelineUniqueLocator2.png
    if ErrorLevel = 0
        {
        ;MouseMove, xTime, yTime, 0
        ;tooltip, where u at son. y %ytime% and x %xtime%
        ;do nothing. continue on.
        xTime := xTime - targetdistance
        ;MouseMove, xTime, yTime, 0
        }
    else
        {
        tooltip, image search failed
        goto resetTrackTargeter
        }
    ;tooltip, continuing...

    ImageSearch, FoundX, FoundY, xTime, yTime, xTime+100, yTime+1000, %A_WorkingDir%\%v1orA1%_unlocked_targeted_alone.png
    if ErrorLevel = 1
        ImageSearch, FoundX, FoundY, xTime, yTime, xTime+100, yTime+1000, %A_WorkingDir%\%v1orA1%_locked_targeted_alone.png
    if ErrorLevel = 2
        {
        tippy("TARGETED v1 not found")
        goto trackIsUntargeted
        }
    if ErrorLevel = 3
        {
        tippy("Could not conduct the TARGETED v1 search!")
        goto resetTrackTargeter
        }
    if ErrorLevel = 0
        {
        ;MouseMove, FoundX, FoundY, 0
        ;tooltip, where is the cursor naow 1,,,2
        ;tippy("a TARGETED track 1 was found.")
        if (v1orA1 = "v1")
            {
            send +9 ;command in premiere to "toggle ALL video track targeting."
            sleep 10
            if (onOff = "on")
                {
                ;tippy("turning ON")
                send +9 ; do it again to TARGET everything.
                }
            sleep 10
            if (numberr > 0)
                Send +%numberr%
            }
        else if (v1orA1 = "a1")
            {
            send !9 ;command in premiere to "toggle ALL audio track targeting."
            sleep 10
            if (onOff = "on")
                send !9 ; do it again to TARGET everything.
            sleep 10
            if (numberr > 0)
                Send !%numberr%
            }
        goto resetTrackTargeter
        }

    trackIsUntargeted:
    ;tooltip, track is untargeted,,,2
    if ErrorLevel = 1
        ImageSearch, FoundX, FoundY, xTime, yTime, xTime+100, yTime+1000, %A_WorkingDir%\%v1orA1%_locked_untargeted_alone.png
    if ErrorLevel = 1
        ImageSearch, FoundX, FoundY, xTime, yTime, xTime+100, yTime+1000, %A_WorkingDir%\%v1orA1%_unlocked_untargeted_alone.png
    if ErrorLevel = 0
        {
        ;MouseMove, FoundX, FoundY, 0
        ;tippy("an UNTARGETED track 1 was found.")
        ;tooltip, where is the cursor naow,,,2
        
        if (v1orA1 = "v1")
            {
            send ^{F9};send +9 ;command in premiere to "toggle ALL video track targets." This should TARGET everything.
            sleep 10
            if (onOff = "off")
                send +9 ; do it again to UNTARGET everything.
            sleep 10
            if (numberr > 0)
                Send +%numberr%
            }
        if (v1orA1 = "a1")
            {
            send ^+{F9} ;command in premiere to "toggle ALL audio track targets." This should TARGET everything. ;also ALT f9 but it's dangerous.
            sleep 10
            if (onOff = "off")
                send !9 ; do it again to UNTARGET everything.
            sleep 10
            if (numberr > 0)
                Send !%numberr%
            }
        goto resetTrackTargeter
        }

    resetTrackTargeter:
    ; MouseMove, xPosCursor, yPosCursor, 0
    ; blockinput, off
    ; blockinput, MouseMoveOff
    ;sleep 1000
    tooltip,
    tooltip,,,,2
    sleep 10
} ; end of Target()


; This one seems to have some functionality, but everything being "blinded" pushes me to
; believe that this was a work in progress function, and I am more focused on fixing other
; stuff than this one
easeInAndOut()
{
    ;NEW method in 2020 is below.
    ;;sleep 11 isn't needed because it was done already....?
    sendevent, {blind}{lshift up}{lctrl up}{rshift up}{rctrl up}{ralt up}{lalt up} ;i have no idea if this will work. This is to try to prevent any stuck modifier keys

    sendinput, {blind}{SC0EB} ;this might send a tooltip. ; edit: nope.

    send, {blind}^+{f10} ;shortcut is set in premiere to "ease in"
    sleep 10
    sendinput, {blind}{SC0EB} ;this might send a tooltip.
    sleep 5
    send, {blind}+{F10} ;shortcut is set in premiere to "ease out"
    sleep 5

    ;sooo, that CTRL SHIFT F10 event has resulted in CTRL being stuck DOWN on more than one occasion. I'm not sure... how... or why...
    ; https://autohotkey.com/board/topic/94091-sometimes-modifyer-keys-always-down/

    ; https://www.autohotkey.com/boards/viewtopic.php?f=5&t=26760
    ; ;--- PREVENT KEYS STICKING ---;
        ; KeyList := "Shift|Win|CTRL|alt|Escape|ScrollLock|CapsLock|NumLock|Tab"
        ; Loop, Parse, KeyList, |
        ; {
            ; If GetKeystate(A_Loopfield, "P")
                ; Send % "{" A_Loopfield " Up}"
        ; }
        ; reload
    ; ;--- /PREVENT KEYS STICKING ---;

    ;https://www.autohotkey.com/docs/commands/_HotkeyModifierTimeout.htm


    sendevent, {blind}{lshift up}{lctrl up}{rshift up}{rctrl up}{ralt up}{lalt up} ;i have no idea if this will work.

    sendinput, {blind}{SC0E8} ;scan code of an unassigned key


    ; ;OLD EASE IN AND EASE OUT before the shortcuts were added for real in 2020
    ; ;This will click on the necessary menu items for you
    ; ;all you have to do is hover the cursor over a keyframe (or selected keyframes) in the Effect Controls panel, and hit the button.
    ; tooltip, ease in and out
    ; ; blockinput, sendandMouse
    ; blockinput, MouseMove
    ; ; blockinput, on
    ; click right
    ; send T
    ; sleep 10
    ; send E
    ; send E
    ; sleep 10
    ; send {enter}
    ; sleep 10
    ; tooltip, 
    ; ; click right
    ; click middle
    ; sendinput {click right}
    ; send T
    ; sleep 10
    ; send E
    ; sleep 10
    ; send {enter}
    ; blockinput, off
    ; blockinput, MouseMoveOff
    ; ;sleep 100
    ; tooltip,
} ; end of easeInAndOut()


; This seems to have some good use, it's meant to stop playback in Premiere even if Premiere
; is not the active window, however, this seems to be a very Taran specific thing with the
; sheer amount of "use this variable that's specific to my machine" moments, so this one's
; going on the backburner
stopPlaying()
{
    ;macro key G3, when NOT in Premiere.
    ;macro sends CTRL SHIFT L, though CTRL ALT L might be better. ideally, it should not use
    ;any modifier keys at all... maybe just send a wrapped super function key.
    ;play/pause premiere even when not in focus

    keywait, %A_priorhotkey% ;avoid stuck modifiers
    send {blind}{SC081} ; this is for debugging. it does nothing but show up in the Key History and Script info.

    ;sendevent, {blind}{lshift up}{lctrl up}{rshift up}{rctrl up}{ralt up}{lalt up} ;i have no idea if this will work.

    ;send {blind}{SC082}

    if WinActive("ahk_exe Adobe Premiere Pro.exe")
        {
        sendinput, {space}
        goto, stopPlayEND
        }
    ;then it will skip this next part and go to the end.
    if !WinActive("ahk_exe Adobe Premiere Pro.exe")
    {
    ;Below is some code to pause/play the timeline in Premiere, when the application is NOT the active window (on top.) This means that I can be reading through the script, WHILE the video is playing, and play/pause as needed without having to switch back to premiere every single time.



    ;WinGet, lolexe, ProcessName, A
    WinGetClass, lolclass, A ; "A" refers to the currently active window

    ;Keyshower("[WC1] pause/play Premiere when not active",,1,-400)
    if IsFunc("Keyshower") {
        Func := Func("Keyshower")
        RetVal := Func.Call("[WC1] pause/play Premiere when not active",,1,-400) 
    }

    ;Trying to bring focus to the TIMELINE itself is really dangerous and unpredictable, since its Class# is always changing, based upon how many sequences, and other panels, that might be open.

    ;ControlFocus, DroverLord - Window Class3,ahk_exe Adobe Premiere Pro.exe ;the problem wiht this is that a project panel on the 2nd monitor also can qualify

    ControlFocus, DroverLord - Window Class3,Adobe Premiere Pro 2022 ;this works because "Adobe Premiere Pro 2022" is found on the MAIN premiere window, but not the one on the 2nd or 3rd monitors.

    ;lol, had to update it from "2021" to "2022" cause it stopped working after I upgraded.


    ;;;;;;;;;ControlFocus, DroverLord - Window Class46,Adobe Premiere Pro 2022 ;after adding frame.io and gettyimages extensions, the window class of the timeline changed.


    ; Window Class14 is the Program monitor, at least on my machine.
    ; well, now it's Window Class13. it really does change around a lot.
    ; Window Class3 seems to fairly consistently be the Effect Controls panel.
    sleep 30
    ;ControlFocus, DroverLord - Window Class14,ahk_exe Adobe Premiere Pro.exe
    ;If we don't use ControlFocus first, ControlSend experiences bizzare and erratic behaviour, only able to work when the video is PLAYING, but not otherwise, but also SOMETIMES working perfectly, in unknown circumstances. Huge thanks to Frank Drebin for figuring this one out; it had been driving me absolutely mad. https://www.youtube.com/watch?v=sC2SeGCTX4U

    ;I tried windowclass3, (the effect controls) but that does not work, possibly due to stuff in the bins, which would play instead sometimes.

    ;sleep 10
    ;ControlSend,DroverLord - Window Class3,^!+5,ahk_exe Adobe Premiere Pro.exe
    ;that is my shortcut for the Effect Controls.
    ;sleep 10
    ;ControlSend,DroverLord - Window Class3,^!+3,ahk_exe Adobe Premiere Pro.exe

    ;that is my shortcut for the Timeline.
    ;this is to ensure that it doesn't start playing something in the source monitor, or a bin somewhere.

    ; ; ; sleep 10
    ; ; ; ControlSend,DroverLord - Window Class14,{ctrl up}{shift up}{space down},ahk_exe Adobe Premiere Pro.exe
    ; ; ; sleep 30
    ; ; ; ControlSend,DroverLord - Window Class14,{space up},ahk_exe Adobe Premiere Pro.exe

    ;now that we have a panel highlighted, we can send keystokes to premiere. But the panel itself is sometimes random. so it's best to use this to FORCE a specific panel that won't screw stuff up.

    ;NOTE: the "5" keystroke is sent to Premiere, but it will NOT show up in the keyhistory. I'm not sure why... i guess it has to do with ControlSend. Just FYI for debugging.
    ;ControlSend,DroverLord - Window Class3, ^+!5,ahk_exe Adobe Premiere Pro.exe ;this shortcut will highlight the EFFECT CONTROLS, which will NOT also stop playback of the source monitor, if it is already playing.
    ControlSend,DroverLord - Window Class3, ^+!5,Adobe Premiere Pro 2022 ;this shortcut will highlight the EFFECT CONTROLS, which will NOT also stop playback of the source monitor, if it is already playing.
    sleep 40
    ;msgbox,,, srsly wtf,0.5
    ;msgbox,srsly wtf
    ;ControlSend,DroverLord - Window Class3, ^+!5,ahk_exe Adobe Premiere Pro.exe
    ControlSend,DroverLord - Window Class3, ^+!5,Adobe Premiere Pro 2022
    sleep 10 ;this asn't here at all for a long time. dunno if i really need it.

    ;FYI, {space} also doesn't show up in the keyhistory.
    ControlSend,,{space}, ahk_exe Adobe Premiere Pro.exe
    ;;;use either the ABOVE line, or the line BELOW. Can't say right now which is better...
    ;ControlSend,DroverLord - Window Class1,{space},ahk_exe Adobe Premiere Pro.exe
    ;even though we are sending the "SPACE" to a windowclass that (often) doesn't exist, because we already highlighted the effect controls, the "space" will go to the effect controls panel. USUALLY. Sometimes it still ends up playing some file in some bin.




    ;in case premiere was accidentally switched to, this will switch the user back to the original window.
    if not WinActive(lolClass)
        WinActivate, %lolclass%
    }

    ;end of Premiere play/pause when not in focus.
    send {blind}{SC083} ; used as a sort of a debugging flag thingy. Always wise to use BLIND on these. ;also probably terrible if you have windows game bar still enabled, lol.
    stopPlayEND:
} ; end of stopPlaying()


; This seems to be a function used primarily to build other functions and get information,
; which is great for a locally used tool, but also really doesn't need to be loaded with
; the essential functions
CoordGetControl(xCoord, yCoord, _hWin) ; _hWin should be the ID of the active window
{

    ;this overly complicated function will get information about a window without having
    ; to move the cursor to those coordinates first. the AHK people really should have a
    ; command for this already....

    ;Keep in mind, Premiere has LOTS of small windows within it. Open window Spy and move
    ; your cursor around Premiere, to see what i mean.

    ;script originally from Coco
    ; https://autohotkey.com/board/topic/84144-find-classnn-of-control-by-posxy-without-moving-mouse/
    
    
    CtrlArray := Object() 
    WinGet, ControlList, ControlList, ahk_id %_hWin%
    Loop, Parse, ControlList, `n
    {
        Control := A_LoopField
        ControlGetPos, left, top, right, bottom, %Control%, ahk_id %_hWin%
      right += left, bottom += top
        if (xCoord >= left && xCoord <= right && yCoord >= top && yCoord <= bottom)
            MatchList .= Control "|"
    }
    StringTrimRight, MatchList, MatchList, 1
    Loop, Parse, MatchList, |
    {
        ControlGetPos,,, w, h, %A_LoopField%, ahk_id %_hWin%
        Area := w * h
        CtrlArray[Area] := A_LoopField
    }
    for Area, Ctrl in CtrlArray
    {
        Control := Ctrl
        if A_Index = 1
            break
    }
    return w
} ; end of CoordGetControl()