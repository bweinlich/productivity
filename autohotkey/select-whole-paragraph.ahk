#Requires AutoHotkey v2.0
; !a::Send "{Home}{Shift down}{End}{Shift up}" ; Select whole line
; !a::Click 3

!a::
{
    If WinActive("ahk_exe Cursor.exe")
    {
        Send "^+{Up}" ; Send Ctrl + Shift + U
        Sleep 100
        Send "^+{Down}" ; Send Ctrl + Shift + D
    }
    else if WinActive("ahk_exe notepad++.exe")
    {
        Send "^+u" ; Send Ctrl + Shift + U
    }
    else
    {
        Send "^+{Up}" ; Send Ctrl + Shift + Up
    }
    return
}