;=====================================================================o
; My Time at Portia Keymap
;=====================================================================o
SendMode "Input"	                            ; 快
SetWorkingDir A_ScriptDir        	            ; 脚本主页
#Hotif WinActive("ahk_exe Portia.exe")          ; 游戏窗口内生效，其它环境不生效
SetMouseDelay -1	                            ; 鼠标上下左右，仅winAPI生效，但没有真的鼠标控制丝滑（鼠标延迟默认10，改成-1就好了）
CoordMode "Pixel", "Window"                     ; 取色相对于窗口    
#include PortiaFunctions.ahk         ; 游戏配置和缓存：优先查询数据，找不到再计算
bagCounter := Counter(972, 512, CounterConst.icon.ZERO)              ; 计数器坐标：背包/工作台/商店; 首次运行创建，关闭脚本时销毁
workCounter := Counter(1000, 584, CounterConst.icon.ONE)
factoryCounter := Counter(990, 620, CounterConst.icon.FACTORY)
;=====================================================================o

#SuspendExempt True
; 变身形态
.:: WorkState.next()
W:: WorkState.main()
T:: WorkState.assist()
Q:: Bag.quickSortItems()
!^E:: Actor.haveDinner()
Y::   Actor.doMisterySwordAttack()
; 确认和退出: 处理状态缓存
CapsLock::
Esc::  ExtendKey.Esc()
*I::   ExtendKey.LButton()
*O::   ExtendKey.RButton()
*R::   ExtendKey.bindToggleScript()
*X::   ExtendKey.bindToggleScript()
Enter::ExtendKey.Enter()
; 不智慧助手
*Space:: AI.heySiri()
; 上下左右（VIM 风格）
*H:: GameMouse.move("←")
*J:: GameMouse.move("↓")
*K:: GameMouse.move("↑")
*L:: GameMouse.move("→")
; 滚轮前后
*':: GameMouse.scroll("⏫")
+`;::GameMouse.scroll("⏬")
*`;::GameMouse.scroll("⏬")
; 开发测试
^g:: Scene.whichScene()
^!g::Helper.getMousePosCode()
!g:: Helper.getPixelSearchCode(5)
^+g::Helper.serilize(Counter.dynamicPos)
; 选择元素
*1:: Element.select(1)
*2:: Element.select(2)
*3:: Element.select(3)
*4:: Element.select(4)
*5:: Element.select(5)
*6:: Element.select(6)
*7:: Element.select(7)
*8:: Element.select(8)
*9:: Element.select(9)
*0:: Element.select(10)
*-:: Element.select(11)
*=:: Element.select(12)
*P:: Element.select(13)
; 挂起脚本：还原方向键
#SuspendExempt False
*S:: Direction.move("←")
*F:: Direction.move("→")
*E:: Direction.move("↑")
*D:: Direction.move("↓")
#Hotif


;=====================================================================o

; 🎮 游戏设定
; ----
; 常量，键位设置。必填。拓展原有的功能键，处理状态的进出。\
; 💡 键位设置：尽量用左手完成，也考虑到右手鼠标，左手键盘协同操作的情况，充分发挥左手操作的价值
class GameSetting {

    ; 不允许实例化，只记录游戏中的按键设置，用于状态切换时的拓展
    __New(p*) {
        return false
    }
     
    ; 游戏设定常量
    class Constant {
        ; 物品栏列数
        static BAG_ITEM_COLUMNS := 8
        ; 产品每页显示个数（分辨率高会显示更多）
        static PAGE_SIZE := 6
        ; 屏幕分辨率（必须） 1680 * 1050 
    }
    
    
     
    ; 键位设置
    class Keyboard {
        ; 替换背包物品
        static EXCHANGE := "g"
        ; 探宝: 或抱起物品
        static SEEKING_TREASURES := "u"
        ; 交互
        static INTERACTIVE := "r"
        ; 推荐设置
        static UP := "e"
        static DOWN := "d"
        static LEFT := "s"
        static RIGHT := "f"
        static JUMP := "space"
        static LCLICK := "i"
        static RCLICK := "o"
        static OPEN_BAG := "x"
        static SWITCH_MONSTER_TARGET := "Alt"
    }
    
    ; 鼠标移动速度
    class Mouse {
        static QUICK_SPEED := 97
        static SLOW_SPEED := 35
    }
}
