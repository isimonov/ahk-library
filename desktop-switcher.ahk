;
; AutoHotkey v2
;
ProcessSetPriority("Realtime", "AutoHotkey64.exe")
DetectHiddenWindows(True)

hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", "VirtualDesktopAccessor.dll", "Ptr") 
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
RegisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
RestartVirtualDesktopAccessorProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RestartVirtualDesktopAccessor", "Ptr")
GetWindowDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetWindowDesktopNumber", "Ptr")
activeWindowByDesktop := Map()

monitorWidth := SysGet(0)
monitorHeight := SysGet(1)

GoToDesktopNumber(num) {
    activeHwnd := WinGetID("A")
    currentDesktop := DllCall(GetCurrentDesktopNumberProc, "UInt") 
    isPinned := DllCall(IsPinnedWindowProc, "UInt", activeHwnd)

    if (isPinned == 0) {
        activeWindowByDesktop[currentDesktop] := activeHwnd
    }
    ; Try to avoid flashing task bar buttons, deactivate the current window if it is not pinned
    if (isPinned != 1 and WinExist("ahk_class Shell_TrayWnd")) {
        WinActivate("ahk_class Shell_TrayWnd")
    }

    DllCall(GoToDesktopNumberProc, "Int", num)

    ; Try to restore active window from memory (if it's still on the desktop and is not pinned)
    activeHwnd := WinGetID("A")
    isPinned := DllCall(IsPinnedWindowProc, "UInt", activeHwnd)
    if (activeWindowByDesktop.Has(num)) {
        oldHwnd := activeWindowByDesktop[num]
        isOnDesktop := DllCall(IsWindowOnCurrentVirtualDesktopProc, "UInt", oldHwnd, "Int")
        if (isOnDesktop == 1 && isPinned != 1) {
            WinActivate("ahk_id " . oldHwnd)
            activeWindowByDesktop.Delete(num)
        }
    }

    CoordMode("ToolTip")
    ToolTip(" " . num+1 . " ", monitorWidth/2, monitorHeight/2)
    SetTimer(() => ToolTip(), -500)
}

GoToNextDesktop() {
    currentDesktop := DllCall(GetCurrentDesktopNumberProc, "UInt")
    lastDesktop := DllCall(GetDesktopCountProc, "UInt") - 1
    if (currentDesktop = lastDesktop) {
        GoToDesktopNumber(0)
    } else {
        GoToDesktopNumber(currentDesktop + 1)    
    }
}
 
GoToPrevDesktop() {
    currentDesktop := DllCall(GetCurrentDesktopNumberProc, "UInt")
    lastDesktop := DllCall(GetDesktopCountProc, "UInt") - 1
    if (currentDesktop = 0) {
        GoToDesktopNumber(lastDesktop)
    } else {
        GoToDesktopNumber(currentDesktop - 1)      
    }
}

; Middle mouse button click on left or right screen part
MButton:: {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&xpos, &ypos)
    if (xpos > monitorWidth/2) {
        GoToNextDesktop()
    } else {
        GoToPrevDesktop()
    }
}

;Ctrl+number switch desktop 
!1::GoToDesktopNumber(0)
!2::GoToDesktopNumber(1)
!3::GoToDesktopNumber(2)
!4::GoToDesktopNumber(3)
!5::GoToDesktopNumber(4)
!6::GoToDesktopNumber(5)
!7::GoToDesktopNumber(6)
!8::GoToDesktopNumber(7)
!9::GoToDesktopNumber(8)
