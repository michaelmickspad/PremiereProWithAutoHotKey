#SingleInstance force ;only one instance of this script may run at a time!
#MaxHotkeysPerInterval 2000
Menu, Tray, Icon, shell32.dll, 303 ; this changes the tray icon to a little check mark!


; This is a modified script originally written by Taran Van Hemert
; The purpose is to bypass the dialogue box that says "This action will delete existing 
; keyframes. Do you want to continue?"

; As it's currently set up, in order to use this, you need to manually set the option
; for "yesDeleteKeyframes" in the PPWAHK_Configs section of the file
; "PremiereProWithAHKConfig.ini" inside the config folder to 1

; I plan to add turning this option on in the gui later, but it's not there yet

; This script is NOT a subprocess that is #Include'd from the primary script that starts
; the program, if it was, it would constantly interfere since it's running an infinite
; loop, so instead the main script runs through a check to see if the option is turned on
; and if so will run this script as a secondary process

DetectHiddenText, On

While(True)
{
    WinWait, Warning ahk_exe Adobe Premiere Pro.exe
    sendinput, {enter}
    sleep 100
}