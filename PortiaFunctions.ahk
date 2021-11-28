;=====================================================================o
;                    Portia Functions

class Element {

    ; 备忘录模式：记录一次最后的参数，实现前进和后退，并轮询机制
    static final := 1

    static next() {
        this.final++ 
        if this.final > 8 {
            this.final := 1
        }
        this.select(this.final)
    }

    static previous() {
        this.final-- 
        if this.final < 1 {
            this.final := 8
        }
        if this.final > 8 {
            this.final := 1
        }
        this.select(this.final)
    }

    ; 选择第 N 个元素
    ; ----
    ; | 场景 |  类型 |坐标 |
    ; | :------ | :------ | :------ |
    ; | 背包 | 二维坐标 |  [i, j] |
    ; | 工作台 / 熔炉  |列表|  [1, 1~6] |
    ; | 手册 / 组装台 | 标签 |  [1, 1~3] |
    ;  ----
    ;  组合键
    ;  - `Ctrl` 背包和物品栏交换
    ;  - `Alt`  背包和储物箱交换
    ;
    static select(index) {
        if WorkState.name == "fish" and Scene.onOutside() {
            WorkState.Fisher.feed(index)
            return
        } 
        this.selectHotKeyPolicy(index) 
        this.final := index
    }

    ; 选择数字的热键策略： \
    ; 附带交换物品栏或右键交换箱子，跑步时不生效 \
    ; 游戏内置 `Shift + 左键` 拆分道具，所以不要用 `Shift` 来修饰交换装备
    static selectHotKeyPolicy(index) {
        this.selectSceneRouter(index)
        if (index <= GameSetting.Constant.itemBarColumns) {
            up := GameSetting.Keyboard.up
            if GetKeyState("Ctrl", "p") and !GetKeyState(up, "p") {
                Send GameSetting.Keyboard.exchange
            } else if GetKeyState("LAlt", "p") {
                Sleep 50
                Send GameMouse.button("⚙️")
            }
        }
    }

    ; 场景路由器                      功能 
    ; 计数器对话框                不变 （ceh数量）
    ; 户外                       不变 （切换道具）
    ; 选择第几个背包物品/标签/产品   分情况讨论（按使用频率排序）
    static selectSceneRouter(index) {
        originKey := SubStr(A_ThisHotkey, -1)
        if Scene.isOutside() or Scene.onCounterUI() {
            Send "{Blind!+^}" originKey
        } else if Scene.onBagItemUI() {
            ; 空间换时间：8 * 5 + 装备栏
            this.selectBagItemSceneRouter(index)
        } else if Scene.onNormalListUI() {
            this.selectListSceneRouter(index)
        } else {
            ; 其他未确定的情况: 如 NPC 交互界面
            Send "{Blind!+^}" originKey
        }
    }

    static selectListSceneRouter(index) {
        if Scene.isRelic() {
            ListUI.selectAtRelic(index)
        } else if Scene.isChickenHouse() {
            ListUI.selectAtChickenHouse(index)
        } else if Scene.isFactory() {
            ListUI.selectAtFacotry(index)
        } else if Scene.isDelegation() {
            ListUI.selectAtDelegation(index)
        } else if Scene.isTowerDrink() {
            ListUI.selectAtTowerDrink(index)
        } else if Scene.isOrder() {
            ListUI.selectAtOrder(index) 
        } else if Scene.isManualUI() {
            ListUI.selectManualTab(index)
        } else if Scene.isCookBook() {
            ListUI.selectCookBookTab(index)
        } else {
            ListUI.selectDefault(index)
        }
    }

    static selectBagItemSceneRouter(index) {
        if Scene.isBag() {
            Bag.selectItemAtBag(index)
        } else if Scene.isBox() {
            Bag.selectItemAtBox(index)
        } else if Scene.isShop() {
            Bag.selectItemAtShop(index)
        } else if Scene.isGift() {
            Bag.selectItemAtGift(index)
        } else if Scene.isPlantBag() {
            Bag.selectItemAtPlantBag(index)
        } else {
            Bag.selectItemAtFileBox(index)
        }
    }
    
}

;=====================================================================o

; 🤖 不智慧助手
; ----
; 综合处理各种消息：接受委托 / 户外保留原键 / 背包搜索和还梯子 / 投喂饲料 / 邮箱接受和已读 / 商会接单 / 对话点击首选项 / 遗迹开始挑战
class AI {

    ; 也许它知道你想做的动作
    static heySiri() {
        ; 叠加状态的抽象层级封装：坐飞机时，也能交互对话
        ; 户外模式保留原来的按键 
        if WorkState.name == "farm" or (Scene.onRiding() and !Scene.hasAircraft) or (Scene.onOutside()) {
            ; 必须区分持续按下
            key := LTrim(A_ThisHotkey, "*")
            Send "{Blind}{" key " down}"
            KeyWait key
            Send "{Blind}{" key " up}"
            return
        } 
        this.heySiriSceneRouter()
        ; 清除状态: 又能选择第一行背包了
        if Scene.HereCache.ui["bag"] {
            Bag.Ladder := 0
        }
    }

    ; 应对不同场景的快捷指令
    static heySiriSceneRouter() {
        
        if Scene.isGift() {
            ; 礼物： 确定送出 [必须在背包 UI 上面，因为重叠了] ; Enter 虚拟按键失灵，物理按键才有用，奇怪
            Click "1098 811" ; 确定
        } else if Scene.isBox() {
            ; 搜索：下拉菜单，移到中位，方便滚轮翻页
            Click "797 172" 
            Sleep 25
            Click "799 286 0"
        } else if Scene.isProductUI() {
            ; 制作：（冗余操作，但合并了位置变动的按钮，第二个无副作用）
            Click "350 905"
            Click "410 905"
        } else if Scene.isFactory() {
            ; 同时制造
            Click "1356 816"
        } else if Scene.isBusMap() {
            ; 回家: 车站地图
            Scene.findHomeStation()
        } else if Scene.isTowerDrink() {
            ; 确定
            Click "363 906"
        } else if Scene.isChickenHouse() {
            ; 添加
            Click "581 972" 
        } else if (PixelSearch(&FoundX, &FoundY, 500, 750, 730, 1000, 0x8BDE6E, 5)) {
            ; 大范围确定：扩大搜索底部区域的确定按钮
            Click FoundX + 10, FoundY + 10
        } else if Scene.isDelegation() or Scene.onCounterUI() {
            Send "{Blind!^}{Enter}"
        } else if Scene.isEmail() {
            ; 关闭：这种退出，避免Esc 清除轮播计数器状态
            this.closeEmail()
        } else if Scene.isHunter() {
            ; 放置诱捕材料
            Click "1008 884"
            Send "{Esc}"
        } else if Scene.isRelic() {
            Click "811 811" ; 开始
        } else if Scene.isPriOrder() {
            ; 接受：主线任务 Primary 级别
            Click "760 870"
        } else if Scene.isDialog() {
            ; 好的：接受任务
            Click "1300 700"
        } else {
            ; 空格：未收录场景，比如对话结束
            key := LTrim(A_ThisHotkey, "*")
            Send "{Blind}{" key "}"
            ; tooltip "助手未收录场景"
            ; SetTimer () => ToolTip(), -2000
        }
    }

    ; 关闭右键按钮
    static closeEmail() {
        PixelSearch(&FoundX, &FoundY, 500, 750, 1150, 1000, 0x8BDE6E, 5)
        Click FoundX, FoundY
    }
}

;=====================================================================o

; 🐱‍🏍 角色
; ----
; 自定义拓展技能：就餐，攻击连招，跑步加速 5 秒
class Actor {

    ; 一键就餐：今日特惠、暴击菜，体力 +60
    static haveDinner() {
        Click "550 930"	; 今日特惠
        Sleep 50
        Click "899 307" ; 加暴击的标签
        sleep 50
        Click "1038 697" ; 酸辣土豆丝
        Sleep 50
        Click "1400 950"	; 买单
        Sleep 100
        Send "{Blind!^}{Enter}"
    }


    ; 神秘武士的剑连招: 打出冲击波; 无怪时稳定触发，有怪时触发不稳定
    static doMisterySwordAttack() {
        Click	; 当前位置持续连按鼠标左键
        Sleep 1300
        Click
        Sleep 200
        Click
        Sleep 170
        Click
        Sleep 50
        Click
        Sleep 50
        Click
    }

    static speedUp(second := 5) {
        ; 持续加速 5 秒钟
        SetTimer () => this.loopSpeedUp(), -1000 * second
    }

    ; 持续加速 5 秒 ：触发不稳定，中断不稳定
    static loopSpeedUp() {
        loop {
            Send "{Blind!^}{Shift Down}"
            Sleep 100
            if getkeystate("F", "p") {
                breaK
            }
        }
    }
    
}

;=====================================================================o

; 🛖 家园工坊
; ----
; 简化了的畜牧养殖、机电设备、制作道具等重复的机械操作，提供指令集接口，让玩家关心操作以外的事务
class Factory {

    ; 收集和管理：开启工厂和管家艾克后，闲置
    static collectAndManage() {
        ; 收获并进入操作界面
        Send "{Blind!^}" GameSetting.Keyboard.interactive
        Sleep 1200
        Send "{Blind!^}" GameSetting.Keyboard.interactive
    }

    static startWorking() {
        ; 自动添柴、照旧增加产量，和返回（先后顺序：添加木柴，才能点击制作）工作台禁用，因为材料不退回
        if Scene.onOutside() or Scene.isWorkStation() {
            Send "{Blind!+^}" SubStr(A_ThisHotkey, -1)
            return
        } 
        if Scene.isProductUI() {
            ; 仅锅炉模式生效，保留原来的按键（多一个维度）
            this.updateFuel()
            Sleep 50
            this.doMaxMake()
            Sleep 50
            Send "{Blind!^}{Esc}"
        } else if Scene.isDelegation() {
            ; 委托次数（数量）
            Click "926 461"
            Sleep 500
            this.doMaxDelegate()
            ; 委托期限 （默认最小天数）
            Sleep 50
            Click "1071 780" ; 确定
            Sleep 50
            Send "{Blind}{Enter}"
        } else {
            ; 其他情况
            Send SubStr(A_ThisHotkey, -1)
        }
    }

    static coninueWorking() {
        ; 排除查用场景的误触
        if Scene.onBagItemUI() {
            return
        }
        ; 解决：手动切换模式，让键位空出位置，每个模式所有的按键共同服务完成一个业务
        this.collectAndManage()
        Sleep 500
        if Scene.isWorkStation() {
            ; 阻止自动造，因为瞬间完成，材料不会退回
            return
        }
        this.updateWorkingProduct()
        Sleep 50
        this.startWorking()
    }

    static updateFuel() {
        Click "1465 830"	; 添加柴火
        Sleep 50
        Send "{Blind}{Enter}"
    }

    static doMaxMake() {
        Click "410 900"	; 制作
        Sleep 100
        ; 是否替换的弹窗: 确定
        if PixelSearch(&FoundX, &FoundY, 715, 599, 725, 609, 0x8BDE6D, 3) {
            Send "{Blind!^}{Enter}"
        }
        Sleep 200
        Click "1000 590"	; 最大量
        Sleep 50
        Send "{Blind!^}{Enter}"
    }
    
    static doMaxDelegate() {
        Click "990 535"
        Sleep 300
        ; 多点一次才保险，经常失灵
        Click "990 535"
        Send "{Blind!^}{Enter}"
    }

    static clickWorkingProduct() {
        ; 找到正在加工的材料（颜色像素查找，比图像识别靠谱多了，筛选又快）
        isWorking := PixelSearch(&FoundX, &FoundY, 170, 300, 195, 860, 0xE76760, 3)
        if (isWorking) {
            Click FoundX + 150, FoundY + 25
        }
        ; 反馈是否找到，如果找不到到，翻页再找一次
        return isWorking
    }

    static updateWorkingProduct() {
        ; 两次机会查找: 第一页， 第二页
        if not this.clickWorkingProduct() {
            ; [TODO] 如果不能翻页，可能是这个原因
            this.scrollNextPage()
            sleep 50
            this.clickWorkingProduct()
        }
    }

    static scrollNextPage() {
        loop 10 {
            Click "400 540 WheelDown"
        }
    }

}

;=====================================================================o

; 列表
; ----
; 选择第 N 行的元素
class ListUI {

    static getNextPageIndex(rows, pageSize) {
        ; 第一页: 直接返回
        if (rows <= pageSize) {
            return rows
        }
        ; 第二页: 计算后返回第二页第N索引（找到第N个循环过后的位置）
        pageSum := Floor((rows - 1) / pageSize) + 1
        index := rows - (pageSum - 1) * pageSize
        return index
    }

    static selectOption(index, originX:=400, originY:=350, dy:=90, options:=6) {
        if (index > options) {
            return
        }
        index := this.getNextPageIndex(index, options)
        posY := originY + dy * (index - 1)
        Click originX, posY
    }
    
    static selectDefault(index) {
        this.selectOption(index) 
    }

    static selectAtRelic(index) {
        this.selectOption(index, 700, 350, 90, 4) 
    }

    static selectAtChickenHouse(index) {
        this.selectOption(index, 622, 224, 90, 7) 
    }

    ; 组装台 vs 手册: 组装台的标签向下动一行
    static selectAtManual(index) {
        if (index < 4 ) {
            originY := Scene.isManual() ? 360 : 300
            this.selectOption(index, 100, originY, 60, 3)
        } else if (index == 4) {
            ; 开始组装
            Click "739 151"
        } else if (index==5) {
            Click "1430 154"
        } else {
            return
        }
    }

    static selectAtCookBook(index) {
        this.selectOption(index, 130, 270, 60, 4)
    }
     
    static selectAtDelegation(index) {
        this.selectOption(index, 600, 400, 90, 5)
    }

    static selectAtFacotry(index)  {
        this.selectOption(index, 600, 368, 90, 6)
    }

    static selectAtTowerDrink(index) {
        this.selectOption(index, 520, 280, 100, 5)
    }

    static selectAtOrder(index) {
        this.selectOption(index, 820, 420, 80, 4)
    }
}

;=====================================================================o

; 计数器
; ----
; 批量拆分 / 制作元素时，弹出的对话框，提供点击增减最值和手动输入的能力，优先级最高。设计有缓存机制记录共存页面。 \
;
; iconType：
; - 0: zeroIcon
; - 1: oneIcon
; - 2: factoryIcon
class Counter {

    ; 动态坐标： 分为无图标，有图标，工厂图标
    static dynamicPos := { zeroIcon: {}, oneIcon: {}, factoryIcon: {} }
    
    __New(originX, originY, iconType, useCache:=true, dx:=63) {
        switch (iconType) {
            case 0: attr := "zeroIcon"
            case 1: attr := "oneIcon"
            case 2: attr := "factoryIcon"
        }
        this.cache := Cache.counterPos[attr]
        this.attr := Counter.dynamicPos[attr]
        this.attr["lock"] := false
        this.hasIcon := iconType 
        this.useCache := useCache
        this.dx := dx
        if useCache {
            this.savePosCache(originX, originY)
        } else {
            this.savePos(this.attr, originX, originY, this.hasIcon, dx) 
        }
    }
    
    savePos(map, x, y, hasIcon, dx) {
        if (x == "" or y == "") {
            return
        }
        attrs := ["max", "plus", "center", "minus", "min"]
        for index, attr in attrs {
            if (index > 3  && hasIcon) {
                ; 产品/商品：有图标，偏移量拉长, 越大越左, 因为 dx 取负号
                index++
            }
            map[attr] := x - dx * (index - 1) " " y
        }
        map["lock"] := true
    }

    ; 备注：确认按钮坐标不用储存，因为支持 Enter 确认 \
    ; 优先使用数据库，找不到再动态生成,生成后，再导出补充数据库 \
    ; ✍🏻 读写锁：只能写一次，避免重复写
    savePosCache(x, y) {
        if this.cache["lock"] == true {
            return
        } else {
            if (!this.attr["lock"]) {
                this.savePos(this.attr, x, y, this.hasIcon, this.dx)
            }
        }
    }

    click(button) {
        try {
            if this.useCache {
                this.slowClick(this.cache[button])
            } else {
                this.slowClick(this.attr[button])
            }
        } catch Error as err {
            msgbox err.message
        }
    } 
    
    slowClick(dynamicPos) {
        ; 修复：第一次只移动鼠标，第二次才点击，因为太快导致游戏中检测不到,所以添加延迟
        Click dynamicPos " 0"
        sleep 50
        Click dynamicPos
    }

}

;=====================================================================o

; 🎒 背包
; ----
; 选择第 N 个物品，涉及二维坐标的定位 
; 。
; ----
; | 场景 | 坐标类型 | 按键设计 |
; | :------ | :------  | :------ |
; | 背包 | 二维 | 数字键 + 其他键溢出数字传参
; | 工作台/锅炉/手册 | 一维 * 2 | 数字键 + 左右，各司其职 |
; | 日历/邮件/标签 | 一维 | 左右 |
class Bag {

    ; 梯子，将二维数组折叠
    static Ladder := 0

    ; @param originX/originY  左上角第一个格子中央坐标
    ; @param dx/dy X/Y 轴间距
    ;
    ; ### 算法设计 
    ; 
    ; 传入参数超过列数的部分，就是第 j 行（梯子）, 借助第三方记录的梯子状态，可以 j 行 第 i 个物品
    ; 。
    ; ---
    ; | 按键传参  | 映射坐标  | 备注     |
    ; | :------ | :------  | :------ |
    ; | [1, 8 ] | [1-8, 1] |         |
    ; | [9, 0-=] | [1-8, 2-5] | 获得第 j 行的梯子，结合数字键定位格子 |
    ; | [p    ] | [1-8, p] | 跳转装备栏 |
    ; 
    ; ---
    ; 提示
    ; - 空格键：已联动，可以清除归位，选择第 1 行物品
    ; - 梯子必须是类的全局静态变量，因为 AHK 不能访问静态内部方法的静态变量，导致不能清除归位 
    ; AHK 设计缺陷
    ; 单向性且不能互换：类静态变量 ⇒ 局部静态变量 ,局部静态变量 ⇒ 类静态变量，即使函数内覆写，但调用时是分开的两个值
    static selectItem(index, originX, originY:=370, dx:=75, dy:=75) {
        ; static this.Ladder := Bag.Ladder
        ; 背包格子列数
        columns := GameSetting.Constant.itemBarColumns
        posY := originY

        if (index <= columns) {
            if this.Ladder {
                PosY := originY + this.Ladder * dy
            }
        } else {
            this.Ladder := index - columns
            PosY := originY + this.Ladder * dy
            index := 1
        }
        posX := originX + (index - 1) * dx
        Click posX, posY
    }
    
    static selectItemAtBag(index) {
        this.selectItem(index, 1050)
    }

    static selectItemAtBox(index) {
        this.selectItem(index, 1000)
    }

    static selectItemAtShop(index) {
        this.selectItem(index, 985, 410)
    }

    static selectItemAtFileBox(index) {
        this.selectItem(index, 990)
    }

    static selectItemAtGift(index) {
        if (index > 12) {
            ; 越界：没有装备栏可以选择，返回第一行
            index := 1
            this.Ladder := 0
        }
        this.selectItem(index, 725)
    }

    static selectItemAtPlantBag(index) {
        this.selectItem(index, 990, 340)
    }

    ; 快速整理背包：全部整理 / 整理 / 储物箱整理 ，鼠标最后停在储物箱中央格子
    static quickSortItems() {
        if Scene.onBagItemUI() {
            this.sortItems()
            Sleep 50
            this.sortStores()
        } else {
            Send "{Blind!+^}{" LTrim(A_ThisHotkey, "*") "}"
        }
    }

    ; 储物箱：全部整理，合并同类进库存
    static sortItems() {
        Click "1320 860"
        Sleep 100
        Send "{Blind!^}{Enter}"
        Scene.hasCounter := false
        ; 背包: 整理（冗余操作，但合并了两个场景，背包和储物箱, 反正不能点中间的丢弃）
        Click "995 860"
    }

    ; 储蓄箱整理
    static sortStores(){
        Click "175 858"  
        Sleep 25
        Click "328 524 0" ; 左侧背包中央，方便移动
        Send "{Blind!^}{Enter}" ; 工厂的整理，在最后确定，冗余，但包容了多个场景
    }

}

;=====================================================================o

; 🗺️ 方向键
; ----
; 场景 ⇒ 热键 ⇒ 场景路由 ⇒ 点击元素 
class Direction {

    ; 挂起脚本机制：AHK 不能同时检测到两个键一起按下，拼凑缓存字符串的效果，跑步像放 PPT ，
    ; 所以干脆不实现方法了，只要在户外跑，就挂起脚本禁用这块功能，保留其他大部分功能。在进出交互界面入口释放
    static move(direction) {
        if Scene.isOutside() or Scene.isRiding() {
            Suspend True
            return
        } 
        switch direction {
            case "→": this.clickLeftOrRight(direction)
            case "←": this.clickLeftOrRight(direction)
            case "↑": this.clickUpOrDown(direction)
            case "↓": this.clickUpOrDown(direction)
        }
    }

    ; 智能翻页: 所有与左、右相关的逻辑操作。常见计数器，翻页
    static clickLeftOrRight(direction) {
        if Scene.onCounterUI() {
            ; 弹出窗口优先级最高，点击其他元素没反应，所以功能合并，交给上下文管理
            ; 去掉缓存（实时监测），才能知道鼠标点击事件过后的状态
            CounterContext.click(direction)
        } else {
            ; 智能翻页：储物箱/手册/组装台/工作台/社交/日历; 
            ; 这两个键，不能设置成此页面上相关的功能，比如不能设为打开背包
            PageContext.turn(direction)
        }
    }

    static clickUpOrDown(direction) {
        switch (direction) {
            case "↑" : Element.previous()
            case "↓" : Element.next()
        }
    }
    
}

; 计数器管理上下文：热键 ⇒ 场景路由 ⇒ 点击元素
class CounterContext {
    
    ; 点击计数器，或点击开始组装。一行共 5 个按钮：最小值，减少，手动输入值，增加，最大值
    static click(direction) {
        ; 添加肥料 E / 商店 E / 工作台 E 
        if Scene.onCounterUI() {
            this.clicHotKeyPolicy(direction)
        } else {
            Send A_ThisHotkey
        }
    }

    static clicHotKeyPolicy(direction) {
        if GetKeyState("Ctrl", "p") {
            button := direction == "→" ? "max" : "min"
        } else if GetKeyState("Alt", "p") {
            button := "center"
        } else {
            button := direction == "→" ? "plus" : "minus"
        }
        this.clickSceneRouter(button)
    }

    static clickSceneRouter(button) {
        ; 带图标：工作台/添加肥料 ; 商店/背包：通用五图标
        if Scene.hasZeroIconCounter() {
            bagCounter.click(button)
        } else if Scene.isOneIconCounterAtFactory() {
            factoryCounter.click(button)
        } else {
            ; 不仅工作台，而且野外添加肥料(这个突然弹窗，不好识别场景)
            workCounter.click(button)
        }
    }

    
}

;=====================================================================o

; 翻页管理上下文：热键 ⇒ 场景路由 ⇒ 点击元素
class PageContext {
        
    ; 翻页：一行共 2 个按钮，左右翻页
    static turn(direction) {
        ; 仅触发正在按的键：防御措施，按键功能拆分后仍需要判断一次
        if Scene.onOutside() {
            Send "{Blind!+^}{" LTrim(A_ThisHotkey, "*") "}"
            return
        }
        this.turnSceneRouter(direction)
    }

    static turnSceneRouter(direction) {
        if Scene.isManualUI() {
            Page.ofMan(direction)
        } else if Scene.isBox() {
            Page.ofBox(direction)
        } else if Scene.isSociality() {
            Page.ofSociality(direction)
        } else if Scene.isCalendar() {
            Page.ofCalendar(direction)
        } else if Scene.isShop() {
            Page.ofShop(direction)
        } else if Scene.isMaterialWare() {
            Page.ofMaterialWare(direction)
        } else if Scene.isFactory() {
            Tabs.ofFactory(direction)
        } else if Scene.isSetting() {
            Tabs.ofSetting(direction)
        } else if Scene.isWorkStation() {
            Tabs.ofWork(direction)
        } else if Scene.isBoilerStation() {
            Tabs.ofBoiler(direction)
        } else if Scene.isMission() {
            Tabs.ofMission(direction)
        } else if Scene.isDelegation() {
            Tabs.ofDelegation(direction)
        } else if Scene.isEmail() {
            ; 和委托重叠，所以放后面
            Tabs.ofEmail(direction)
        } else {
            tooltip "场景未收录"
            SetTimer () => ToolTip(), -2000
        }
    }

}

;=====================================================================o

; 🖱️ 游戏鼠标
; ----
; 1. 基本功能：上下左右（按住 A 降速） | 左键右键 | 滚轮
; 2. 操作技巧：Shift + WASD + /（锁定怪物） 动态调整角色视角
; 3. 镜头惯性：必须开启，避免镜头拉动幅度突变，割裂感，保持过度自然的体验
; 4. API: https://www.autohotkey.com/board/topic/53956-fast-mouse-control/
class GameMouse  {

    ; 设计思路
    ; 1. 由于 WASD 被前后左右占用，使用 ! 修饰时会冲突卡顿延迟，添加 [*] 全键无冲，共存控制方向和 shift + 按键，也许大写被判定为加速跑？
    ; 2. 故障：骑马时，shift 和 hjkl 视角冲突，只能保留一个
    ;    解决：+ 修饰的 hjkl 是另一套组合键，给鼠标控制 * 最广范围的权限，可以叠加任何按键，充分发挥键位无冲
    ; 3. 设置鼠标延迟为 -1 ，过度自然
    static move(event, offset := 97) {
        if GetKeyState("a", "p")
        {
            OFFSET := 35
        }
        switch (event)
        {
            case "↑": DllCall("mouse_event", "uint", 1, "int", 0      , "int", -offset)
            case "↓": DllCall("mouse_event", "uint", 1, "int", 0      , "int", offset )
            case "←": DllCall("mouse_event", "uint", 1, "int", -offset, "int", 0      )
            case "→": DllCall("mouse_event", "uint", 1, "int", offset , "int", 0      )
        }
    }

    
    ; 鼠标：左键 / 右键 \
    ; 单击：区分了按住不放的能力，适配电锯/电钻 ; 清除下马的缓存 ; 周末鉴定右键拖拽视角（不如鼠标灵活，推荐用鼠标）
    static button(event) {
        switch(event) 
        {
            case "🖱️": 
                DllCall("mouse_event", "UInt", 0x02) ; left button down
                KeyWait GameSetting.Keyboard.LClick
                DllCall("mouse_event", "UInt", 0x04) ; left button up
            case "⚙️": 
                DllCall("mouse_event", "UInt", 0x08) ; right button down
                KeyWait GameSetting.Keyboard.RClick
                DllCall("mouse_event", "UInt", 0x10) ; right button up
        }
        
    }


    ; 波西亚定制的滚轮
    static scroll(event) {
        ; 默认滚动一下
        if !(getkeystate("Ctrl", "p") or Scene.isLongListUI()) {
            mouse(event)
        } else {
            loop 5 {
                mouse(event)
            }
        }
    }
}

;=====================================================================o

; 🧪 游戏工具
; ---
; 辅助写代码的集合：取色，取坐标，序列化二维数组（储存数据库）
class GameUtils {

   static serilize(nestedObj) {
        inner := "", outer := ""
        for k1, nested in nestedObj.OwnProps() {
            for k2, v2 in nested.OwnProps() {
                inner .= k2 ':"' v2 '", '
            }
            outer .= k1 ': {' Rtrim(inner, ", ") '},`n'
            inner := ""
        }
        outer := "{`n" Rtrim(outer, ",`n") "`n}"
        A_Clipboard := outer
        msgbox outer, "已拷贝"
        return outer
    }

    static getPixelSearchCode(d := 5) {
        MouseGetPos & x, &y
        msg := x - d ", " y - d ", " x + d ", " y + d ", " PixelGetColor(x, y)
        A_clipboard := "PixelSearch(&FoundX, &FoundY, " msg ", 3)"
        Tooltip msg " 已拷贝"
        SetTimer () => ToolTip(), -2000
    }

    static getMousePosCode() {
        MouseGetPos & x, &y
        msg := x " " y
        A_clipboard := 'Click "' msg '"'
        Tooltip msg " 已拷贝"
        SetTimer () => ToolTip(), -2000
    }
    
}

;=====================================================================o

; 翻页
; ----
; 翻页有两种，静态写死的页面，和动态计算的二维页面（1：N ⇒ 初始坐标⇒同类坐标）
class Page {

    ; 单例模式
    __New(param*) {
        return false
    }

    static turn(direction, leftPos, rightPos) {
        switch (direction)
        {
            case "←": Click leftPos
            case "→": Click rightPos
        }
    }
        
    ; [NEXT]  区分箱子 和 背包的左右翻页（后期解锁背包再开发, 需要按键政策区分策略模式）
    static ofBox(direction) {
        this.turn(direction, "320 170", "1320 170")
    }

    ; 因为两者有重叠范围，所以不用判断是否是手册 / 组装台
    static ofMan(direction) {
        this.turn(direction, "160 600", "1630 600")
    }

    static ofSociality(direction) {
        this.turn(direction, "100 560", "1630 560")
    }

    static ofCalendar(direction) {
        this.turn(direction, "180 615", "1145 615")
    }

    static ofShop(direction) {
        this.turn(direction, "115 590", "570 590")
    }

    static ofMaterialWare(direction) {
        this.turn(direction, "115 560", "570 560")
    }

}

; 标签
; ----
; 选择上 / 下一个标签。设计有寄存器记录当前位置，实现了轮播机制
class Tabs {

    ; 单例模式
    __New(param*) {
        return false
    }

    ; 左右切换，如果到头就循环
    ; @param originX/originY 左侧第一个元素的中央坐标
    ; @param dx 两个标签的间距
    ; @param maxTags 最大标签数
    ; @param direction 方向
    static carousel(originX, originY, dx, maxTags, direction) {

        ; 标签计数器，当前索引位置
        static counter := 0
        ; 索引从零开始计算（从1开始符合生活习惯）
        max := maxTags - 1

        switch (direction)
        {
            case "←": counter--
            case "→": counter++
        }
        if (counter < 0) {
            counter := max
        }
        if (counter > max) {
            counter := 0
        }
        posX := originX + dx * counter
        Click posX, originY
    }

    static ofWork(direction) {
        this.carousel(190, 210, 80, 7, direction)
        ; 默认点击第一个，方便滚轮页
        Sleep 50
        Click "370 542"
    }

    static ofBoiler(direction) {
        this.carousel(190, 210, 80, 2, direction)
    }

    static ofSetting(direction) {
        this.carousel(260, 210, 160, 4, direction)
    }

    static ofEmail(direction) {
        this.carousel(850, 550, 200, 4, direction)
    }

    static ofMission(direction) {
        this.carousel(160, 270, 140, 3, direction)
    }
    
    static ofDelegation(direction) {
        this.carousel(490, 240, 170, 3, direction)
    }

    static ofFactory(direction) {
        this.carousel(530, 240, 75, 13, direction)
    }

}
;=====================================================================o

; 🐱‍🚀 工作状态
; ---
; 管理上下文的模板接口：每个场景只为完成一件事。不同场景，对应不同配套的按键。
class WorkState {

    ; 工作状态：不同场景的能力独享 \
    ; 
    ; - AHK: Map 映射本质是 Set ，会自动排序，所以要手动设置索引, 或者换成 [{}] 对象的有序数组，或者换成 {{}} 按键取值 \
    ; - AHK：字面量允许数字作为 key , 支持自定义索引取值
    static states := {
        1: { name: "home", icon: "🛖", action: this.Hoster },
        2: { name: "fish", icon: "🐟", action: this.Fisher },
        3: { name: "farm", icon: "⛏️", action: this.Farmer },
    }
    
    static final := 1
    static name := "home"
    
    ; 切换模式
    static next() { 
        static i := 1
        i++
        ; AHK: 对象容量，居然会多一个, 可能包括自身
        if i > ObjGetCapacity(this.states) - 1 {
            i := 1
        } 
        this.final := i
        this.name := this.states[i].name
        this.workStateTip()
    }
    
    static workStateTip() {
        Tooltip this.states[this.final]["icon"]
        SetTimer () => ToolTip(), -2000
    }
    
    ; 继续
    ; @param param* 一个可选参数：可以是数组/字符串，可以无参数，但不能传两个比如 (3，5)
    static proceed(param*) {
        this.states[this.final]["action"].proceed(param*)
    }
    
    ; 开始
    ; @param param* 一个可选参数：可以是数组/字符串，可以无参数，但不能传两个比如 (3，5)
    static start(param*) {
        this.states[this.final]["action"].start(param*)
    }
    
    
    ; 需要交给上下文管理，只要实现这些接口
    class Interface {

        ; 工厂模板：交给上下文管理的状态动作
        static start() {
        }
        
        static proceed() {
        }
        
    }
    
    ; ======================== 具体实现类 ==================================

    ; ⛏️ 矿工/伐木工
    class Farmer {

        ; 工厂模板：交给上下文管理的状态动作
        static start() {
            this.searchMineral()
        }
        
        static proceed() {
            this.farmLoop()
        }
            
        ; 持续左键点击: 适用范围仅限于非电钻、电锯，因为后期鼠标控制效果更好，持续和稳定的视角
        static farmLoop() {
            loop {
                Click	; 当前位置持续连按鼠标左键
                Sleep 500
                ; 挖矿时左手小指停止，或者右手食指停止
                if getkeystate(",", "p") or getkeystate("Shift", "p") {
                    return
                } 
            }
        }

        ; 按下探宝键: 鼠标侧键控制更好， 探宝键 = 抱起
        static searchMineral() {
            Send "{Blind!^}" GameSetting.Keyboard.searchMineral
        }
        
        ; 持续挖矿和踢树
        static kickTreeLoop() {
            loop {
                Send GameSetting.Keyboard.interactive
                Sleep 900
                if getkeystate("Ctrl", "p") {
                    return
                }
            }
        }

    }

    ; 🐟 鱼类饲养员
    ; ---
    ; 状态栏放饭团，按数字键 N 则喂养 N 对成鱼
    class Fisher {
        
        ; 放入 10 条鱼
        static start() {
            loop 10 {
                GameMouse.button("🖱️")
                Sleep 1500
            }
        }

        ; 取走 5 条鱼
        static proceed() {
           loop 5 {
                Send GameSetting.Keyboard.interactive
                Sleep 400
            }
        }
        
        ; 合法性校验: 喂太多鱼会撑死, 大型鱼缸上限 15 条鱼（5 对成鱼 + 5 条鱼仔 ）
        static feed(couple) {
            if couple > 5 or !IsNumber(couple) {
                Send "{Blind!+^}{" LTrim(A_ThisHotkey, "*") "}"
            }
            this.feedFish(couple)
        }

        ; 喂鱼：给定数量喂鱼，每对 35 饭团，七天管饱
        static feedFish(couple) {
            count := couple * 35
            GameMouse.button("🖱️")
            Sleep 500
            workCounter.click("center")
            Sleep 50
            Send "{blind^!} " count
            Send "{Enter}"
        }

    }
    
    ; 🛖 家园：管理锅炉，开始最大化制作
    class Hoster {

        ; 工厂模板：交给上下文管理的状态动作
        static start() {
            Factory.startWorking()
        }
        
        static proceed() {
            Factory.coninueWorking()
        }
    }
    
}

class ExtendKey {
    ; 拓展确认键: 弥补有的场景没有触发的功能，如送礼物，以前要手动点击
    static Enter() {
        if Scene.isGift() {
            ; 点击确认
            Click "1100 800"	
            Scene.HereCache.clear()
        } else {
            Send "{Blind}{Enter}"
        }
        ; 计数器确认后，自动消失
        if Scene.hasCounter {
            Scene.hasCounter := false
        }
    }

    static LButton() {
        GameMouse.button("🖱️")
        if Scene.hasCounter {
            Scene.hasCounter := false
        }
    }

    static RButton() {
        GameMouse.button("⚙️")
        ; 工厂材料仓库：用右键打开
        ; 交换背包和储物箱
        if Scene.onBagItemUI() {
            if Scene.isMaterialWare() {
                Suspend False
                return
            }
            return
        }
        ; 下飞船
        if Scene.onRiding() {
            Scene.HereCache.action["ride"] := false
            Scene.hasAircraft := false
        }
    }

    ; 拓展交互按键：如果不在户外，则释放挂起的脚本，激活上下左右翻页
    static Interactive() {
        Send SubStr(A_ThisHotkey, -1)
        SetTimer () => this.wait4InteraciveUI(), -2000
    }

    static wait4InteraciveUI() {
        if Scene.isSwitching() {
            return
        }
        if Scene.onRiding() { 
           Scene.hasAircraft := true
           return
        }
        if !Scene.isOutside() {
            Scene.HereCache.action["outside"] := false
            Suspend False
            return
        }
        SetTimer ,0
    }

    ; 清除所有记录的状态（梯子/计数/当前界面/有弹窗），返回上个界面
    static Esc() {
        Send "{Blind}{Esc}"
        ; 关掉弹窗
        if Scene.hasCounter {
            Scene.hasCounter := false
            return
        }
        ; 关掉搜索框：点击储物箱中央
        if Scene.isBoxSearch() {
            Click "332 514"
            return
        }
        ; 关掉所有界面，进入户外模式可以跑步了
        Bag.Ladder := 0
        Tabs.counter := 0
        Scene.HereCache.clear()
        Sleep 100
        Suspend True
    }

}

; 📦 缓存
; ----
; 一次记录，重复使用的，直接查询就好了 \
; 如果第一次用，动态计算，用工具类的序列化拷贝至剪切板，粘贴到这里
class Cache {

    static counterPos := {
        zeroIcon    : {center:"846 512", lock:"1", max:"972 512"  , min:"720 512", minus:"783 512", plus:"909 512"},
        oneIcon     : {center:"874 584", lock:"1", max:"1000 584" , min:"685 584", minus:"748 584", plus:"937 584"},
        factoryIcon : {center:"864 620", lock:"1", max:"990 620"  , min:"675 620", minus:"738 620", plus:"927 620"},
    }
}



;=====================================================================o

; 🏕️ 游戏场景
; ----
;
; 每个场景都有独一无二的色彩特征。准确地识别场景，针对场景执行不同的操作。
; - 场景特征
; > 1.唯一色块：多个场景不会重复、覆盖 \
; > 2.目标本身：容易受悬浮高亮影响，可借用通行证，或者排除目标，周围多点取色
; - 取色技巧：
; > 1. 避免悬浮高亮：使用置顶悬浮截图工具，再点击游戏画面。可以保持真实坐标和颜色。具有一次性，如果有鼠标悬浮事件，则识别失效了。
; > 2. 抽象画：多点取色，简化为散列的像素点。
; > 3. 相对静止：在变化中找不变的特征。如迪迪车站，随角色地理位置不同，地图视角框偏移，但经度固定，而每个站台的经度都是唯一的，问题转换为，在一边对联上找一个字。
; - 动态计算：场景不断切换，所以要动态计算。
; - 通行证：长时间停留在一个界面，而识别需要多次查询时使用的缓存。本质是寄存器的真假值，或者对象，必须有借出和归还的行为。
; ---
; 使用方法
; @method isXXX 判断当前是否处在 XXX 场景
; @return boolean ture 1 ，false 0 \
; [TODO] 艾克管家芯片解锁自动化管理后，有些场景的适用频率大幅度降低了，需要用缓存，或者失效，减轻负担
class Scene {

    ; [💳] 通行证：计数器。悬浮按钮高亮变色时，仍可以继续操作; 计数器取色时，登录产品界面时，借用; Esc 归还
    static hasCounter := false
    ; 托管: 骑马也能进行对话等，多一个层级的叠加状态
    static hasAircraft := false

    ; 还在这里
    ; ----
    ; 场景缓存：仍处在这个界面时，避免重复取色， Esc 清除状态
    ; 取色次数多，用缓存减负 \
    ; 🐞 AHK 设计缺陷: 静态方法在脚本加载时创建完成,共享的静态方法,会给所有路过的变量都赋值,所以禁止共享静态方法
    class HereCache {
        
        ; 界面缓存：辅助记录当前 UI 层级叠加关系
        static ui := Map(
            "bag", false, 
            "list", false,
        )
        
        ; 动作缓存：按键交互影响的状态
        static action := Map(
            "ride", false,
            "outside", false,
        )
        
        ; 清除自定义界面缓存，解决层级叠加状态
        static clear() {
            for k, v in this.ui {
                this.ui[k] := false
            }
        }
    }

    ; 单例模式
    __New(param*) {
        return false
    }
    

    ; 查看当前处在什么场景（检索所有已知场景）
    static whichScene() {
        msgbox
        (
            WorkState.states[WorkState.final]["icon"] " WorkState `n"
            Scene.isSociality() " Social `n"
            Scene.isBag() " Bag `n"
            Scene.isBox() " Box `n"
            Scene.isPlantBag() " PlantBag `n"
            Scene.isMaterialWare() " MaterialWare `n"
            Scene.isFactory() " Factory `n"
            Scene.isCalendar() " Calendar `n"
            Scene.isDialog() " Dialog `n"
            Scene.isOutside() " Outside `n"
            Scene.isCounter() " Counter `n"
            Scene.isManual() " Manual `n"
            Scene.isPackStation() " Pack `n"
            Scene.isBoilerStation() " Boiler `n"
            Scene.isWorkStation() " Work `n"
            Scene.isMission() " Mission `n"
            Scene.isDelegation() " Delegation `n"
            Scene.isSetting() " Setting `n"
            Scene.isRelic() " Relic `n"
            Scene.isEmail() " Email `n"
            Scene.isGift() " Gift `n"
            Scene.isShop() " Shop `n"
            Scene.isHunter() " Hunter `n"
            Scene.isChickenHouse() " ChickenHouse `n"
            Scene.isBuild() " Build `n"
            Scene.isCookBook() " CookBook `n"
            Scene.isBusMap() " BusMap `n"
            Scene.isTowerDrink() " TowerDrink `n"
            Scene.isOrder() " Order `n"
            Scene.isRiding() " Riding `n"
            Scene.findHomeStation() " HomeStation `n"
            Bag.Ladder " Ladder `n"
            Scene.hasCounter " hasCounter `n"
            Scene.hasAircraft " hasAircraft `n"
            Scene.HereCache.ui["bag"] " stayAtBag `n"
            Scene.HereCache.ui["list"] " stayAtList `n"
            Scene.HereCache.action["ride"] " stayAtRide `n"
            Scene.HereCache.action["outside"] " stayAtOutside `n"
            bagCounter.attr["lock"] " counterBagWriteLock `n"
            workCounter.attr["lock"] " counterWorkWriteLock `n"
            factoryCounter.attr["lock"] " counterWorkWriteLock `n"
        )
    }

    ; 储物箱：定位右上角: 储物箱的改名铅笔图标 [✏️]（区别于不可改名的背包）
    static isBox() {
        return PixelSearch(&FoundX, &FoundY, 1374, 171, 1375, 173, 0xEFB567, 2)
    }
    
    static isBoxSearch() {
        return this.isBox() and PixelSearch(&FoundX, &FoundY, 387, 276, 397, 286, 0x5499BC, 3)
    }

    ; 背包：生命血条最左边 [🟥]
    ; 不要选交集，两者UI叠加，可以共存，"在背包中的计数器"; 右下角的灰色加号透明度，受背景影响大，不选。
    static isBag() {
        return PixelSearch(&FoundX, &FoundY, 42, 534, 52, 544, 0xFC9490, 3)
    }
    
    ; 材料仓库：[料] 字米中间的颜色
    static isMaterialWare() {
        noPen := PixelSearch(&FoundX, &FoundY, 1374, 171, 1375, 173, 0x54B8E3, 3)
        mi := PixelSearch(&FoundX, &FoundY, 813, 164, 823, 174, 0xFFE17E, 3)
        return  noPen and mi
    }
    
    ; 文件柜：钱币 [🪙]
    static isFileBox() {
        return PixelSearch(&FoundX, &FoundY, 1446, 853, 1456, 863, 0xFFEDA3, 3)
    }

    ; 手册：定位左上角: 第一个蓝色标签页 [组装书]
    static isManual() {
        return PixelSearch(&FoundX, &FoundY, 130, 360, 140, 370, 0x67C9E2, 2)
    }

    ; 组装台：定位左上角: 第一个蓝色标签页 [组装书] （Y-60）
    static isPackStation() {
        return PixelSearch(&FoundX, &FoundY, 130, 300, 140, 370, 0x67C9E2, 2)
    }

    ; 社交：定位右下角送礼物的图标丝带[🎁]
    static isSociality() {
        return PixelSearch(&FoundX, &FoundY, 1460, 840, 1500, 860, 0xF96B4F, 5)
    }

    ; 日历：定位右下角 [红色边框]
    static isCalendar() {
        return PixelSearch(&FoundX, &FoundY, 990, 890, 995, 895, 0xDC5655, 2)
    }

    ; 委托（A级）：定位订单左侧 [A] 背景条幅
    static isPriOrder() {
        return PixelSearch(&FoundX, &FoundY, 520, 400, 525, 425, 0x50A06F, 2)
    }

    ; 对话：定位右下角，对话左边的问号 [?]
    static isDialog() {
        options2 := PixelSearch(&FoundX, &FoundY, 1112, 732, 1115, 735, 0x80D245, 5)
        options3 := PixelSearch(&FoundX, &FoundY, 1108, 710, 1118, 720, 0x83D44B, 5)
        return options2 or options3
    }

    ; 工作台：标签图标中间的猪腿中央 [🍗] （点击抬高后丢失目标位置，所以扩大10x10范围）
    static isWorkStation() {
        return PixelSearch(&FoundX, &FoundY, 415, 200, 440, 225, 0xEC8F47, 2)
    }

    ; 右上角关闭红叉中央 [❌]
    static isBoilerStation() {
        X       := PixelSearch(&FoundX, &FoundY, 1530, 96, 1540, 106, 0xEEEEEE, 3)
        shadowX := PixelSearch(&FoundX, &FoundY, 1529, 97, 1539, 107, 0xA9A9A9, 3)
        return X or shadowX
    }

    ; 任务：右下角小鼠标右键蓝色色块 [🖱️️追踪] (背包此处是+)
    static isMission() {
        return PixelSearch(&FoundX, &FoundY, 1481, 928, 1491, 938, 0x3C83A8, 3)
    }

    ; 户外：底部物品栏的第一个格子背景（范围大） [🗡️]
    static isOutside() {
        return PixelSearch(&FoundX, &FoundY, 560, 1000, 580, 1020, 0x5BBEDF, 6)
    }
    
    static onOutside() {
        if this.HereCache.action["outside"] {
            return true
        } else {
            this.HereCache.action["outside"] := this.isOutside()
            return this.HereCache.action["outside"]
        }
    }

    ; 计数器：没有图标，初始位置最大值 [999] 和 [取消]
    static isZeroIconCounter() {
        zeroIconMax    := PixelSearch(&FoundX, &FoundY, 972, 522, 982  , 532, 0x84D667, 3)
        zeroIconCancel := PixelSearch(&FoundX, &FoundY, 968, 600, 978  , 610, 0xF4AD3D, 3)
        return zeroIconMax or zeroIconCancel
    }
    
    ; 计数器：有图标，初始位置最大值 [999] 和 [取消]
    static isOneIconCounter() {
        oneIconMax     := PixelSearch(&FoundX, &FoundY, 998, 584, 1008 , 594, 0x8CDD6E, 3)
        oneIconCancel  := PixelSearch(&FoundX, &FoundY, 979, 646, 989  , 656, 0xF4AE3D, 3)
        return oneIconMax or oneIconCancel
    }
    
    ; 计数器：有图标，工厂点击同时制作出现坐标偏移 20dy， 初始位置最大值 [999] 和 [取消]
    static isOneIconCounterAtFactory() {
        factoryOneIconMax := PixelSearch(&FoundX, &FoundY, 991, 629, 1001, 639, 0x83D766, 3)
        factoryOneIconCancel := PixelSearch(&FoundX, &FoundY, 969, 678, 979, 688, 0xF4AF3D, 3)
        return factoryOneIconMax or factoryOneIconCancel
    }

    ; 计数器: 出现了三种之一，中间必须白色 \
    ; 背包/工作台/商店：绿色数字最大值 [999] 和 [取消] 按钮 \
    ; 选择超大的渐变值，是因为高亮（效果很差，蓝色都被判断为真） 所以两点取色 \
    ; 工厂的材料仓库：莫名其妙判定有计数器，所以三点取色
    static isCounter() {
        betweenButton := PixelSearch(&FoundX, &FoundY, 837, 595, 847, 655, 0xEEEEEE, 3)
        return betweenButton and (
            this.isZeroIconCounter() or
            this.isOneIconCounter() or
            this.isOneIconCounterAtFactory()
        )
    }
    

    ; 右上角关闭红叉中央 [❌]
    static isSetting() {
        return PixelSearch(&FoundX, &FoundY, 1494, 159, 1504, 169, 0xEEEEEE, 3)
    }

    ; 右上角关闭红叉中央 [❌]
    static isRelic() {
        return PixelSearch(&FoundX, &FoundY, 1374, 227, 1384, 237, 0xEEEEEE, 3)
    }

    ; 格子：左下角小鸟的翅膀 [🕊️️]
    ; 竖信封：抬头中央， 横信封：内容中央，两者颜色差别大，不好合并
    ; 信封底色和菜谱重叠 [TODO] ，但操作逻辑没有冲突
    static isEmail() {
        verticalPaper   := PixelSearch(&FoundX, &FoundY, 956, 192, 966, 202, 0xEDE5C0, 3)
        horizontalPaper := PixelSearch(&FoundX, &FoundY, 825, 615, 835, 625, 0xF9F0CA, 3)
        pigeon          := PixelSearch(&FoundX, &FoundY, 92 , 929, 102, 939, 0xC0D1E1, 3)
        return pigeon or horizontalPaper or verticalPaper
    }

    ; 送礼物：右下角 [取消]
    static isGift() {
        return PixelSearch(&FoundX, &FoundY, 1211, 802, 1221, 812, 0xEF857D, 3)
    }

    ; 商店：[装潢橙色条幅]
    static isShop() {
        return PixelSearch(&FoundX, &FoundY, 111, 222, 121, 232, 0xF49750, 3)
    }

    ; 捕兽笼：金色羊驼的墨镜 [🕶️]
    static isHunter() {
        return PixelSearch(&FoundX, &FoundY, 554, 521, 564, 531, 0x5A6673, 3)
    }
    
    ; 建造：满级工作台的贴纸 [🧾]
    static isBuild() {
        return PixelSearch(&FoundX, &FoundY, 63, 379, 73, 389, 0xD0B8A1, 3)
    }
     
    ; 畜禽屋：顶部栏最左的色块 [⚪]
    static isChickenHouse() {
        return PixelSearch(&FoundX, &FoundY, 22, 150, 32, 160, 0x8BDD6E, 3)
    }
     
    ; 菜谱：右上角蓝色书签 [🔖]
    static isCookBook() {
        return PixelSearch(&FoundX, &FoundY, 1422, 157, 1432, 167, 0x5574A5, 3)
    }

    ; 委托：第四个问号标签 [？]
    static isDelegation() {
        return PixelSearch(&FoundX, &FoundY, 932, 243, 942, 253, 0x7BCDEB, 3)
    }
    
    ; 工厂：最左上角标志的 [黄] 色（和贩卖机重叠了） 锁链 [⛓️]
    static isFactory() {
        link := PixelSearch(&FoundX, &FoundY, 34, 61, 44, 71, 0xFFFFFF, 3)
        yellow := PixelSearch(&FoundX, &FoundY, 10, 35, 20, 45, 0xFAD260, 3)
        return link and yellow
    }

    ; 车站：全图可能上下滚动，但不能左右滚动，找到不变的元素 [波西亚] [🖱️缩放]
    static isBusMap() {
        boxiya := PixelSearch(&FoundX, &FoundY, 1521, 149, 1531, 159, 0xFFFFFF, 3)
        zoomin := PixelSearch(&FoundX, &FoundY, 1476, 941, 1486, 951, 0xF6F6F4, 3)
        return boxiya and zoomin
    }
    
    ; 遗迹塔饮料贩卖机：左上角可乐的红色 [🧃]
    static isTowerDrink() {
        return PixelSearch(&FoundX, &FoundY, 113, 164, 123, 174, 0xDE5F4E, 3)
    }
    
    ; 交货单：单字
    static isOrder() {
        return PixelSearch(&FoundX, &FoundY, 882, 327, 892, 337, 0xA07958, 3)
    }
    
    ; 种子包：管家艾克的自动种植的界面 种[子]包 [<]
    static isPlantBag() {
        zi := PixelSearch(&FoundX, &FoundY, 215, 278, 225, 288, 0xFFFFFF, 3)
        leftArrow := PixelSearch(&FoundX, &FoundY, 542, 274, 552, 284, 0x8CDE6E, 3)
        return zi and leftArrow
    }
    
    ; 飞猪：依赖空格键上升，加缓存 
    static isRiding() {
        clock := PixelSearch(&FoundX, &FoundY, 666, 1045, 676, 1055, 0xF88F90, 3)
        background := PixelSearch(&FoundX, &FoundY, 679, 1052, 689, 1062, 0x5CCCEC, 3)
        return clock and background
    }
    
    static onRiding() {
        if this.HereCache.action["ride"] {
            return true
        }
        this.HereCache.action["ride"] := this.isRiding()
        return this.HereCache.action["ride"]
    }
    
    
    ; 切换场景：全屏黑屏，中央是黑色的
    static isSwitching() {
        return PixelSearch(&FoundX, &FoundY, 843, 538, 853, 548, 0x0D0D0D, 3)
    }
    
    ; 找到家园站台：发现每个站台的 X 坐标都不一样，而且每条 Y 轴的颜色差异是唯一的，所以锁定区间
    static findHomeStation() {
        bus := PixelSearch(&FoundX, &FoundY, 720, 90, 765, 840, 0x3984D8, 3)
        if bus {
            Click FoundX - 2 ", " FoundY + 1 " 0"
        }
        return bus
    }
    
    static isBagItemUI() {
        return this.isBox() or this.isBag() or this.isPlantBag() or
               this.isShop() or this.isFileBox() or this.isMaterialWare() or 
               this.isGift() 
    }


    static onBagItemUI() {
        if this.HereCache.ui["bag"] {
            return true
        } 
        this.HereCache.ui["bag"] := this.isBagItemUI()
        return this.HereCache.ui["bag"]
    }

    static isProductUI() {
        return this.isBoilerStation() or this.isWorkStation()
    }

    static isManualUI() {
        return this.isManual() or this.isPackStation()
    }

    static isNormalList() {
        return this.isProductUI() or this.isMission() or this.isRelic() or 
               this.isChickenHouse() or this.isFactory() or this.isDelegation() or 
               this.isTowerDrink() or this.isOrder() or this.isManualUI() or
               this.isCookBook()

    }
    
    static onNormalListUI() {
        if this.HereCache.ui["list"] {
            return true
        } 
        this.HereCache.ui["list"] := this.isNormalList()
        return this.HereCache.ui["list"]
    }
    
    static isLongListUI() {
        return this.isProductUI() or this.isManualUI() or this.isBox() or
               this.isFactory() or this.isManualUI()
    }

    ; 有计数器（弹窗）存在。存在时，记录缓存; Exit 退出，清空缓存
    static onCounterUI() {
        if this.hasCounter {
            return true
        } else {
            this.hasCounter := this.isCounter()
            return this.hasCounter 
        }
    }

    static hasZeroIconCounter() {
        return this.isBag() or this.isBox() or this.isShop() or this.isMaterialWare() 
    }
}
