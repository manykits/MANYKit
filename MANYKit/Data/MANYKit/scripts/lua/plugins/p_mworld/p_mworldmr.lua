-- p_mworldmr.lua

-------------------------------------------------------------------------------
function p_mworld:_CreateMRObjects()
    local scene = PX2_PROJ:GetScene()
    local cameraNodeRoot = scene:GetMainCameraNodeRoot()

    local nodeHelp = scene:GetObjectByID(p_holospace._g_IDNodeHelp)
    if nodeHelp then
        local nodeHand = Node:New()
        nodeHelp:AttachChild(nodeHand)
        nodeHand:SetDoPick(false)
        g_manykit._nodeHandsRoot = nodeHand

        for i=0, 1, 1 do
            local hand = Node:New()
            nodeHand:AttachChild(hand)

            if 0==i then
                g_manykit._nodeHandLeft = nodeHand
            elseif 1==i then
                g_manykit._nodeHandRight = nodeHand
            end

            for i=0, 19, 1 do
                local box = PX2_CREATER:CreateMovable_Box("engine/white.png")
                hand:AttachChild(box)
                box.LocalTransform:SetUniformScale(0.008)
                box:SetID(i)  

                if i==4 or 8 ==i then
                    local s = Float4(1, 1, 1, 1.0)
                    local bk = Float4(1, 0, 0, 1.0)

                    local propData = PropertySetData()
                    propData.DoSetShine = true
                    propData.ShineEmissive = s
                    propData.ShineAmbient = bk
                    propData.ShineDiffuse = bk
                    PX2_GH:SetObjectMtlProperty(box, propData)
                end
            end
        end

        local nodeAprilTag = Node:New()
        g_manykit._nodeAprilTag = nodeAprilTag
        nodeHelp:AttachChild(nodeAprilTag)
        nodeAprilTag:SetDoPick(false)

        local box = PX2_CREATER:CreateMovable_Box()
        g_manykit._nodeAprilTagBox0 = box
        nodeAprilTag:AttachChild(box)
        box.LocalTransform:SetUniformScale(0.01)

        local box1 = PX2_CREATER:CreateMovable_Box()
        g_manykit._nodeAprilTagBox1 = box1
        nodeAprilTag:AttachChild(box1)
        box1.LocalTransform:SetUniformScale(0.01)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateSlamHelpObjects()
    print(self._name.." p_mworld:_CreateSlamHelpObjects")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local nodeHelp = scene:GetObjectByID(p_holospace._g_IDNodeHelp)
        if nodeHelp then
            for i=0, 2, 1 do
                local cmtlD = CMtlData()

                cmtlD.IsShadowMap = true
                cmtlD.IsNormalMap = false
                cmtlD.IsPBR = true
                
                local mtln = "wall"
                if 0==i then
                    mtln = "wall"
                elseif 1==i then
                    mtln = "rusted_iron"
                elseif 2==i then
                    mtln = "gold"
                end

                cmtlD.ImageBase = "engine/pbr/"..mtln.."/albedo.png"
                cmtlD.ImageNormal = "engine/pbr/"..mtln.."/normal.png"
                cmtlD.ImageMetallic = "engine/pbr/"..mtln.."/metallic.png"
                cmtlD.ImageRoughness = "engine/pbr/"..mtln.."/roughness.png"
                cmtlD.ImageAO = "engine/pbr/"..mtln.."/ao.png"
                cmtlD.IsDoSetShine = true
                cmtlD:GetShine().Ambient = Float4(1,1,1,1)
                cmtlD:GetShine().Diffuse = Float4(1,1,1,1)
                cmtlD:GetShine().Specular = Float4(0,0,0,1)

                local x = -10 + 10*i

                local box = PX2_CREATER:CreateMovable_BoxPieces(cmtlD)
                nodeHelp:AttachChild(box)
                box.LocalTransform:SetTranslate(APoint(x, 0, 10.0))

                if 0==i then
                    g_manykit._boxVSlam = box
                elseif 1==i then
                    g_manykit._boxIMU = box
                elseif 2==i then
                    g_manykit._boxSlam = box
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_SandBox(use, setsky)
    print(self._name.." p_mworld:_SandBox")
    print_i_b(use)

    g_manykit._isInSandBox = use

    local scene = PX2_PROJ:GetScene()
    if scene then
        local nodeRoot = scene:GetNodeRoot()
        local skyObj = scene:GetObjectByID(p_holospace._g_IDNodeSky)
        local skyMov = Cast:ToMovable(skyObj)

        if g_manykit._isInSandBox then
            if nodeRoot then
                nodeRoot.LocalTransform:SetUniformScale(self._sandBoxScale)
                nodeRoot.LocalTransform:SetTranslate(APoint(self._sandBoxPosX, self._sandBoxPosY, self._sandBoxPosZ))
                nodeRoot.LocalTransform:SetRotateDegree(0.0, 0.0, self._sandBoxRot)
            end
            if skyMov and setsky then
                skyMov:Show(false)
            end 
        else
            if nodeRoot then
                nodeRoot.LocalTransform:SetUniformScale(1.0)
                nodeRoot.LocalTransform:SetTranslate(APoint(0, 0, 0))
                nodeRoot.LocalTransform:SetRotateDegree(0, 0, 0)
            end
            if skyMov and setsky  then
                skyMov:Show(true)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameHot()
    print(self._name.." p_mworld:_CreateCameraHot")

    local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-40, -40, "")
    btnClose:SetName("BtnHotClose")
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    local fPicBoxHot = UIFPicBox:New()
    g_manykit._fPicBoxHot = fPicBoxHot
    uiFrame:AttachChild(fPicBoxHot)
    fPicBoxHot:GetUIPicBox():SetTexture("engine/black.png")
    fPicBoxHot:LLY(-1)
    fPicBoxHot:SetAnchorHor(0.0, 1.0)
    fPicBoxHot:SetAnchorVer(0.0, 1.0)

    return uiFrameBack, uiFrame
end
-------------------------------------------------------------------------------
function p_mworld:_UseCameraHot(use)
    print(self._name.." p_mworld:_UseCameraHot")
    print_i_b(use)

    g_manykit._isUseCameraHot = use

    if use then
        PX2_GH:SendGeneralEvent("hotcamera", "1")
    else
        PX2_GH:SendGeneralEvent("hotcamera", "0")
    end

    if self._frameHot then
        self._frameHot:Show(use)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateCameraIP()
    print(self._name.." p_mworld:_CreateCameraIP")

    local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-40, -40, "")
    btnClose:SetName("BtnCameraIPClose")
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    local fPicBoxCameraIP = UIFPicBox:New()
    g_manykit._fPicBoxCameraIP = fPicBoxCameraIP
    uiFrame:AttachChild(fPicBoxCameraIP)
    fPicBoxCameraIP:GetUIPicBox():SetTexture("engine/black.png")
    fPicBoxCameraIP:LLY(-1)
    fPicBoxCameraIP:SetAnchorHor(0.0, 1.0)
    fPicBoxCameraIP:SetAnchorVer(0.0, 1.0)

    -- local frameVLC = UIFrameVLC:New("UIFrameVLC")
    -- g_manykit._frameVLCCameraIP = frameVLC
    -- uiFrame:AttachChild(frameVLC)
    -- frameVLC:LLY(-2.0)
    -- frameVLC:SetAnchorHor(0.0, 1.0)
    -- frameVLC:SetAnchorVer(0.0, 1.0)

    return uiFrameBack, uiFrame
end
-------------------------------------------------------------------------------
function p_mworld:_UseCameraIP(use)
    print(self._name.." p_mworld:_UseCameraIP")
    print_i_b(use)

    g_manykit._isUseCameraIP = use

    self._frameCameraIP:Show(use)

    if use then
        PX2_GH:SendGeneralEvent("ipcamera", "1")
    else
        PX2_GH:SendGeneralEvent("ipcamera", "0")
    end

    -- if use then
    --     g_manykit._frameVLCCameraIP:StartVLC("http://192.168.6.56:8080/")
    -- else
    --     g_manykit._frameVLCCameraIP:StopVLC()
    -- end
end
-------------------------------------------------------------------------------
function p_mworld:_HandGestureChange(ht, gesture)
    local hpos = PX2_INPUTM:GetHandPosion(ht, 8)

    local scene = PX2_PROJ:GetScene()
    local mainActor = scene:GetMainActor()
    if mainActor then
        local mainID = mainActor:GetID()

        if "OK"==gesture then
            self:_HandCatch(mainID, ht, hpos)
        elseif "None"==gesture or "Palm"==gesture then
            self:_HandDrop()
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_HandDrop()
    print("p_mworld:_HandDrop")

    if self._currentCatchObjectID > 0 then
        self:_OnDisSelectObj(true)
        p_net._g_net:_RequestTranslateObj(self._currentCatchObjectID, false, true, self._curmapid)

        self._currentCatchObjectID = 0
        self._handTypeCatch = 0
    end
end
-------------------------------------------------------------------------------
function p_mworld:_HandCatch(byid, handtype, handPos)
    print("p_mworld:_HandCatch")

    local scene = PX2_PROJ:GetScene()
    local nodeRoot = scene:GetNodeRoot()

    if self._handTypeCatch==handtype then
        return
    end

    self._currentCatchObjectByID = byid
    self._handTypeCatch = handtype
    local catchActor = scene:GetActorFromMap(byid)
    
    if catchActor then
        local hpos = handPos
        local uniScale = nodeRoot.WorldTransform:GetUniformScale()
        if 1.0~=uniScale then
            --local transInverse = nodeRoot.WorldTransform:InverseTransform()
            --hpos = transInverse * handPos
        end

        local b = Bound()
        b:SetCenter(hpos)
        b:SetRadius(0.05)
    
        if self._currentCatchObjectID > 0 then
        else
            local numActors = scene:CalGetNumActors()
            for i=0, numActors-1, 1 do 
                local act = scene:GetActor(i)
                local idi = act:GetID()
        
                if act~=catchActor then
                    local nodeRoot = act:GetNodeRoot()
                    local mp = nodeRoot:GetObjectByID(p_actor._g_idModelPick)
                    local mpMov = Cast:ToMovable(mp)
                    if mpMov then
                        local worldBound = mpMov.WorldBound
                        if b:TestIntersection(worldBound) then
                            self:_TrySelectObj(idi, false)
                            self._currentCatchObjectID = idi
                        end
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------