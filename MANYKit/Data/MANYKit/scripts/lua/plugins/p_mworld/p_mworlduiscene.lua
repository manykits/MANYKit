-- p_mworlduiscene.lua

-------------------------------------------------------------------------------
function p_mworld:_CreateFrameSceneObjectList()
    local frame = UIFrame:New()
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
    frame:CreateAddBackgroundPicBox(true, g_manykit._colorBackGround)

    local fTextTitle = UIFText:New("TextTitle")
    self._fTextListInfo = fTextTitle
	frame:AttachChild(fTextTitle)
	fTextTitle:LLY(-6.0)
	fTextTitle:SetAnchorHor(0.0, 1.0)
    fTextTitle:SetAnchorParamHor(5.0, -5.0)
	fTextTitle:SetAnchorVer(1.0, 1.0)
	fTextTitle:SetAnchorParamVer(-g_manykit._hBtn ,-g_manykit._hBtn)
	fTextTitle:SetPivot(0.5, 0.0)
	fTextTitle:SetHeight(g_manykit._hBtn)
	fTextTitle:GetText():SetFontColor(Float3.WHITE)
	fTextTitle:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
	fTextTitle:GetText():SetText("Info")
	fTextTitle:GetText():SetFontScale(0.8)

    -- tab frame
    local frameTab = UITabFrame:New()
    frame:AttachChild(frameTab)
    frameTab:LLY(-1.0)
    frameTab:SetAnchorHor(0.0, 1.0)
    frameTab:SetAnchorVer(0.0, 1.0)
    frameTab:SetAnchorParamVer(0.0, -g_manykit._hBtn)

    -- items
    local listFrame = UIFrame:New()
    listFrame:SetAnchorHor(0.0, 1.0)
    listFrame:SetAnchorVer(0.0, 1.0)
    listFrame:SetAnchorParamVer(0.0, 0.0)

    local frameCata = UIFrame:New()
    listFrame:AttachChild(frameCata)
    frameCata:LLY(-1.0)
    frameCata:SetAnchorHor(0.0, 1.0)
    frameCata:SetAnchorVer(1.0, 1.0)
    frameCata:SetPivot(0.5, 1.0)
    frameCata:SetHeight(40.0)
    
    local num = 4
    local tmp = 1.0/num
    for i=0, num-1, 1 do
        local btn = UIButton:New("BtnSceneCata")
        frameCata:AttachChild(btn)
        btn:LLY(-1.0)
        local f = i*tmp
        local t = f + tmp
        btn:SetAnchorHor(f, t)
        btn:SetAnchorParamHor(2.0, -2.0)
        btn:SetAnchorVer(0.0, 1.0)
        btn:SetAnchorParamVer(2.0, -2.0)
        btn:SetScriptHandler("_UICallback", self._scriptControl)
        local fText = ""
        local cata = ""
        if 0==i then
            fText="NPC"
            cata= "npc"
        elseif 1==i then
            fText="场景"
            cata= "scene"
        elseif 2==i then
            fText="逻辑"
            cata= "logic"
        elseif 3==i then
            fText="全部"
            cata= "all"
        end
        local fText = btn:CreateAddFText(fText)
        btn:SetUserDataString("cata", cata)
        fText:GetText():SetFontColor(Float3.RED)

        manykit_uiProcessBtn(btn)
    end

    local listMapItems = UIList:New("ListMapItems")
    listFrame:AttachChild(listMapItems)
    self._listMapItems = listMapItems
    frameTab:AddTab("Scene", ""..PX2_LM_APP:V("Scene"), listFrame)
    listMapItems:LLY(-1.0)
    listMapItems:SetAnchorHor(0.0, 1.0)
    listMapItems:SetAnchorVer(0.0, 1.0)
    listMapItems:SetAnchorParamVer(0.0, -40.0)
    listMapItems:SetReleasedDoSelect(true)
    listMapItems:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessList(listMapItems)

    -- peoples
    local framePeople = UIFrame:New()
    framePeople:SetAnchorHor(0.0, 1.0)
    framePeople:SetAnchorVer(0.0, 1.0)
    framePeople:SetAnchorParamVer(0.0, 0.0)

    local frameCataPeople = UIFrame:New()
    framePeople:AttachChild(frameCataPeople)
    frameCataPeople:LLY(-1.0)
    frameCataPeople:SetAnchorHor(0.0, 1.0)
    frameCataPeople:SetAnchorVer(1.0, 1.0)
    frameCataPeople:SetPivot(0.5, 1.0)
    frameCataPeople:SetHeight(40.0)
    local num = 3
    local tmp = 1.0/num
    for i=0, num-1, 1 do
        local btn = UIButton:New("BtnSceneCataPeople")
        frameCataPeople:AttachChild(btn)
        btn:LLY(-1.0)
        local f = i*tmp
        local t = f + tmp
        btn:SetAnchorHor(f, t)
        btn:SetAnchorParamHor(2.0, -2.0)
        btn:SetAnchorVer(0.0, 1.0)
        btn:SetAnchorParamVer(2.0, -2.0)
        btn:SetScriptHandler("_UICallback", self._scriptControl)
        local fText = ""
        local cata = ""

        if 0==i then
            fText="全部"
            cata= "all"
        elseif 1==i then
            fText="在图"
            cata= "inmap"
        elseif 2==i then
            fText="离图"
            cata= "outmap"
        end
        local fText = btn:CreateAddFText(fText)
        btn:SetUserDataString("cata", cata)
        fText:GetText():SetFontColor(Float3.RED)

        manykit_uiProcessBtn(btn)
    end

    local listPeoples = UIList:New("ListPeoples")
    self._listPeoples = listPeoples
    framePeople:AttachChild(listPeoples)
    listPeoples:LLY(-1.0)
    listPeoples:SetAnchorHor(0.0, 1.0)
    listPeoples:SetAnchorVer(0.0, 1.0)
    listPeoples:SetAnchorParamVer(0.0, -40.0)
    listPeoples:SetPivot(0.5, 0.5)
    listPeoples:SetReleasedDoSelect(true)
    listPeoples:SetMulti(true)
    manykit_uiProcessList(listPeoples)
    listPeoples:SetScriptHandler("_UICallback", self._scriptControl)

    frameTab:AddTab("People", ""..PX2_LM_APP:V("People"), framePeople)

    manykit_uiProcessTable(frameTab)
    frameTab:SetTabWidth(90.0)
    frameTab:SetActiveTab("Scene")

    return frame
end
-------------------------------------------------------------------------------