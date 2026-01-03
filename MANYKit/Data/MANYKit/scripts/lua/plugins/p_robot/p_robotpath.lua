-- p_robotpath.lua

p_robotpath = class(p_ctrl,
{
    _requires = {"p_robot",},

	_name = "p_robotpath",

    _listPos = nil,
    _textChargetPos = nil,
    _textChargePosSide = nil,
    _textCurPos = nil,
    _editBoxAddPos = nil,
})
-------------------------------------------------------------------------------
function p_robotpath:OnAttached()
	PX2_LM_APP:AddItem(self._name, "ROBOTPath", "路径")
    PX2_LM_APP:AddItem("Add", "Add", "增加")
	PX2_LM_APP:AddItem("Remove", "Remove", "删除")
	PX2_LM_APP:AddItem("Update", "Update", "更新")
	PX2_LM_APP:AddItem("UpdatePos", "UpdatePos", "更新位置")
	PX2_LM_APP:AddItem("Go", "Go", "去")
    PX2_LM_APP:AddItem("SetChargerPosFront", "SetChargerPosFront", "设置当前为充电前点")
	PX2_LM_APP:AddItem("ChargerPosFront", "ChargerPosFront", "充电前点")
    PX2_LM_APP:AddItem("ChargerPosSide", "ChargerPosSide", "充电侧点")
	PX2_LM_APP:AddItem("ChargerPos", "ChargerPos", "充电点")
	PX2_LM_APP:AddItem("Patrol", "Patrol", "巡逻")

	p_ctrl.OnAttached(self)
	print(self._name.." p_robotpath:OnAttached")

    RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
        if "updatedtargetpos"==str then
            myself:_refreshTargetPos()
        end
    end)

    self:_CreateContentFrame()
end
-------------------------------------------------------------------------------
function p_robotpath:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_robotpath:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_robotpath:OnPPlay()
	print(self._name.." p_robotpath:OnPPlay")
end
-------------------------------------------------------------------------------
function p_robotpath:_CreateContentFrame()
	print(self._name.." p_robotpath:_CreateContentFrame")

    local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-10, -10, "")
    self._frame:AttachChild(uiFrameBack)

    self._frame:AttachChild(uiFrameBack)

    btnClose:Show(false)

    local frame = UIFrame:New() 
	uiFrame:AttachChild(frame)
	frame:LLY(-2)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
    local back = frame:CreateAddBackgroundPicBox(true, Float3:MakeColor(90.0, 90.0, 90.0))


    local list = UIList:New("ListPos")
    self._listPos = list
    frame:AttachChild(list)
    list:LLY(-2.0)
    list:SetAnchorHor(0.0, 0.5)
    list:SetAnchorParamHor(10.0, -10.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamVer(10.0, -10.0)
    list:SetReleasedDoSelect(true)
    manykit_uiProcessList(list)

    local textChargePos = UIFText:New()
    self._textChargetPos = textChargePos
	frame:AttachChild(textChargePos)
	textChargePos:LLY(-2.0)
    textChargePos:SetAnchorHor(0.5, 1.0)
    textChargePos:SetAnchorParamHor(5.0, -5.0)
    textChargePos:SetAnchorVer(1.0, 1.0)
    textChargePos:SetAnchorParamVer(-40.0, -40.0)
    textChargePos:GetText():SetText(PX2_LM_APP:V("ChargerPosFront")..":".."")
    textChargePos:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    manykit_uiProcessFText(textChargePos)

    local textChargePosSide = UIFText:New()
    self._textChargePosSide = textChargePosSide
	frame:AttachChild(textChargePosSide)
	textChargePosSide:LLY(-2.0)
    textChargePosSide:SetAnchorHor(0.5, 1.0)
    textChargePosSide:SetAnchorParamHor(5.0, -5.0)
    textChargePosSide:SetAnchorVer(1.0, 1.0)
    textChargePosSide:SetAnchorParamVer(-80.0, -80.0)
    textChargePosSide:GetText():SetText(PX2_LM_APP:V("ChargerPosSide")..":".."")
    textChargePosSide:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    manykit_uiProcessFText(textChargePosSide)

    local posVer = -120.0

    local textCurPos = UIFText:New()
    self._textCurPos = textCurPos
	frame:AttachChild(textCurPos)
	textCurPos:LLY(-2.0)
	textCurPos:SetAnchorHor(0.5, 1.0)
	textCurPos:SetAnchorVer(1.0, 1.0)
	textCurPos:SetAnchorParamVer(posVer, posVer)
    textCurPos:GetText():SetText("(,,)")
    manykit_uiProcessFText(textCurPos)

    posVer = posVer -60.0

    local uiEditBoxID = UIEditBox:New("EditBoxRobotID")
    self._editBoxAddPos = uiEditBoxID
	frame:AttachChild(uiEditBoxID)
	uiEditBoxID:LLY(-2.0)
	uiEditBoxID:SetAnchorHor(0.5, 1.0)
	uiEditBoxID:SetAnchorParamHor(5.0, -10.0)
	uiEditBoxID:SetAnchorVer(1.0, 1.0)
    uiEditBoxID:SetAnchorParamVer(posVer, posVer)
	uiEditBoxID:SetHeight(g_manykit._hBtn)

    posVer = posVer -60.0

    local btnSetChargePos = UIButton:New("BtnSetChargePosFront")
	frame:AttachChild(btnSetChargePos)
	btnSetChargePos:LLY(-1.0)
	btnSetChargePos:SetSize(160, g_manykit._hBtn)
	btnSetChargePos:SetAnchorHor(0.5, 1.0)
    btnSetChargePos:SetAnchorParamHor(5.0, -10.0)
	btnSetChargePos:SetAnchorVer(1.0, 1.0)
	btnSetChargePos:SetAnchorParamVer(posVer, posVer)
    btnSetChargePos:SetScriptHandler("_UICallback", self._scriptControl)
	local fText = btnSetChargePos:CreateAddFText(""..PX2_LM_APP:V("SetChargerPosFront"))
    manykit_uiProcessBtn(btnSetChargePos)

    local btnRemove = UIButton:New("BtnAddPosRemove")
	frame:AttachChild(btnRemove)
	btnRemove:LLY(-1.0)
	btnRemove:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnRemove:SetAnchorHor(0.5, 0.5)
    btnRemove:SetAnchorParamHor(g_manykit._wBtn*0.5 + 5, g_manykit._wBtn*0.5 + 5)
	btnRemove:SetAnchorVer(0.0, 0.0)
	btnRemove:SetAnchorParamVer(60.0, 60.0)
	local fText = btnRemove:CreateAddFText(""..PX2_LM_APP:V("Remove"))
    btnRemove:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessBtn(btnRemove)

    local btnUpdate = UIButton:New("BtnAddPosUpdate")
	frame:AttachChild(btnUpdate)
	btnUpdate:LLY(-1.0)
	btnUpdate:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnUpdate:SetAnchorHor(0.5, 0.5)
    btnUpdate:SetAnchorParamHor(g_manykit._wBtn*1.5 + 10, g_manykit._wBtn*1.5 + 10)
	btnUpdate:SetAnchorVer(0.0, 0.0)
	btnUpdate:SetAnchorParamVer(60.0, 60.0)
	local fText = btnUpdate:CreateAddFText(""..PX2_LM_APP:V("UpdatePos"))
    btnUpdate:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessBtn(btnUpdate)

	local btnOK = UIButton:New("BtnAddPosOK")
	frame:AttachChild(btnOK)
	btnOK:LLY(-1.0)
	btnOK:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnOK:SetAnchorHor(0.5, 0.5)
    btnOK:SetAnchorParamHor(g_manykit._wBtn*2.5 + 15, g_manykit._wBtn*2.5 + 15)
	btnOK:SetAnchorVer(0.0, 0.0)
	btnOK:SetAnchorParamVer(60.0, 60.0)
    manykit_uiProcessBtn(btnOK)
	local fText = btnOK:CreateAddFText(""..PX2_LM_APP:V("Add"))
    btnOK:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessBtn(btnOK)

    local btnGo = UIButton:New("BtnGoTarget")
	frame:AttachChild(btnGo)
	btnGo:LLY(-1.0)
	btnGo:SetSize(g_manykit._hBtn, g_manykit._hBtn)
	btnGo:SetAnchorHor(0.5, 0.5)
    btnGo:SetAnchorParamHor(g_manykit._wBtn*3 + g_manykit._hBtn*0.5 + 20, g_manykit._wBtn*3 + g_manykit._hBtn*0.5 + 20)
	btnGo:SetAnchorVer(0.0, 0.0)
	btnGo:SetAnchorParamVer(60.0, 60.0)
    manykit_uiProcessBtn(btnGo)
	local fText = btnGo:CreateAddFText(""..PX2_LM_APP:V("Go"))
    btnGo:SetScriptHandler("_UICallback", self._scriptControl)

    local sightCheck = UICheckButton:New("CheckButtonSight")
    frame:AttachChild(sightCheck)
	sightCheck:LLY(-1.0)
	sightCheck:SetAnchorHor(0.5, 0.5)
    sightCheck:SetAnchorParamHor(g_manykit._wBtn*3 + g_manykit._hBtn*1.5 + 25, g_manykit._wBtn*3 + g_manykit._hBtn*1.5 + 25)
	sightCheck:SetAnchorVer(0.0, 0.0)
	sightCheck:SetAnchorParamVer(60.0, 60.0)
    sightCheck:SetSize(g_manykit._hBtn, g_manykit._hBtn)
    local fText = sightCheck:CreateAddFText(""..PX2_LM_APP:V("Patrol"))
    fText:GetText():SetFontColor(Float3.BLACK)
    sightCheck:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessCheck(sightCheck)

    if p_robot._g_sceneInst then
        local roboAgent = p_robot._g_sceneInst._roboAgent
        if roboAgent then
            roboAgent:LoadPoses()
        end
    end

    self:_refreshTargetPos()
end
-------------------------------------------------------------------------------
function p_robotpath:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

    local roboAgent = p_robot._g_sceneInst._roboAgent

    if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)
    elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

        if "BtnAddPosOK"==name then
            local text = self._editBoxAddPos:GetText()
            if ""~=text then
                local changed = roboAgent:AddCurTargetPos(text)
                if changed then
                    PX2_GH:SendGeneralEvent("updatedtargetpos")
                end
            end
        elseif "BtnAddPosUpdate"==name then
            local text = self._editBoxAddPos:GetText()
            if ""~=text then
                local changed = roboAgent:UpdateCurTargetPos(text)
                if changed then
                    PX2_GH:SendGeneralEvent("updatedtargetpos")
                end
            end
        elseif "BtnAddPosRemove"==name then
            local item = self._listPos:GetSelectedItem()
            if item then
                local name = item:GetUserDataString("name")
                if ""~=name then
                    local changed = roboAgent:RemoveTargetPos(name)
                    if changed then
                        PX2_GH:SendGeneralEvent("updatedtargetpos")
                    end
                end
            end
        elseif "BtnSetChargePosFront"==name then
            local pos = roboAgent:GetPosition()
            roboAgent:SetChargerPosFront(pos)

            local dir = roboAgent:GetDirection()
            
            local sidePos = pos - dir * 1.0
            roboAgent:SetChargerPos(sidePos)

            PX2_GH:SendGeneralEvent("updatedtargetpos")
        elseif "BtnGoTarget"==name then
            local item = self._listPos:GetSelectedItem()
            if item then
                local name = item:GetUserDataString("name")
                if ""~=name then
                    roboAgent:GoTargetPos(name)
                end
            end
        end
    elseif UICT_RELEASED_NOTPICK==callType then
        PX2_GH:PlayNormal(obj)
    elseif UICT_CHECKED==callType then
        if "CheckButtonSight"==name then
            p_robot._g_sceneInst._isdowaypatrol = true
            p_robot._g_sceneInst._indexwaypoint = 0
            p_robot._g_sceneInst:_gotargetpoints()
        end
    elseif UICT_DISCHECKED==callType then
        if "CheckButtonSight"==name then
            p_robot._g_sceneInst._isdowaypatrol = false
        end
    end
end
-------------------------------------------------------------------------------
function p_robotpath:_refreshTargetPos()
    if p_robot._g_sceneInst then
        local roboAgent = p_robot._g_sceneInst._roboAgent
        if roboAgent then
            roboAgent:SavePoses()

            self._listPos:RemoveAllItems()
            local numPos = roboAgent:GetNumTargetPosList()
            for i=0, numPos-1 do
                local na = roboAgent:GetTargetListName(i)
                local pos = roboAgent:GetTargetListPos(i)

                local txt = na..":"..StringHelp:FloatToString(pos:X())..","..StringHelp:FloatToString(pos:Y())..","..StringHelp:FloatToString(pos:Z())
                local item = self._listPos:AddItem(txt)
                item:SetUserDataString("name", na)
            end

            local posC = roboAgent:GetChargerPosFront()
            local txtC = PX2_LM_APP:V("ChargerPosFront")..":"..StringHelp:FloatToString(posC:X())..","..StringHelp:FloatToString(posC:Y())..","..StringHelp:FloatToString(posC:Z())
            self._textChargetPos:GetText():SetText(txtC)

            local posCS = roboAgent:GetChargerPos()
            local txtCS = PX2_LM_APP:V("ChargerPos")..":"..StringHelp:FloatToString(posCS:X())..","..StringHelp:FloatToString(posCS:Y())..","..StringHelp:FloatToString(posCS:Z())
            self._textChargePosSide:GetText():SetText(txtCS)
        end
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_robotpath)
-------------------------------------------------------------------------------