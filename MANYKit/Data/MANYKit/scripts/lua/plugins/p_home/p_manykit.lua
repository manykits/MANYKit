---- p_manykit.lua

p_manykit = class(p_ctrl,
{
	_name = "p_manykit",

	_requires = {},
	
	-- UI 控件
	_webFrame = nil,
})
-------------------------------------------------------------------------------
function p_manykit:OnAttached()
	PX2_LM_APP:AddItem(self._name, "MANYKit", "MANYKit")
	
	print(self._name.." p_manykit:OnAttached")

	p_ctrl.OnAttached(self)

	self:_CreateContentFrame()
end
-------------------------------------------------------------------------------
function p_manykit:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_manykit:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_manykit:_Cleanup()
	print(self._name.." p_manykit:_Cleanup")
	PX2_OPENCVM:SetScriptCallback("", nil)
end

function p_manykit:OnPPlay()
	print(self._name.." p_manykit:OnPPlay")
end
-------------------------------------------------------------------------------
function p_manykit:OnPUpdate()
	local secs = PX2_APP:GetElapsedSecondsWidthSpeed()
end
-------------------------------------------------------------------------------
function p_manykit:_CreateContentFrame()
	print(self._name.." p_manykit:_CreateContentFrame")

	local frame = UIFrame:New()
    self._frame:AttachChild(frame)
	frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

	-- 创建网页控件（默认隐藏）
	if nil~=UIFrameCEF then
        local fmanykit = UIFrameCEF:New("UIFrameCEFManykit")
        self._webFrame = fmanykit
        frame:AttachChild(fmanykit)
        fmanykit:LLY(-2.0)
        fmanykit:SetAnchorHor(0.0, 1.0)
        fmanykit:SetAnchorVer(0.0, 1.0)
        fmanykit:SetURL("http://manykit.com")
    end

	self._scriptControl:ResetPlay()
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_manykit)
-------------------------------------------------------------------------------