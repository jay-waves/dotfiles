#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode("Event")
SetKeyDelay(-1, -1)
SetWorkingDir(A_ScriptDir)

; ============================================================
; 基础快捷键
; ============================================================

; Alt + T：切换当前窗口置顶
!t::
{
    hwnd := WinExist("A")
    if hwnd
        WinSetAlwaysOnTop(-1, hwnd)
}

; 音量控制
!c::SendEvent("{Volume_Up}")
!x::SendEvent("{Volume_Down}")
!z::SendEvent("{Volume_Mute}")


; ============================================================
; CapsLock 导航层
;
; 单击 CapsLock：Esc
; 按住 CapsLock：启用导航层
; Caps + V：临时 Visual 模式
; 松开 Caps：退出 Visual 模式
; ============================================================

SetCapsLockState("AlwaysOff")

VisualMode := false
CapsLayerUsed := false
CapsIsDown := false


; Caps 按下
*CapsLock::
{
    global VisualMode, CapsLayerUsed, CapsIsDown

    ; 防止键盘重复事件重置 CapsLayerUsed
    if CapsIsDown
        return

    CapsIsDown := true
    CapsLayerUsed := false
    VisualMode := false

    SetCapsLockState("AlwaysOff")
}


; Caps 松开
*CapsLock Up::
{
    global VisualMode, CapsLayerUsed, CapsIsDown

    CapsIsDown := false
    VisualMode := false

    SetCapsLockState("AlwaysOff")

    ; 没有触发任何组合键，视为单击 Caps
    if !CapsLayerUsed
        SendEscape()
}


; 使用完整的 Esc 扫描码按下/松开事件
; 比 Send "{Esc}" 对部分程序更可靠
SendEscape()
{
    SendEvent("{vk1Bsc001 down}")
    Sleep(25)
    SendEvent("{vk1Bsc001 up}")
}


; 普通移动或 Visual 选择移动
CapsMove(normalKeys, visualKeys)
{
    global VisualMode, CapsLayerUsed

    CapsLayerUsed := true

    if VisualMode
        SendEvent(visualKeys)
    else
        SendEvent(normalKeys)
}


; 普通 Caps 层命令
CapsCommand(keys, exitVisual := false)
{
    global VisualMode, CapsLayerUsed

    CapsLayerUsed := true
    SendEvent(keys)

    if exitVisual
        VisualMode := false
}


#HotIf GetKeyState("CapsLock", "P")

; movement
*h::CapsMove("{Left}",  "+{Left}")
*j::CapsMove("{Down}",  "+{Down}")
*k::CapsMove("{Up}",    "+{Up}")
*l::CapsMove("{Right}", "+{Right}")

; word movement
*w::CapsMove("^{Right}", "^+{Right}")
*b::CapsMove("^{Left}",  "^+{Left}")

; line
*u::CapsMove("{Home}", "+{Home}")
*i::CapsMove("{End}",  "+{End}")

; page
*n::CapsMove("{PgUp}", "+{PgUp}")
*m::CapsMove("{PgDn}", "+{PgDn}")

; visual mode
*v::
{
    global VisualMode, CapsLayerUsed

    CapsLayerUsed := true
    VisualMode := true
}

; copy
*y::CapsCommand("^c", true)

; cut
*x::CapsCommand("^x", true)

; paste
*p::CapsCommand("^v")

#HotIf


; ============================================================
; VirtualDesktopAccessor
; 必须使用 64 位 AutoHotkey
; ============================================================

VDA_PATH := "D:\bin\VirtualDesktopAccessor.dll"

if !FileExist(VDA_PATH)
    throw Error("找不到 VirtualDesktopAccessor.dll：`n" VDA_PATH)

hVirtualDesktopAccessor := DllCall(
    "LoadLibrary",
    "Str", VDA_PATH,
    "Ptr"
)

if !hVirtualDesktopAccessor
    throw Error("无法加载 VirtualDesktopAccessor.dll")

GoToDesktopNumberProc := DllCall(
    "GetProcAddress",
    "Ptr", hVirtualDesktopAccessor,
    "AStr", "GoToDesktopNumber",
    "Ptr"
)

GetCurrentDesktopNumberProc := DllCall(
    "GetProcAddress",
    "Ptr", hVirtualDesktopAccessor,
    "AStr", "GetCurrentDesktopNumber",
    "Ptr"
)

MoveWindowToDesktopNumberProc := DllCall(
    "GetProcAddress",
    "Ptr", hVirtualDesktopAccessor,
    "AStr", "MoveWindowToDesktopNumber",
    "Ptr"
)

if !GoToDesktopNumberProc || !MoveWindowToDesktopNumberProc
    throw Error("VirtualDesktopAccessor.dll 缺少必要函数")


MoveCurrentWindowToDesktop(number)
{
    global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc

    activeHwnd := WinGetID("A")

    DllCall(
        MoveWindowToDesktopNumberProc,
        "Ptr", activeHwnd,
        "Int", number,
        "Int"
    )

    DllCall(
        GoToDesktopNumberProc,
        "Int", number,
        "Int"
    )
}


GoToDesktopNumber(number)
{
    global GoToDesktopNumberProc

    DllCall(
        GoToDesktopNumberProc,
        "Int", number,
        "Int"
    )
}


MoveOrGotoDesktopNumber(number)
{
    ; 按住鼠标左键时，将当前窗口移动到目标桌面
    if GetKeyState("LButton", "P")
        MoveCurrentWindowToDesktop(number)
    else
        GoToDesktopNumber(number)
}


; Alt + 1：切换到第一个虚拟桌面
!1::MoveOrGotoDesktopNumber(0)
!2::MoveOrGotoDesktopNumber(1)
!3::MoveOrGotoDesktopNumber(2)
!4::MoveOrGotoDesktopNumber(3)
