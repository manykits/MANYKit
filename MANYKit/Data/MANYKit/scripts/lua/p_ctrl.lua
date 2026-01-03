-- p_ctrl.lua

p_ctrl = class(LuaScriptController,
{
	_requires = {},
	_requireindex = 1,
	_isTreeInstancePlugin = false,

	_name = "p_ctrl",
	_scriptControl = nil,
	_ctrlable = nil,
	_movable = nil,
	_node = nil,
	_frameback = nil,
	_frame = nil,
	_dt = 0.03,
	_isInstanceSelected = false,
})
-------------------------------------------------------------------------------
function p_ctrl:OnAttached()
	print(self._name.." p_ctrl:OnAttached")

	self:_GetCtrlable()
	self:_CreateFrame()
end
-------------------------------------------------------------------------------
function p_ctrl:OnDetach()
	print(self._name.." p_ctrl:OnDetach")
	
	self:_Cleanup()
end
-------------------------------------------------------------------------------
function p_ctrl:_Cleanup()
	print(self._name.." p_ctrl:_Cleanup")
end
-------------------------------------------------------------------------------
function p_ctrl:_GetCtrlable()
	print(self._name.." p_ctrl:_GetCtrlable")

	self._scriptControl = Cast:ToSC(self.__object)
	self._scriptControl:SetName(self._name)
	self._ctrlable = self._scriptControl:GetControlledable()
	self._movable = Cast:ToMovable(self._ctrlable)
	self._node = Cast:ToNode(self._ctrlable)
	self._sizeNode = Cast:ToSizeNode(self._ctrlable)

	self._ctrlable:RegistToScriptSystem()
end
-------------------------------------------------------------------------------
function p_ctrl:OnInitUpdate()
	print(self._name.." p_ctrl:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_ctrl:OnPPlay()
	print(self._name.." p_ctrl:OnPPlay")
end
-------------------------------------------------------------------------------
function p_ctrl:OnPUpdate()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()
	local appsec = PX2_APP:GetAppSeconds()
end
-------------------------------------------------------------------------------
function p_ctrl:OnFixUpdate()
	local t = self._dt
end
-------------------------------------------------------------------------------
function p_ctrl:_CreateFrame()
	print(self._name.." p_ctrl:_CreateFrame")

	-- create back,frame attack to g_manykit._frameRightCnt

    local frameBack = UIFrame:New(self._name)
    self._frameback = frameBack

    frameBack:SetAnchorHor(0.0, 1.0)
    frameBack:SetAnchorVer(0.0, 1.0)
	frameBack:Show(true)

	local frame = UIFrame:New()
    self._frame = frame
    frameBack:AttachChild(frame)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
    frame:LLY(-1.0)
    frame:SetWidget(true)
    frame:Show(true)
end
-------------------------------------------------------------------------------
function p_ctrl:OnPluginInstanceSelected(act)
	print(self._name.." p_ctrl:OnPluginInstanceSelected")
    if act then print("1") else print("0") end
	self._isInstanceSelected = act
end
-------------------------------------------------------------------------------
function p_ctrl:OnPluginRegisted()
	print(self._name.." p_ctrl:OnPluginRegisted")
end
-------------------------------------------------------------------------------
function p_ctrl:OnPluginPreCreate()
	print(self._name.." p_ctrl:OnPluginPreCreate")
end
-------------------------------------------------------------------------------
function p_ctrl:OnPluginTreeInstanceAfterAttached()
	print(self._name.." p_ctrl:OnPluginTreeInstanceAfterAttached")
end
-------------------------------------------------------------------------------