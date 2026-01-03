-- p_mworldui.lua
-------------------------------------------------------------------------------
function p_mworld:_CreateUI()
	print(self._name.." p_mworld:_CreateUI")

    local frameUI = UIFrame:New()

    local barV = self._bhspace_border
    local frameBar = self:_CreateFrameBar()
    self._frameBar = frameBar
    frameUI:AttachChild(frameBar)
    frameBar:LLY(-5.0)
    frameBar:SetAnchorHor(0.5, 0.5)
    frameBar:SetAnchorVer(0.0, 0.0)
    frameBar:SetAnchorParamVer(barV, barV)
    frameBar:SetPivot(0.5, 0.0)
    frameBar:SetHeight(self._bh)
    frameBar:Show(true)

    local frameFire = self:_CreateFrameFireInfo()
    self._frameFire = frameFire
    frameUI:AttachChild(frameFire)
    frameFire:LLY(-5.0)
    frameFire:SetAnchorHor(0.5, 0.5)
    frameFire:SetAnchorVer(1.0, 1.0)
    frameFire:SetAnchorParamVer(-self._bh, -self._bh)
    frameFire:Show(false)

    local v = -self._bhspace_border

    local frameTop = self:_CreateFrameTopFrame()
    frameUI:AttachChild(frameTop)
    frameTop:LLY(-5.0)
    frameTop:SetPivot(0.5, 1.0)
    frameTop:SetAnchorHor(0.0, 1.0)
    frameTop:SetAnchorParamHor(0.0, 0.0)
    frameTop:SetAnchorVer(1.0, 1.0)
    frameTop:SetAnchorParamVer(-1.0, -1.0)
    frameTop:SetSize(0.0, g_manykit._hBtn)

    local frameMap = self:_CreateFrameInfoMap()
    self._frameInfo = frameMap
    frameUI:AttachChild(frameMap)
    frameMap:LLY(-5.0)
    frameMap:SetPivot(0.5, 0.5)
    frameMap:SetAnchorHor(0.5, 0.5)
    frameMap:SetAnchorParamHor(0.0, 0.0)
    frameMap:SetAnchorVer(0.5, 0.5)
    frameMap:SetAnchorParamVer(0.0, 0.0)
    frameMap:SetSize(400.0, 400.0)
    frameMap:Show(false)
    
    local itemSetting2 = UIButton:New()
    frameUI:AttachChild(itemSetting2)
    itemSetting2:SetName("BtnEdit2")
    itemSetting2:SetStateColorDefaultWhite()
	itemSetting2:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/setting.png")	
    itemSetting2:LLY(-5.0)
    itemSetting2:SetAnchorHor(0.72, 0.72)
    itemSetting2:SetAnchorVer(0.28, 0.28)
    itemSetting2:SetAnchorParamHor(self._bh * 1.5 + 6, self._bh * 1.5 + 6)
    itemSetting2:SetAnchorParamVer(2, 2)
    itemSetting2:SetSize(self._bh+6.0, self._bh+6.0)
    itemSetting2:SetScriptHandler("_UICallback", self._scriptControl)
    itemSetting2:Show(false)

    local barW = frameBar:GetWidth()
    -- local frameHead = self:_CreateFrameHead()
    -- self._frameHead = frameHead
    -- frameUI:AttachChild(frameHead)
    -- frameHead:LLY(-1.0)
    -- frameHead:SetAnchorHor(0.0, 0.0)
    -- frameHead:SetAnchorVer(1.0, 1.0)
    -- frameHead:SetAnchorParamHor(100, 100)
    -- frameHead:SetAnchorParamVer(-25.0, -25.0)
    -- frameHead:SetPivot(0.0, 1.0)
    -- frameHead:SetSize(400.0, 200.0)

    -- local frameMap = self:_CreateFrameSmallMap()
    -- frameUI:AttachChild(frameMap)
    -- frameMap:LLY(-1.0)
    -- frameMap:SetAnchorHor(1.0, 1.0)
    -- frameMap:SetAnchorVer(1.0, 1.0)
    -- frameMap:SetAnchorParamHor(-25.0, -25.0)
    -- frameMap:SetAnchorParamVer(-25.0, -25.0)
    -- frameMap:SetPivot(1.0, 1.0)
    -- frameMap:SetSize(200.0, 189.0)

    local w = self._bh * 15 + 20
    local frameBag = self:_CreateFrameBag(w, 620)
    self._frameBag = frameBag
    frameUI:AttachChild(frameBag)
    frameBag:LLY(-20.0)
    frameBag:SetAnchorHor(0.0, 1.0)
    frameBag:SetAnchorVer(0.0, 1.0)
    frameBag:Show(false)

    local fPicSelectBoxOfEquip = UIFPicBox:New()
	PX2_PROJ:PoolSet("FrameSelectBoxOfEquip", fPicSelectBoxOfEquip)
    self._frameSelectBoxOfEquip = fPicSelectBoxOfEquip
    frameUI:AttachChild(fPicSelectBoxOfEquip)
    fPicSelectBoxOfEquip:LLY(-4.0)
    fPicSelectBoxOfEquip:SetAnchorHor(0.5, 0.5)
    fPicSelectBoxOfEquip:SetAnchorVer(0.5, 0.5)
    fPicSelectBoxOfEquip:SetSize(self._bh, self._bh)
    fPicSelectBoxOfEquip:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/select.png"))
    fPicSelectBoxOfEquip:Show(false)
    fPicSelectBoxOfEquip:SetColor(Float3:MakeColor(254, 79, 50))

    local fPicSelectBox = UIFPicBox:New()
	PX2_PROJ:PoolSet("FrameSelectBox", fPicSelectBox)
    self._frameSelectBox = fPicSelectBox
    frameUI:AttachChild(fPicSelectBox)
    fPicSelectBox:LLY(-4.0)
    fPicSelectBox:SetAnchorHor(0.5, 0.5)
    fPicSelectBox:SetAnchorVer(0.5, 0.5)
    fPicSelectBox:SetSize(self._bh, self._bh)
    fPicSelectBox:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/select.png"))
    fPicSelectBox:Show(false)

    local frameSelectInfo = self:_CreateSelectInfo()
    self._frameSelectInfo = frameSelectInfo
    PX2_PROJ:PoolSet("FrameSelectInfo", frameSelectInfo)
    frameSelectInfo:Show(false)

    local frameSelectItem = UIFPicBox:New()
	PX2_PROJ:PoolSet("FrameSelectItem", frameSelectItem)
    self._uifPicBoxSelectItem = frameSelectItem
    frameBag:AttachChild(frameSelectItem)
    frameSelectItem:LLY(-20.0)
    frameSelectItem:SetAnchorHor(0.0, 0.0)
    frameSelectItem:SetAnchorVer(0.0, 0.0)
    frameSelectItem:SetSize(self._bh, self._bh)
    frameSelectItem:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/select.png"))
    frameSelectItem:Show(false)

    local fPicAim = UIFPicBox:New()
    self._fPicBoxAim = fPicAim
    frameUI:AttachChild(fPicAim)
    fPicAim:LLY(-20.0)
    fPicAim:SetAnchorHor(0.5, 0.5)
    fPicAim:SetAnchorVer(0.5, 0.5)
    fPicAim:SetSize(50, 50)
    fPicAim:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/aim.png"))
    fPicAim:SetColor(Float3(1.0, 0.0, 0.))
    fPicAim:Show(false)

    -- small map
    local scene = PX2_PROJ:GetScene()
    local nodeRoot = scene:GetNodeRoot()

    local frameHot = self:_CreateFrameHot()
    self._frameHot = frameHot
    frameUI:AttachChild(frameHot)
    frameHot:LLY(-20.0)
    frameHot:SetAnchorHor(0.0, 1.0)
    frameHot:SetAnchorVer(0.0, 1.0)
    frameHot:Show(false)

    local frameCameraIP = self:_CreateCameraIP()
    self._frameCameraIP = frameCameraIP
    frameUI:AttachChild(frameCameraIP)
    frameCameraIP:LLY(-25.0)
    frameCameraIP:SetAnchorHor(0.0, 1.0)
    frameCameraIP:SetAnchorVer(0.0, 1.0)
    frameCameraIP:Show(false)

    return frameUI
end
-------------------------------------------------------------------------------
function p_mworld:_CreateSelectInfo()
    local fPicSelectInfo = UIFPicBox:New()
    
    fPicSelectInfo:LLY(-30.0)
    fPicSelectInfo:SetAnchorHor(1.0, 1.0)
    fPicSelectInfo:SetAnchorVer(1.0, 1.0)
    fPicSelectInfo:SetAnchorParamHor(self._bh * 2.2, self._bh * 2.2)
    fPicSelectInfo:SetSize(300, 90)
    fPicSelectInfo:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/square3.png"))
    fPicSelectInfo:SetAlpha(0.5)

    local fText = UIFText:New("ItemInfo")
    fPicSelectInfo:AttachChild(fText)
    fText:LLY(-31.0)
    fText:SetAnchorHor(0.0, 1.0)
    fText:SetAnchorParamHor(4.0, -4.0)
    fText:SetAnchorVer(0.0, 1.0)
    fText:SetAnchorParamVer(4.0, -4.0)
    fText:GetText():SetFontColor(Float3.BLACK)
    fText:GetText():SetFontSize(25)
    fText:GetText():SetFontScale(0.8)
    fText:SetAlpha(2.0)
    fText:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_TOP)
    local txt = "物品ID:\n描述:\n协议ID:\n姓名:"
    fText:GetText():SetText(txt)

    return fPicSelectInfo
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameCompass()
    local fPicCompass = UIFPicBox:New()
    self._fPicCompass = fPicCompass
    fPicCompass:LLY(-1.0)
    fPicCompass:SetAnchorHor(1.0, 1.0)
    fPicCompass:SetAnchorVer(1.0, 1.0)
    fPicCompass:SetAnchorParamHor(-80.0, -80.0)
    fPicCompass:SetAnchorParamVer(-150.0, -150.0)
    fPicCompass:SetSize(100, 100)
    fPicCompass:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/pan.png"))
    fPicCompass:Show(true)

    local fPicCompassSubChe = UIFPicBox:New()
    self._fPicCompassSubChe = fPicCompassSubChe
    fPicCompass:AttachChild(fPicCompassSubChe)
    fPicCompassSubChe:LLY(-1)
    fPicCompassSubChe:SetAnchorHor(0.5, 0.5)
    fPicCompassSubChe:SetAnchorVer(0.5, 0.5)
    fPicCompassSubChe:SetSize(100, 100)
    fPicCompassSubChe:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/zhen.png"))
    fPicCompassSubChe:Show(true)
    fPicCompassSubChe:SetColor(Float3.GREEN)

    local fPicCompassSub = UIFPicBox:New()
    self._fPicCompassSub = fPicCompassSub
    fPicCompass:AttachChild(fPicCompassSub)
    fPicCompassSub:LLY(-2)
    fPicCompassSub:SetAnchorHor(0.5, 0.5)
    fPicCompassSub:SetAnchorVer(0.5, 0.5)
    fPicCompassSub:SetSize(100, 100)
    fPicCompassSub:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/zhen.png"))
    fPicCompassSub:Show(true)

    return fPicCompass
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameBar()
	print(self._name.." p_mworld:_CreateFrameBar")

    local frameBar = self:_CreateBarItems(false)

    local frameCtrl = self:_CreateFrameCtrl()
    self._frameQuickBarTopSkill = frameCtrl
    frameBar:AttachChild(frameCtrl)
    frameCtrl:SetAnchorHor(0.0, 1.0)
    frameCtrl:SetAnchorVer(1.0, 1.0)
    frameCtrl:SetHeight(self._bh)
    frameCtrl:SetPivot(0.5, 0.0)
    --frameCtrl:CreateAddBackgroundPicBox(true)
    frameCtrl:Show(false)

    local frameEquipped = self:_CreateFrameItemQuipped()
    self._frameQuickBarLeftItem = frameEquipped
    frameBar:AttachChild(frameEquipped)
    frameEquipped:SetAnchorHor(0.0, 0.0)
    frameEquipped:SetAnchorVer(0.0, 0.0)
    frameEquipped:SetWidth(self._bh*3)
    frameEquipped:SetHeight(self._bh)
    frameEquipped:SetPivot(1.0, 0.0)
    frameEquipped:CreateAddBackgroundPicBox(true)
    frameEquipped:Show(false)

    -- bagitem
    local itemBag = UIButton:New("BtnBag")
    frameBar:AttachChild(itemBag)
    itemBag:SetStateColorDefaultWhite()
    itemBag:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture(self:_imgpthmworld("ui/bagitem.png"))

    local btnHor = self._bh * 0.5 + 6
    itemBag:LLY(-1.0)
    itemBag:SetAnchorHor(1.0, 1.0)
    itemBag:SetAnchorParamHor(btnHor, btnHor)
    itemBag:SetAnchorParamVer(2, 2)
    itemBag:SetScriptHandler("_UICallback", self._scriptControl) 
    
    -- -- gestureItem
    -- local itemGesture = UIButton:New("BtnGesture")
    -- frameBar:AttachChild(itemGesture)
    -- itemGesture:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture(self:_imgpthmworld("ui/gesture.png"))
    -- itemGesture:SetStateColorDefaultWhite()
    -- itemGesture:LLY(-1.0)
    -- itemGesture:SetAnchorHor(1.0, 1.0)
    -- itemGesture:SetAnchorParamHor(self._bh * 1.5, self._bh * 1.5)
    -- itemGesture:SetAnchorParamVer(2, 2)
    -- itemGesture:SetScriptHandler("_UICallback", self._scriptControl) 

    btnHor = btnHor + self._bh*0.6
    local itemBtnSetting = UIButton:New("BtnSetting")
    frameBar:AttachChild(itemBtnSetting)
	itemBtnSetting:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/setting.png")	itemBtnSetting:SetStateColorDefaultWhite()
    itemBtnSetting:LLY(-1.0)
    itemBtnSetting:SetAnchorHor(1.0, 1.0)
    itemBtnSetting:SetAnchorParamHor(btnHor, btnHor)
    itemBtnSetting:SetAnchorParamVer(2, 2)
    itemBtnSetting:SetScriptHandler("_UICallback", self._scriptControl) 

    -- sandbox
    btnHor = btnHor + self._bh*0.6
    local itemSandBox = UIButton:New("BtnSandBox")
    frameBar:AttachChild(itemSandBox)
    itemSandBox:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture(self:_imgpthmworld("ui/sandbox.png"))
    itemSandBox:SetStateColorDefaultWhite()
    itemSandBox:LLY(-1.0)
    itemSandBox:SetAnchorHor(1.0, 1.0)
    itemSandBox:SetAnchorParamHor(btnHor, btnHor)
    itemSandBox:SetAnchorParamVer(2, 2)
    itemSandBox:SetScriptHandler("_UICallback", self._scriptControl) 
    
    -- hot
    btnHor = btnHor + self._bh*0.6
    local itemHot = UIButton:New("BtnHot")
    frameBar:AttachChild(itemHot)
    itemHot:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture(self:_imgpthmworld("ui/hot.png"))
    itemHot:SetStateColorDefaultWhite()
    itemHot:LLY(-1.0)
    itemHot:SetAnchorHor(1.0, 1.0)
    itemHot:SetAnchorParamHor(btnHor, btnHor)
    itemHot:SetAnchorParamVer(2, 2)
    itemHot:SetScriptHandler("_UICallback", self._scriptControl)  

    -- camera
    btnHor = btnHor + self._bh*0.6
    local btnCamera = UIButton:New("BtnCameraIP")
    frameBar:AttachChild(btnCamera)
    btnCamera:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture(self:_imgpthmworld("ui/camera.png"))
    btnCamera:SetStateColorDefaultWhite()
    btnCamera:LLY(-1.0)
    btnCamera:SetAnchorHor(1.0, 1.0)
    btnCamera:SetAnchorParamHor(btnHor, btnHor)
    btnCamera:SetAnchorParamVer(2, 2)
    btnCamera:SetScriptHandler("_UICallback", self._scriptControl)  

    return frameBar
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameFireInfo()
	print(self._name.." p_mworld:_CreateFrameFireInfo")

    local frameFire = UIFrame:New()
    frameFire:LLY(-5.0)
    frameFire:SetSize(700.0, 100.0)
    local back = frameFire:CreateAddBackgroundPicBox(false)
    back:UseAlphaBlend(true)
    back:SetTexture(self:_imgpthmworld("ui/square3.png"))
    back:SetPicBoxType(UIPicBox.PBT_NINE)
    back:SetTexCornerSize(0.0, 0.0, 0.0, 0.0)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.1)
    back:SetColor(Float3:MakeColor(255, 255, 255))
    frameFire:RegistToScriptSystem()

    -- pic txt
    local f = UIFrame:New()
    f:SetAnchorHor(0.0, 1.0)
    f:SetAnchorVer(0.0, 1.0)
    f:SetID(1011)
    f:RegistToScriptSystem()
    f:Show(true)

    local fPicBox = UIFPicBox:New()
    frameFire:AttachChild(f)
    f:AttachChild(fPicBox)
    fPicBox:SetID(1022)
    fPicBox:LLY(-2.0)
    fPicBox:SetAnchorHor(0.0, 1.0)
    --fPicBox:SetAnchorParamHor(0.0, 0.0)
    fPicBox:SetAnchorVer(0.0, 0.0)
    fPicBox:SetAnchorParamVer(15.0, 15.0)
    fPicBox:SetHeight(25.0)
    fPicBox:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/square3.png"))
    fPicBox:GetUIPicBox():SetAlpha(0.5)
    fPicBox:SetColor(Float3:MakeColor(255, 255, 255))
    fPicBox:RegistToScriptSystem()

    local fText = UIFText:New("Name")
    fPicBox:AttachChild(fText)
    fText:SetID(1033)
    fText:LLY(-3.0)
    fText:SetAnchorHor(0.0, 1.0)
    fText:SetAnchorVer(0.0, 1.0)
    fText:GetText():SetFontColor(Float3.WHITE)
    fText:GetText():SetFontSize(25)
    fText:GetText():SetFontScale(0.7)
    fText:GetText():SetDrawStyle(FD_BORDER)
    fText:GetText():SetBorderShadowColor(Float3(0, 0, 0))
    fText:GetText():SetBorderShadowAlpha(0.4)
    fText:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    fText:GetText():SetText("fire information")

    return frameFire
end
-------------------------------------------------------------------------------
function p_mworld:_CreateBarItems(isbag)
    local frameBar = UIFrame:New()
    frameBar:SetPickOnlyInSizeRange(false)

    local num = self._numBar
    for i=0, num-1, 1 do
        local frame = self:_CreateBagGrid(isbag)
        frameBar:AttachChild(frame)
        frame:LLY(-5.0)
        frame:SetSize(self._bh-5, self._bh-5)
        frame:SetAnchorHor(0.0, 0.0)
        local phor = self._bh*0.5 + self._bh*i
        frame:SetAnchorParamHor(phor, phor)
        frame:SetAnchorVer(0.5, 0.5)
        frame:SetUserDataInt("isbar", 1)
        frame:SetUserDataInt("index", i)

        if isbag then
            frame:SetUserDataInt("isbag", 1)
        else
            frame:SetUserDataInt("isbag", 0)
        end
    end

    local bw = num * self._bh
    frameBar:SetWidth(bw)

    return frameBar
end
-------------------------------------------------------------------------------
function p_mworld:_ClearQuickBarItems()
    print(self._name.." p_mworld:_ClearQuickBarItems")

    if self._frameBagBar then
        local numItems = self._frameBagBar:GetNumChildren()
        for i=0, numItems-1, 1 do
            local objCnt = self._frameBagBar:GetChild(i)
            local frameCnt = Cast:ToSizeNode(objCnt)
            if frameCnt then
                frameCnt:SetUserDataInt("id", 0)

                local f = frameCnt:GetObjectByID(10)
                f:Show(false)       
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshQuickBarItem(skillcharaid)
    print(self._name.." p_mworld:_RefreshQuickBarItem")

    self:_ClearQuickBarItems()

    local scene = PX2_PROJ:GetScene()
    if scene then
        local mainActor = scene:GetMainActor()
        if mainActor then
            local doRefresh = true
            if skillcharaid and skillcharaid~=mainActorID then
                doRefresh = false
            end

            if doRefresh then
                local skillChara = mainActor:GetSkillChara()
                if skillChara then
                    local numQ = skillChara:GetNumQuickBar()
                    for i=0, numQ-1, 1 do
                        local skillItem = skillChara:GetQuickBarItem(i)
                        local uiItemBagBar = self._frameBagBar:GetChild(i)
                        self:_RefreshItem(uiItemBagBar, skillItem, false)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshItemUI(charaid, itemid)
    print(self._name.." p_mworld:_RefreshItemUI")

    print("charaid:"..charaid)
    print("itemid:"..itemid)

    local scene = PX2_PROJ:GetScene()
    if scene then
        local mainActor = scene:GetMainActor()
        if mainActor then
            local idMainActor = mainActor:GetID()
            if idMainActor == charaid then
                local skillChara = mainActor:GetSkillChara()
                local skillItem = skillChara:GetItemByID(itemid)
                
                local uiItem = self:_GetBagGridByItemID(itemid)
                if uiItem then
                    self:_RefreshItem(uiItem, skillItem, false)
                end

                local uiItemEquip = self:_GetMeEquipGridByItemID(itemid)
                if uiItemEquip then
                    self:_RefreshItem(uiItemEquip, skillItem, false)
                end

                local uiItemWeapon = self:_GetQuickBarLeftUIItemByItemID(itemid)
                if uiItemWeapon then
                    self:_RefreshItem(uiItemWeapon, skillItem, false)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ClearMe()
    print(self._name.." p_mworld:_ClearMe")

    local numItems = self._frameMeEquipItems:GetNumChildren()
    for i=0, numItems-1, 1 do
        local objCnt = self._frameMeEquipItems:GetChild(i)
        local frameCnt = Cast:ToSizeNode(objCnt)
        if frameCnt then
            frameCnt:SetUserDataInt("id", 0)

            local f = frameCnt:GetObjectByID(10)
            f:Show(false)       
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_GetMeEquipGridByItemID(itemid)  
    local numItems = self._frameMeEquipItems:GetNumChildren()
    for i=0, numItems-1, 1 do
        local c = self._frameMeEquipItems:GetChild(i)
        local sz = Cast:ToSizeNode(c)
        if sz then
            local id = sz:GetUserDataInt("id")
            if itemid==id then
                return sz
            end
        end
    end

    return nil
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshQuickBarItemSkill(skillcharaid)
    local scene = PX2_PROJ:GetScene()
    if scene then
        local mainActor = scene:GetMainActor()
        if mainActor then
            local mainActorID = mainActor:GetID()

            print("charaiddddddddddddddddddmainActorID:"..mainActorID)

            local doRefresh = true
            if skillcharaid and skillcharaid~=mainActorID then
               doRefresh = false
            end

            if doRefresh then
                local skillChara = mainActor:GetSkillChara()
                if skillChara then
                    local charaid = skillChara:GetID()
                    print("charaidddddddddddddddddd:"..charaid)

                    local numSkills = skillChara:GetNumSkills()
                    print("numSkills:"..numSkills)     
                    self._frameQuickBarTopSkill:DetachAllChildren()       
                    for i=0, numSkills-1, 1 do
                        local skill = skillChara:GetSkill(i)
                        local sid = skill:GetID()
                        local skillTypeID = skill:GetTypeID()
            
                        local frame = self:_CreateBagGrid(false)
                        self._frameQuickBarTopSkill:AttachChild(frame)
                        frame:LLY(-5.0)
                        frame:SetSize(self._bh-5, self._bh-5)
                        frame:SetAnchorHor(0.0, 0.0)
                        local phor = self._bh*0.5 + self._bh*i
                        frame:SetAnchorParamHor(phor, phor)
                        frame:SetAnchorVer(0.5, 0.5)
                        frame:SetUserDataInt("isbar", 0)
                        frame:SetUserDataInt("index", i)
                        frame:SetUserDataInt("isbag", 0)
                        frame:SetUserDataInt("isskill", 1)
                        frame:SetUserDataInt("skillindex", i)
                        frame:SetUserDataInt("skilltypeid", skillTypeID)
            
                        self:_UIRefreshSkill(frame, skill)
                    end
            
                    self._frameQuickBarLeftItem:DetachAllChildren()
                    local numItemEquipped = skillChara:GetNumEquippedItem("def")            
                    print("numItemEquipped:"..numItemEquipped)  
                    for i=0, numItemEquipped-1, 1 do
                        local item = skillChara:GetEquippedItem("def", i)
                        local id = item:GetID()
                        local itemTypeID = item:GetTypeID()
            
                        local frame = self:_CreateBagGrid(false)
                        self._frameQuickBarLeftItem:AttachChild(frame)
                        frame:LLY(-5.0)
                        frame:SetSize(self._bh-5, self._bh-5)
                        frame:SetAnchorHor(1.0, 1.0)
                        local phor = -self._bh*0.5 - self._bh*i
                        frame:SetAnchorParamHor(phor, phor)
                        frame:SetAnchorVer(0.5, 0.5)
                        frame:SetUserDataInt("isbar", 0)
                        frame:SetUserDataInt("index", i)
                        frame:SetUserDataInt("isbag", 0)
                        frame:SetUserDataInt("isitem", 1)
                        frame:SetUserDataInt("itemindex", i)
                        frame:SetUserDataInt("itemid", id)
                        frame:SetUserDataInt("itemtypeid", itemTypeID)
            
                        self:_UITakeCtrlActorRefreshItem(frame, item)
                    end            
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_GetQuickBarLeftUIItemByItemID(itemid)  
    local numItems = self._frameQuickBarLeftItem:GetNumChildren()
    for i=0, numItems-1, 1 do
        local c = self._frameQuickBarLeftItem:GetChild(i)
        local sz = Cast:ToSizeNode(c)
        if sz then
            local id = sz:GetUserDataInt("itemid")
            if itemid==id then
                return sz
            end
        end
    end

    return nil
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshMe(skillcharaid)
    print(self._name.." p_mworld:_RefreshMee")
    if skillcharaid then
        print("skillcharaid:"..skillcharaid)
    else
        print("skillcharaid is null")
    end
    
    local scene = PX2_PROJ:GetScene()
    if scene then
        local mainActor = scene:GetMainActor()
        if mainActor then
            local mainActorID = mainActor:GetID()
            print("mainActorID:"..mainActorID)

            local doRefresh = true
            if skillcharaid and skillcharaid~=mainActorID then
                doRefresh = false
            end

            if doRefresh then
                print("doRefresh")

                self:_ClearMe()

                local skillChara = mainActor:GetSkillChara()
                if skillChara then
                    local numItems = skillChara:GetNumEquippedItem("def")
                    print("numItems:"..numItems)
                    for i=0, numItems-1, 1 do
                        local skillItem = skillChara:GetEquippedItem("def", i)
                        if skillItem then
                            print("i:"..i)
                            local uiItemBagBar = self._frameMeEquipItems:GetChild(i)
                            self:_RefreshItem(uiItemBagBar, skillItem, false)
                        end
                    end
                
                    local ctrlHuman, scCtrlHuman = g_manykit_GetControllerDriverFrom(mainActor, "p_human")
                    if scCtrlHuman then
                        scCtrlHuman:_CheckSetPosture(scCtrlHuman._posture)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameHead()
	print(self._name.." p_mworld:_CreateFrameHead")

    local frame = UIFrame:New()
    --frame:CreateAddBackgroundPicBox()

    local pbblood, fTextHP, textValueHP = self:_CreateFrameProgressBar("red")
    frame:AttachChild(pbblood)
    pbblood:LLY(-2.0)
    pbblood:SetPivot(0.0, 0.5)
    pbblood:SetAnchorHor(0.0, 0.0)
    pbblood:SetAnchorVer(1.0, 1.0)
    pbblood:SetAnchorParamVer(-18.0, -18.0)
    pbblood:SetProgress(0.6)
    fTextHP:GetText():SetText("健康")
    fTextHP:GetText():SetFontColor(Float3.RED)
    textValueHP:GetText():SetFontScale(0.9)
    textValueHP:GetText():SetText("198")

    local pbExp, fTextExp, textValueExp = self:_CreateFrameProgressBar("green")
    frame:AttachChild(pbExp)
    pbExp:LLY(-2.0)
    pbExp:SetPivot(0.0, 0.5)
    pbExp:SetAnchorHor(0.0, 0.0)
    pbExp:SetAnchorVer(1.0, 1.0)
    pbExp:SetAnchorParamVer(-42.0, -42.0)
    pbExp:SetProgress(0.4)
    pbExp:SetHeight(12)
    fTextExp:GetText():SetText("经验")
    fTextExp:GetText():SetFontColor(Float3.GREEN)
    textValueExp:GetText():SetText("Lv35")
    textValueExp:GetText():SetFontScale(0.6)

    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameProgressBar(color)
    local pb = UIProgressBar:New()
    pb:SetSize(220, 16)
    pb:SetColorSelfCtrled(true)
    pb:SetColor(Float3.WHITE)    
    pb:GetBackPicBox():GetUIPicBox():SetTexture(self:_imgpthmworld("ui/bloodback.png"))
    pb:GetBackPicBox():GetUIPicBox():SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    pb:GetBackPicBox():GetUIPicBox():SetAlpha(0.3)
    pb:GetBackPicBox():SetAnchorParamHor(-1, 1)
    pb:GetBackPicBox():SetAnchorParamVer(-1, 1)
    if "red"==color then
        pb:GetProgressPicBox():GetUIPicBox():SetTexture(self:_imgpthmworld("ui/bloodred.png"))
    elseif "green"==color then
        pb:GetProgressPicBox():GetUIPicBox():SetTexture(self:_imgpthmworld("ui/bloodgreen.png"))
    end
    pb:GetProgressPicBox():GetUIPicBox():SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    
    local textTitle = UIFText:New("TextTitle")
	pb:AttachChild(textTitle)
	textTitle:LLY(-6.0)
	textTitle:SetAnchorHor(0.0, 0.0)
    textTitle:SetAnchorParamHor(-34.0, -34.0)
	textTitle:SetAnchorVer(0.5, 0.5)
	textTitle:SetAnchorParamVer(0.0, 0.0)
	textTitle:SetPivot(0.0, 0.5)
	textTitle:SetHeight(20.0)
	textTitle:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    textTitle:GetText():SetFont(self:_imgpthmworld("ui/font.ttf"), 24, 24)
    textTitle:GetText():SetText("HP")
    textTitle:GetText():SetFontColor(Float3.WHITE)
    textTitle:GetText():SetFontSize(24)
	textTitle:GetText():SetFontScale(0.7)
    textTitle:GetText():SetDrawStyle(FD_BORDER)
    textTitle:GetText():SetBorderShadowColor(Float3(0, 0, 0))

    local textValue = UIFText:New("TextValue")
	pb:AttachChild(textValue)
	textValue:LLY(-6.0)
	textValue:SetAnchorHor(1.0, 1.0)
    textValue:SetAnchorParamHor(-35.0, -35.0)
	textValue:SetAnchorVer(0.5, 0.5)
	textValue:SetAnchorParamVer(5.0, 5.0)
	textValue:SetPivot(0.0, 0.5)
	textValue:SetHeight(20.0)
	textValue:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    textValue:GetText():SetFont(self:_imgpthmworld("ui/dengxian.ttf"), 24, 24)
    textValue:GetText():SetText("HP")
    textValue:GetText():SetFontColor(Float3.WHITE)
    textValue:GetText():SetFontSize(24)
    textValue:GetText():SetDrawStyle(FD_BORDER)
    textValue:GetText():SetBorderShadowColor(Float3(0, 0, 0))

    return pb, textTitle, textValue
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameSmallMap()
    local frame = UIFrame:New()

    local fPicBoxBack = UIFPicBox:New()
    frame:AttachChild(fPicBoxBack)
    fPicBoxBack:SetAnchorHor(0.0, 1.0)
    fPicBoxBack:SetAnchorVer(0.0, 1.0)
    fPicBoxBack:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/iconmap.png"))
    
    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_UICallback(ptr, callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()        
    local platType = PX2_APP:GetPlatformType()

    if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)
    elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)
        if "BtnDlgClose"==name then
			self:_ShowMapListFrame(false)
        elseif "BtnRemove"==name then
            local item = self._listMap1:GetSelectedItem()
            if item then
                local id = item:GetUserDataString("id")
                local idi = StringHelp:StringToInt(idi)
                p_net._g_net:_RequestDeleteMap(id)
            end
        elseif "BtnRemove1"==name then
            local item = self._listMap:GetSelectedItem()--add 55
            if item then
                local id = item:GetUserDataString("id")
                local idi = StringHelp:StringToInt(idi)
                p_net._g_net:_RequestDeleteMap(id)
            end
        elseif "BtnAdd"==name then
            local txt = self._editboxMapName1:GetText()
            if ""~=txt then
                p_net._g_net:_RequestAddMap(txt)
            end
        elseif "BtnAdd1"==name then
            local txt = self._editboxMapName:GetText()--add 55
            if ""~=txt then
                p_net._g_net:_RequestAddMap(txt)
            end
        elseif "BtnRefresh"==name then
            p_net._g_net:_GetRefreshMap(self._listMap1)
        elseif "BtnRefresh1"==name then--
            p_net._g_net:_GetRefreshMap(self._listMap)--add 55
        elseif "BtnOpenMap"==name then
            local item = self._listMap1:GetSelectedItem()
            if item then
                local url = item:GetUserDataString("url")
                local idstr = item:GetUserDataString("id")
                local id = StringHelp:SToI(idstr)
                local filename = item:GetUserDataString("filename")
                self._iscommingroom_openmap = false
                self:_OpenMap(url, id, filename)
            end
        elseif "BtnOpenMap1"==name then--
            local item = self._listMap:GetSelectedItem()--add 55
            if item then
                local url = item:GetUserDataString("url")
                local idstr = item:GetUserDataString("id")
                local id = StringHelp:SToI(idstr)
                local filename = item:GetUserDataString("filename")
                self._iscommingroom_openmap = false
                self:_OpenMap(url, id, filename)
            end
        elseif "BtnCloseMap"==name then
            self:_CloseCurMap()
        elseif "BtnCloseMap1"==name then
            self:_CloseCurMap()
        elseif "BtnFlowGraphClose"==name then
            self:_ShowFlowGraph(false)
        elseif "BtnObjectOption2"==name or "BtnObjectOption3"==name then
            local useagestr = obj:GetUserDataString("useage")
            if "Use"==useagestr then
                if self._curSelectActorID>0 then
                    self:_TakeControlOfAgentByID(self._curSelectActorID, AIAgent.HTPM_ALL)
                else
                    self:_Use()
                end
            elseif "Focus"==useagestr then
                self:_ViewFocus() 
            elseif "Trans"==useagestr then
                p_holospace._g_curSceneNodeCtrl:SetCtrlType(SceneNodeCtrl.CT_TRANSLATE)  
            elseif "Rotate"==useagestr then
                p_holospace._g_curSceneNodeCtrl:SetCtrlType(SceneNodeCtrl.CT_ROLATE)  
            elseif "Scale"==useagestr then
                p_holospace._g_curSceneNodeCtrl:SetCtrlType(SceneNodeCtrl.CT_SCALE)  
            elseif "Reset"==useagestr then
                if self._curSelectActorID>0 then
                    p_net._g_net:_RequestTranslateObj(self._curSelectActorID, true, false, nil, nil, self._curmapid)
                end             
            elseif "Cancelselect"==useagestr then
                self:_OnDisSelectObj(true)
                if self._frameAdjFText then
                    self._frameAdjFText:GetText():SetText("当前选择的角色信息：\n 无")
                end
                self:_RegistPropertyOnScene()
            elseif "Delete"==useagestr then
                self:_DeleteCurSelectObj()
            elseif "Edit"==useagestr then
                self:_Edit(not self._isediting)
            elseif "Simu"==useagestr then
                print("simu2")
                self:_PlaySimu(not self._isSimuing)
            elseif "God"==useagestr then
                print("God")
                self:_TakeControlOfAgentByID(0)
            elseif "Character"==useagestr then
                local useid = self._curSelectActorID
                if useid<=0 then
                    local scene = PX2_PROJ:GetScene()
                    local mainActor = scene:GetMainActor()
                    if mainActor then
                        useid = mainActor:GetID()
                    end
                end
                if useid>0 then
                    print("Character")
                    self:_TakeControlOfAgentByID(useid, AIAgent.HTPM_ALL)
                end
            elseif "Follow"==useagestr then
                local useid = self._curSelectActorID
                if useid<=0 then
                    local scene = PX2_PROJ:GetScene()
                    local mainActor = scene:GetMainActor()
                    if mainActor then
                        useid = mainActor:GetID()
                    end
                end
                if useid>0 then
                    self:_TakeControlOfAgentByID(useid, AIAgent.HTPM_NONE)
                    self:_ThirdViewOfActor(useid, g_manykit._defaultViewDistanceThird)  
                end
            elseif "GodControl"==useagestr then
                local useid = self._curSelectActorID
                if useid<=0 then
                    local scene = PX2_PROJ:GetScene()
                    local mainActor = scene:GetMainActor()
                    if mainActor then
                        useid = mainActor:GetID()
                    else
                        local meActor = scene:GetMeActor()
                        useid = meActor:GetID()
                    end
                end
                if useid>0 then
                    self:_TakeControlOfAgentByID(useid, AIAgent.HTPM_NONE)
                    self:_GodView(g_manykit._defaultViewDistanceThird)  
                end
            elseif "FixView"==useagestr then
                local useid = self._curSelectActorID
                if useid<=0 then
                    local scene = PX2_PROJ:GetScene()
                    local mainActor = scene:GetMainActor()
                    if mainActor then
                        useid = mainActor:GetID()
                    end
                end
                if useid>0 then
                    self:_TakeControlOfAgentByID(useid, AIAgent.HTPM_NONE)
                    self:_FirstViewOfAgentByID(useid, true)
                end
            elseif "FixViewBody"==useagestr then
                local useid = self._curSelectActorID
                if useid<=0 then
                    local scene = PX2_PROJ:GetScene()
                    local mainActor = scene:GetMainActor()
                    if mainActor then
                        useid = mainActor:GetID()
                    end       
                end

                p_holospace._g_beforeTargetPos = p_holospace._g_cameraPlayCtrl:GetTargetPos()
                p_holospace._g_beforeDistance = p_holospace._g_cameraPlayCtrl:GetCameraDistance()
                p_holospace._g_beforeHor = p_holospace._g_cameraPlayCtrl:GetDegreeHor()
                p_holospace._g_beforeVer = p_holospace._g_cameraPlayCtrl:GetDegreeVer()
                p_holospace._g_beforeDistMin = p_holospace._g_cameraPlayCtrl:GetCameraDistMin()
                p_holospace._g_beforeDistMax = p_holospace._g_cameraPlayCtrl:GetCameraDistMax()
                p_holospace._g_beforeOffset = p_holospace._g_cameraPlayCtrl:GetTargetOffset()   

                if useid>0 then
                    self:_TakeControlOfAgentByID(useid, AIAgent.HTPM_BODY)
                    self:_FirstViewOfAgentByID(useid)
                end
            elseif "Test20"==useagestr then
                self:_Test(20)
            elseif "Test200"==useagestr then
                self:_Test(200)
            elseif "Test1000"==useagestr then
                self:_Test(1000)
            elseif "A20"==useagestr then
                self:_GenerateActorWithNum(20)
            elseif "A200"==useagestr then
                self:_GenerateActorWithNum(200)
            elseif "A1000"==useagestr then
                self:_GenerateActorWithNum(1000)
            elseif "P0"==useagestr then
                self:_TestProtol(0)
            elseif "P1"==useagestr then
                self:_TestProtol(1)
            elseif "P2"==useagestr then
                self:_TestProtol(2)
            elseif "P3"==useagestr then
                self:_TestProtol(3)
            elseif "P4"==useagestr then
                self:_TestProtol(4)
            elseif "P5"==useagestr then
                self:_TestProtol(5)
            elseif "P6"==useagestr then
                self:_TestProtol(6)
            elseif "System"==useagestr then
                local sw = not g_manykit._isUIShowSide
                g_manykit:_ShowSide(sw)
            elseif "Map"==useagestr then
                self._frameInMap:Show(true)
                self._frameInMain:Show(false)
                self._frameInInfo:Show(false)
                self._frameInTest:Show(false)

                p_net._g_net:_GetRefreshMap(self._listMap)
            elseif "OpenMap"==useagestr then
                self._frameInfo:Show(true)
                p_net._g_net:_GetRefreshMap(self._listMap)

            elseif "MainControlPanel"==useagestr then
                self._frameInMap:Show(false)
                self._frameInMain:Show(true)
                self._frameInInfo:Show(false)
                self._frameInTest:Show(false)
            elseif "Informations"==useagestr then
                self._frameInMap:Show(false)
                self._frameInMain:Show(false)
                self._frameInInfo:Show(true)
                self._frameInTest:Show(false)
            elseif "Test"==useagestr then
                self._frameInMap:Show(false)
                self._frameInMain:Show(false)
                self._frameInInfo:Show(false)
                self._frameInTest:Show(true)
            elseif "toHLEFT"==useagestr then
                if self._frameInfo then
                    self._frameInfo:SetAnchorHor(0.0, 0.0)
                    self._frameInfo:SetAnchorParamHor(150.0, 150.0)
                    self._frameInfo:SetAnchorVer(0.0, 0.0)
                    self._frameInfo:SetAnchorParamVer(160.0, 160.0)
                end
            elseif "toHCENTER"==useagestr then
                if self._frameInfo then
                    self._frameInfo:SetAnchorHor(0.5, 0.5)
                    self._frameInfo:SetAnchorParamHor(-70.0, -70.0)
                    self._frameInfo:SetAnchorVer(0.5, 0.5)
                    self._frameInfo:SetAnchorParamVer(-75.0, -75.0)
                end
            end
        elseif "BtnBag"==name then
            self:_ShowBag(true)
        elseif "BtnGesture"==name then
            self:_ChangePosture()
        elseif "BtnSetting"==name then
            self:_ShowInspector(true)
        elseif "BtnSandBox"==name then
            self:_SandBox(not g_manykit._isInSandBox, true)
        elseif "BtnHot"==name then
            self:_UseCameraHot(not g_manykit._isUseCameraHot)
        elseif "BtnCameraIP"==name then
            self:_UseCameraIP(not g_manykit._isUseCameraIP)
        elseif "BtnBagClose"==name then
            self:_ShowBag(false)
        elseif "BtnEditBarClose"==name then
            if self._frameInfo then
                self._frameInfo:Show(false)
            end
        elseif "BtnEdit2"==name then
            self:_ShowInspector(true)
        elseif "BtnCompass"==name then
            self:_ShowCompass()
        elseif "BtnEditClose"==name then
            self:_ShowInspector(false)
        elseif "BtnSimu"==name then
            print("BtnSimu")
            self:_PlaySimu(not self._isSimuing)
        elseif "BtnItem"==name then
            self:_BagItemSelect(obj)
        elseif "BtnItemSkill"==name then
            self:_SkillItemSelect(obj)
        elseif "BtnItemItem"==name then
            self:_SkillItemItem(obj)
        elseif "BagIndex"==name then
            self:_OnCallBagItemIndex(obj)
        elseif "BtnOperator"==name then
            local id = obj:GetUserDataInt("id")
            print("id:"..id)

            local scene = PX2_PROJ:GetScene()
            if scene then
                local actorMain = scene:GetMainActor()
                if actorMain then
                    local skillChara = actorMain:GetSkillChara()
                    if skillChara then
                        local item = skillChara:GetItemByID(id)
                        if item then
                            local actorMain = scene:GetMainActor()
                            local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actorMain, "p_actor")
                            if scCtrl then
                                scCtrl:_AutoChargeItem(item)
                            end
                        end
                    end
                end
            end
        elseif "BtnHotClose"==name then
            self:_UseCameraHot(false)
        elseif "BtnCameraIPClose"==name then
            self:_UseCameraIP(false)
        end
    elseif UICT_RELEASED_NOTPICK==callType then
        PX2_GH:PlayNormal(obj)
    elseif UICT_TABFRAME_SETACTIVE==callType then
        print("UICT_TABFRAME_SETACTIVE")
        local tabName = obj:GetActiveTab()
        print(tabName)

        if "TableFrameSetting"==name then
            if "Set"==tabName then
                self:_RegistPropertyOnSet()
            elseif "Server"==tabName then
                self:_RegistPropertyOnServer()
            end
        end
    elseif UICT_PROPERTY_CHANGED==callType then
        if "PropertyGrid"==name then
            local pObj = obj:GetPorpertyObject()
            print("obj.Name:"..pObj.Name)
            print("obj.Cata:"..pObj.Cata)

            if "Scene"==pObj.Cata then
                if  Object.PT_BUTTON==pObj.Type then
                else
                    self:_GetScenePropertyAndSend(pObj.Name)
                end
            elseif "Actor"==pObj.Cata then
                if  Object.PT_BUTTON==pObj.Type then
                    self:_PropertyButtonTrigger(pObj)
                else
                    self:_GetObjectPropertyAndSend()
                end
            end
        elseif "PropertyGridEdit"==name then            
            local pObj = obj:GetPorpertyObject()
            local scene = PX2_PROJ:GetScene()
            if self._curSelectActorID > 0 then
                local actor = scene:GetActorFromMap(self._curSelectActorID)
                if actor then
                    local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
                    if scCtrl then
                        scCtrl:_OnPropertyEditChanged(pObj)
                    end
                end
            else
                self:_OnPropertyEditChangedScene(pObj)                
            end
        elseif "PropertyGridEdit1"==name then
            local pObj = obj:GetPorpertyObject()
            print("obj.Name:"..pObj.Name)

            if "TerWireframe"==pObj.Name then
                local wf = pObj:PBool()
                print("TerWireframe:")
                print_i_b(wf)

                local scene = PX2_PROJ:GetScene()
                if scene then
                    local terrain = scene:GetTerrain()
                    if terrain then
                        terrain:ShowWireFrame(wf)
                    end
                end
            elseif "TerSave"==pObj.Name then
                self:_TerrainSave()
            elseif "TerUpload"==pObj.Name then
                self:_TerrainUpload()
            end
        elseif "PropertyGridSet"==name then
            local pObj = obj:GetPorpertyObject()
            self:_OnPropertyChangedSet(pObj) 
        elseif "PropertyGridServer"==name then
            local pObj = obj:GetPorpertyObject()
            self:_OnPropertyChangedServer(pObj) 
        end

        local pObj = obj:GetPorpertyObject()
        print("obj.Name:"..pObj.Name)

        if "LandscapeOctaves"==pObj.Name then
            self._LandscapeOctaves = pObj:PFloat()
        elseif "LandscapePersistence"==pObj.Name then
            self._LandscapePersistence = pObj:PFloat()
        elseif "LandscapeScale"==pObj.Name then
            self._LandscapeScale = pObj:PFloat()
        elseif "MountainOctaves"==pObj.Name then
            self._MountainOctaves = pObj:PFloat()
        elseif "MountainPersistence"==pObj.Name then
            self._MountainPersistence = pObj:PFloat()
        elseif "MountainScale"==pObj.Name then
            self._MountainScale = pObj:PFloat()
        elseif "MountainMultiplier"==pObj.Name then
            self._MountainMultiplier = pObj:PFloat()
        elseif "VoxelReGen"==pObj.Name then
            self:_CreateVoxelWorld(self._LandscapeOctaves, self._LandscapePersistence, self._LandscapeScale,
                self._MountainOctaves, self._MountainPersistence, self._MountainScale, self._MountainMultiplier)
        elseif "TerReGen"==pObj.Name then
            print("TerReGen")
            local scene = PX2_PROJ:GetScene()
            if scene then        
                local nodeTerrain = scene:GetObjectByID(p_holospace._g_IDNodeTerrain)
                p_holospace._g_holospace:_ReCreateTerrain(nodeTerrain, scene, nil)
            end
        elseif "CalMapSize"==pObj.Name then
            self:_CalGisWidthHeight()
        elseif "TerNumNavGridIndex"==pObj.Name then
            local numNav = pObj:PEnumData2()
            local scene = PX2_PROJ:GetScene()
            if scene then
                local ter = scene:GetTerrain()
                local plugInst = p_holospace._g_holospace
                if plugInst then
                    plugInst:_SetNavGridNum(ter, numNav)
                    self:_UpdateScemeNav()
                end
            end
        elseif "UpdateNavGrid"==pObj.Name then
            self:_UpdateScemeNav()
        elseif "CalGis"==pObj.Name then
            print("CalGis")
            self:_CalTerrainGis()
        elseif "TerEditObjectsRandom"==pObj.Name then
            print("TerEditObjectsRandom")
            self:_TerEditObjectsRandom()
        elseif "TerEditMode"==pObj.Name then
            local ch = pObj:PInt()
            self._terEditMode = ch

            if 0==ch then
                PX2_EDIT:GetTerrainEdit():DisableEdit()
                PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_HEIGHT)
            elseif 1==ch then
                PX2_EDIT:GetTerrainEdit():EnableEdit()
                PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_HEIGHT)
            elseif 2==ch then
                PX2_EDIT:GetTerrainEdit():EnableEdit()
                PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_TEXTURE)
            elseif 3==ch then
                PX2_EDIT:GetTerrainEdit():EnableEdit()
                PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_JUNGLER)
            elseif 4==ch then
                PX2_EDIT:GetTerrainEdit():EnableEdit()
                PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_TERRAINOBJECTS)
            elseif 5==ch then
                PX2_EDIT:GetTerrainEdit():EnableEdit()
                PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_WALK)
            end
        elseif "TerBrushSize"==pObj.Name then
            self._terBrushSize = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetBrush():SetSize(self._terBrushSize)
        elseif "TerBrushStrength"==pObj.Name then
            self._terBrushStrength = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetBrush():SetStrength(self._terBrushStrength)    
        elseif "TerEditHighMode"==pObj.Name then
            local ch = pObj:PInt()
            self._terHighMode = ch
            if 0==ch then
                PX2_EDIT:GetTerrainEdit():GetHeightProcess():SetHeightMode(TerrainHeightProcess.HM_RAISE)
            elseif 1==ch then
                PX2_EDIT:GetTerrainEdit():GetHeightProcess():SetHeightMode(TerrainHeightProcess.HM_LOWER)
            elseif 2==ch then
                PX2_EDIT:GetTerrainEdit():GetHeightProcess():SetHeightMode(TerrainHeightProcess.HM_FLATTEN)
            elseif 3==ch then
                PX2_EDIT:GetTerrainEdit():GetHeightProcess():SetHeightMode(TerrainHeightProcess.HM_SMOOTH)
            end
        elseif "TerEditTexLayer"==pObj.Name then
            local ch = pObj:PInt()
            self._terTexLayer = ch+1
            PX2_EDIT:GetTerrainEdit():GetTextureProcess():SetSelectedLayer(self._terTexLayer)
        elseif "TerEditBaseLayerMode"==pObj.Name then
            local ch = pObj:PInt()
            self._terTexMode = ch

            local scene = PX2_PROJ:GetScene()
            local terrain = scene:GetTerrain()

            if 0==ch then
                terrain:SetBaseLayerMode(Terrain.LM_ONE)
            elseif 1==ch then
                terrain:SetBaseLayerMode(Terrain.LM_REPEAT)
            elseif 2==ch then
                terrain:SetBaseLayerMode(Terrain.LM_REPEATONE)
            end
        elseif "TerUVRepeatU"==pObj.Name then
            local u = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetTextureProcess():SetSelectLayerUVRepeatU(u)
        elseif "TerUVRepeatV"==pObj.Name then
            local v = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetTextureProcess():SetSelectLayerUVRepeatV(v)        
        elseif "TerEditTexTexture"==pObj.Name then
            local ch = pObj:PInt()
            local img = self._terTexTextures[ch+1]
            print("img:"..img)
            local srd = SelectResData()
            srd:SetResPathnameObject(img)
            PX2_EDIT:SetSelectedResource(srd)
        elseif "TerEditGrassWidth"==pObj.Name then
            local width = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetJunglerProcess():SetWidth(width)
        elseif "TerEditGrassHigh"==pObj.Name then
            local height = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetJunglerProcess():SetHeight(height)
        elseif "TerEditGrassLower"==pObj.Name then
            local lower = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetJunglerProcess():SetLower(lower)
        elseif "TerEditGrassTexture"==pObj.Name then
            local ch = pObj:PInt()
            local img = self._terGrassTextures[ch+1]
            print("img:"..img)
            PX2_EDIT:GetTerrainEdit():GetJunglerProcess():SetUsingTexture(img)

        elseif "TerEditObjectsSize"==pObj.Name then
            local sz = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetSize(sz)
        elseif "TerEditObjectsSizeBig"==pObj.Name then
            local sz = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetSizeBig(sz) 
        elseif "TerEditObjectsLower"==pObj.Name then
            local lower = pObj:PFloat()
            PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetLower(lower)
        elseif "TerEditObjects"==pObj.Name then
            local ch = pObj:PInt()

            local modelID = self._terObjects[ch+1]
            local defModel = PX2_SDM:GetDefModel(modelID)
            if defModel then
                local name = defModel.Name
                local model = defModel.Model
                local scale = defModel.ModelScale
                local bd = defModel.BD

                PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetInitSize(scale)
                PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetUsingFilename(model)
                PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetUsingFilenameBD(bd)
            end
        end
    elseif UICT_LIST_SELECTED==callType then
        if "ListMapItems"==name then
            local item = obj:GetSelectedItem()
            if item then
                local idstr = item:GetUserDataString("id")
                local idi = StringHelp:StringToInt(idstr)
                self:_TrySelectObj(idi, true)
            end
        elseif "ListPeoples"==name then
            local item = obj:GetSelectedItem()
            if item then
                local uinstr = item:GetUserDataString("uin")
                local uin = StringHelp:StringToInt(uinstr)
                if 0~=uin then
                    self:_TrySelectObj(uin, true)
                end
            end
        end
    elseif UICT_CHECKED ==callType then
    elseif UICT_DISCHECKED ==callType then
    elseif UICT_TREE_SELECTED==callType then
        if "AppMenuTree"==name then
            local bpObj = PX2_BPEDIT:GetSelectBPObject()
            local item = PX2_APP:GetTreeMenu():GetSelectedItem()
            if item then
                local name = item:GetName()
                local label = item:GetLabel()
                local cata = item:GetUserDataString("cata")
                local cata1 = item:GetUserDataString("cata1")
                print("name:"..name)
                print("label:"..label)
                print("cata:"..cata)
                print("cata1:"..cata1)

                if "Compile"==name then
                    local bpFile = PX2_BPM:CastToBPFile(bpObj)
                    if bpFile then
                        PX2_BPEDIT:CompileBPFile("test.lua", bpFile)
                    end
                elseif "Delete"==name then
                    if bpObj then
                        PX2_BPM:DeleteBPObject(bpObj)
                    end
                elseif "Disconnect"==name then
                    PX2_BPEDIT:DisconnectBPParam()
                elseif "BPFile"==name then
                    self:_CreateBPFile()
                else                    
                    self:_CreateBPLogicObj(cata, cata1, name)
                end
            end

            local frameMenu = PX2_APP:GetFrameMenu()
            if frameMenu then
                frameMenu:Show(false)
            end
        end
    
    elseif UICT_EDITBOX_ENTER==callType then
        local txt = obj:GetText()
        print("txt:"..txt)
        if "EditBoxInput"==name then
            if ""~=txt then
                local net = p_net._g_net
                net:_SendCmd(txt)
            end
        elseif "EditBoxInput2"==name then
            if ""~=txt then
                local net = p_net._g_net
                net:_SendCmd(txt)
            end
        end
    elseif UICT_COMBOBOX_CHOOSED==callType then
        if "ComboCtrlType"==name then
           local ch = obj:GetChoose()

           if 0==ch then
                self:_TakeControlOfAgentByID(0)
           elseif 1==ch then
                local useid = self._curSelectActorID
                if useid<=0 then
                    local scene = PX2_PROJ:GetScene()
                    local mainActor = scene:GetMainActor()
                    if mainActor then
                        useid = mainActor:GetID()
                    end
                end
                if useid>0 then
                    print("Character")
                    self:_TakeControlOfAgentByID(useid, AIAgent.HTPM_ALL)
                end
           elseif 2==ch then
                local useid = self._curSelectActorID
                if useid<=0 then
                    local scene = PX2_PROJ:GetScene()
                    local mainActor = scene:GetMainActor()
                    if mainActor then
                        useid = mainActor:GetID()
                    else
                        local meActor = scene:GetMeActor()
                        useid = meActor:GetID()
                    end
                end
                if useid>0 then
                    self:_TakeControlOfAgentByID(useid, AIAgent.HTPM_NONE)
                    self:_GodView(g_manykit._defaultViewDistanceThird)  
                end
           elseif 3==ch then
                local useid = self._curSelectActorID
                if useid<=0 then
                    local scene = PX2_PROJ:GetScene()
                    local mainActor = scene:GetMainActor()
                    if mainActor then
                        useid = mainActor:GetID()
                    end
                end
                if useid>0 then
                    self:_TakeControlOfAgentByID(useid, AIAgent.HTPM_NONE)
                    self:_ThirdViewOfActor(useid, g_manykit._defaultViewDistanceThird)  
                end
           end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameCtrl()
	print(self._name.." p_mworld:_CreateFrameCtrl")

    local frame = UIFrame:New()
    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameItemQuipped()
	print(self._name.." p_mworld:_CreateFrameItemQuipped")

    local frame = UIFrame:New()
    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameTopFrame()
	print(self._name.." p_mworld:_CreateFrameTopFrame")

    local frameInfo = UIFrame:New()
    local back = frameInfo:CreateAddBackgroundPicBox(true)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.6)
    back:SetColor(Float3:MakeColor(0, 0, 0))

    local numB = 13
    local tmp = 1.0
    local allw = numB * g_manykit._hBtn + tmp * (numB+1) + g_manykit._hBtn*2.0 + tmp
    local halfw = allw * 0.5
    local posH1 = -allw * 0.5 +  g_manykit._hBtn *0.5 + tmp

    -- local fPicBox = UIFPicBox:New()
    -- frameInfo:AttachChild(fPicBox)
    -- fPicBox:SetAnchorHor(0.5, 0.5)
    -- fPicBox:SetAnchorVer(0.5, 0.5)
    -- fPicBox:SetSize(allw, g_manykit._hBtn)

    for i=0,numB-1,1 do
        local btnAdj = UIButton:New("BtnObjectOption3")
        frameInfo:AttachChild(btnAdj)
        btnAdj:LLY(-3.0)
        btnAdj:SetAnchorHor(0.5, 0.5)
        btnAdj:SetAnchorParamHor(posH1, posH1)
        btnAdj:SetAnchorVer(0.5, 0.5)
        btnAdj:SetSize(g_manykit._hBtn, g_manykit._hBtn)
        btnAdj:SetScriptHandler("_UICallback", self._scriptControl)

        local fText= btnAdj:CreateAddFText(txt)
        fText:GetText():SetFontScale(0.8)
        
        local txt = ""
        local useage = ""
        if 0==i then
            txt = "系统"
            useage = "System"
        elseif 1==i then
            txt = "地图"
            useage = "OpenMap"
        elseif 2==i then
            txt = "聚焦"
            useage = "Focus"
        elseif 3==i then
            txt = "位移"
            useage = "Trans"
        elseif 4==i then
            txt = "旋转"
            useage = "Rotate"
        elseif 5==i then
            txt = "缩放"
            useage = "Scale"
        elseif 6==i then
            txt = "重置"
            useage = "Reset"
        elseif 7==i then
            txt = "操控"
            useage = "Control" 
        elseif 8==i then
            txt = "取消\n选择"
            useage = "Cancelselect"
            fText:GetText():SetFontScale(0.7)
            fText:SetAnchorParamVer(5.0, 5.0)
        elseif 9==i then
            txt = "使用"
            useage = "Use"
        elseif 10==i then
            txt = "删除"
            useage = "Delete"
        elseif 11==i then
            txt = "编辑"
            useage = "Edit"
            self._btnedit2 = btnAdj
        elseif 12==i then
            txt = "仿真"
            useage = "Simu"
            self._btnsimu2 = btnAdj
        end

        fText:GetText():SetText(txt)
        btnAdj:SetUserDataString("useage", useage)

        manykit_uiProcessBtn(btnAdj)

        if "Delete"==useage then
            btnAdj:SetStateColor(UIButtonBase.BS_NORMAL, Float3(0.5, 0.0, 0.0))
            btnAdj:SetStateColor(UIButtonBase.BS_PRESSED, Float3(0.5, 0.0, 0.0))
            btnAdj:SetStateColor(UIButtonBase.BS_HOVERED, Float3(0.5, 0.0, 0.0))
        end

        if numB-1==i then
            posH1 = posH1 + g_manykit._hBtn * 0.5 + tmp
        else
            posH1 = posH1 + g_manykit._hBtn + tmp
        end
    end

	local comboCtrlType = UIComboBox:New("ComboCtrlType")
    frameInfo:AttachChild(comboCtrlType)
    comboCtrlType:LLY(-6.0)
	comboCtrlType:GetChooseList():SetItemHeight(30.0)
    comboCtrlType:AddChooseStr("上帝")
    comboCtrlType:AddChooseStr("角色")
    comboCtrlType:AddChooseStr("上帝角色")
    comboCtrlType:AddChooseStr("跟随")
    comboCtrlType:SetChooseListHeightSameWithChooses()
    comboCtrlType:Choose(1)
	comboCtrlType:SetPivot(0.5, 0.5)
    comboCtrlType:SetAnchorHor(0.5, 0.5)
    comboCtrlType:SetAnchorParamHor(posH1 + g_manykit._hBtn, posH1 + g_manykit._hBtn)
    comboCtrlType:SetAnchorVer(0.5, 0.5)
    comboCtrlType:SetAnchorParamVer(0.0, 0.0)
    comboCtrlType:SetSize(g_manykit._hBtn*2.0, g_manykit._hBtn)
    comboCtrlType:GetSelectButton():GetText():SetFontScale(0.8)
    comboCtrlType:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(comboCtrlType:GetSelectButton())

    frameInfo:SetPickOnlyInSizeRange(false)
    
    return frameInfo
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameInfoMap()
    local frame = UIFrame:New()
    local back = frame:CreateAddBackgroundPicBox(true)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.3)

    --删除 增加 刷新 打开 关闭
    local ver = self._bhspace_border + g_manykit._hBtn*0.5
    local numB = 4
    local btnW = g_manykit._hBtn * 1.5
    local tmp = 1.0
    local horF = btnW * 0.5 + self._bhspace_border
    for i=0, numB, 1 do
        local btnADD = nil
        local fTEXT = nil

        if 0==i then
            btnADD = UIButton:New("BtnRemove1")
            fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Remove"))
        elseif 1==i then
            btnADD = UIButton:New("BtnAdd1")
            fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Add"))
        elseif 2==i then
            btnADD = UIButton:New("BtnRefresh1")
            fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Refresh"))
        elseif 3==i then
            btnADD = UIButton:New("BtnOpenMap1")
            fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Open"))
        elseif 4==i then
            btnADD = UIButton:New("BtnCloseMap1")
            fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Close"))
        end
        
        frame:AttachChild(btnADD)
        btnADD:LLY(-6.0)
        btnADD:SetAnchorHor(0.0, 0.0)
        btnADD:SetAnchorParamHor(horF, horF)
        btnADD:SetAnchorVer(0.0, 0.0)
        btnADD:SetAnchorParamVer(ver, ver)
        btnADD:SetSize(btnW, g_manykit._hBtn)
        btnADD:SetScriptHandler("_UICallback", self._scriptControl)--
        fTEXT:GetText():SetFontScale(0.9)
        manykit_uiProcessBtn(btnADD)

        horF = horF +  btnW + tmp
    end

    ver = ver + g_manykit._hBtn + self._bhspace_border * 0.5

    local fTextName = UIFText:New()
    frame:AttachChild(fTextName)
    fTextName:LLY(-2.0)
    fTextName:SetAnchorHor(0.0, 0.0)
    fTextName:SetAnchorVer(0.0, 0.0)
    fTextName:SetPivot(0.0, 0.5)
    fTextName:SetAnchorParamHor(self._bhspace_border, self._bhspace_border)
    fTextName:SetAnchorParamVer(ver, ver)
    fTextName:GetText():SetText(""..PX2_LM_APP:V("Name"))
    fTextName:SetSize(g_manykit._hBtn * 2.0, g_manykit._hBtn)
    fTextName:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    fTextName:GetText():SetFontColor(Float3.WHITE)--RED
    fTextName:GetText():SetDrawStyle(FD_SHADOW)
    fTextName:GetText():SetShadowBorderSize(1)
    fTextName:GetText():SetBorderShadowAlpha(0.7)
    fTextName:GetText():SetBorderShadowColor(Float3.BLACK)

    local uiEditBoxName = UIEditBox:New("EditBoxName")
    frame:AttachChild(uiEditBoxName)
    self._editboxMapName = uiEditBoxName
    uiEditBoxName:LLY(-2.0)
    uiEditBoxName:SetAnchorHor(0.0, 1.0)
    uiEditBoxName:SetAnchorVer(0.0, 0.0)
    uiEditBoxName:SetAnchorParamHor(self._bhspace_border + g_manykit._hBtn, -self._bhspace_border)
    uiEditBoxName:SetAnchorParamVer(ver, ver)
    uiEditBoxName:SetHeight(g_manykit._hBtn)

    ver = ver + g_manykit._hBtn*0.5 + self._bhspace_border * 0.5

    --list & slider
    local list = UIList:New("ListMap1")
    frame:AttachChild(list)
    self._listMap = list --add 55
    list:LLY(-6.0)
    list:SetAnchorHor(0.0, 1.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamHor(self._bhspace_border, - self._bhspace_border)
    list:SetAnchorParamVer(ver,  -g_manykit._hBtn - self._bhspace_border)
    list:SetReleasedDoSelect(true)
    list:CreateAddBackgroundPicBox(true, Float3:MakeColor(230, 230, 230))
    list:SetItemBackColor(Float3.BLACK)
    list:SetItemBackAlpha(0.2)
    list:SetFontSize(10)
    list:SetSliderSize(15.0)
    list:SetItemHeight(20.0)
    list:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessList(list, true)
    local slider = list:GetSlider()
    slider:GetFPicBoxBack():GetUIPicBox():SetPicBoxType(UIPicBox.PBT_NINE)
    slider:GetFPicBoxBack():GetUIPicBox():SetTexture("engine/white.png")
    slider:GetFPicBoxBack():GetUIPicBox():SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    slider:GetFPicBoxBack():GetUIPicBox():SetAlpha(0.5)
    slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
    slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/white.png")
    slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    slider:GetButSlider():SetStateColor(UIButtonBase.BS_HOVERED, Float3.WHITE)
    slider:GetButSlider():SetStateColor(UIButtonBase.BS_NORMAL, Float3.WHITE)
    slider:GetButSlider():SetStateColor(UIButtonBase.BS_PRESSED, Float3.WHITE)
    slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_HOVERED, 0.6)
    slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_NORMAL, 0.6)
    slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_PRESSED, 0.6)

    local btnEditBatClose = UIButton:New("BtnEditBarClose")
    frame:AttachChild(btnEditBatClose)
    btnEditBatClose:SetStateColorDefaultWhite()
	btnEditBatClose:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/close1.png")	
    btnEditBatClose:LLY(-6.0)
    btnEditBatClose:SetAnchorHor(1.0, 1.0)
    btnEditBatClose:SetAnchorParamHor(-g_manykit._hBtn*0.5-self._bhspace_border, -g_manykit._hBtn*0.5-self._bhspace_border)
    btnEditBatClose:SetAnchorVer(1.0, 1.0)
    btnEditBatClose:SetAnchorParamVer(-g_manykit._hBtn*0.5-self._bhspace_border, -g_manykit._hBtn*0.5-self._bhspace_border)
    btnEditBatClose:SetScriptHandler("_UICallback", self._scriptControl)

    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameInfo()
	print(self._name.." p_mworld:_CreateFrameInfo")

    local frameInfo = UIFrame:New()
    frameInfo:LLY(-4.0)
    frameInfo:SetSize(273.0, 305.0)
    local back = frameInfo:CreateAddBackgroundPicBox(true)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.3)
    back:SetColor(Float3:MakeColor(255, 255, 255))

    local btnSZ = 32.0
    local btnSZ3 = 50.0
    local btnSZ4 = 30.0
    local tmp = 1.0
    local posH2 = 34.0 

    --地图 主控板 信息 调试, 设置图标， 居中 居左
    for j=0, 3, 1 do
        local btnAdj = UIButton:New("BtnObjectOption2")
        frameInfo:AttachChild(btnAdj)
        btnAdj:LLY(-6.0)
        btnAdj:SetAnchorHor(0.0, 0.0)
        btnAdj:SetAnchorParamHor(30.0 + (btnSZ3 + 1)*j, 30.0 + (btnSZ3 + 1)*j)
        btnAdj:SetAnchorVer(0.0, 0.0)
        btnAdj:SetAnchorParamVer(btnSZ*8.0 + 30.0, btnSZ*8.0 + 30.0)
        btnAdj:SetSize(btnSZ3, btnSZ)
        btnAdj:SetScriptHandler("_UICallback", self._scriptControl)--

        local fText= btnAdj:CreateAddFText(txt)--
        fText:GetText():SetFontScale(0.9)

        local txt = ""
        local useage = ""
        if 0==j then
            txt = "地图"
            useage = "Map"
        elseif 1==j then
            txt = "主控板"
            useage = "MainControlPanel"
        elseif 2==j then
            txt = "信息"
            useage = "Informations"
        elseif 3==j then
            txt = "调试"
            useage = "Test"
        end

        fText:GetText():SetText(txt)
        btnAdj:SetUserDataString("useage", useage)

        manykit_uiProcessBtn(btnAdj)
    end

    local btnEditBatClose = UIButton:New()
    frameInfo:AttachChild(btnEditBatClose)
    btnEditBatClose:SetName("BtnEditBarClose")
    btnEditBatClose:SetStateColorDefaultWhite()
	btnEditBatClose:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/close1.png")	
    btnEditBatClose:LLY(-6.0)-- -1
    btnEditBatClose:SetAnchorHor(0.9, 1.0)
    btnEditBatClose:SetAnchorVer(0.9, 1.0)
    btnEditBatClose:SetScriptHandler("_UICallback", self._scriptControl)
    --居中 居左
    for j=0,1,1 do
        local btnAdj = UIButton:New("BtnObjectOption2")
        frameInfo:AttachChild(btnAdj)
        btnAdj:LLY(-6.0)
        btnAdj:SetAnchorHor(0.0, 0.0)
        btnAdj:SetAnchorParamHor(20.0 + (btnSZ3 + 1)*4, 20.0 + (btnSZ3 + 1)*4)
        btnAdj:SetAnchorVer(0.0, 0.0)
        btnAdj:SetAnchorParamVer(278.0 + (15.0 + 1)*j, 278.0 + (15.0 + 1)*j)
        btnAdj:SetSize(btnSZ4, 15.0)
        btnAdj:SetScriptHandler("_UICallback", self._scriptControl)--

        local fText= btnAdj:CreateAddFText(txt)--
        fText:GetText():SetFontScale(0.75)

        local txt = ""
        local useage = ""
        if 0==j then
            txt = "居左"
            useage = "toHLEFT"--self._frameInfo
        elseif 1==j then
            txt = "居中"
            useage = "toHCENTER"
        end

        fText:GetText():SetText(txt)
        btnAdj:SetUserDataString("useage", useage)

        manykit_uiProcessBtn(btnAdj)
    end

    --frameInMap, frameInMain, frameInInfor, frameInTest
    for k=0, 3, 1 do 
        local frameTop = UIFrame:New()
        frameInfo:AttachChild(frameTop)
        frameTop:LLY(-1.0)-- 0.0最底
        frameTop:SetAnchorHor(0.0, 1.0)
        frameTop:SetAnchorVer(0.0, 1.0)
        
        local back = frameTop:CreateAddBackgroundPicBox(false)
        back:UseAlphaBlend(true)
        back:SetTexture(self:_imgpthmworld("ui/square3.png"))
        back:SetPicBoxType(UIPicBox.PBT_NINE)
        back:SetTexCornerSize(0.0, 0.0, 0.0, 0.0)
        back:UseAlphaBlend(true)
        back:SetAlpha(0.3)
        back:SetColor(Float3:MakeColor(255, 255, 255))
        frameTop:RegistToScriptSystem()

        if 0==k then
            self._frameInMap = frameTop
        elseif 1==k then
            self._frameInMain = frameTop
        elseif 2==k then
            self._frameInInfo = frameTop
        elseif 3==k then
            self._frameInTest = frameTop
        end
    end

    self:_CreateFrameInMap()
    self:_CreateFrameInMain()
    self:_CreateFrameInInfo()
    self:_CreateFrameInTest()

    self._frameInMap:Show(false)
    self._frameInMain:Show(true)
    self._frameInInfo:Show(false)
    self._frameInTest:Show(false)

    return frameInfo
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameInMap()
    if self._frameInMap then 
        local btnSZ = 32.0
        local btnSZ2 = 51.0
        local tmp = 1.0
        local posH1 = 32.0
        local posH2 = 34.0 
        local posH3 = 43.0

        --list & slider
        local list = UIList:New("ListMap1")
        self._frameInMap:AttachChild(list)
        self._listMap = list --add 55
        list:LLY(-6.0)
        list:SetAnchorHor(0.0, 1.0)
        list:SetAnchorVer(0.27, 0.87)
        list:SetAnchorParamHor(3.0, -3.0)
        list:SetAnchorParamVer(3.0, -3.0)
        list:SetReleasedDoSelect(true)
        list:CreateAddBackgroundPicBox(true, Float3:MakeColor(230, 230, 230))
        list:SetItemBackColor(Float3.BLACK)
        list:SetItemBackAlpha(0.2)
        list:SetFontSize(10)
        list:SetSliderSize(15.0)
        list:SetItemHeight(20.0)
        list:SetScriptHandler("_UICallback", self._scriptControl)
        manykit_uiProcessList(list, true)
    
        local slider = list:GetSlider()
        slider:GetFPicBoxBack():GetUIPicBox():SetPicBoxType(UIPicBox.PBT_NINE)
        slider:GetFPicBoxBack():GetUIPicBox():SetTexture("engine/white.png")
        slider:GetFPicBoxBack():GetUIPicBox():SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
        slider:GetFPicBoxBack():GetUIPicBox():SetAlpha(0.5)
        slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
        slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/white.png")
        slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
        slider:GetButSlider():SetStateColor(UIButtonBase.BS_HOVERED, Float3.WHITE)
        slider:GetButSlider():SetStateColor(UIButtonBase.BS_NORMAL, Float3.WHITE)
        slider:GetButSlider():SetStateColor(UIButtonBase.BS_PRESSED, Float3.WHITE)
        slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_HOVERED, 0.6)
        slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_NORMAL, 0.6)
        slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_PRESSED, 0.6)

        --名称 & 输入框
        local fTextName = UIFText:New()
        self._frameInMap:AttachChild(fTextName)
        fTextName:LLY(-2.0)
        fTextName:SetAnchorHor(0.0, 0.15)
        fTextName:SetAnchorVer(0.0, 0.0)
        fTextName:SetAnchorParamHor(3.0, -3.0)
        fTextName:SetAnchorParamVer(btnSZ + 30.0, btnSZ + 30.0)
        fTextName:GetText():SetText(""..PX2_LM_APP:V("Name"))
        fTextName:SetHeight(btnSZ)
        fTextName:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
        fTextName:GetText():SetFontColor(Float3.WHITE)--RED
        fTextName:GetText():SetDrawStyle(FD_SHADOW)
        fTextName:GetText():SetShadowBorderSize(1)
        fTextName:GetText():SetBorderShadowAlpha(0.7)
        fTextName:GetText():SetBorderShadowColor(Float3.BLACK)
    
        local uiEditBoxName = UIEditBox:New("EditBoxName")
        self._frameInMap:AttachChild(uiEditBoxName)
        self._editboxMapName = uiEditBoxName
        uiEditBoxName:LLY(-2.0)
        uiEditBoxName:SetAnchorHor(0.15, 1.0)
        uiEditBoxName:SetAnchorVer(0.0, 0.0)
        uiEditBoxName:SetAnchorParamHor(3.0, -3.0)
        uiEditBoxName:SetAnchorParamVer(btnSZ + 30.0, btnSZ + 30.0)
        uiEditBoxName:SetHeight(btnSZ)

        --删除 增加 刷新 打开 关闭
        local btnADD = nil
        local fTEXT = nil
        for i=0,4,1 do
            if 0==i then
                btnADD = UIButton:New("BtnRemove1")
                fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Remove"))
            elseif 1==i then
                btnADD = UIButton:New("BtnAdd1")
                fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Add"))
            elseif 2==i then
                btnADD = UIButton:New("BtnRefresh1")
                fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Refresh"))
            elseif 3==i then
                btnADD = UIButton:New("BtnOpenMap1")
                fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Open"))
            elseif 4==i then
                btnADD = UIButton:New("BtnCloseMap1")
                fTEXT = btnADD:CreateAddFText(""..PX2_LM_APP:V("Close"))
            end
            
            self._frameInMap:AttachChild(btnADD)
            btnADD:LLY(-6.0)
            btnADD:SetAnchorHor(0.0, 0.0)
            btnADD:SetAnchorParamHor(posH1, posH1)
            btnADD:SetAnchorVer(0.0, 0.0)
            btnADD:SetAnchorParamVer(20.0, 20.0)
            btnADD:SetSize(btnSZ2, btnSZ)
            btnADD:SetScriptHandler("_UICallback", self._scriptControl)--
            fTEXT:GetText():SetFontScale(0.9)--
            manykit_uiProcessBtn(btnADD)--

            posH1 = posH1 + btnSZ2 + tmp
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameInMain()
    if self._frameInMain then 

        local btnSZ = 32.0
        local btnSZ2 = 28.0
        local tmp = 1.0
        local posH1 = 21.0
        local posH2 = 34.0 
        local posH3 = 43.0

        --仿真等
        for i=0, 3, 1 do
            if 0==i then
                local btnAdj = UIButton:New("BtnObjectOption2")
                self._frameInMain:AttachChild(btnAdj)
                btnAdj:LLY(-6.0)
                btnAdj:SetAnchorHor(0.0, 0.0)
                btnAdj:SetAnchorParamHor(posH2, posH2)
                btnAdj:SetAnchorVer(0.0, 0.0)
                btnAdj:SetAnchorParamVer(btnSZ*5.0 + 60.0, btnSZ*5.0 + 60.0)
                btnAdj:SetSize(btnSZ*1.8, btnSZ*3)
                btnAdj:SetScriptHandler("_UICallback", self._scriptControl)--

                local fText= btnAdj:CreateAddFText(txt)
                fText:GetText():SetFontScale(0.8)

                local txt = "仿真"
                local useage = "Simu"
                
                self._btnsimu2 = btnAdj

                fText:GetText():SetText(txt)
                btnAdj:SetUserDataString("useage", useage)

                manykit_uiProcessBtn(btnAdj)
            elseif 1==i then
                for j=0,2,1 do
                    local btnAdj = UIButton:New("BtnObjectOption2")
                    self._frameInMain:AttachChild(btnAdj)
                    btnAdj:LLY(-6.0)
                    btnAdj:SetAnchorHor(0.0, 0.0)
                    btnAdj:SetAnchorParamHor(posH2, posH2)
                    btnAdj:SetAnchorVer(0.0, 0.0)
                    btnAdj:SetAnchorParamVer(btnSZ*5.0 + 28.0 + 32.0*j, btnSZ*5.0 + 28.0 + 32.0*j)
                    btnAdj:SetSize(btnSZ*1.8, 32.0)
                    btnAdj:SetScriptHandler("_UICallback", self._scriptControl)--

                    local fText= btnAdj:CreateAddFText(txt)
                    fText:GetText():SetFontScale(0.8)

                    --权限 管理员 普通角色
                    local txt = ""
                    local useage = ""
                    if 2==j then
                        txt = "权限"--无功能
                        useage = "Power"
                    elseif 1==j then
                        txt = "管理员"--
                        useage = "Administrator"
                    elseif 0==j then
                        txt = "普通角色"--
                        useage = "Normal character"
                    end

                    fText:GetText():SetText(txt)
                    btnAdj:SetUserDataString("useage", useage)

                    manykit_uiProcessBtn(btnAdj)
                    if 2==j then
                        fText:GetText():SetFontColor(Float3.BLACK)
                        --fText:GetText():SetDrawStyle(FD_NORMAL)
                        fText:GetText():SetBorderShadowColor(Float3.WHITE)                        
                    end
                end
            elseif 2==i then
                local btnH = 14
                for j=0, 6, 1 do
                    local btnAdj = UIButton:New("BtnObjectOption2")
                    self._frameInMain:AttachChild(btnAdj)
                    btnAdj:LLY(-6.0)
                    btnAdj:SetAnchorHor(0.0, 0.0)
                    btnAdj:SetAnchorParamHor(posH2, posH2)
                    btnAdj:SetAnchorVer(0.0, 0.0)
                    local v=btnSZ*5.0 + 3.0 + btnH + btnH*j
                    btnAdj:SetAnchorParamVer(v, v)
                    btnAdj:SetSize(btnSZ*1.8, btnH)
                    btnAdj:SetScriptHandler("_UICallback", self._scriptControl)--

                    local fText= btnAdj:CreateAddFText(txt)
                    fText:GetText():SetFontScale(0.8)

                    --视角 上帝 角色 第一人称
                    local txt = ""
                    local useage = ""
                    if 6==j then
                        txt = "视角"--无功能
                        useage = "View"
                    elseif 5==j then
                        txt = "上帝"
                        useage = "God"
                    elseif 4==j then
                        txt = "角色"
                        useage = "Character"
                    elseif 3==j then
                        txt = "跟随"
                        useage = "Follow"
                    elseif 2==j then
                        txt = "上帝控制"
                        useage = "GodControl"
                    elseif 1==j then
                        txt = "第一人称"
                        useage = "FixViewBody"
                    elseif 0==j then
                        txt = "锁定"
                        useage = "FixView"
                    end

                    fText:GetText():SetText(txt)
                    btnAdj:SetUserDataString("useage", useage)

                    manykit_uiProcessBtn(btnAdj)
                    if 6==j then
                        fText:GetText():SetFontColor(Float3.BLACK)
                        fText:GetText():SetBorderShadowColor(Float3.WHITE)
                    end
                end
            elseif 3==i then
                for j=0,3,1 do
                    local btnAdj = UIButton:New("BtnObjectOption2")
                    self._frameInMain:AttachChild(btnAdj)
                    btnAdj:LLY(-6.0)
                    btnAdj:SetAnchorHor(0.0, 0.0)
                    btnAdj:SetAnchorParamHor(posH2, posH2)
                    btnAdj:SetAnchorVer(0.0, 0.0)
                    btnAdj:SetAnchorParamVer(btnSZ*5.0 + 24.0 + 24.0*j, btnSZ*5.0 + 24.0 + 24.0*j)
                    btnAdj:SetSize(btnSZ*1.8, 24.0)
                    btnAdj:SetScriptHandler("_UICallback", self._scriptControl)--

                    local fText= btnAdj:CreateAddFText(txt)
                    fText:GetText():SetFontScale(0.8)

                    --东 南 西 北
                    local txt = ""
                    local useage = ""
                    if 3==j then
                        txt = "东"--
                        useage = "East"
                    elseif 2==j then
                        txt = "南"--
                        useage = "North"
                    elseif 1==j then
                        txt = "西"--
                        useage = "West"
                    elseif 0==j then
                        txt = "北"--
                        useage = "South"
                    end

                    fText:GetText():SetText(txt)
                    btnAdj:SetUserDataString("useage", useage)

                    manykit_uiProcessBtn(btnAdj)
                end
            end
            posH2 = posH2 + btnSZ*1.8 + tmp*1.0
        end

        --slider
        -- local list = UIList:New("ListVSlider")
        -- frameInfo:AttachChild(list)
        -- list:LLY(-6.0)
        -- list:SetAnchorHor(0.95, 1.0)
        -- list:SetAnchorParamHor(2.0, -5.0)
        -- list:SetAnchorVer(0.55, 0.9)
        -- list:SetAnchorParamVer(4.0, -6.0)
        -- list:SetReleasedDoSelect(true)
        -- list:CreateAddBackgroundPicBox(true, Float3.RED)
        -- list:SetScriptHandler("_UICallback", self._scriptControl)--
        -- local slider = manykit_uiProcessList(list, true)
        -- slider:SetAnchorHor()
        if true then
            local frameSlider = UIFrame:New()
            self._frameInMain:AttachChild(frameSlider)
            frameSlider:LLY(-6.0)-- 0.0最底
            frameSlider:SetAnchorHor(0.88, 0.98)
            frameSlider:SetAnchorVer(0.55, 0.9)
            frameSlider:SetAnchorParamVer(4.0, -6.0)
            local back = frameSlider:CreateAddBackgroundPicBox(false)
            back:UseAlphaBlend(true)
            back:SetTexture(self:_imgpthmworld("ui/square3.png"))
            back:SetPicBoxType(UIPicBox.PBT_NINE)
            back:SetTexCornerSize(0.0, 0.0, 0.0, 0.0)
            back:UseAlphaBlend(true)
            back:SetAlpha(0.3)
            back:SetColor(Float3:MakeColor(255, 255, 255))--55, 255, 255
            frameSlider:RegistToScriptSystem()
        end

        --输入框
        local v = g_manykit._hBtn * 0.5--40*0.5=20
        local uiEditBoxInput = UIEditBox:New("EditBoxInput2")
        self._frameInMain:AttachChild(uiEditBoxInput)
        uiEditBoxInput:LLY(-6.0)-- -2
        uiEditBoxInput:SetAnchorHor(0.0, 1.0)
        uiEditBoxInput:SetAnchorParamHor(5.0, -5.0)
        uiEditBoxInput:SetAnchorVer(0.0, 0.0)
        uiEditBoxInput:SetAnchorParamVer(btnSZ*4.0 + 24.0, btnSZ*4.0 + 24.0)
        uiEditBoxInput:SetHeight(btnSZ)
        uiEditBoxInput:SetAlpha(0.6)
        uiEditBoxInput:SetScriptHandler("_UICallback", self._scriptControl)

        --使用等
        local btnW = 25
        for i=0,9,1 do
            local btnAdj = UIButton:New("BtnObjectOption2")
            self._frameInMain:AttachChild(btnAdj)
            btnAdj:LLY(-6.0)
            btnAdj:SetAnchorHor(0.0, 0.0)
            btnAdj:SetAnchorParamHor(posH1-1, posH1-1)
            btnAdj:SetAnchorVer(0.0, 0.0)
            btnAdj:SetAnchorParamVer(btnSZ*3.0 + 20.0, btnSZ*3.0 + 20.0)
            btnAdj:SetSize(btnW, btnSZ)
            btnAdj:SetScriptHandler("_UICallback", self._scriptControl)--

            local fText= btnAdj:CreateAddFText(txt)--
            fText:GetText():SetFontScale(0.75)
            
            local txt = ""
            local useage = ""
            if 0==i then
                txt = "使用"
                useage = "Use"
            elseif 1==i then
                txt = "聚焦"
                useage = "Focus"
            elseif 2==i then
                txt = "位移"
                useage = "Trans"
            elseif 3==i then
                txt = "旋转"
                useage = "Rotate"
            elseif 4==i then
                txt = "缩放"
                useage = "Scale"
            elseif 5==i then
                txt = "重置"--
                useage = "Reset"
            elseif 6==i then
                txt = "操控"--
                useage = "Control" 
            elseif 7==i then
                txt = "取消\n选择"
                useage = "Cancelselect"
                fText:GetText():SetFontScale(0.7)
                fText:SetAnchorParamVer(5.0, 5.0)
            elseif 8==i then
                txt = "删除"--
                useage = "Delete"
            elseif 9==i then
                txt = "编辑"
                useage = "Edit"

                self._btnedit2 = btnAdj
            end

            fText:GetText():SetText(txt)
            btnAdj:SetUserDataString("useage", useage)

            manykit_uiProcessBtn(btnAdj)

            if "Delete"==useage then
                btnAdj:SetStateColor(UIButtonBase.BS_NORMAL, Float3(0.5, 0.0, 0.0))
                btnAdj:SetStateColor(UIButtonBase.BS_PRESSED, Float3(0.5, 0.0, 0.0))
                btnAdj:SetStateColor(UIButtonBase.BS_HOVERED, Float3(0.5, 0.0, 0.0))
            end

            posH1 = posH1 + btnW + tmp
        end

        -- local btnSZ = 32.0
        -- local tmp = 1.0
        local posHt = 55.0
        --当前选择的角色信息
        if true then
            local frameAdj = UIFrame:New()
            self._frameInMain:AttachChild(frameAdj)
            self._frameAdj = frameAdj
            frameAdj:LLY(-6.0)
            frameAdj:SetAnchorHor(0.0, 1.0)
            frameAdj:SetAnchorParamHor(5.0, -5.0)
            frameAdj:SetAnchorVer(0.0, 0.0)
            frameAdj:SetAnchorParamVer(btnSZ*0.0 + 50.0, btnSZ*0.0 + 50.0)
            frameAdj:SetHeight(btnSZ*3)
            
            local back = frameAdj:CreateAddBackgroundPicBox(false)
            back:UseAlphaBlend(true)
            back:SetTexture(self:_imgpthmworld("ui/square3.png"))
            back:SetPicBoxType(UIPicBox.PBT_NINE)
            back:SetTexCornerSize(0.0, 0.0, 0.0, 0.0)
            back:UseAlphaBlend(true)
            back:SetAlpha(0.3)
            back:SetColor(Float3:MakeColor(255, 255, 255))
            frameAdj:RegistToScriptSystem()
        
            local fText = UIFText:New("SelectCharaInfor")
            self._frameAdjFText = fText
            frameAdj:AttachChild(fText)
            fText:SetID(1043)
            fText:LLY(-6.0)
            fText:SetAnchorHor(0.0, 1.0)
            fText:SetAnchorParamHor(4.0, -4.0)
            fText:SetAnchorVer(0.0, 1.0)
            fText:SetAnchorParamVer(4.0, -4.0)
            fText:GetText():SetFontColor(Float3.BLACK)
            --fText:GetText():SetFontSize(25)
            fText:GetText():SetFontScale(0.8)
            --fText:GetText():SetDrawStyle(FD_BORDER)
            --fText:GetText():SetBorderShadowColor(Float3(255, 255, 255))
            fText:GetText():SetBorderShadowAlpha(0.4)
            fText:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_TOP)
        
            --local txt = "当前选择的角色信息：\n 1\n2\n3\n4\n5"
            local txt = "当前选择的角色信息：\n 无"
            local useage = "Selecting CharaInformation"

            fText:GetText():SetText(txt)
            frameAdj:SetUserDataString("useage", useage)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameInInfo()
    if self._frameInInfo then
        local f = UIFrame:New()
        self._frameInInfo:AttachChild(f)
        f:LLY(-6.0)
        f:SetAnchorHor(0.0, 1.0)
        f:SetAnchorVer(0.0, 1.0)
        f:RegistToScriptSystem()
        f:Show(true)
        
        local fPicBox = UIFPicBox:New()
        f:AttachChild(fPicBox)
        fPicBox:LLY(-6.0)
        fPicBox:SetAnchorHor(0.0, 1.0)
        --fPicBox:SetAnchorParamHor(0.0, 0.0)
        fPicBox:SetAnchorVer(1.0, 1.0)
        fPicBox:SetAnchorParamVer(-90.0, -90.0)
        fPicBox:SetHeight(80.0)
        fPicBox:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/square3.png"))
        fPicBox:GetUIPicBox():SetAlpha(0.5)
        fPicBox:SetColor(Float3:MakeColor(255, 55, 255))
        fPicBox:RegistToScriptSystem()

        local fText = UIFText:New("Name")
        fPicBox:AttachChild(fText)
        self._frameInInFireT = fText
        --fText:SetID(1033)
        fText:LLY(-6.0)
        fText:SetAnchorHor(0.0, 1.0)
        fText:SetAnchorVer(0.0, 1.0)
        fText:GetText():SetFontColor(Float3.WHITE)
        fText:GetText():SetFontSize(25)
        fText:GetText():SetFontScale(0.7)
        fText:GetText():SetDrawStyle(FD_BORDER)
        fText:GetText():SetBorderShadowColor(Float3(0, 0, 0))
        fText:GetText():SetBorderShadowAlpha(0.4)
        fText:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_TOP)
        fText:GetText():SetText("fire information")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameInTest()
    if self._frameInTest then
        local btnSZ = 32.0
        local tmp = 1.0
        local posH1 = 21.0

        -- +20 +200 +1000
        for i=0,5,1 do
            local btnAdj = UIButton:New("BtnObjectOption2")
            self._frameInTest:AttachChild(btnAdj)
            btnAdj:LLY(-6.0)
            btnAdj:SetAnchorHor(0.0, 0.0)
            btnAdj:SetAnchorParamHor(posH1-1, posH1-1)
            btnAdj:SetAnchorVer(1.0, 1.0)
            btnAdj:SetAnchorParamVer(-btnSZ*1.5-10.0, -btnSZ*1.5-10.0)
            btnAdj:SetSize(btnSZ, btnSZ)
            btnAdj:SetScriptHandler("_UICallback", self._scriptControl)

            local fText= btnAdj:CreateAddFText(txt)--
            fText:GetText():SetFontScale(0.75)
            
            local txt = ""
            local useage = ""
            if 0==i then
                txt = "+20"
                useage = "Test20"
            elseif 1==i then
                txt = "+200"
                useage = "Test200"
            elseif 2==i then
                txt = "+1000"
                useage = "Test1000"
            elseif 3==i then
                txt = "A20"
                useage = "A20"
            elseif 4==i then
                txt = "A200"
                useage = "A200"
            elseif 5==i then
                txt = "A1000"
                useage = "A1000"
            end

            fText:GetText():SetText(txt)
            btnAdj:SetUserDataString("useage", useage)

            manykit_uiProcessBtn(btnAdj)

            posH1 = posH1 + btnSZ + tmp
        end

        posH1 = 21.0
        for i=0,6,1 do
            local btnAdj = UIButton:New("BtnObjectOption2")
            self._frameInTest:AttachChild(btnAdj)
            btnAdj:LLY(-6.0)
            btnAdj:SetAnchorHor(0.0, 0.0)
            btnAdj:SetAnchorParamHor(posH1-1, posH1-1)
            btnAdj:SetAnchorVer(1.0, 1.0)
            btnAdj:SetAnchorParamVer(-btnSZ*2.5-15.0, -btnSZ*2.5-15.0)
            btnAdj:SetSize(btnSZ, btnSZ)
            btnAdj:SetScriptHandler("_UICallback", self._scriptControl)

            local fText= btnAdj:CreateAddFText(txt)--
            fText:GetText():SetFontScale(0.75)
            
            local txt = ""
            local useage = ""
            if 0==i then
                txt = "P0"
                useage = "P0"
            elseif 1==i then
                txt = "P1"
                useage = "P1"
            elseif 2==i then
                txt = "P2"
                useage = "P2"
            elseif 3==i then
                txt = "P3"
                useage = "P3"
            elseif 4==i then
                txt = "P4"
                useage = "P4"
            elseif 5==i then
                txt = "P5"
                useage = "P5"
            elseif 6==i then
                txt = "P6"
                useage = "P6"
            end

            fText:GetText():SetText(txt)
            btnAdj:SetUserDataString("useage", useage)

            manykit_uiProcessBtn(btnAdj)

            posH1 = posH1 + btnSZ + tmp
        end
    end

    --[[
    local btnAdj = UIButton:New("BtnObjectOption2")
    self._frameInTestNum:AttachChild(btnAdj)
    btnAdj:LLY(-6.0)
    btnAdj:SetAnchorHor(0.0, 0.0)
    btnAdj:SetAnchorParamHor(42, 42)
    btnAdj:SetAnchorVer(0.0, 0.0)
    btnAdj:SetAnchorParamVer(btnSZ*4.0 +30 , btnSZ*4.0 +30)
    btnAdj:SetSize(64, 32)
    btnAdj:SetScriptHandler("_UICallback", self._scriptControl)
    local fText= btnAdj:CreateAddFText(txt)
    fText:GetText():SetFontScale(0.75)
    local txt = "RePlay"
    local useage = "RePlay"
    fText:GetText():SetText(txt)
    btnAdj:SetUserDataString("useage", useage)
    manykit_uiProcessBtn(btnAdj)
    ]]--
end
-------------------------------------------------------------------------------
function p_mworld:_ViewFocus(id)
    print(self._name.." p_mworld:_ViewFocus")

    local useid = self._curSelectActorID
    if nil~=id then
        useid = id
    end

    print("useid:"..useid)

    if useid then
        local scene = PX2_PROJ:GetScene()
        if scene then
            local act = scene:GetActorFromMap(useid)
            if act then
                local ag = act:GetAIAgentBase()
                local skillChara = act:GetSkillChara()
                if ag and skillChara then
                    local maxDist = 15
                    if skillChara then
                        local defChara = skillChara:GetDefChara()
                        local defModel = skillChara:GetDefModel()
                        if defModel then
                            local len = defModel.Height
                            maxDist = len * 10
                        end
                    end
                    local pos = ag:GetPosition()
                    p_holospace._g_cameraPlayCtrl:SetTargetPos(pos)
                    p_holospace._g_cameraPlayCtrl:SetCameraDistance(maxDist*0.5)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_Edit(edit)
    print(self._name.." p_mworld:edit")
    print_i_b(edit)

    self._isediting = edit

    local scene = PX2_PROJ:GetScene()
    if scene then
        if self._curSelectActorID > 0 then
            local actor = scene:GetActorFromMap(self._curSelectActorID)
            if actor then
                local nodeRoot = actor:GetNodeRoot()
                local nodeModel = actor:GetNodeModel()
                local model = actor:GetModel()
                
                nodeModel:SetDoPick(true)

                local mp = nodeRoot:GetObjectByID(p_actor._g_idModelPick)
                local mpMov = Cast:ToMovable(mp)            
                if edit then
                    nodeModel:SetDoPick(true)
                    if mpMov then
                        mpMov:SetDoPick(false)
                    end
                else
                    nodeModel:SetDoPick(false)
                    if mpMov then
                        mpMov:SetDoPick(true)
                    end
                end

                local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
                if scCtrl then
                    scCtrl:_OnEdit(edit)
                    
                    if edit then
                        scCtrl:_RegistPropertyEdit()
                        self._propertyGridEdit:RegistOnObject(scCtrl._scriptControl, "Edit")
                    end
                end
            end
        else
            if edit then
                self:_RegistPropertySceneEdit()
                self:_RegistPropertySceneEditExt()
            end      
        end
    end

    if not edit then
        self._propertyGridEdit:RemoveAllPropertiesUI()
    end

    if self._isediting then
        if self._btnedit then
            self._btnedit:SetStateColor(UIButtonBase.BS_NORMAL, Float3(0.0, 0.5, 0.0))
            self._btnedit:SetStateColor(UIButtonBase.BS_PRESSED, Float3(0.0, 0.5, 0.0))
            self._btnedit:SetStateColor(UIButtonBase.BS_HOVERED, Float3(0.0, 0.5, 0.0)) 
        end
        if self._btnedit2 then
            self._btnedit2:SetStateColor(UIButtonBase.BS_NORMAL, Float3(0.0, 0.5, 0.0))
            self._btnedit2:SetStateColor(UIButtonBase.BS_PRESSED, Float3(0.0, 0.5, 0.0))
            self._btnedit2:SetStateColor(UIButtonBase.BS_HOVERED, Float3(0.0, 0.5, 0.0)) 
        end
    else
        if self._btnedit then        
            manykit_uiProcessBtn(self._btnedit)
        end
        if self._btnedit2 then        
            manykit_uiProcessBtn(self._btnedit2)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameNoInput()
    local frameCover = UIFrame:New()
    frameCover:SetAnchorHor(0.0, 1.0)
    frameCover:SetAnchorVer(0.0, 1.0)
    frameCover:SetWidget(true)
    --frameCover:CreateAddBackgroundPicBox(false, Float3(1,1,1))

    return frameCover
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameWeb()

    if nil~=UIFrameCEF then
        local frameCEF = UIFrameCEF:New("UIFrameCEF")
        gframeCEF = frameCEF
        frameCEF:SetAnchorHor(0.0, 1.0)
        frameCEF:SetAnchorVer(0.0, 1.0)

        self:_LoadFrameWeb()

        return frameCEF
    end

    return nil
end
-------------------------------------------------------------------------------
function p_mworld:_LoadFrameWeb(urll)
    print(self._name.." p_mworld:_LoadFrameWeb")

    if gframeCEF then
        local url = ""
        if nil==urll then
            local pth = ResourceManager:GetCurExecutablePath()
            local pth1 = "file:///"..pth.."webs/test.html"
            url = PX2_PROJ:GetConfig("url")
            if ""==url then
                url = pth1
                PX2_PROJ:SetConfig("url", url)
            end
        else
            url = urll
        end

        gframeCEF:SetURL(url)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ShowCursor(show)
    print("_ShowCursor:")
    print_i_b(show)

    self._isHideCursor = not show
    local rw = PX2_GH:GetMainWindow()
    if rw then
        rw:ShowCursor(show) 
    end

    p_holospace._g_cameraPlayCtrl:SetTouchMoveIngorePress(not show)

    local rw = PX2_GH:GetMainWindow()
    if rw then
        if not show then
            rw:SetScreenDragType(RenderWindow.SDT_LEFT)
            rw:SetScreenDragKeep(true)
        else
            rw:SetScreenDragType(RenderWindow.SDT_NONE)
            rw:SetScreenDragKeep(false)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateMapListFrame()
	local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-10, -10, "地图")
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

	local frame = UIFrame:New()
    uiFrame:AttachChild(frame)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    -- list
    local list = UIList:New("ListMap")
    frame:AttachChild(list)
    self._listMap1 = list -- add 55
    list:LLY(-1.0)
    list:SetAnchorHor(0.0, 0.5)
    list:SetAnchorParamHor(40.0, -20.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamVer(120.0, -120.0)
    list:SetReleasedDoSelect(true)
    list:CreateAddBackgroundPicBox(true, Float3:MakeColor(230, 230, 230))
    list:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessList(list, true)

    local posVer = -150.0

    local fTextName = UIFText:New()
	frame:AttachChild(fTextName)
	fTextName:LLY(-2.0)
	fTextName:SetAnchorHor(0.5, 0.5)
    fTextName:SetAnchorVer(1.0, 1.0)
    fTextName:SetAnchorParamHor(0.0, 150.0)
    fTextName:SetAnchorParamVer(posVer, posVer)
    fTextName:GetText():SetText(""..PX2_LM_APP:V("Name"))
    fTextName:SetHeight(g_manykit._hBtn)
    fTextName:SetPivot(0.0, 0.5)
    fTextName:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
	manykit_uiProcessFText(fTextName)

    local uiEditBoxName = UIEditBox:New("EditBoxName")
	frame:AttachChild(uiEditBoxName)
    self._editboxMapName1 = uiEditBoxName
	uiEditBoxName:LLY(-2.0)
	uiEditBoxName:SetAnchorHor(0.5, 1.0)
	uiEditBoxName:SetAnchorParamHor(100.0, -100.0)
    uiEditBoxName:SetAnchorVer(1.0, 1.0)
    uiEditBoxName:SetAnchorParamVer(posVer, posVer)
	uiEditBoxName:SetPivot(0.5, 0.5)
	uiEditBoxName:SetHeight(g_manykit._hBtn)

    local h = 1.0/6.0
    local btnRemove = UIButton:New("BtnRemove")
	frame:AttachChild(btnRemove)
	btnRemove:LLY(-1.0)
	btnRemove:SetSize(150, 50)
	btnRemove:SetAnchorHor(h, h)
	btnRemove:SetAnchorVer(0.0, 0.0)
	btnRemove:SetAnchorParamVer(60.0, 60.0)
	btnRemove:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnRemove:CreateAddFText(""..PX2_LM_APP:V("Remove"))
	manykit_uiProcessBtn(btnRemove)
    btnRemove:SetScriptHandler("_UICallback", self._scriptControl)

    local btnAdd= UIButton:New("BtnAdd")
	frame:AttachChild(btnAdd)
	btnAdd:LLY(-1.0)
	btnAdd:SetSize(150, 50)
	btnAdd:SetAnchorHor(h*2, h*2)
	btnAdd:SetAnchorVer(0.0, 0.0)
	btnAdd:SetAnchorParamVer(60.0, 60.0)
	btnAdd:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnAdd:CreateAddFText(""..PX2_LM_APP:V("Add"))
	manykit_uiProcessBtn(btnAdd)
    btnAdd:SetScriptHandler("_UICallback", self._scriptControl)

	local btnRefresh = UIButton:New("BtnRefresh")
	frame:AttachChild(btnRefresh)
	btnRefresh:LLY(-1.0)
	btnRefresh:SetSize(150, 50)
	btnRefresh:SetAnchorHor(h*3, h*3)
	btnRefresh:SetAnchorVer(0.0, 0.0)
	btnRefresh:SetAnchorParamVer(60.0, 60.0)
	btnRefresh:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnRefresh:CreateAddFText(""..PX2_LM_APP:V("Refresh"))
	manykit_uiProcessBtn(btnRefresh)
    btnRefresh:SetScriptHandler("_UICallback", self._scriptControl)

    local btnOpen = UIButton:New("BtnOpenMap")
	frame:AttachChild(btnOpen)
	btnOpen:LLY(-1.0)
	btnOpen:SetSize(150, 50)
	btnOpen:SetAnchorHor(h*4, h*4)
	btnOpen:SetAnchorVer(0.0, 0.0)
	btnOpen:SetAnchorParamVer(60.0, 60.0)
	btnOpen:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnOpen:CreateAddFText(""..PX2_LM_APP:V("Open"))
	manykit_uiProcessBtn(btnOpen)
    btnOpen:SetScriptHandler("_UICallback", self._scriptControl)

    local btnClose = UIButton:New("BtnCloseMap")
	frame:AttachChild(btnClose)
	btnClose:LLY(-1.0)
	btnClose:SetSize(150, 50)
	btnClose:SetAnchorHor(h*5, h*5)
	btnClose:SetAnchorVer(0.0, 0.0)
	btnClose:SetAnchorParamVer(60.0, 60.0)
	btnClose:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnClose:CreateAddFText(""..PX2_LM_APP:V("Close"))
	manykit_uiProcessBtn(btnClose)
    btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    return uiFrameBack
end
-------------------------------------------------------------------------------
function p_mworld:_ShowInspector(show)
	print("p_mworld:_ShowInspector")
	print_i_b(show)

	self._frameInspector:Show(show)

    if show then
        self._frameUI:SetAnchorParamHor(0.0, -g_manykit._inspectorWidth)
    else
        self._frameUI:SetAnchorParamHor(0.0, 0.0)
    end
end
-------------------------------------------------------------------------------