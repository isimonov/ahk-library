;
; AutoHotkey v2
;
ProcessSetPriority("Realtime", "AutoHotkey64.exe")
DetectHiddenWindows(True)

monitorWidth := SysGet(0)
monitorHeight := SysGet(1)

currentDesktop := 1

; Middle mouse button click on left or right screen part
MButton:: {
    global currentDesktop
    if (currentDesktop == 1) {
        Send("#^{Right}")
        currentDesktop := 2
    } else {
        Send("#^{Left}")
        currentDesktop := 1
    }

    CoordMode("ToolTip")
    ToolTip(" " . currentDesktop . " ", monitorWidth/2, monitorHeight/2)
    SetTimer(() => ToolTip(), -500)
}
