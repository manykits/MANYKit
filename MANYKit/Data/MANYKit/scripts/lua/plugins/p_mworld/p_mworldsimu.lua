-- p_holocreatesimu.lua
-------------------------------------------------------------------------------
function p_mworld:_PlaySimu(issimu)
    print(self._name.." p_holospace:_PlaySimu")

    local net = p_net._g_net
    if net then
        net:_SendSimu(issimu,self._curmapid)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnSimu(issimu)
    print(self._name.." p_holospace:_OnSimu:")
    print_i_b(issimu)

    if self._isSimuing == issimu then
        return
    end

    self._isSimuing = issimu

    local scene = PX2_PROJ:GetScene()
    local actorMain = scene:GetMainActor()
    local terrain = scene:GetTerrain()

    local aw = scene:GetAIAgentWorld()
    if aw then
        aw:EnablePhysics(issimu)
    end

    if issimu then
        if self._btnsimu2 then
            self._btnsimu2:SetStateColor(UIButtonBase.BS_NORMAL, Float3(0.0, 0.5, 0.0))
            self._btnsimu2:SetStateColor(UIButtonBase.BS_PRESSED, Float3(0.0, 0.5, 0.0))
            self._btnsimu2:SetStateColor(UIButtonBase.BS_HOVERED, Float3(0.0, 0.5, 0.0))
        end

        local actMe = scene:GetActorFromMap(g_manykit._uin)
        if actMe then
            actMe:Show(g_manykit._isShowMe)
            
            local meID = actMe:GetID()
            if g_manykit._systemControlMode== 1 then
                self:_TakeControlOfAgentByID(meID, AIAgent.HTPM_MOVE)
            else
                self:_TakeControlOfAgentByID(meID, AIAgent.HTPM_ALL)
            end
        end

        -- delete files
        local filepath = ResourceManager:GetWriteablePath().."Write_MANYKit/genscripts/";
        local dir = DirP()
        dir:GetAllFiles(filepath, "");
        local numFiles = dir:GetNumFiles()
        print("numFiles:"..numFiles)
        for i=0,numFiles-1,1 do
            local filename = dir:GetFile(i)
            print("filename:"..filename)

            local f = File(filename)
            f:Delete()
        end

        if self._frameSnappy then
            self._frameSnappy:CallJS("manykit_gencode()")
        end

        -- scripts
        local scene = PX2_PROJ:GetScene()
        local nodeLogicScript = scene:GetNodeLogicScript()
        nodeLogicScript:DetachAllControllers()

        coroutine.wrap(function()
            sleep(2.0)

            -- create controller
            local filepath = ResourceManager:GetWriteablePath().."Write_MANYKit/genscripts/";
            local dir = DirP()
            dir:GetAllFiles(filepath, "");
            local numFiles = dir:GetNumFiles()
            print("numFiles:"..numFiles)
            for i=0,numFiles-1,1 do
                local filename = dir:GetFile(i)
                print("filename:"..filename)

                PX2_SC_LUA:CallFile(filename, true)

                local sc = PX2_CREATER:CreateScriptController_FromRes(filename)
                if sc then
                    nodeLogicScript:AttachController(sc)
                    sc:ResetPlay()
                end
            end
        end)()
    else
        if self._btnsimu2 then 
            manykit_uiProcessBtn(self._btnsimu2)
        end

        self:_TakeControlOfAgent(nil)
    end

    local numActors = scene:CalGetNumActors()
    for i=0, numActors-1, 1 do
        local act = scene:GetActor(i)
        if act then
            local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_actor")
            if scCtrl then
                scCtrl:_Simu(issimu)
            end
        end
    end      
end
-------------------------------------------------------------------------------
function p_mworld:_Use()
	print(self._name.." p_mworld:_Use")
    
    local scene = PX2_PROJ:GetScene()
    local agw = scene:GetAIAgentWorld()
    local mainActor = scene:GetMainActor()
    if mainActor then
        local agentMain = mainActor:GetAIAgent()
        agent = agw:GetClosestAgent(agentMain)
    end

    if agent then
        self:_TakeControlOfAgentByID(agent:GetID(), AIAgent.HTPM_ALL)
    end
end
-------------------------------------------------------------------------------