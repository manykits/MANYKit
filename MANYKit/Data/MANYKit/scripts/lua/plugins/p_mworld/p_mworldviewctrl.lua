-- p_mworldviewctrl.lua

-------------------------------------------------------------------------------
function p_mworld:_ExitCurCtrl()
    print(self._name.." p_mworld:_ExitCurCtrl")

    if self._agentAgentFirstView then
        local id = self._agentAgentFirstView:GetID()

        local tm = self._agentAgentFirstView:GetHumanTakePossessed()
        local usetm = AIAgent.HTPM_NONE
        if tm==AIAgent.HTPM_ALL then
            usetm = AIAgent.HTPM_ALL
        end
        self:_TakeControlOfAgentByID(id, usetm)  
        self:_ThirdViewOfActor(id, g_manykit._defaultViewDistanceThird)  
    end
end
-------------------------------------------------------------------------------
function p_mworld:_UIAim(idstr)
	print(self._name.." p_mworld:_UIAim")
    print("idstr:"..idstr)

    local scene = PX2_PROJ:GetScene()

    local idi = StringHelp:StringToInt(idstr)
    if idi > 0 then
        p_holospace._g_cameraIsAiming = true

        local act = scene:GetActorFromMap(idi)
        if act then
            local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
            if scCtrl then
                local fov = scCtrl:_GetEquippedJuJiFov()
                if fov>0 then
                    p_holospace._g_cameraFovAim = fov
                    self._fPicBoxAim:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/juji.png"))
                    self._fPicBoxAim:SetSize(800.0, 800.0)
                else
                    p_holospace._g_cameraFovAim = 40.0
                    self._fPicBoxAim:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/aim.png"))
                    self._fPicBoxAim:SetSize(50.0, 50.0)
                end
            end
        end
    else
        p_holospace._g_cameraIsAiming = false
        p_holospace._g_cameraFovAim = 40.0
        self._fPicBoxAim:GetUIPicBox():SetTexture(self:_imgpthmworld("ui/aim.png"))
        self._fPicBoxAim:SetSize(50.0, 50.0)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_UITakeCtrlActor(id)	   
    print(self._name.." p_mworld:_UITakeCtrlActor")

    print("iddddddddddddddddddd:"..id)

    if id <= 0 then
        self:_ClearQuickBarItems()
        self:_ClearBagGrid()
        self:_ClearMe()
        self:_ClearFrameBar()

        self._frameQuickBarTopSkill:Show(false)
        self._frameQuickBarLeftItem:Show(false)
        return
    end

    print("iddddddddddddddddddd1:"..id)

    self._frameQuickBarTopSkill:Show(true)    
    self._frameQuickBarTopSkill:DetachAllChildren()

    self._frameQuickBarLeftItem:Show(true)    
    self._frameQuickBarLeftItem:DetachAllChildren()

    local scene = PX2_PROJ:GetScene()
    local actor = scene:GetActorFromMap(id)
    if actor then
        local agent = actor:GetAIAgentBase()
        local skillChara = actor:GetSkillChara()

        print("iddddddddddddddddddd2:"..id)

        self:_RefreshQuickBarItemSkill(id)
        self:_SetBagItems(0)
        self:_RefreshQuickBarItem()
        self:_RefreshMe(id)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_UIFirstView(idstr)
	print(self._name.." p_mworld:_UIFirstView")
    print(idstr)

    local idi = StringHelp:StringToInt(idstr)

    if g_manykit._systemControlMode == 0 then
        self:_ShowCursor(idi<=0)
    end

    self._fPicBoxAim:Show(idi>0)
end
-------------------------------------------------------------------------------
function p_mworld:_ThirdViewOfActor(idi, distance)
	print(self._name.." p_mworld:_ThirdViewOfActor:"..idi)

    if distance then
        print("distance:"..distance)
    else
        print("null distance")
    end

    self:_FirstViewOfAgentByID(0)

    local scene = PX2_PROJ:GetScene()
    if scene then
        local actor = scene:GetActorFromMap(idi)
        if actor then
            p_holospace._g_cameraPlayCtrl:SetTarget(actor)
            p_holospace._g_cameraPlayCtrl:SetTargetOffset(APoint(0.0, 0.0, 2.0))
            p_holospace._g_cameraPlayCtrl:SetCameraDist(0.01, distance*1.2)
            p_holospace._g_cameraPlayCtrl:SetCameraDistance(distance)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_GodView(distance)
    local scene = PX2_PROJ:GetScene()
    if scene then
        p_holospace._g_cameraPlayCtrl:SetTarget(nil)
        p_holospace._g_cameraPlayCtrl:SetTargetOffset(APoint(0.0, 0.0, 0.0))
        p_holospace._g_cameraPlayCtrl:SetCameraDist(0.01, g_manykit._defaultViewDistanceMax)
        p_holospace._g_cameraPlayCtrl:SetCameraDistance(distance)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_TakeControlOfAgentByID(id, mode, lookPos, degree, dist)
    print(self._name.." p_mworld:_TakeControlOfAgentByIDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD:"..id)
    local agent = nil
    local scene = PX2_PROJ:GetScene()
    if id>0 then
        local actor = scene:GetActorFromMap(id)
        if actor then
            agent = actor:GetAIAgent()
        end
        if agent then
            self:_TakeControlOfAgent(agent, mode, nil)
        end
    else
        self:_TakeControlOfAgent(nil, nil, lookPos, degree, dist)
    end

    self:_FirstViewOfAgent(nil)
end

-------------------------------------------------------------------------------
function p_mworld:_FirstViewOfAgentByID(id, dofix)
    local agent = nil
    local scene = PX2_PROJ:GetScene()
    if id>0 then
        local actor = scene:GetActorFromMap(id)
        if actor then
            agent = actor:GetAIAgent()
        end
        if agent then
            self:_FirstViewOfAgent(agent, dofix)
        end
    else
        self:_FirstViewOfAgent(nil)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_FirstViewOfAgent(agent, dofix)
    if self._agentAgentFirstView==agent then
        return
    end

    local scene = PX2_PROJ:GetScene()
	local cameraNode = scene:GetMainCameraNode()
    local camera = cameraNode:GetCamera()

    local sz = PX2_ENGINESCENECANVAS:GetSize()
    if self._agentAgentFirstView then
        print("before set on first view false")

        local act = Cast:ToActor(self._agentAgentFirstView:GetNode())
        local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
        if scCtrl then
            scCtrl:_OnFirstView(false)
        end

        p_holospace._g_curSceneNodeCtrlEnableRot = true
        p_holospace._g_cameraPlayCtrl:EnableDistance(true)
        p_holospace._g_cameraPlayCtrl:Enable(true)
        p_holospace._g_cameraPlayCtrl:SetTarget(act)
        p_holospace._g_cameraPlayCtrl:SetCameraDistance(g_manykit._defaultViewDistance*0.5)
        p_holospace._g_cameraPlayCtrl:SetTargetOffset(APoint(0.0, 0.0, 2.0))
        p_holospace._g_cameraPlayCtrl:SetDegreeHorRange(-1.0)
        p_holospace._g_cameraPlayCtrl:SetParentHor(0)
        p_holospace._g_cameraPlayCtrl:SetParentVer(0)

        PX2_GH:SendGeneralEvent("UIFirstView", "0")

        PX2_GH:SendGeneralEvent("leavefirstview", ""..self._agentAgentFirstView:GetID())
    end

    local beforeAgent = self._agentAgentFirstView
    
    self._agentAgentFirstView = agent

    if self._agentAgentFirstView then   
        print("before set on first view true")
        
        local act = Cast:ToActor(self._agentAgentFirstView:GetNode())
        local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
        scCtrl:_OnFirstView(true)

        if scCtrl then
            if dofix then
                scCtrl._isViewFix = dofix
            end
        end

        p_holospace._g_cameraPlayCtrl:SetCameraDistance(0.0)
        if scCtrl then
            p_holospace._g_cameraPlayCtrl:SetTargetOffset(APoint(0.0, 0.0, scCtrl._firstViewDist))
        else
            p_holospace._g_cameraPlayCtrl:SetTargetOffset(APoint(0.0, 0.0, 2.0))
        end
        p_holospace._g_cameraPlayCtrl:SetDegreeVer(0.0)
        p_holospace._g_cameraPlayCtrl:Update(0.0, 0.0)

        local isHumainProcessNone = agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_NONE)

		if isHumainProcessNone then
            p_holospace._g_curSceneNodeCtrlEnableRot = false
			p_holospace._g_cameraPlayCtrl:EnableDistance(false)

            p_holospace._g_cameraPlayCtrl:Enable(false)
		else
            local tm = agent:GetHumanTakePossessed()
            local isHumainProcessBodyExactly = tm==AIAgent.HTPM_BODY

            if isHumainProcessBodyExactly then
                p_holospace._g_cameraPlayCtrl:EnableDistance(false)
            else
                p_holospace._g_cameraPlayCtrl:EnableDistance(true)

                local dir = self._agentAgentFirstView:GetDirection()
                p_holospace._g_cameraPlayCtrl:SetDirectionResetHorVer(dir)
            end
            p_holospace._g_curSceneNodeCtrlEnableRot = true
            
			PX2_GH:SendGeneralEvent("UIFirstView", ""..self._agentAgentFirstView:GetID())
		end

        PX2_GH:SendGeneralEvent("enterfirstview", ""..self._agentAgentFirstView:GetID())

        self:_OnDisSelectObj(true)
    else
        print("self._agentAgentFirstView is null")

        local actor = scene:GetMainActor()
        if actor then

        end
    end

    if p_holospace._g_cameraPlayCtrl_SmallMap then
        if self._agentAgentFirstView then
            p_holospace._g_cameraPlayCtrl_SmallMap:Enable(true)
            p_holospace._g_cameraPlayCtrl_SmallMap:SetTarget(beforeAgent)
    
            p_holospace._g_cameraPlayCtrl_SmallMap:SetCameraDist(p_holospace._g_beforeDistMin, p_holospace._g_beforeDistMax)
            p_holospace._g_cameraPlayCtrl_SmallMap:SetCameraDistance(p_holospace._g_beforeDistance)
    
            p_holospace._g_cameraPlayCtrl_SmallMap:SetTargetPos(p_holospace._g_beforeTargetPos)
            p_holospace._g_cameraPlayCtrl_SmallMap:SetTargetOffset(p_holospace._g_beforeOffset)
        
            p_holospace._g_cameraPlayCtrl_SmallMap:SetDegreeHor(p_holospace._g_beforeHor)
            p_holospace._g_cameraPlayCtrl_SmallMap:SetDegreeVer(p_holospace._g_beforeVer)
        else
            p_holospace._g_cameraPlayCtrl_SmallMap:Enable(false)
        end
    end
end
-------------------------------------------------------------------------------