-- p_splash.lua

p_splash = class(p_ctrl,
{
    _requires = {"p_robot", },

	_name = "p_splash",

    _ContentFrame = nil,
})
-------------------------------------------------------------------------------
function p_splash:OnAttached()
    PX2_LM_APP:AddItem(self._name, "Splash", "欢迎")

	p_ctrl.OnAttached(self)
    print(self._name.." p_splash:OnAttached")

    local splash = ""
    local startproject = g_manykit._startProject
    if startproject then
        splash = startproject.splash
    end

    if ""~=splash then
        self:_CreateContentFrame(splash)
    end
end
-------------------------------------------------------------------------------
function p_splash:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_splash:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_splash:OnPPlay()
	print(self._name.." p_splash:OnPPlay")
end
-------------------------------------------------------------------------------
-- ui call back
function p_splash:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

    if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)
    elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)
    elseif UICT_RELEASED_NOTPICK==callType then
        PX2_GH:PlayNormal(obj)
    end
end
-------------------------------------------------------------------------------
-- ui
function p_splash:_CreateContentFrame(splash)
    print(self._name.." p_splash:_CreateContentFrame")

    local frame = UIFrame:New()
    g_manykit._frameRoot:AttachChild(frame)
    frame:LLY(-100.0)
    self._ContentFrame = frame
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
    local pic = frame:CreateAddBackgroundPicBox(true)
    pic:SetTexture(splash)
    pic:UseAlphaBlend(true)

    local ctrlPlay = InterpCurveUniformScaleController:New("ScaleCtrlSmall")
    frame:AttachController(ctrlPlay)
    ctrlPlay:Clear()
    ctrlPlay:AddPoint(0.0, 8.0, ICM_LINEAR)
    ctrlPlay:AddPoint(0.4, 1.1, ICM_LINEAR)
    ctrlPlay:AddPoint(4.8, 1.0, ICM_LINEAR)
	ctrlPlay:ResetPlay()

    local ctrlAlpha = InterpCurveAlphaController:New("ScaleCtrlAlpha")
    frame:AttachController(ctrlAlpha)
    ctrlAlpha:Clear()
    ctrlAlpha:AddPoint(0.0, 1.0, ICM_LINEAR)
    ctrlAlpha:AddPoint(4.8, 1.0, ICM_LINEAR)
    ctrlAlpha:AddPoint(5.5, 0.0, ICM_LINEAR)
	ctrlAlpha:ResetPlay()

    frame:ResetPlay()

    return frame
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_splash)
-------------------------------------------------------------------------------