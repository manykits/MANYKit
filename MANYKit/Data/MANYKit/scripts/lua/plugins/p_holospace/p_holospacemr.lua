-- p_holospacemr.lua

-------------------------------------------------------------------------------
function p_holospace:_ChangeTo2D3D(is3d)
    print(self._name.." p_holospace:_ChangeTo2D3D")
    print_i_b(is3d)

    g_manykit._isUI3DMode = is3d

    self:_Update3DMR()

    if g_manykit._isUI3DMode then
        if g_manykit._canvasSceneUINode then
            local scene = PX2_PROJ:GetScene()
            local terrain = scene:GetTerrain()
            if PX2_GH:IsHololens() then                
            else
                local cameraNodeRoot = scene:GetMainCameraNodeRoot()
                local camNodeRootPos = cameraNodeRoot.LocalTransform:GetTranslate()
                local cameraNode = scene:GetMainCameraNode()
                local camera = cameraNode:GetCamera()
                local dir = camera:GetDVector()
                local pos = camNodeRootPos + dir * 3.0
    
                local dir1 = AVector(-dir:X(), -dir:Y(), -dir:Z())
                local right = dir1:UnitCross(AVector.UNIT_Z)
                
                if terrain then
                    local h = terrain:GetHeight(pos:X(), pos:Y())
                    pos:SetZ(h+1.0)
                end
                g_manykit._canvasSceneUINode.LocalTransform:SetTranslate(pos)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_ChangeToMR(mr)
    print(self._name.." p_holospace:_ChangeToMR")
    print_i_b(mr)

    g_manykit._isMRMode = mr
    
    self:_Update3DMR()
end
-------------------------------------------------------------------------------
function p_holospace:_AdjustCameraMR()
    print(self._name.." p_mworld:_AdjustCameraMR")

    if g_manykit._systemControlMode==1 then
        local ui = PX2_PROJ:GetUI()
        local frameLeft = ui:GetFrameLeft()
        local frameRight = ui:GetFrameRight()

        local camObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
        local eyeParam0 = camObj:GetEyeParam(0)
        local eyeParam1 = camObj:GetEyeParam(1)
        print("eyeParam0:"..eyeParam0:ToString(8))
        print("eyeParam1:"..eyeParam1:ToString(8))

        local eyeRotDegree0 = camObj:GetEyeRotDegree(0)
        local eyeRotDegree1 = camObj:GetEyeRotDegree(1)
        print("eyeRotDegree0:"..eyeRotDegree0:ToString(8))
        print("eyeRotDegree1:"..eyeRotDegree1:ToString(8))

        local eyeTrans0 = camObj:GetEyeTrans(0)
        local eyeTrans1 = camObj:GetEyeTrans(1)
        print("eyeTrans0:"..eyeTrans0:ToString(8))
        print("eyeTrans1:"..eyeTrans1:ToString(8))

        local ts = g_manykit._slamEyeTransScale

        local scene = PX2_PROJ:GetScene()
        local cameraNode = scene:GetMainCameraNode()
        cameraNode.LocalTransform:MakeIdentity()
        cameraNode.LocalTransform:SetRotateDegree(APoint(-eyeRotDegree0:X(), -eyeRotDegree0:Z(), -eyeRotDegree0:Y()))
        cameraNode.LocalTransform:SetTranslate(APoint(eyeTrans0:X()*ts, eyeTrans0:Z()*ts, eyeTrans0:Y()*ts))

        local camera = cameraNode:GetCamera()
        camera:SetFrustumBeCV(true)
        camera:SetFrustumCV(eyeParam0:X(), eyeParam0:Y(), eyeParam0:Z(), eyeParam0:W(), g_manykit._mrCameraScreenWidth, g_manykit._mrCameraScreenHeight + 18, 0.1, 1000)

        local cameraNodeRight = scene:GetCameraNodeRight()
        if cameraNodeRight then
            cameraNodeRight.LocalTransform:MakeIdentity()
            cameraNodeRight.LocalTransform:SetRotateDegree(APoint(-eyeRotDegree1:X(), -eyeRotDegree1:Z(), -eyeRotDegree1:Y()))
            cameraNodeRight.LocalTransform:SetTranslate(APoint(eyeTrans1:X()*ts, eyeTrans1:Z()*ts, eyeTrans1:Y()*ts))

            local cameraRight = cameraNodeRight:GetCamera()
            cameraRight:SetFrustumBeCV(true)
            cameraRight:SetFrustumCV(eyeParam1:X(), eyeParam1:Y(), eyeParam1:Z(), eyeParam1:W(), g_manykit._mrCameraScreenWidth, g_manykit._mrCameraScreenHeight + 18, 0.1, 1000)
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_Update3DMR()
    local ui = PX2_PROJ:GetUI()
    local scene = PX2_PROJ:GetScene()
    local nodeRootOut = scene:GetNodeRootOut()
    local cameraNodeRoot = scene:GetMainCameraNodeRoot()

    local nodeCameraLeft = scene:GetMainCameraNode()
    nodeCameraLeft:GetCamera():SetViewPortSizeNode(nil)

    local nodeCameraRight = scene:GetObjectByName("CameraNodeRight")
    if nodeCameraRight then
        if g_manykit._canvasSceneUI then
            g_manykit._canvasSceneUI:RemoveCamera(nodeCameraRight:GetCamera())
        end          
        nodeCameraRight:DetachFromParent()
        scene:SetCameraNodeRight(nil)
    end

    local canvasSceneUINodeO = nodeRootOut:GetObjectByName("CanvasSceneUINode")
    local canvasSceneUINode = Cast:ToNode(canvasSceneUINodeO)
    if canvasSceneUINode then
        canvasSceneUINode:DetachFromParent()
    end

    if g_manykit._isUI3DMode then
        local canvasSceneUINode = Node:New("CanvasSceneUINode")
        g_manykit._canvasSceneUINode = canvasSceneUINode
        PX2_PROJ:PoolSet("CanvasSceneUINode", canvasSceneUINode)
        nodeRootOut:AttachChild(canvasSceneUINode)
        canvasSceneUINode.LocalTransform:SetTranslate(APoint(0.0, 1.5, 0.96))
        canvasSceneUINode:SetOnlyShowUpdate(true)

        local canvasSceneUINode1 = Node:New("CanvasSceneUINode1")
        g_manykit._canvasSceneUINode1 = canvasSceneUINode1
        canvasSceneUINode:AttachChild(canvasSceneUINode1)
        canvasSceneUINode1.LocalTransform:SetTranslate(APoint(0.0, 0.0, 0.0))

        local bdCanvasSceneUI = BillboardNode:New("BDCanvasSceneUI")
        g_manykit._bdCanvasSceneUI = bdCanvasSceneUI
        canvasSceneUINode1:AttachChild(bdCanvasSceneUI)
        bdCanvasSceneUI:AlignTo(cameraNodeRoot)
        bdCanvasSceneUI:SetAlignType(BillboardNode.BAT_Z)
        bdCanvasSceneUI:Enable(true)

        local canvasSceneUI = Canvas:New("CanvasSceneUI")
        g_manykit._canvasSceneUI = canvasSceneUI
        bdCanvasSceneUI:AttachChild(canvasSceneUI)
        canvasSceneUI:GetCanvasRenderBind():SetRenderLayer(Renderable.RL_UI)
        canvasSceneUI.Culling = Movable.CULL_NEVER
        canvasSceneUI:SetNoCameraDoDraw(false)
        canvasSceneUI.LocalTransform:SetUniformScale(0.003)
        canvasSceneUI:Set3D(true)
        canvasSceneUI:SetSize(1136.0, 640.0)
        canvasSceneUI:EnableAnchorLayout(false)
        canvasSceneUI:EnableScreenRectLayout(false)
        canvasSceneUI:AddCamera(nodeCameraLeft:GetCamera())
        canvasSceneUI:SetClearFlag(false, false, false)
        canvasSceneUI:SetScreenRectSameWithEngineCanvas(true)
        canvasSceneUI:SetSortType(Canvas.ST_LLY)
        canvasSceneUI:GetCanvasRenderBind():SetCastShadow(false)
        canvasSceneUI:GetCanvasRenderBind():SetRenderStyle(Movable.RS_LIGHTING, false)
        canvasSceneUI:Set3DPickInfluenceScene(true)
        PX2_ENGINESCENECANVAS:AddPickCanvas3D(canvasSceneUI)

        local fPicBox = UIFPicBox:New("UIFPicBoxPickMovable")
        canvasSceneUI:SetPickMovable(fPicBox)
        fPicBox:GetUIPicBox():SetName("PicBoxPickMovable")
        fPicBox:SetAnchorHor(0.0, 1.0)
        fPicBox:SetAnchorVer(0.0, 1.0)
        fPicBox:Show(false, false)
        fPicBox:SetDoPick(true)
        fPicBox:GetUIPicBox():SetID(101)
        PX2_ENGINESCENECANVAS:AddPickerOnlyCareID(101)

        local sfctrl = StringFollowController:New("FollowController")
        g_manykit._followCtrl = sfctrl
        canvasSceneUINode:AttachController(sfctrl)
        sfctrl:SetFollower(canvasSceneUINode)
        sfctrl:SetTarget(cameraNodeRoot)
        sfctrl:SetStringForceParam(70.0)
        sfctrl:SetResistance(30.0)
        sfctrl:SetFollowerTargetType(StringFollowController.FTT_DEGREE_ZSAME)
        sfctrl:SetFollowerTargetDegree(0.0)
        sfctrl:SetFollowerDirToTarget(AVector(0.0, 1.0, 0.0))
        sfctrl:SetDistance(4.0)
        sfctrl:ResetPlay()

        self:_UI3DFollow(g_manykit._isUI3DFollow)

        -- ui
        g_manykit._frameRoot:DetachFromParent()
        canvasSceneUI:AttachChild(g_manykit._frameRoot)
        ui:SetUIMode(UI.UIM_NORMAL)
        g_manykit._frameRoot:SetAnchorHor(0.0, 1.0)

        -- give 2 cameras
        if g_manykit._isMRMode then      
            ui:GetFrameLeft():SetAnchorHor(0.0, 0.5)
            
            local nodeCameraLeft = scene:GetMainCameraNode()
            nodeCameraLeft:RegistToScriptSystem()
            nodeCameraLeft:SetName("CameraNodeLeft")
            nodeCameraLeft:GetCamera():SetName("CameraLeft")
            nodeCameraLeft:GetCamera():SetClearFlag(false, false, false)
            nodeCameraLeft:GetCamera():SetFrustumBeCV(false)
            nodeCameraLeft:GetCamera():SetViewPortSizeNode(ui:GetFrameLeft())

            nodeCameraLeft.LocalTransform:SetTranslate(APoint(-0.06, 0.0, 0.0))
            cameraNodeRoot:AttachChild(nodeCameraLeft)
            scene:SetMainCameraNodeRoot(cameraNodeRoot, nodeCameraLeft)

            local nodeCameraRight = PX2_CREATER:CreateNode_Camera()
            nodeCameraRight:RegistToScriptSystem()
            nodeCameraRight:SetName("CameraNodeRight")
            nodeCameraRight:GetCamera():SetName("CameraRight")
            nodeCameraRight:GetCamera():SetClearFlag(false, false, false)
            nodeCameraRight:GetCamera():SetFrustumBeCV(false)
            nodeCameraRight:GetCamera():SetViewPortSizeNode(ui:GetFrameRight())

            nodeCameraRight.LocalTransform:SetTranslate(APoint(0.06, 0.0, 0.0))
            cameraNodeRoot:AttachChild(nodeCameraRight)
            scene:SetCameraNodeRight(nodeCameraRight)

            canvasSceneUI:AddCamera(nodeCameraRight:GetCamera())
        else
            ui:GetFrameLeft():SetAnchorHor(0.0, 1.0)

            local nodeCameraLeft = scene:GetMainCameraNode()
            nodeCameraLeft.LocalTransform:SetTranslate(APoint(0.0, 0.0, 0.0))
        end
    else
        -- ui
        g_manykit._frameRoot:DetachFromParent()
        ui:AttachChild(g_manykit._frameRoot)

        if g_manykit._isMRMode then
            ui:SetUIMode(UI.UIM_VR)
            g_manykit._frameRoot:SetAnchorHor(0.0, 0.5)
        else
            ui:SetUIMode(UI.UIM_NORMAL)
            g_manykit._frameRoot:SetAnchorHor(0.0, 1.0)
        end

        -- clear
        g_manykit._followCtrl = nil
        g_manykit._canvasSceneUI = nil
        g_manykit._canvasSceneUINode = nil
        g_manykit._canvasSceneUINode1 = nil
        g_manykit._bdCanvasSceneUI = nil

        -- give 2 cameras
        if g_manykit._isMRMode then    
            ui:GetFrameLeft():SetAnchorHor(0.0, 0.5)
            
            local nodeCameraLeft = scene:GetMainCameraNode()
            nodeCameraLeft:RegistToScriptSystem()
            nodeCameraLeft:SetName("CameraNodeLeft")
            nodeCameraLeft:GetCamera():SetName("CameraLeft")
            nodeCameraLeft:GetCamera():SetClearFlag(false, false, false)
            nodeCameraLeft:GetCamera():SetViewPortSizeNode(ui:GetFrameLeft())
            nodeCameraLeft.LocalTransform:SetTranslate(APoint(-0.06, 0.0, 0.0))
            cameraNodeRoot:AttachChild(nodeCameraLeft)
            scene:SetMainCameraNodeRoot(cameraNodeRoot, nodeCameraLeft)
   
            local nodeCameraRight = PX2_CREATER:CreateNode_Camera()
            nodeCameraRight:RegistToScriptSystem()
            nodeCameraRight:SetName("CameraNodeRight")
            nodeCameraRight:GetCamera():SetName("CameraRight")
            nodeCameraRight:GetCamera():SetClearFlag(false, false, false)
            nodeCameraRight:GetCamera():SetViewPortSizeNode(ui:GetFrameRight())
            nodeCameraRight.LocalTransform:SetTranslate(APoint(0.06, 0.0, 0.0))
            cameraNodeRoot:AttachChild(nodeCameraRight)
            scene:SetCameraNodeRight(nodeCameraRight)
        else
            ui:GetFrameLeft():SetAnchorHor(0.0, 1.0)

            local nodeCameraLeft = scene:GetMainCameraNode()
            nodeCameraLeft.LocalTransform:SetTranslate(APoint(0.0, 0.0, 0.0))
        end
    end

    self:_AdjustCameraMR()
end
-------------------------------------------------------------------------------
function p_holospace:_UI3DFollow(f)
    print(self._name.." p_holospace:_UI3DFollow")
    print_i_b(f)

    g_manykit._isUI3DFollow = f
    if f then
        if g_manykit._followCtrl then
            g_manykit._followCtrl:ResetPlay()
        end
        if g_manykit._bdCanvasSceneUI then
            g_manykit._bdCanvasSceneUI:Enable(true)
        end
        PX2_PROJ:SetConfig("ui3dfollow", "1")
    else
        if g_manykit._followCtrl then
            g_manykit._followCtrl:Pause()
        end
        if g_manykit._bdCanvasSceneUI then
            g_manykit._bdCanvasSceneUI:Enable(false)
        end
        PX2_PROJ:SetConfig("ui3dfollow", "0")
    end

    PX2_GH:SendGeneralEvent("UI3DFollowChanged")
end
-------------------------------------------------------------------------------
function p_holospace:_ToggleUI3DFollowShow()
    if g_manykit._isUI3DMode then  
        if g_manykit._canvasSceneUINode then
            if g_manykit._canvasSceneUINode:IsShow() then
                self:_UI3DFollow(not g_manykit._isUI3DFollow)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_ToggleSceneUINodeShow()
    if g_manykit._canvasSceneUINode then
        g_manykit._canvasSceneUINode:Show(not g_manykit._canvasSceneUINode:IsShow() )
    end

    PX2_GH:SendGeneralEvent("SceneUINodeShowChanged")
end
-------------------------------------------------------------------------------
function p_holospace:_Refresh3DFollowParam()
    if g_manykit._followCtrl then
        g_manykit._followCtrl:SetStringForceParam(g_manykit._3DUIFollowStringForceParam)
        g_manykit._followCtrl:SetResistance(g_manykit._3DUIFollowResistance)
        g_manykit._followCtrl:SetDistance(g_manykit._3DUIFollowDistance)
    end
end
-------------------------------------------------------------------------------