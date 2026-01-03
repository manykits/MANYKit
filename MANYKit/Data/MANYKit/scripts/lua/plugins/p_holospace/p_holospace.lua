-- p_holospace.lua

p_holospace = class(p_ctrl,
{
    _g_holospace = nil,

    _requires = {"p_net"},

	_name = "p_holospace",

    -- scene ids
    _g_IDNodeActor = 100011,
    _g_IDNodeActorAIOT = 100012,
    _g_IDNodeObject = 100013,
    _g_IDNodeTerrain = 100014,
    _g_IDActorTerrain = 100015,
    _g_IDNodeSky = 100016,
    _g_IDNodeWeather = 100017,	
    _g_IDNodeHelp = 100018,
    _g_IDNodePath = 100019,
    _g_IDVoxel = 100020,
    _g_IDActorVoxel = 100021,

    -- ui
    _frameContent = nil,

    -- touch
    _g_mouse_x = 0.5,
    _g_mouse_y = 0.5,
    _g_wRecParent = Rectf(0,0,0,0),
    _g_mTag = 0,

    _isPressed = false,
    _isLeftPressed = false,
    _isRightPressed = false,
    _isMoved = false,
    _moveDeltaLengthAll = 0.0,
    _curPickPos = APoint(0.0, 0.0, 0.0),
    _lastPickPos = APoint(0.0, 0.0, 0.0),

    _g_RenderStyle = Movable.RS_LIGHTING,

    -- terrain
    _terrain = nil,
    _isTerrainHeightCreatedOK = false,

    -- weather
    _nodeWeather = nil,

    -- effect
    _nodeEffect = nil,

    -- camera
    _g_skyDefaultScale = 600.0,
    _g_cameraFov = 45.0,
    _g_cameraFovAim = 40.0,
    _g_cameraIsAiming = false,
	
    _g_cameraNear = 10,
    _g_cameraFar = 10000.0,

    _g_cameraNear_Small = 0.1,
    _g_cameraFar_Small = 2000.0,
    _g_cameraPlayCtrl = nil,
    _g_cameraPlayCtrl_SmallMap = nil,

    _g_beforeTargetPos = APoint(0,0,0),
    _g_beforeDistance = 0.0,
    _g_beforeHor = 0.0,
    _g_beforeVer = 0.0,
    _g_beforeDistMin = 0.0,
    _g_beforeDistMax = 0.0,
    _g_beforeOffset = APoint(0.0, 0.0, 0.0),

    -- nodeCtrl
    _g_curSceneNodeCtrl = nil,
    _g_curSceneNodeCtrlEnableRot = true,
    _g_curSceneNodeCtrlPath = nil,
    _aimobj = nil,

    _axisBoxNode = nil,
    _axisBox = nil,
    _axisDirStart = AVector(0.0, 1.0, 0.0),

    -- callback
    _pickCallbacks = {},

    -- cfg
    _g_viewdist_objects = 0.0,
    _g_viewdist_objects_lod = 0.0,

    _g_renderStyle = 0,
})

function p_holospace:OnAttached()

	p_holospace._g_holospace = self

	PX2_LM_APP:AddItem(self._name, "HoloSpace", "Holo空间")

	p_ctrl.OnAttached(self)
	print(self._name.." p_holospace:OnAttached")

    self:_CreateContentFrame()

    -- load defs
    PX2_SDM:ReLoadAllDefs("MANYKit")

    self:_CreateScene()
    self:_SetRenderStyle(p_holospace._g_renderStyle)
end

function p_holospace:OnPluginTreeInstanceAfterAttached()
	print(self._name.." p_holospace:OnPluginTreeInstanceAfterAttached")

    if 1==g_manykit._systemControlMode then
        -- defalut not use 3D
        self:_ChangeTo2D3D(false)

        self:_UI3DFollow(false)
    else
        self:_ChangeTo2D3D(false)
        self:_UI3DFollow(false)
    end

    if g_manykit._systemControlMode==1 then
        local strisfull = PX2_PROJ:GetConfig("isfullscreen")
        g_manykit._isFullScreen = true
        --PX2_GH:GetMainWindow():SetFullScreen(g_manykit._isFullScreen)

        self:_ChangeToMR(true)
    end

    RegistEventObjectFunction("InputEventSpace::KeyReleased", self, function(myself, keyStr)
        if "KC_G" == keyStr then
            if not UIEditBox:IsHasAttachedIME() then
                local scene = PX2_PROJ:GetScene()
                if scene then
                    local ter = scene:GetTerrain()
                    if ter then
                        ter:Show(not ter:IsShow())
                    end
                end
            end
        elseif "KC_F"==keyStr then
            if not UIEditBox:IsHasAttachedIME() then
                if g_manykit._isPressed_Ctrl then
                else
                    myself:_ToggleUI3DFollowShow()
                end
            end
        elseif "KC_HOME"==keyStr or "KC_H"==keyStr then
            if not UIEditBox:IsHasAttachedIME() then
                myself:_ToggleSceneUINodeShow()
            end
        elseif "KC_J"==keyStr then
            if not UIEditBox:IsHasAttachedIME() then
                myself:_ChangeTo2D3D(not g_manykit._isUI3DMode)

                coroutine.wrap(function()
                    if g_manykit._bdCanvasSceneUI then
                        g_manykit._bdCanvasSceneUI:Enable(true)
                    end
                    sleep(1.0)
                    if g_manykit._bdCanvasSceneUI then
                        g_manykit._bdCanvasSceneUI:Enable(false)
                    end
                end)()
            end
        elseif "KC_K"==keyStr then
            if not UIEditBox:IsHasAttachedIME() then
                myself:_ChangeToMR(not g_manykit._isMRMode)
            end
        elseif "KC_5" == keyStr then 
            if not UIEditBox:IsHasAttachedIME() then
                self:_AdjustCameraMR()
            end
        end
    end)


    RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
        if "RenderStyle"==str then
            local rm = StringHelp:SToI(str1)
            myself:_SetRenderStyle(rm)
        end
    end)
end

function p_holospace:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_holospace:OnInitUpdate")
end

function p_holospace:OnPPlay()
	print(self._name.." p_holospace:OnPPlay")
end

function p_holospace:OnUpdate()
    local scene = PX2_PROJ:GetScene()
	if scene then
        -- update mr translate
        self:_UpdateMRTransUWP()

        -- ctrl adjust
        local camDist = p_holospace._g_cameraPlayCtrl:GetCameraDistance()
        --print("camDist:"..camDist)
        local camAdj = camDist
        local camAdjMove = camDist
        local platType = PX2_APP:GetPlatformType()
        if Application.PLT_LINUX == platType then 
            camAdj = camAdj * 0.01
            camAdjMove = camAdjMove * 0.001
        else 
            camAdj = camAdj * 0.001
            camAdjMove = camAdjMove * 0.001
        end
        if camAdj<0.01 then
            camAdj = 0.01
        end
        if camAdjMove<0.001 then
            camAdjMove = 0.001
        end

        p_holospace._g_cameraPlayCtrl:SetRotationAdjust(0.1 * g_manykit._mouseHorAdjust_r, 0.1 * g_manykit._mouseVerAdjust_r)
        p_holospace._g_cameraPlayCtrl:SetScaleAdjust(camAdj * g_manykit._mouseWheelAdjust)
        p_holospace._g_cameraPlayCtrl:SetTranslateAdjust(camAdjMove * g_manykit._mouseHorAdjust, camAdjMove * g_manykit._mouseVerAdjust)
	
        local rw = PX2_GH:GetMainWindow()
        rw:SetDragAdjust(g_manykit._mouseHorDragAdjust, g_manykit._mouseVerDragAdjust)
    end
end

function p_holospace:OnFixUpdate()
	local t = self._dt

    PX2_EDIT.IsCtrlDown = g_manykit._isPressed_Ctrl
    PX2_EDIT.IsShiftDown = g_manykit._isPressed_Shift

    local scene = PX2_PROJ:GetScene()
    if scene then
        local camera = scene:GetMainCameraNode():GetCamera()

        if p_holospace._g_curSceneNodeCtrl then
            local fobj = PX2_SELECTM_D:GetFirstObject()
            local act = Cast:ToActor(fobj)
            if act then
                local agent = act:GetAIAgent()
                if agent then
                    local isDrag = p_holospace._g_curSceneNodeCtrl:IsDragNone()
                    agent:Enable(isDrag)
                end
            end

            p_holospace._g_curSceneNodeCtrl:UpdateCtrlTrans(camera)
        end 


        if p_holospace._g_curSceneNodeCtrlPath then
            p_holospace._g_curSceneNodeCtrlPath:UpdateCtrlTrans(camera)
        end   
        
        local actorMain = scene:GetMainActor()
        local actorMe = scene:GetMeActor()
        local mainCameraNodeRoot = scene:GetMainCameraNodeRoot()
        local pos = mainCameraNodeRoot.LocalTransform:GetTranslate()
        local wPos = mainCameraNodeRoot.WorldTransform:GetTranslate()
        local wPos1 = APoint(wPos:X(), wPos:Y(), wPos:Z() + 0.5)
        if self._nodeWeather then
            self._nodeWeather.WorldTransform:SetTranslate(wPos1)
        end

		local terrain = scene:GetTerrain()
		if terrain then
            if terrain:IsDoDebug() then
                terrain:SetActorMovable(actorMe)
            else
                terrain:SetActorMovable(actorMain)
            end
            terrain:SetViewLocalPos(wPos)
		end
    end

    -- local avrPos = PX2_GH:GetAVRPos()
    -- local avrD = PX2_GH:GetAVRDirection()
    -- if g_manykit._canvasSceneUI and self._axisBoxNode then
    --     local pickMovbale = g_manykit._canvasSceneUI:GetPickMovable()
    --     if pickMovbale then
    --         local picker = Picker()
    --         picker:Execute(pickMovbale, avrPos, avrD, 0.0, Mathf.MAX_REAL)
    --         local picRec = picker:GetClosestNonnegative()
    --         if picRec.Intersected then
    --             self._axisBoxNode:Show(true)
    --         else
    --             self._axisBoxNode:Show(false)
    --         end
    --     end
    -- end

    self:_RefreshNodePlayCtrlRot()
    self:_AdjustCameraFov()

    -- wsadq,1,3,e,xcz
    if scene then
        local ter = scene:GetTerrain()
        if ter then
            local dh = p_holospace._g_cameraPlayCtrl:GetDegreeHor()
            local dv = p_holospace._g_cameraPlayCtrl:GetDegreeVer()
    
            local lookDegreeSend = APoint(-dv, 0.0, dh)
            local nodeCamera = p_holospace._g_cameraPlayCtrl:GetNode()
            if nodeCamera then
                local wpos = nodeCamera.LocalTransform:GetTranslate()
    
                local lon = ter:WTLon(wpos:X())
                local lat = ter:WTLat(wpos:Y())
                local posH = wpos:Z() + ter:GetHeightMinNotZero()
    
                local ret = {}
                ret.lng = lon
                ret.lat = lat
                ret.alt = posH
                ret.heading = lookDegreeSend:Z()
                ret.pitch = lookDegreeSend:X()
    
                if PCEFPlugin then
                    local retstr = PX2JSon.encode(ret)
                    PCEFPlugin:SetGlobal("gcp", retstr)

                    local keystr = PX2JSon.encode(g_manykit._keyState)
                    --print("keystr:"..keystr)
                    PCEFPlugin:SetGlobal("ks", keystr)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-- update
function p_holospace:_RefreshNodePlayCtrlRot()
    local rot = true
	local isCanvas3DPicking = PX2_ENGINESCENECANVAS:IsPickCanvas3DPicking()
	local isPickCanvas3DPressing = PX2_ENGINESCENECANVAS:IsPickCanvas3DPressing()
	if isCanvas3DPicking then
        if isPickCanvas3DPressing then
            rot = false	
        end
	end

    local scene = PX2_PROJ:GetScene()
    if p_holospace._g_curSceneNodeCtrl then
        local numObjects = PX2_SELECTM_D:GetNumObjects()
        if numObjects > 0 then
            if rot then
                if scene then
                    local dt = p_holospace._g_curSceneNodeCtrl:GetDragType()
                    rot = 0==dt
                else
                    rot = false
                end
            end
        end
    end

    if p_holospace._g_curSceneNodeCtrlPath then
        if rot then
            if scene then
                local dt = p_holospace._g_curSceneNodeCtrlPath:GetDragType()
                rot = 0==dt
            else
                rot = false
            end
        end
    end

    if PX2_EDIT:GetTerrainEdit():IsEditEnabled() then
        if PX2_EDIT.IsCtrlDown then
            rot = false
        end
    end

    if false==p_holospace._g_curSceneNodeCtrlEnableRot then
        rot = false
    end    
    p_holospace._g_cameraPlayCtrl:EnableRot(rot)
end
function p_holospace:_AdjustCameraFov()
    local scene = PX2_PROJ:GetScene()
    local cameraNode =  scene:GetMainCameraNode()
    local camera = cameraNode:GetCamera()
    local isOpenCV = camera:IsFrustumBeCV()

    if not isOpenCV then
        self:_AdjustCameraFov1(camera)

        local cameraNodeRight = scene:GetCameraNodeRight()
        if cameraNodeRight then
            local cameraRight = cameraNodeRight:GetCamera()
            self:_AdjustCameraFov1(cameraRight)
        end
    end
end
function p_holospace:_AdjustCameraFov1(camera)
    local scene = PX2_PROJ:GetScene()
    local sz = PX2_ENGINESCENECANVAS:GetSize()
    local szWOH = sz.Width/sz.Height

    if camera then
        local dmax = camera:GetDMax()
        local sizeNode = camera:GetViewPortSizeNode()
        if sizeNode then
            local sz1 = sizeNode:GetSize()
            szWOH = sz1.Width/sz1.Height
        end

        local camDistance = p_holospace._g_cameraPlayCtrl:GetCameraDistance()
        local learpParam = (camDistance-p_holospace._g_cameraNear_Small)/5000.0
        if learpParam>1.0 then
            learpParam = 1.0
        end
        local near = p_holospace._g_cameraNear_Small + (p_holospace._g_cameraNear - p_holospace._g_cameraNear_Small)*learpParam
        local far = p_holospace._g_cameraFar_Small + (p_holospace._g_cameraFar - p_holospace._g_cameraFar_Small)*learpParam

        -- print("_defaultViewDistanceMax:"..g_manykit._defaultViewDistanceMax)
        -- print("camDistance:"..camDistance)
        -- print("learpParam:"..learpParam)
        -- print("near:"..near)
        -- print("far:"..far)

        local usefov = p_holospace._g_cameraFov
        if p_holospace._g_cameraIsAiming then
            usefov = p_holospace._g_cameraFovAim
        else
            usefov = p_holospace._g_cameraFov
        end
        camera:SetFrustum(usefov, szWOH, near, far)
    end
end
function p_holospace:_UpdateMRTransUWP()
    local platType = PX2_APP:GetPlatformType()
    if Application.PLT_UWP==platType then
        local avrPos = PX2_GH:GetAVRPos()
        local avrD = PX2_GH:GetAVRDirection()
        local avrU = PX2_GH:GetAVRUp()
        local avrR = PX2_GH:GetAVRRight()

        local sp = PX2_GH:GetSpatialPos()
        local spl = PX2_GH:GetSpatialLocalPos()

        if self._axisBoxNode then
            self._axisBoxNode.LocalTransform:SetScale(APoint(0.01, 10.0, 0.01))
            self._axisBoxNode.LocalTransform:SetDU(avrD, avrU)
            self._axisBoxNode.LocalTransform:SetTranslate(APoint(avrPos:X(), avrPos:Y(), avrPos:Z()+0.1))
        end
    end
end
-------------------------------------------------------------------------------
-- ui
function p_holospace:_CreateContentFrame()
	print(self._name.." p_holospace:_CreateContentFrame")

    local frame = UIFrame:New()
    self._frameContent = frame
    self._frame:AttachChild(frame)
    frame:LLY(-5)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    if g_manykit._frameTouch then
        g_manykit._frameTouch:SetScriptHandlerWidgetPicked("_HoloSpaceTouch", self._scriptControl)
    end
end

-- rendering
function p_holospace:_SetRenderStyle(rs)
    print(self._name.." p_holospace:_SetRenderStyle:"..rs)

    p_holospace._g_renderStyle = rs

    local scene = PX2_PROJ:GetScene()
    if scene then
        local terrain = scene:GetTerrain()
        if terrain then
            local rsTer = 0
            
            rsTer = p_holospace._g_renderStyle
            if rsTer==3 then
                rsTer=2
            end

            terrain:SetRenderStyle(rsTer, true)
        end

        local vs = scene:GetVoxelSection()
        if vs then
            vs:SetRenderStyle(rs, true)
        end        

        local envirParam = scene:GetEnvirParamController()
        envirParam:SetUseShadowMap(rs~=0)

		local numActors = scene:CalGetNumActors()
		for i=0, numActors-1, 1 do 
            local act = scene:GetActor(i)
            if act then
                local model = act:GetModel()
                if model then
                    model:SetRenderStyle(rs, true)
                end
            end
		end
    end
end

-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_holospace)
-------------------------------------------------------------------------------