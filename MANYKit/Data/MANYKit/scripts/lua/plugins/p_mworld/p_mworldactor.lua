-- p_mworldmapactor.lua

-------------------------------------------------------------------------------
function p_mworld:_CreateOrUpdateActor(id, typeid, pos, 
    theActor, uin, genscript, title)
    
    if genscript then
        print("p_mworld:_CreateOrUpdateActor")
        print("id:"..id)
        print("typeid:"..typeid)
    end

    print("genactor _CreateOrUpdateActor")

    local actor = nil
    local asc = nil
    local defChara = PX2_SDM:GetDefChara(typeid)
    if defChara then
        if theActor then
            actor = theActor
        else
            actor = PX2_CREATER:CreateActor()
        end

        actor:SetID(id)
        actor:SetUserDataString("typeid", typeid)
        actor:SetUserDataString("uin", uin)
        actor.LocalTransform:SetTranslate(pos)
        actor:RegistToScriptSystem()
        
        local skillChara = actor:GetSkillChara()
        skillChara:SetID(id)
        if uin and uin>0 then
            skillChara:SelfCreateSkillPlayer()
            skillChara:GetSkillPlayer():SetUIN(uin)
        end
        skillChara:SetTypeID(typeid)
        skillChara:SetBeMyS(p_net._g_net._islogicserver)

        actor:SkillCharaCreateModel()
        actor:SkillCharaProcessCollides()
        actor:SetRenderStyle(p_holospace._g_renderStyle, true)

        -- script
        if genscript then
            local script = defChara.Script
            print("script:")
            print(script)

            local nodeRoot = actor:GetNodeRoot()
            local nodeModel = actor:GetNodeModel()

            if script and ""~=script then
                local plugin = g_manykit:GetPluginRegistByName(script)
                if plugin then
                    asc = plugin:New()
                else
                    print_e("no plugin with name:"..script)
                end
                if "p_actor"==script then
                    actor:SetAIType(Actor.AIT_AGENTOBJECT)
                    actor:SetPhysicsShapeType(Actor.PST_MESHSTATIC, actor)
                else
                    actor:SetAIType(Actor.AIT_AGENT)
                    actor:SetPhysicsShapeType(Actor.PST_GENERAL)
                end
            else
                asc = p_actor:New()
                actor:SetAIType(Actor.AIT_AGENTOBJECT)
                actor:SetPhysicsShapeType(Actor.PST_MESHSTATIC, actor)
            end

            local agBase = actor:GetAIAgentBase()
            agBase:SetID(id)
            agBase:UsePhysics(g_manykit._isUsePhysics)

            actor:EnableAgent(true)

            asc._uin = uin
            asc._id = id
            asc._typeid = typeid
            if title then
                actor:SetUserDataString("allname", title)
                asc._title = title
                asc:_RefreshTitle()
            end

            local asc_controller = Cast:ToSC(asc.__object)
            actor:AttachController(asc_controller)
            asc:_OnCreateSceneInstance()
            asc:_RegistProperty()
            
            asc:_OnPropertyAct()
        end

        local modelController = actor:GetModelController()
        if modelController then
            modelController:SetUpdateFreTime(g_manykit._animUpdateTime)
        end
    end

    return actor, asc
end
-------------------------------------------------------------------------------
function p_mworld:_CharacterSetItems(dt)
    local scene = PX2_PROJ:GetScene()
    local meActor = scene:GetMeActor()
    if meActor then
        local skillChara = meActor:GetSkillChara()
        skillChara:RemoveAllItems(true)    
        if dt.items then
            self:_CharaAddItems(skillChara, dt.items)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CharaAddItems(skillChara, items)
    if items then
        for key, value in pairs(items) do
            local item = value

            local si = SkillItem:New()
            si:SetID(item.id)
            si:SetTypeID(item.typeid)
            si:SetNum(item.num)
            if item.subobjs then
                for k,v in pairs(item.subobjs) do
                    local typeid = v.typeid
                    local num = v.num

                    print("typeid:"..typeid)
                    print("num:"..num)

                    si:SetSubObjectNum(typeid, num)
                end
            end
            skillChara:AddItem(si)
        end
    end
    
    local charaid = skillChara:GetID()
    PX2_GH:SendGeneralEvent("SkillCharaAddItems", ""..charaid)
end
-------------------------------------------------------------------------------
function p_mworld:_CharaEquipItemsInit(skillChara, items)

    local numEquipTags = skillChara:CalGetNumEquipTags()
    for i=0, numEquipTags-1, 1 do
        local tag = skillChara:GetEquipTag(i)
        skillChara:UnEquipAllItems(tag);
    end

    if items then
        local isEquipped = false

        for key, value in pairs(items) do
            local item = value

            local id = item.id
            local tag = item.tag
            local num = item.num
            local equipindex = item.equipindex

            local skillItem = skillChara:GetItemByID(id)
            if skillItem then
                skillChara:EquipItem(tag, skillItem)
                isEquipped = true
            end
        end
    
        if isEquipped then
            local charaid = skillChara:GetID()
            PX2_GH:SendGeneralEvent("SkillCharaEquipItems", ""..charaid)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CharaSetQuickBarItems(skillChara, items)
    if items then
        for key, value in pairs(items) do
            local item = value
            local id = item.id
            local skillItem = skillChara:GetItemByID(id)
            if skillItem then
                skillChara:SetQuickBarItem(item.index, skillItem)
            end
        end
    end

    local charaid = skillChara:GetID()
    PX2_GH:SendGeneralEvent("SkillCharaSetQuickBarItems", ""..charaid)
end
-------------------------------------------------------------------------------
function p_mworld:_ChangePosture()
    print("p_mworld:_ChangePosture")

    local scene = PX2_PROJ:GetScene()
    if self._curSelectActorID > 0 then
        local act = scene:GetActorFromMap(self._curSelectActorID)
        if act then
            local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_human")
            if scCtrl then
                scCtrl:_ChangePosture()
            end 
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ActorShowCtrl(show, id, orglevel, orgid, feature)
    print(self._name.." p_mworld:_ActorShowCtrl")

    local isShow = (show==1 or show=="1")

    if orglevel then
        print("orglevel")
        print(orglevel)
    end
    if orgid then
        print("orgid")
        print(orgid)
    end
    if feature then
        print("feature")
        print(feature)
    end
    
    local scene = PX2_PROJ:GetScene()
    if orglevel or orgid or feature then
        local tag = ""
        local tagval = ""
        if orglevel then
            tag = "orglevel"
            tagval = orglevel
        elseif orgid then
            tag = "orgid"
            tagval = orgid
        elseif feature then
            tag = "feature"
            tagval = feature
        end

        local numActors = scene:CalGetNumActors(tag, tagval)
        for i=0, numActors-1, 1 do 
            local actor = scene:GetActor(i)
            if actor then
                local ctrlChara, scChara = g_manykit_GetControllerDriverFrom(actor, "p_chara")
                if scChara then
                    scChara._isShow = isShow
                end

                actor:Show(isShow)
            end
        end
    else
        local actor = scene:GetActorFromMap(id)
        if actor then
            local ctrlChara, scChara = g_manykit_GetControllerDriverFrom(actor, "p_chara")
            if scChara then
                scChara._isShow = isShow
            end

            actor:Show(isShow) 
        end
    end
end

-------------------------------------------------------------------------------