-- p_mworlduiedit.lua
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameInspector(w, h)
	local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(w, h, "")
    btnClose:SetName("BtnEditClose")
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    local frameTab = UITabFrame:New("TableFrameSetting")
    uiFrame:AttachChild(frameTab)
    frameTab:LLY(-1.0)
    frameTab:SetAnchorHor(0.0, 1.0)
    frameTab:SetAnchorVer(0.0, 1.0)
    frameTab:SetAnchorParamVer(0.0, 0.0)
    frameTab:SetTabWidth(60)
    frameTab:SetTabBarHeight(g_manykit._hBtn)
    frameTab:SetTabHeight(g_manykit._hBtn)
    frameTab:SetFontColor(Float3.WHITE)
	frameTab:SetScriptHandler("_UICallback", self._scriptControl)

    local frameList = self:_CreateFrameSceneObjectList()
    frameTab:AddTab("List", "物件", frameList)

    local frameProperty = self:_CreateFrameProperty()
    frameTab:AddTab("Property", "属性", frameProperty)

    local frameEdit = self:_CreateFrameEdit()
    frameTab:AddTab("Edit", "编辑", frameEdit)

    local frameProgram = self:_CreateFrameProgram()
    frameTab:AddTab("Program", "编程", frameProgram)

    local frameSet = self:_CreateFrameSet()
    frameTab:AddTab("Set", "设置", frameSet)

    local frameServer = self:_CreateFrameServer()
    frameTab:AddTab("Server", "服务器", frameServer)

    frameTab:SetActiveTab("Property")

    return uiFrameBack, uiFrame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameProperty()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
	uiFrame:SetAnchorVer(0.0, 1.0)

	local pg = UIPropertyGrid:New("PropertyGrid")
    self._propertyGrid = pg
    uiFrame:AttachChild(pg)
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.0, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl) 
    pg:GetUISplitterFrame():SetAnchorHor(0.45, 0.45)

	return uiFrame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameEdit()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
	uiFrame:SetAnchorVer(0.0, 1.0)

    local frameTable = UITabFrame:New("TabFrameEdit")
    uiFrame:AttachChild(frameTable)
    frameTable:AddTab("edit", ""..PX2_LM_APP:V("Edit"), self:_CreateFrameEdit0())
    frameTable:AddTab("other", ""..PX2_LM_APP:V("Other"), self:_CreateFrameEdit1())
    frameTable:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessTable(frameTable)
    frameTable:SetActiveTab("edit")

	return uiFrame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameEdit0()
    local frame = UIFrame:New() 
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    local pg = UIPropertyGrid:New("PropertyGridEdit")
    self._propertyGridEdit = pg
    frame:AttachChild(pg)
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.0, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl)
    pg:GetUISplitterFrame():SetAnchorHor(0.45, 0.45)

    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameEdit1()
    local frame = UIFrame:New()
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    local pg = UIPropertyGrid:New("PropertyGridEdit1")
    self._propertyGridEdit1 = pg
    frame:AttachChild(pg)
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.0, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl)
    pg:GetUISplitterFrame():SetAnchorHor(0.5, 0.5)

    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameSet()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
	uiFrame:SetAnchorVer(0.0, 1.0)

	local pg = UIPropertyGrid:New("PropertyGridSet")
    self._propertyGridSet = pg
    uiFrame:AttachChild(pg)
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.0, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl) 
    pg:GetUISplitterFrame():SetAnchorHor(0.45, 0.45)

    self:_RegistPropertyOnSet()

	return uiFrame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameServer()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
	uiFrame:SetAnchorVer(0.0, 1.0)

	local pg = UIPropertyGrid:New("PropertyGridServer")
    self._propertyGridServer = pg
    uiFrame:AttachChild(pg)
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.0, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl) 
    pg:GetUISplitterFrame():SetAnchorHor(0.45, 0.45)

    self:_RegistPropertyOnServer()

	return uiFrame
end
-------------------------------------------------------------------------------
function p_mworld:_Test(num)
    print("p_mworld:_Testtttttttttttttttttt")

    local scene = PX2_PROJ:GetScene()
    local terrain = scene:GetTerrain()
    local nodeObject = scene:GetObjectByID(p_holospace._g_IDNodeObject)
    if nodeObject then
        local dist = num
        if 1==num then
            dist = 10.0
        end
        coroutine.wrap(function()
            for i=1, num, 1 do
                local fx = Mathf:IntervalRandom(-dist, dist)
                local fy = Mathf:IntervalRandom(-dist, dist)
                local h = terrain:GetHeight(fx, fy)            
                local pos = APoint(fx, fy, h)

                local act, asc = self:_CreateOrUpdateActor(666, 10002, pos, nil, 0, false)
                nodeObject:AttachChild(act)
                local mc = act:GetModelController()
                if mc then
                    local numAnims = mc:GetNumAnims()
                    local a = Mathf:IntRandom(0, numAnims)
                    local anim = mc:GetAnim(a)
                    if anim then
                        mc:PlayAnim(anim)
                    end
                end
                act:SetDoReflect(false)

                sleep(0.01)
            end
        end)()
    end
end
-------------------------------------------------------------------------------
function p_mworld:_GenerateActorWithNum(num)
    print("p_mworld:_TestttttttttttttttttttNum")

    local scene = PX2_PROJ:GetScene()
    local terrain = scene:GetTerrain()
    local nodeObject = scene:GetObjectByID(p_holospace._g_IDNodeObject)
    if nodeObject then
        local sceneID = scene:GetID()

        local dist = num
        if 1==num then
            dist = 10.0
        end
        coroutine.wrap(function()
            for i=1, num, 1 do
                local fx = Mathf:IntervalRandom(-dist, dist)
                local fy = Mathf:IntervalRandom(-dist, dist)
                local h = terrain:GetHeight(fx, fy)            
                local pos = APoint(fx, fy, h)

                local uin = PX2_IDM:GetNextID("Actor")
                p_net._g_net:_RequestAddObject(0, 10002, pos:ToString(), uin, nil,nil, nil, nil, sceneID)

                sleep(0.1)
            end
        end)()
    end
end
-------------------------------------------------------------------------------
function p_mworld:_TestProtol(idx)
    print("p_mworld:_TestProtol")
    print("idx:"..idx)

    PX2_GH:SendGeneralEvent("TestProtol", ""..idx)
end
-------------------------------------------------------------------------------