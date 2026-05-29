;global iC_Haus_Addr := "C:\Program Files\iC-Haus\MU_9SO_gui_B10\MU_9SO_gui_B10.exe"
;global ProcessExist_name := "MU_9SO_gui_B10.exe"
global iC_Haus_Addr := "C:\Program Files (x86)\iC-Haus\MU_9SO_gui_B4\MU_9SO_gui_B4.exe"
global ProcessExist_name := "MU_9SO_gui_B4.exe"
global Load_Config_Name := "MU-Y1H.cfg"
global Load_Config_Addr := "D:\iC-Uaus_ahk\Load_Config"
global Generate_Report_Addr := "D:\iC-Uaus_ahk\新松数据自动保存"
global Generate_Report_Name := "iC-MU200 0_report"
global delay_time :=    800
global version :=    4
;global version :=    10
;TargetDPI := 76   ; 100     ; 常见值：96 = 100% 缩放，120 = 125%，144 = 150%
TargetDPI := 120   ; 125
GetCurrentDPI() {
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    dpi := DllCall("GetDeviceCaps", "Ptr", hdc, "Int", 88, "Int")  ; LOGPIXELSX
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

global shouldStop := false   ; 中断标志，true 时停止所有步骤

!Esc::
{
    global shouldStop := true
    BlockInput("MouseMoveOff")	
    BlockInput("Off")     ;Apply
    ToolTip "⚠ 按键 ESC，正在中断脚本..."
    SetTimer () => ToolTip(), -1500   ; 1.5秒后清除提示
}

CheckInterrupt(sleepMs := 0) {
    global shouldStop
    if shouldStop
        return true
    if sleepMs > 0 {
        ; 分段睡眠，每 50ms 检查一次标志
        loop Ceil(sleepMs / 50) {
            if shouldStop
                return true
            Sleep 50
        }
    }
    return false
}

pattern := "^1\.0\.\d+V\d+"
ih := InputHook("V")       ; V = 可见（不屏蔽原按键）
ih.KeyOpt("{Space}{Enter}", "E")   ; 空格/回车结束捕获
ih.OnEnd  := OnEndCallback          ; 捕获结束时触发检测
ih.Start()

OnEndCallback(ih) {
    global  shouldStop
    capturedText := ih.Input   
        if (RegExMatch(capturedText, pattern)) {
        shouldStop := false
        if !step_Interface()          ; 如果被中断则停止后续
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
                DPIAwareMouseMove(490, 0)     ;X
                MoveAbsoluteOffset(0, -30)
                Click "Left"
                CheckInterrupt(delay_time)
                if result = "OK" {
                    if !step_SAVE(capturedText)
                        goto CleanUp
                }else {
                    DPIAwareMouseMove(920, 80)     ;connect
                    if CheckInterrupt(delay_time)
                        return false
                    Click "Left" 
                    goto CleanUp          
                }                
            } else {
                DPIAwareMouseMove(920, 80)     ;connect
                if CheckInterrupt(delay_time)
                    return false
                Click "Left"
                goto CleanUp   
            }
        } else {
            DPIAwareMouseMove(920, 80)     ;connect
            if CheckInterrupt(delay_time)
                return false
            Click "Left"
            goto CleanUp    
        }       
    }   
CleanUp:
    BlockInput "Off"
    shouldStop := false          ; 复位中断标志，以便下次执行
    ih.Start()
}

step_Interface() {
    BlockInput("MouseMove")
    if !ProcessExist(ProcessExist_name) {
        Run iC_Haus_Addr
        Sleep 7000   ; 等待界面加载，可根据实际启动速度调整
        Send("{Shift}")
        if (version==10)
        {
            DPIAwareMouseMove(150, 200)     ;open-ok
            if CheckInterrupt(delay_time)
                return false
            Click "Left"       
        }
        WinActivate("MU: Off-Axis Nonius Encoder with Integrated Hall Sensors")
        if CheckInterrupt(delay_time)
            return false
        if WinExist("Status Information Window") {
            WinActivate("Status Information Window")  ; 激活窗口
            DPIAwareMouseMove(490, 0)     ;X
            MoveAbsoluteOffset(0, -30)
            Click "Left"
            CheckInterrupt(delay_time)
        } 
        DPIAwareMouseMove(550, 240)     ;Nonius Calibration
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
    DPIAwareMouseMove(920, 80)     ;connect
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*6)
        return false      
    DPIAwareMouseMove(130, 240)     ;interface
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false   
    Click "Left"
    if CheckInterrupt(delay_time)
        return false   
    DPIAwareMouseMove(420, 360)     ;ST Mode
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
    DPIAwareMouseMove(420, 510)     ;ZBO
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
    DPIAwareMouseMove(1080, 760)     ;write eerpom
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*6)
        return false
    DPIAwareMouseMove(920, 80)     ;connect
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
    DPIAwareMouseMove(960, 760)     ;Load Config
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*3)
        return false
    Send("^l")
    if CheckInterrupt(delay_time)
        return false
    ;Send "shell:Desktop"
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
    DPIAwareMouseMove(550, 240)     ;Nonius Calibration
    if CheckInterrupt(delay_time*5)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*2)
        return false
/*
    DPIAwareMouseMove(40, 440)     ;Adjust SPO
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false    
    DPIAwareMouseMove(40, 400)     ;Adjust Analog
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(880, 680)     ;Error
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false    
    DPIAwareMouseMove(1010, 680)     ;SPO
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
*/
    if CheckInterrupt(delay_time*2)
        return false
    DPIAwareMouseMove(90, 520)     ;Settings
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*2)
        return false  
    DPIAwareMouseMove(90, 140)     ;Biss/SSI
    if CheckInterrupt(delay_time/2)
        return false  
    Click "Left"
    if CheckInterrupt(delay_time)
        return false  
    DPIAwareMouseMove(200, 280)     ;FRR
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
            DPIAwareMouseMove(390, 590)     ;Apply
        case 10:
            DPIAwareMouseMove(390, 690)     ;Apply
    } 
    ;DPIAwareMouseMove(390, 690)     ;Apply
    if CheckInterrupt(delay_time/2)
        return false 
    Click "Left"
    if CheckInterrupt(delay_time*2)
        return false
    DPIAwareMouseMove(70, 370)      ;Acquire Data
    if CheckInterrupt(delay_time)
        return false
    ;Click "Left"
    if CheckInterrupt(delay_time)
        return false
    BlockInput("MouseMoveOff")
    return true
}

step_XX(){
    BlockInput("MouseMove")
    DPIAwareMouseMove(40, 440)     ;Adjust SPO
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false    
    DPIAwareMouseMove(40, 400)     ;Adjust Analog
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    switch version {
        case 4:
            DPIAwareMouseMove(1160, 680)     ;Error
        case 10:
            DPIAwareMouseMove(880, 680)     ;Error
    }
    ;DPIAwareMouseMove(880, 680)     ;Error
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false    
    DPIAwareMouseMove(1010, 680)     ;SPO
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    if (version==10)
    {
        DPIAwareMouseMove(1160, 680)     ;SPO
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
    DPIAwareMouseMove(700, 240)     ;EWS
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*3)
        return false
    DPIAwareMouseMove(190, 630)     ;Accumulated
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(960, 180)     ;Show Details
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(420, 670)     ;Read Status
    if CheckInterrupt(delay_time)
        return false 
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(490, 0)     ;X
    if CheckInterrupt(delay_time/2)
        return false
    MoveAbsoluteOffset(0, -30)
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(1080, 760)     ;write eerpom
    if CheckInterrupt(delay_time/2)
        return false
    Click "Left"
    if CheckInterrupt(delay_time*4)
        return false
    DPIAwareMouseMove(960, 180)     ;Show Details
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(420, 670)     ;Read Status
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

    DPIAwareMouseMove(180, 10)     ;Extras
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    DPIAwareMouseMove(180, 110)     ;Generate Report
    if CheckInterrupt(delay_time)
        return false
    Click "Left"
    if CheckInterrupt(delay_time)
        return false
    Send fullFileName    
    ;Send capturedText
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
    DPIAwareMouseMove(920, 80)     ;connect
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

!w::MoveAbsoluteOffset(0, -30)   ; 上 (Y 减少 10)
!a::MoveAbsoluteOffset(-30, 0)   ; 左 (X 减少 10)
!s::MoveAbsoluteOffset(0, 30)    ; 下 (Y 增加 10)
!d::MoveAbsoluteOffset(30, 0)    ; 右 (X 增加 10)
;!q::DPIAwareMouseMove(130, 240)     ;interface
;!e::DPIAwareMouseMove(420, 360)     ;ST Mode
;!q::DPIAwareMouseMove(550, 240)     ;Nonius Calibration
;!e::DPIAwareMouseMove(960, 760)     ;Load Config
;!q::DPIAwareMouseMove(delay_time, 370)     ;Acquire Data
;!q::DPIAwareMouseMove(700, 240)     ;EWS
;!e::DPIAwareMouseMove(190, 630)     ;Accumulated
;!e::DPIAwareMouseMove(90, 520)     ;Settings
;!e::DPIAwareMouseMove(180, 10)     ;Extras
;!q::DPIAwareMouseMove(180, 110)     ;Generate Report
;!e::DPIAwareMouseMove(420, 670)     ;Read Status
;!q::DPIAwareMouseMove(490, 0)     ;X
;!e::DPIAwareMouseMove(90, 140)     ;Biss/SSI
;!q::DPIAwareMouseMove(90, 520)     ;Settings
;!e::DPIAwareMouseMove(1160, 680)     ;Error
;!q::DPIAwareMouseMove(1010, 680)     ;SPO

;!q::DPIAwareMouseMove(100,180)     ;interface
;!e::DPIAwareMouseMove(350,280)     ;ST Mode
;!q::DPIAwareMouseMove(130, 240)     ;interface
;!e::DPIAwareMouseMove(390, 690)     ;Apply 
;!q::DPIAwareMouseMove(70, 370)     ;Acquire Data
;!e::DPIAwareMouseMove(390, 590)     ;Apply 
!q::{
    global version
    DPIAwareMouseMove(1010, 680)     ;SPO
    switch version {
        case 4:
            ;MsgBox("函数中：版本4")
        case 10:
            ;MsgBox("函数中：版本10")
    }
    ;step_Error_Warning_Status()
    ;BlockInput("MouseMove")
    ;BlockInput("Mouse") 
    ;BlockInput("On")    ;Acquire Data
    ;DPIAwareMouseMove(390, 690)     ;Apply
    ;Sleep 5000
    ;BlockInput("MouseMoveOff")	
    ;BlockInput("Off")
}

!e::{
;DPIAwareMouseMove(550, 240)     ;Nonius Calibration
Send("{Shift}")
DPIAwareMouseMove(150, 200)     ;open-ok
    ;DPIAwareMouseMove(1160, 680)     ;Error
    ;DPIAwareMouseMove(390, 590)     ;Apply 
    ;step_XX()
    ;DPIAwareMouseMove(90, 520)     ;Settings
    ;DPIAwareMouseMove(90, 140)     ;Biss/SSI
    BlockInput("MouseMoveOff")	
    BlockInput("Off")     ;Apply 
}

!z::{
;step_XX()
step_SAVE(666)
}

!r::Reload()