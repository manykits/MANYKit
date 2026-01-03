-- p_holocreatesimu1.lua

-------------------------------------------------------------------------------
function p_mworld:_mapCtrlMode(m)
    print(self._name.." p_holospace:_mapCtrlMode:"..m)

    PX2_PROJ:SetConfig("pnight_slam_ctrlmode", m)
    g_manykit._systemControlMode = m
    PX2_GH:SendGeneralEvent("CtrlModeChanged")
end
-------------------------------------------------------------------------------
function p_mworld:_mapRunMode(m)
    print(self._name.." p_holospace:_mapRunMode:"..m)
    
    self._mapOpenRunMode = m

    if self._curmapid>0 and 1==m then
        self:_OnSimu(true)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_mapSlamMode(m)
    print(self._name.." p_holospace:_mapSlamMode:"..m)

    self._mapOpenSlamMode = m

    PX2_GH:SendGeneralEvent("MapSlamMode", ""..m)
end
-------------------------------------------------------------------------------
function p_mworld:_OnActorDie(id)
    local scene = PX2_PROJ:GetScene()    

    if p_net._g_net._islogicserver then
        local act = scene:GetActorFromMap(id)
        if act then
            local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_actor")
            if scCtrl then
                if scCtrl._uin>0 then
                    if self._Charasters_Dead then
                        if not manykit_IsInArray(id, self._Charasters_Dead) then
                            table.insert(self._Charasters_Dead, #self._Charasters_Dead + 1, id)
                        end
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnActorSeeTarget(fromid, targetid)
    print("p_mworld:_OnActorSeeTarget")
    print(fromid)
    print(targetid)
    print("p_mworld:_OnActorSeeTarget111")

    print(self._name.." p_mworld:_OnActorSeeTarget:"..fromid.." targetid:"..targetid)
    print(fromid)
    print(targetid)

    local scene = PX2_PROJ:GetScene()
    if p_net._g_net._islogicserver then
        if targetid>0 then
            local fromActor = scene:GetActorFromMap(fromid)
            local targetActor = scene:GetActorFromMap(targetid)
            if fromActor and targetActor then
                local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(fromActor, "p_actor")
                if scCtrl then
                    if 0==scCtrl._uin then
                    end
                end
            end
        end        
    end

    print("1233333333333333333333333")
end
-------------------------------------------------------------------------------
function p_mworld:_TakeControlOfAgent(agent, mode, lookPos, lookDegree, lookDist)
    print(self._name.." p_mworld:_TakeControlOfAgent")

    local scene = PX2_PROJ:GetScene()
    local terrain = scene:GetTerrain()

    local pos = APoint(0.0, 0.0, 0.0)
    if self._agentAgentTakeProcess then
        self._agentAgentTakeProcess:HumanTakePossession(AIAgent.HTPM_NONE)

        local target = p_holospace._g_cameraPlayCtrl:GetTarget()
        if target then
            pos = target.LocalTransform:GetTranslate()
        end
        scene:SetMainActor(nil)
    else
        local n = p_holospace._g_cameraPlayCtrl:GetNode()
        if n then
            local lpos = n.LocalTransform:GetTranslate()

            local dir = n.LocalTransform:GetDirection()

            local picker = Picker()
            picker:Execute(terrain, lpos, dir, 0.0, Mathf.MAX_REAL)
            local picRec = picker:GetClosestNonnegative()
            if picRec.Intersected then
                pos = picRec.WorldPos
            end
        end
    end

    if lookPos then
        pos = lookPos
    end

    if nil==agent then
        p_holospace._g_cameraPlayCtrl:SetTarget(nil)
        p_holospace._g_cameraPlayCtrl:SetTargetPos(pos)
        p_holospace._g_cameraPlayCtrl:SetTargetOffset(APoint(0.0, 0.0, 0.0))
        p_holospace._g_cameraPlayCtrl:SetCameraDist(0.01, g_manykit._defaultViewDistanceMax)

        if lookDegree then
            p_holospace._g_cameraPlayCtrl:SetDegreeHor(-lookDegree:Z())
            p_holospace._g_cameraPlayCtrl:SetDegreeVer(-lookDegree:X())
        end
        if lookDist then
            p_holospace._g_cameraPlayCtrl:SetCameraDistance(lookDist)
        else
            p_holospace._g_cameraPlayCtrl:SetCameraDistance(g_manykit._defaultViewDistance)
        end
    end
    
    self._agentAgentTakeProcess = agent

    if self._agentAgentTakeProcess then
        
        print("agent:HumanTakePossession")
        agent:HumanTakePossession(mode)

        local act = agent:GetControlledable()
        scene:SetMainActor(act)

        local agent = act:GetAIAgent()
        local skillChara = act:GetSkillChara()
        local maxDist = 15
        if skillChara then
            local defChara = skillChara:GetDefChara()
            local defModel = skillChara:GetDefModel()
            if defModel then
                local len = defModel.Height
                maxDist = len * 10
            end
        end
        p_holospace._g_cameraPlayCtrl:SetTarget(act)
        p_holospace._g_cameraPlayCtrl:SetTargetOffset(APoint(0.0, 0.0, 2.0))
        p_holospace._g_cameraPlayCtrl:SetCameraDist(0.01, maxDist)
        p_holospace._g_cameraPlayCtrl:SetCameraDistance(maxDist*0.5)    
    end

    local id = 0
    if agent then
        id = agent:GetID()
    end
    PX2_GH:SendGeneralEvent("HumanTakeProcessd", id)
end
-------------------------------------------------------------------------------