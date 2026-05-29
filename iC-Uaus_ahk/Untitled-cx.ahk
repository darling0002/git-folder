global iC_Haus_Addr := "C:\Program Files (x86)\iC-Haus\MU_9SO_gui_B4\MU_9SO_gui_B4.exe"
global ProcessExist_name := "MU_9SO_gui_B4.exe"
global Load_Config_Name := "MU-Y1H.cfg"
global Load_Config_Addr := "D:\iC-Uaus_ahk\Load_Config"
global Generate_Report_Addr := "D:\iC-Uaus_ahk\新松数据自动保存"
global Generate_Report_Name := "iC-MU200 0_report"
global delay_time :=    800
global version :=    4
TargetDPI := 120
GetCurrentDPI() {
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    dpi := DllCall("GetDeviceCaps", "Ptr", hdc, "Int", 88, "Int")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    return dpi
}
CurrentDPI := GetCurrentDPI()
Ratio := TargetDPI / CurrentDPI
DPIAwareMouseMove(dx, dy, speed := 0) {
    global Ratio
    new_dx := Round(dx * Ratio)
    new_dy := Round(dy * Ratio)
    MouseMove(new_dx, new_dy, speed)
}
global shouldStop := false
!Esc::
{
    global shouldStop := true
    BlockInput("MouseMoveOff")
    BlockInput("Off")
    ToolTip "⚠ 按键 ESC，正在中断脚本..."
    SetTimer () => ToolTip(), -1500
}
CheckInterrupt(sleepMs := 0) {
    global shouldStop
    if shouldStop
        return true
    if sleepMs > 0 {
        loop Ceil(sleepMs / 50) {
            if shouldStop
                return true
            Sleep 50
        }
    }
    return false
}
pattern := "^1\.0\.\d+V\d+"
ih := InputHook("V")
ih.KeyOpt("{Space}{Enter}", "E")
ih.OnEnd  := OnEndCallback
ih.Start()
OnEndCallback(ih) {
    global  shouldStop
    capturedText := ih.Input
        if (RegExMatch(capturedText, pattern)) {
        shouldStop := false
        if !step_Interface()
            goto CleanUp
        result := MsgBox("查看数据是否异常，然后启动电源", "提示", "OKCancel")
        if result = "OK" {
            if !step_Load_Config()
                goto CleanUp
            if !step_Nonius_Calibration()
                goto CleanUp
            CheckInterrupt(delay_time*10)
            result := MsgBox("查看数据是否异常", "提示", "OKCancel")
            if result = "OK" {
                if !step_Error_Warning_Status()
                    goto CleanUp
                result := MsgBox("查看数据是否异常", "提示", "OKCancel")
                DPIAwareMouseMove(490, 0)
                MoveAbsoluteOffset(0, -30)
                Click "Left"
                CheckInterrupt(delay_time)
                if result = "OK" {
                    if !step_SAVE(capturedText)
                        goto CleanUp
                }else {
                    DPIAwareMouseMove(920, 80)
                    if CheckInterrupt(delay_time)
                        return false
                    Click "Left"
                    goto CleanUp
                }
            } else {
                DPIAwareMouseMove(920, 80)
                if CheckInterrupt(delay_time)
                    return false
                Click "Left"
                goto CleanUp
            }
        } else {
            DPIAwareMouseMove(920, 80)
            if CheckInterrupt(delay_time)
                return false
            Click "Left"
            goto CleanUp
        }
    }
CleanUp:
    BlockInput "Off"
    shouldStop := false
    ih.Start()
}
step_Interface() {
    BlockInput("MouseMove")
    if !ProcessExist(ProcessExist_name) {
        Run iC_Haus_Addr
        Sleep 7000
        Send("{Shift}")
        if (version==10)
        {
            DPIAwareMouseMove(150, 200)
            if CheckInterrupt(delay_time)
                return false
            Click "Left"
        }
        WinActivate("MU: Off-Axis Nonius Encoder with Integrated Hall Sensors")
        if CheckInterrupt(delay_time)
            return false
        if WinExist("Status Information Window") {
            WinActivate("Status Information Window")
            DPIAwareMouseMove(490, 0)
            MoveAbsoluteOffset(0, -30)
            Click "Left"
            CheckInterrupt(delay_time)
        }
        DPIAwareMouseMove(550, 240)
        if CheckInterrupt(delay_time)
            return false
        Click "Left"
        if CheckInterrupt(delay_time*2)
            return false
        step_XX()
    }
    WinActivate("MU: Off-Axis Nonius Encoder with Integrated Hall Sensors")
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(920, 80)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*6)
        return false
    DPIAwareMouseMove(130, 240)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(420, 360)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Backspace}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Backspace}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "0"
    if CheckInterrupt(delay_time/2)
        return false
    Send "0"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time/2)
        return false
    DPIAwareMouseMove(420, 510)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Backspace}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Backspace}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "0"
    if CheckInterrupt(delay_time/2)
        return false
    Send "0"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Enter}"
    DPIAwareMouseMove(1080, 760)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*6)
        return false
    DPIAwareMouseMove(920, 80)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*3)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*3)
        return false
    BlockInput("MouseMoveOff")
    return true
}
step_Load_Config(){
    BlockInput("MouseMove")
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(960, 760)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*3)
        return false
    Send("^l")
    if CheckInterrupt(delay_time)
        return false
    Send Load_Config_Addr
    if CheckInterrupt(delay_time)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time)
        return false
    Send("^e")
    if CheckInterrupt(delay_time)
        return false
    Send Load_Config_Name
    if CheckInterrupt(delay_time*7)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time)
        return false
    Send "{Down}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Down}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Up}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time)
        return false
    BlockInput("MouseMoveOff")
    return true
}
step_Nonius_Calibration() {
    global version
    BlockInput("MouseMove")
    if CheckInterrupt(delay_time*2)
        return false
    DPIAwareMouseMove(550, 240)
    if CheckInterrupt(delay_time*5)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*2)
        return false
    if CheckInterrupt(delay_time*2)
        return false
    DPIAwareMouseMove(90, 520)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*2)
        return false
    DPIAwareMouseMove(90, 140)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(200, 280)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Right}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Backspace}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Backspace}"
    if CheckInterrupt(delay_time/2)
        return false
    Send "8"
    if CheckInterrupt(delay_time/2)
        return false
    Send "0"
    if CheckInterrupt(delay_time/2)
        return false
    Send "{Enter}"
    switch version {
        case 4:
            DPIAwareMouseMove(390, 590)
        case 10:
            DPIAwareMouseMove(390, 690)
    }
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*2)
        return false
    DPIAwareMouseMove(70, 370)
    if CheckInterrupt(delay_time)
        return false
    if CheckInterrupt(delay_time)
        return false
    BlockInput("MouseMoveOff")
    return true
}
step_XX(){
    BlockInput("MouseMove")
    DPIAwareMouseMove(40, 440)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(40, 400)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    switch version {
        case 4:
            DPIAwareMouseMove(1160, 680)
        case 10:
            DPIAwareMouseMove(880, 680)
    }
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(1010, 680)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    if (version==10)
    {
        DPIAwareMouseMove(1160, 680)
        if CheckInterrupt(delay_time/2)
            return false
        Click "Left"
    }
    BlockInput("MouseMoveOff")
    return true
}
step_Error_Warning_Status() {
    BlockInput("MouseMove")
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(700, 240)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*3)
        return false
    DPIAwareMouseMove(190, 630)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(960, 180)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(420, 670)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(490, 0)
    if CheckInterrupt(delay_time/2)
        return false
    MoveAbsoluteOffset(0, -30)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(1080, 760)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*4)
        return false
    DPIAwareMouseMove(960, 180)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(420, 670)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    BlockInput("MouseMoveOff")
    return true
}
step_SAVE(capturedText) {
    BlockInput("MouseMove")
    global Generate_Report_Name, Generate_Report_Addr, delay_time
    fullFileName := Generate_Report_Name . "_" . capturedText
    DPIAwareMouseMove(180, 10)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(180, 110)
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    Send fullFileName
    if CheckInterrupt(delay_time*2)
        return false
    Send("^l")
    if CheckInterrupt(delay_time)
        return false
    Send Generate_Report_Addr
    if CheckInterrupt(delay_time*2)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time*2)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time*4)
        return false
    Send "{Enter}"
    if CheckInterrupt(delay_time*4)
        return false
    DPIAwareMouseMove(920, 80)
    if CheckInterrupt(delay_time*2)
        return false
    Click "Left"
    BlockInput("MouseMoveOff")
    return true
}
MoveAbsoluteOffset(dx, dy) {
    global Ratio
    MouseGetPos(&curX, &curY)
    newX :=  ((curX + dx) )
    newY :=  ((curY + dy) )
    MouseMove(newX, newY, 0)
}
!w::MoveAbsoluteOffset(0, -30)
!a::MoveAbsoluteOffset(-30, 0)
!s::MoveAbsoluteOffset(0, 30)
!d::MoveAbsoluteOffset(30, 0)
!q::{
    global version
    DPIAwareMouseMove(1010, 680)
    switch version {
        case 4:
        case 10:
    }
}
!e::{
Send("{Shift}")
DPIAwareMouseMove(150, 200)
    BlockInput("MouseMoveOff")
    BlockInput("Off")
}
!z::{
step_SAVE(666)
}
!r::Reload()
