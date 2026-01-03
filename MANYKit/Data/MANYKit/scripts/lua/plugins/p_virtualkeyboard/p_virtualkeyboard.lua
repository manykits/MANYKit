-- p_virtualkeyboard.lua

p_virtualkeyboard = class(p_ctrl,
{
	_name = "p_virtualkeyboard",

	_propertyGridEdit = nil,
    _iscapslock = false,
    _btncaps = nil,
})

function p_virtualkeyboard:OnAttached()
	PX2_LM_APP:AddItem(self._name, "VirtualKeyboard", "虚拟键盘")

	p_ctrl.OnAttached(self)
	print(self._name.." p_virtualkeyboard:OnAttached")

	self:_CreateContentFrame()

    local vb = self:_CreateVirtualBoard()

    local platType = PX2_APP:GetPlatformType()
    if Application.PLT_UWP == platType then
        if g_manykit._systemControlMode == 1 then
            PX2_GH:SetVirtualKeyBoard(vb)
        end
    end
    
    g_manykit._frameRoot:AttachChild(vb)
    vb:LLY(-500.0)
    vb:SetAnchorHor(0.0, 1.0)
    vb:SetAnchorVer(0.0, 0.0)
    vb:SetPivot(0.5, 0.0)
    vb:Show(false)
    vb:SetOnlyShowUpdate(true)

    RegistEventObjectFunction("UIES::UICT_EDITBOX_ATTACHWITHIME", self, function(myself)
        local vk = PX2_GH:GetVirtualKeyBoard()
        if vk then
            vk:Show(true)
        end
    end)
    RegistEventObjectFunction("UIES::UICT_EDITBOX_DETACHWITHIME", self, function(myself)
    end)
end

function p_virtualkeyboard:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_virtualkeyboard:OnInitUpdate")

	self:_RegistPropertyOnSetting()
end

function p_virtualkeyboard:_Cleanup()
	print(self._name.." p_virtualkeyboard:_Cleanup")
end

function p_virtualkeyboard:OnPPlay()
	print(self._name.." p_virtualkeyboard:OnPPlay")
end

function p_virtualkeyboard:OnPUpdate()
	--print(self._name.." p_virtualkeyboard:OnPUpdate")
	self:_OnPUpdate()
end

-------------------------------------------------------------------------------

function p_virtualkeyboard:_CreateContentFrame()
	print(self._name.." p_virtualkeyboard:_CreateContentFrame")

	local frame = UIFrame:New()
    self._frame:AttachChild(frame)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

	self._scriptControl:ResetPlay()
end

function p_virtualkeyboard:_CreateVirtualBoard()
    local frameBack = UIFrame:New()
    frameBack:SetWidget(true)
    frameBack:SetHeight(300.0)

    local frame = UIFrame:New()
    frameBack:AttachChild(frame)
    frame:SetWidth(660.0)
    frame:SetAnchorVer(0.0, 1.0)

    local bs = 60.0
    local v = -bs * 0.5

    local txts = {"0","1","2","3","4","5","6","7","8","9","."}
    local f = self:_CreateKeyboardLine(bs, txts)
    frame:AttachChild(f)
    f:SetAnchorVer(1.0, 1.0)
    f:SetAnchorParamVer(v, v)

    v = v - bs
    local txts = {"A","B","C","D","E","F","G"}
    local fa = self:_CreateKeyboardLine(bs, txts)
    frame:AttachChild(fa)
    fa:SetAnchorVer(1.0, 1.0)
    fa:SetAnchorParamVer(v, v)

    v = v - bs
    local txts = {"H","I","J","K","L","M","N"}
    local fb = self:_CreateKeyboardLine(bs, txts)
    frame:AttachChild(fb)
    fb:SetAnchorVer(1.0, 1.0)
    fb:SetAnchorParamVer(v, v)

    v = v - bs
    local txts = {"O","P","Q","R","S","T"}
    local fo = self:_CreateKeyboardLine(bs, txts)
    frame:AttachChild(fo)
    fo:SetAnchorVer(1.0, 1.0)
    fo:SetAnchorParamVer(v, v)

    v = v - bs
    local txts = {"U","V","W","X","Y","Z", "SPACE", "BACK", "ENTER", "CAPS", "CLOSE"}
    local fu = self:_CreateKeyboardLine(bs, txts)
    frame:AttachChild(fu)
    fu:SetAnchorVer(1.0, 1.0)
    fu:SetAnchorParamVer(v, v)

    return frameBack
end

function p_virtualkeyboard:_CreateKeyboardLine(bs, txts)
    local frame = UIFrame:New()
    frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetHeight(bs)
    --frame:CreateAddBackgroundPicBox(true, Float3(1.0, 0.0, 0.0))

    local i = 0
    for key, value in pairs(txts) do
        local hor = bs*0.5 + bs*i
        i = i + 1

        local btn = UIButton:New(value)
        frame:AttachChild(btn)
        btn:LLY(-2.0)
        btn:CreateAddFText(value)
        btn:SetAnchorHor(0.0, 0.0)
        btn:SetAnchorVer(0.5, 0.5)
        btn:SetSize(bs-6.0, bs-6.0)
        btn:SetAnchorParamHor(hor, hor)
        btn:SetAnchorParamVer(0.0, 0.0)
        btn:SetScriptHandler("_UIIMECallback", self._scriptControl)

        if value=="CAPS" then
            self._btncaps = btn
        end
    end

    return frame
end

function p_virtualkeyboard:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

	if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)

	elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

	elseif UICT_RELEASED_NOTPICK == callType then
        PX2_GH:PlayNormal(obj)

	elseif UICT_PROPERTY_CHANGED==callType then
        print("UICT_PROPERTY_CHANGED "..name)
        if "PropertyGridEdit"==name then
            local pObj = obj:GetPorpertyObject()
            print("obj.Name:"..pObj.Name)
		end
	end
end

function p_virtualkeyboard:_UIIMECallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

	if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)

	elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

        local na = obj:GetName()
        if "ENTER"==na then
            local vk = PX2_GH:GetVirtualKeyBoard()
            if vk then
                PX2_IME:DispathInsertText("\n", 1)
                vk:Show(false)
            end
        elseif "SPACE"==na then
            PX2_IME:DispathInsertText(" ", 1)
        elseif "CAPS"==na then
            self._iscapslock = not self._iscapslock
            if self._iscapslock then
                self._btncaps:SetBrightness(2.0)
            else
                self._btncaps:SetBrightness(1.0)
            end
        elseif "BACK"==na then
            PX2_IME:DispathDeleteBackward()
        elseif "CLOSE"==na then
            local vk = PX2_GH:GetVirtualKeyBoard()
            if vk then
                PX2_IME:DispathInsertText("\n", 1)
                vk:Show(false)
            end
        else
            if self._iscapslock then
                PX2_IME:DispathInsertText(na, 1)
            else
                local nalower = StringHelp:ToLower(na)
                PX2_IME:DispathInsertText(nalower, 1)
            end
        end
        print("na:"..na)
	elseif UICT_RELEASED_NOTPICK == callType then
        PX2_GH:PlayNormal(obj)
    end
end

function p_virtualkeyboard:_RegistPropertyOnSetting()
	self._scriptControl:RemoveProperties("EditSetting")
    self._scriptControl:BeginPropertyCata("EditSetting")
    self._scriptControl:AddPropertyClass("Setting", "设置")

    self._scriptControl:EndPropertyCata()

    --self._propertyGridEdit:RegistOnObject(self._scriptControl, "EditSetting")
end

function p_virtualkeyboard:_OnPUpdate()

end

-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_virtualkeyboard)
-------------------------------------------------------------------------------