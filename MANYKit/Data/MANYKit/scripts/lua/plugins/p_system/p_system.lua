-- p_system.lua

p_system = class(p_ctrl,
{
	_name = "p_system",

    -- ui
    _frameContent = nil,
    _propertyGridInfo = nil,

    _screenW = 1,
    _screenH = 2,
})

function p_system:OnAttached()
	PX2_LM_APP:AddItem(self._name, "System", "系统")
    PX2_LM_APP:AddItem("System", "System", "系统")
    PX2_LM_APP:AddItem("Log", "Log", "日志")
    PX2_LM_APP:AddItem("ScreenSize", "ScreenSize", "屏幕大小")

    PX2_LM_APP:AddItem("Spatial", "Spatial", "空间")
    PX2_LM_APP:AddItem("CamPos", "CamPos", "相机位置")
    PX2_LM_APP:AddItem("CamDir", "CamDir", "相机旋转")
    PX2_LM_APP:AddItem("HandPos", "HandPos", "手势位置")
    PX2_LM_APP:AddItem("HandDir", "HandDir", "手势朝向")

	p_ctrl.OnAttached(self)
	print(self._name.." p_system:OnAttached")

    self:_CreateContentFrame()
end

function p_system:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_system:OnInitUpdate")
end

function p_system:OnPPlay()
	print(self._name.." p_system:OnPPlay")
end

function p_system:OnFixUpdate()
	local t = self._dt
end

function p_system:OnPluginInstanceSelected(act)
	print(self._name.." p_system:OnPluginInstanceSelected")
    if act then print("1") else print("0") end

    p_ctrl.OnPluginInstanceSelected(self, act)

    if act then
        self:_RegistOnPropertyInfo()
    end
end

function p_system:_Cleanup()
	print(self._name.." p_system:_Cleanup")
end

-------------------------------------------------------------------------------
 
function p_system:_CreateContentFrame()
	print(self._name.." p_system:_CreateContentFrame")

    local frame = UIFrame:New()
    self._frameContent = frame
    self._frame:AttachChild(frame)
    frame:LLY(-5)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
	local back = frame:CreateAddBackgroundPicBox(true, Float3(0.0, 0.0, 0.0))
    back:UseAlphaBlend(true)
    back:SetAlpha(0.65)

    local frameTable = UITabFrame:New("TabFrameInfo")
    frame:AttachChild(frameTable)
    frameTable:AddTab("system", ""..PX2_LM_APP:V("System"), self:_CreateFrameInfo())
    --frameTable:AddTab("log", ""..PX2_LM_APP:V("Log"), self:_CreateFrameLog())
    frameTable:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessTable(frameTable)
    frameTable:SetActiveTab("system")
end

function p_system:_CreateFrameInfo()
    local frame = UIFrame:New()
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    local pg = UIPropertyGrid:New("PropertyGridInfo")
    self._propertyGridInfo = pg
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

function p_system:_RegistOnPropertyInfo()
    print(self._name.." p_system:_RegistOnPropertyInfo")

    self._scriptControl:RemoveProperties("System")

    self._scriptControl:BeginPropertyCata("System")

    -- window
    self._scriptControl:AddPropertyClass("Window", "窗口")

    local sc = PX2_GH:GetMainWindow():GetScreenSize()
    self._scriptControl:AddPropertySize("ScreenSize", ""..PX2_LM_APP:V("ScreenSize"), sc, false, true)

    local isFS = PX2_GH:GetMainWindow():IsFullScreen()
    self._scriptControl:AddPropertyBool("ScreenFull", "全屏", isFS, true, true)

    -- local sz = PX2_GH:GetMainWindow():GetWindowSize()
    -- self._screenW = sz.Width
    -- self._screenH = sz.Height
    
    PX2Table2Vector({ "1920", "1136", "640", "852", "480", "640"})
    local vec = PX2_GH:Vec()
    PX2Table2Vector({ "1920", "1136", "640", "852", "480", "640"})
    local vec1 = PX2_GH:Vec()
    PX2Table2Vector({})
    local vec2 = PX2_GH:Vec()
    self._scriptControl:AddPropertyEnumUserData("WindowWidth", "窗口宽", self._screenW, vec, vec1, vec2, true, true)
    self._scriptControl:AddPropertyEnumUserData("WindowHeight", "窗口高", self._screenH, vec, vec1, vec2, true, true)
    self._scriptControl:AddPropertyButton("ChangeWindow", "应用窗口宽高")

    local isSSWS = PX2_PROJ:IsSizeSameWithScreen()
    self._scriptControl:AddPropertyBool("IsSizeSameWithScreen", "项目窗口大小一致", isSSWS, true, true)

    local psize = PX2_PROJ:GetSize()
    self._scriptControl:AddPropertyFloat("ProjectWidth", "项目宽", psize.Width, false, false)
    self._scriptControl:AddPropertyFloat("ProjectHeight", "项目高", psize.Height, false, false)

    -- spatial
    self._scriptControl:AddPropertyClass("Spatial", "空间")
    local pos = PX2_GH:GetAVRPos()
    self._scriptControl:AddPropertyAPoint("CamPos", ""..PX2_LM_APP:V("CamPos"), pos, false, true)
    local dir = PX2_GH:GetAVRDirection()
    self._scriptControl:AddPropertyAVector("CamDir", ""..PX2_LM_APP:V("CamDir"), dir, false, true)
    local hPos = PX2_GH:GetSpatialPos()
    self._scriptControl:AddPropertyAPoint("HandPos", ""..PX2_LM_APP:V("HandPos"), hPos, false, true)

    self._scriptControl:AddPropertyClass("SystemInfo", "信息")
    self._scriptControl:AddPropertyInt("EngineServerTCPPort", "引擎服务器TCP端口", 9907, false, true)
    self._scriptControl:AddPropertyInt("EngineServerUDPPort", "引擎服务器UDP端口", 9908, false, true)
    self._scriptControl:AddPropertyInt("EngineServerUDPPortEditor", "引擎编辑器服务器UDP端口", 9909, false, true)
    self._scriptControl:AddPropertyInt("AppServerTCPPort", "AppServerTCP端口", 28186, false, true)
    self._scriptControl:AddPropertyInt("AppServerUDPPort", "AppServerUDP端口", 11140, false, true)
    self._scriptControl:AddPropertyInt("AppServerHttpPort", "AppServerHttp端口", 6606, false, true)

    self._scriptControl:AddPropertyInt("CameraMJPEGServerPort", "摄像头MJPEGServer", 8802, false, true)
    self._scriptControl:AddPropertyInt("ScreenMJPEGServerPort", "屏幕MJPEGServer ", 8803, false, true)
    self._scriptControl:AddPropertyInt("CameraMediaServerPort", "摄像头MediaServer ", 8554, false, true)
    self._scriptControl:AddPropertyInt("ScreenMediaServerPort", "屏幕MediaServer", 8654, false, true)

    self._scriptControl:AddPropertyInt("MinnaTCP", "MinnaTCP端口", 9812, false, true)
    self._scriptControl:AddPropertyInt("MinnaHttp", "MinnaHttp端口", 6700, false, true)
    self._scriptControl:AddPropertyInt("MKTCP", "MKTCP端口", 9801, false, true)

    self._scriptControl:EndPropertyCata()

    self._propertyGridInfo:RegistOnObject(self._scriptControl, "System")
end

function p_system:_CreateFrameLog()
    local frame = UIFrame:New()
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    local list = UIList:New()
    frame:AttachChild(list)
    list:LLY(-1.0)
    list:SetAnchorHor(0.0, 1.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamHor(20.0, -20.0)
    list:SetAnchorParamVer(20.0, -20.0)
    list:SetNumMaxItems(50)
    manykit_uiProcessList(list)

    return frame
end

function p_system:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

	if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)

	elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

    elseif UICT_PROPERTY_CHANGED==callType then
        print("UICT_PROPERTY_CHANGED "..name)
        if "PropertyGridInfo"==name then
            local pObj = obj:GetPorpertyObject()
            print("obj.Name:"..pObj.Name)

            if "ChangeWindow"==pObj.Name then
                self:_ChangeScreen()
            elseif "ChangeProject"==pObj.Name then
                self:_ChangeProject()
            elseif "ScreenFull"==pObj.Name then
                local sf = pObj:PBool()
                self:_SetWindowFull(sf)
            elseif "IsSizeSameWithScreen"==pObj.Name then
                local sf = pObj:PBool()
                PX2_PROJ:SetSizeSameWithScreen(sf)
                PX2_GH:GetMainWindow():SetWindowDoReSize()
            end
        end
    end
end

function p_system:_ChangeScreen()
    print(self._name.." p_system:_ChangeScreen")

	local sw = self._scriptControl:PEnumData2("WindowWidth")
	local sh = self._scriptControl:PEnumData2("WindowHeight")
    print("sw:"..sw)
    print("sh:"..sh)

    if not PX2_GH:GetMainWindow():IsFullScreen() then
        PX2_GH:GetMainWindow():SetWindowSize(Sizef(sw, sh))
    end
end

function p_system:_SetWindowFull(fs)
    print(self._name.." p_system:_SetWindowFull")
    print_i_b(fs)

    PX2_GH:GetMainWindow():SetFullScreen(fs)
end

-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_system)
-------------------------------------------------------------------------------