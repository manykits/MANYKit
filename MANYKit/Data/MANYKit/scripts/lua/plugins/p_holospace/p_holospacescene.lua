-- p_holospacescene.lua

-- scene
-------------------------------------------------------------------------------
function p_holospace:_CreateScene()
    print("p_holospace:_CreateScene")

    if 0 == g_manykit._lessfullmode then
        p_holospace._g_renderStyle = Movable.RS_LIGHTING
    end

    -- scene
    local scene = Scene:New("Scene")
    scene:SetID(0)
    scene:ResetPlay()
    PX2_PROJ:PoolSet("Scene", scene)
    PX2_APP:SetScene(scene)

    -- ambient control
    local a = 0.3
	local d = 1.0
	local s = 0.0
	local actrl = scene:GetAmbientRegionController()
    actrl:RegistToScriptSystem()
	actrl:SetHorAngle(135.0)
	actrl:SetVerAngle(60.0)
	actrl:SetAmbientColor(Float3(a, a, a))
	actrl:SetDiffuseColor(Float3(d, d, d))
	actrl:SetSpecularColor(Float3(s, s, s))
    actrl:SetLightCameraPerspective(false)
    actrl:SetLightCameraLookDistance(40.0)
    actrl:SetLightCameraDistance(0.1, 400.0)
    actrl:SetLightCameraExtent(40.0)
    actrl:SetShadowMap_OffsetPropertyScale(2.0)
    actrl:SetShadowMap_OffsetPropertyBias(4.0)
    actrl:SetFogParamHeight(Float2(-2000.0, -1900.0))
    actrl:SetFogParamDistance(Float2(6000.0, 8000.0))

    -- env
    local envirParam = scene:GetEnvirParamController()

    -- RM_FORWARD,
    -- RM_DEFERRED,
    if g_manykit._lessfullmode==0 then
        envirParam:SetUseShadowMap(false)
	    envirParam:SetUseBloom(false)
        scene:GetEnvirParamController():SetRenderMode(EnvirParamController.RM_FORWARD)
    else
        scene:GetEnvirParamController():SetRenderMode(EnvirParamController.RM_FORWARD)
        envirParam:SetUseBloom(false)
    end

    -- physics
    scene:GetAIAgentWorld():UsePhysics(g_manykit._isUsePhysics)
    PX2_GH:SetDebugPhysics(false)

    -- nodes
    local nodeRootOut = scene:GetNodeRootOut()
    local nodeRoot = scene:GetNodeRoot()

    local nodeActor = Node:New("NodeActor")
    nodeRoot:AttachChild(nodeActor)
    nodeActor:SetID(p_holospace._g_IDNodeActor)
    nodeActor:RegistToScriptSystem()
    --nodeActor:Show(false)

    local nodeActorBot = Node:New("NodeActorBot")
    nodeRoot:AttachChild(nodeActorBot)
    nodeActorBot:SetID(p_holospace._g_IDNodeActorAIOT)
    nodeActorBot:RegistToScriptSystem()

    local nodeObject = Node:New("NodeObject")
    nodeRoot:AttachChild(nodeObject)
    nodeObject:SetID(p_holospace._g_IDNodeObject)
    nodeObject:RegistToScriptSystem()

    local nodeTerrain = Node:New("NodeTerrain")
    nodeRoot:AttachChild(nodeTerrain)
    nodeTerrain:SetID(p_holospace._g_IDNodeTerrain)
    nodeTerrain:RegistToScriptSystem()

    local nodeSky = Node:New("NodeSkyMK")
    nodeRoot:AttachChild(nodeSky)
    nodeSky:SetID(p_holospace._g_IDNodeSky)
    nodeSky:RegistToScriptSystem()
    nodeSky:SetDoPick(false)

    local nodeWeather = Node:New("NodeWeather")
    nodeRoot:AttachChild(nodeWeather)
    nodeWeather:SetID(p_holospace._g_IDNodeWeather)
    self._nodeWeather = nodeWeather
    nodeWeather.WorldTransformIsCurrent = true
    nodeWeather:RegistToScriptSystem()
    nodeWeather:SetDoPick(false)

    local nodeHelp = Node:New("NodeHelp")
    nodeRootOut:AttachChild(nodeHelp)
    nodeHelp:SetID(p_holospace._g_IDNodeHelp)
    nodeHelp:RegistToScriptSystem()

    --self:_CreatePbrObjects(nodeHelp)

    local nodePath = Node:New("NodePath")
    nodeRoot:AttachChild(nodePath)
    nodePath:SetID(p_holospace._g_IDNodePath)
    nodePath:RegistToScriptSystem()

    local nodeVoxel = Node:New("NodeVoxel")
    nodeRoot:AttachChild(nodeVoxel)
    nodeVoxel:SetID(p_holospace._g_IDVoxel)
    nodeVoxel:RegistToScriptSystem()

    -- camera
    local mainCameraNodeRoot = scene:GetMainCameraNodeRoot()
    local cameraNode = scene:GetMainCameraNode()
    local camera = cameraNode:GetCamera()
    camera:SetFrustum(p_holospace._g_cameraFov, 1.0, p_holospace._g_cameraNear_Small, p_holospace._g_cameraFar_Small)   
    camera:SetClearFlag(false, false, false)

    local camPlayCtrl = PX2_CREATER:CreateNodePlayController()
    p_holospace._g_cameraPlayCtrl = camPlayCtrl
    nodeRoot:AttachController(camPlayCtrl)
    camPlayCtrl:SetPriority(-10.0)
    camPlayCtrl:SetNode(mainCameraNodeRoot)
    camPlayCtrl:SetCameraDist(0.01, g_manykit._defaultViewDistance)
    camPlayCtrl:SetCameraDistance(g_manykit._defaultViewDistance*0.5)
    camPlayCtrl:SetTargetPos(APoint(0.0, 0.0, 0.0))
    camPlayCtrl:SetTouchSizeNode(g_manykit._frameTouch)
    local platType = PX2_APP:GetPlatformType()
    camPlayCtrl:Enable(true)
    camPlayCtrl:ResetPlay()

    -- terrain
    if g_manykit._lessfullmode==0 then
        local actorRect = PX2_CREATER:CreateActorInfinitePlane("engine/white.png", "", 50.0)
        nodeTerrain:AttachChild(actorRect)
    else
        self:_CreateSky(scene)
    end

    -- weather
    self:_CreateWeather(scene)

    -- help
    local sceneNodeCtrl = SceneNodeCtrl:New()
    nodeHelp:AttachChild(sceneNodeCtrl:GetCtrlsGroup())
    p_holospace._g_curSceneNodeCtrl = sceneNodeCtrl
    sceneNodeCtrl:ComeInEventWorld()
    sceneNodeCtrl:GetCtrlsGroup().WorldTransform:SetUniformScale(2.0)
    sceneNodeCtrl:SetSelectionName("Default")
    sceneNodeCtrl:SetCtrlType(SceneNodeCtrl.CT_TRANSLATE)
    sceneNodeCtrl:SetSelectionScene(scene)
    sceneNodeCtrl:Enable(true)

    PX2_SELECTM:CreateAddSelection("PathCtrl")
    local sceneNodeCtrlPath = SceneNodeCtrl:New()
    nodeHelp:AttachChild(sceneNodeCtrlPath:GetCtrlsGroup())
    p_holospace._g_curSceneNodeCtrlPath = sceneNodeCtrlPath
    sceneNodeCtrlPath:ComeInEventWorld()
    sceneNodeCtrlPath:GetCtrlsGroup().WorldTransform:SetUniformScale(2.0)
    sceneNodeCtrlPath:SetSelectionName("PathCtrl")
    sceneNodeCtrlPath:SetCtrlType(SceneNodeCtrl.CT_TRANSLATE)
    sceneNodeCtrlPath:SetSelectionScene(scene)

    local rendableBrush = PX2_EDIT:GetHelpNode()
    nodeHelp:AttachChild(rendableBrush)
    PX2_GH:SetNodeHelp(nodeHelp)

    -- axisbox
    local axisBoxNode = Node:New()
    self._axisBoxNode = axisBoxNode
    nodeHelp:AttachChild(axisBoxNode)
    local axisBox = PX2_CREATER:CreateMovable_Box()
    self._axisBox = axisBox
    self._axisBoxNode:AttachChild(axisBox)
    axisBox.LocalTransform:SetScale(APoint(0.05, 2.0, 0.05))
    axisBox.LocalTransform:SetTranslate(APoint(0.0, 1.0, 0.0))
    axisBoxNode:Show(false, false)
    axisBoxNode:SetDoPick(false)

    RegistEventObjectFunction("InputEventSpace::SpatialDetected", self, function(myself, data)
        print("SpatialDetected")
	end)
    RegistEventObjectFunction("InputEventSpace::SpatialLost", self, function(myself, data)
        print("SpatialLost")
	end)

    return scene
end
-------------------------------------------------------------------------------
function p_holospace:_CreatePbrObjects(nodeHelp)
    -- wall
    local sp = 2.0
    local mtln = "wall"
    for x=0, 4, 1 do 
        for y=0, 3, 1 do
            local cmtlD = CMtlData()
            if 0==y then
                cmtlD.IsShadowMap = true
                cmtlD.IsNormalMap = false
                cmtlD.IsPBR = false
            elseif 1==y then
                cmtlD.IsShadowMap = true
                cmtlD.IsNormalMap = true
                cmtlD.IsPBR = false
            elseif 2==y then
                cmtlD.IsShadowMap = true
                cmtlD.IsNormalMap = false
                cmtlD.IsPBR = true
            elseif 3==y then
                cmtlD.IsShadowMap = true
                cmtlD.IsNormalMap = false
                cmtlD.IsPBR = true
            end

            if 0==x then
                mtln = "wall"
            elseif 1==x then
                mtln = "grass"
            elseif 2==x then
                mtln = "rusted_iron"
            elseif 3==x then
                mtln = "gold"
            elseif 4==x then
                mtln = "plastic"
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

            if 3==y then
                local sph = PX2_CREATER:CreateMovable_Sphere(cmtlD)
                nodeHelp:AttachChild(sph)
                sph.LocalTransform:SetTranslate(APoint(sp*x, sp*y, 10.0))
            else
                local box = PX2_CREATER:CreateMovable_BoxPieces(cmtlD)
                nodeHelp:AttachChild(box)
                box.LocalTransform:SetTranslate(APoint(sp*x, sp*y, 10.0))
            end
        end
    end
    
    --local mov = PX2_CREATER:CreateVolume()
    --nodeHelp:AttachChild(mov)
    --mov.LocalTransform:SetUniformScale(2)
end
-------------------------------------------------------------------------------
function p_holospace:_CreateSky(scene)
    local nodeSky = scene:GetObjectByID(p_holospace._g_IDNodeSky)

    local nsky = scene:CreateSky()
    nodeSky:AttachChild(nsky)
    scene:GetNodeSky():SetDoPick(false)
    local skyMeshO = nsky:GetObjectByName("SkyMesh")
    local skyMesh = Cast:ToSkyMesh(skyMeshO)
    if skyMesh then
        skyMesh:SetSkyParam(Float4(0.5, 1.0, 1.0, 0.0))

        skyMesh:SetCloudRange(Float3(10, 400.0, 300.0))

        skyMesh:SetCloudBaseBright(Float3(1.26, 1.25, 1.29))
        skyMesh:SetCloudBaseDark(Float3(0.61, 0.61, 0.62))
        skyMesh:SetCloudLightBright(Float3(1.29, 1.17, 1.05))
        skyMesh:SetCloudLightDark(Float3(0.7, 0.75, 0.8))

        skyMesh:SetCloudNumStep(32)
        skyMesh:SetCloudStep(4)
        skyMesh:SetCloudSpeed(Float2(0.1, 0.1))
        skyMesh:SetCloudClip(0.55)
    end

    local mapw = scene:PFloat("MapLength")
    local maph = scene:PFloat("MapWidth")
    if mapw<=0.0 then
        mapw = 200.0
     end
    if maph<=0.0 then
        maph = 200.0
    end
end
-------------------------------------------------------------------------------
function p_holospace:_CreateWeather(scene)
    local nodeWeather = scene:GetObjectByID(p_holospace._g_IDNodeWeather)
    if nodeWeather then
        local rainObj = PX2_RM:BlockLoadCopy("common/effects/rain.px2obj")
        local movRain = Cast:ToMovable(rainObj)
        if movRain then
            nodeWeather:AttachChild(movRain)
            movRain:SetName("EffectRain")

            local rain = movRain:GetObjectByName("Rain")
            local pe = Cast:ToParticleEmitter(rain)
            if nil~=pe then
                pe.LocalTransform:SetTranslateY(6.0)
                pe.LocalTransform:SetTranslateZ(2.0)    
                pe:SetMaxNumParticles(2000)
                pe:SetEmitRate(800)
                pe:SetEmitLife(1)
                pe:SetEmitSizeX(1.5)
                pe:SetEmitAlpha(1.0)
                pe:SetEmitSpeed(5.0)
                pe:Pause()
            end

            local soundableRain = movRain:GetObjectByName("SoundableRain")
            local soundableRainMov = Cast:ToMovable(soundableRain)
            if soundableRainMov then
                soundableRainMov:Pause()
            end
        end

        local flashObj = PX2_RM:BlockLoadCopy("common/effects/flash.px2obj")
        local movFlash = Cast:ToMovable(flashObj)
        if movFlash then
            nodeWeather:AttachChild(movFlash)
            movFlash.LocalTransform:SetTranslate(APoint(0.0, 200.0, 100.0))
            movFlash:SetName("EffectFlash")
        end

        local snowObj = PX2_RM:BlockLoadCopy("objects/effect/snow.px2obj")
        local movSnow = Cast:ToMovable(snowObj)
        if nil~=movSnow then   
            nodeWeather:AttachChild(movSnow)
            movSnow:SetName("Snow") 

            local pe = Cast:ToParticleEmitter(movSnow)
            if pe then
                pe.LocalTransform:SetTranslateY(6.0)
                pe.LocalTransform:SetTranslateZ(2.0)
            end
    
            movSnow:Pause()
        end    

        local soundWind = Soundable:New("SoundWind")
        nodeWeather:AttachChild(soundWind)
        soundWind:SetSoundFilename("common/media/audio/windwithgusts.ogg")
        soundWind:SetMinDistance(10000.0)
        soundWind:SetMaxDistance(10000.0)
        soundWind:SetLoop(true)
        soundWind:Pause()
    
        local soundThunder = Soundable:New("SoundThunder")
        nodeWeather:AttachChild(soundThunder)
        soundThunder:AddSoundFilename("common/media/audio/thunder1.wav")
        soundThunder:AddSoundFilename("common/media/audio/thunder2.wav")
        soundThunder:AddSoundFilename("common/media/audio/thunder3.wav")
        soundThunder:AddSoundFilename("common/media/audio/thunder4.wav")
        soundThunder:AddSoundFilename("common/media/audio/thunder5.wav")
        soundThunder:SetRandomSeconds(5.0, 10.0)
        soundThunder:SetRandomVolume(0.5, 1.0)
        soundThunder:SetMinDistance(10000.0)
        soundThunder:SetMaxDistance(10000.0)
        soundThunder:SetLoop(true)
        soundThunder:Pause()
        soundThunder:SetMovableAfterPlay(movFlash)
    end
end
-------------------------------------------------------------------------------