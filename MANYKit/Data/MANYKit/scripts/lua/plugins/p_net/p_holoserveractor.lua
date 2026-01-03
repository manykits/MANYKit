-- p_holoserveractor.lua
-------------------------------------------------------------------------------
-- map objs
function p_holoserver:_CreateActor(tab)
    print(self._name.." p_holoserver:_CreateActorr")

    local uin = tab.uin
    local mapid = tab.mid
    local typeid = tab.typeid
    local itemid = tab.itemid
    local idstr = ""..tab.id
    local id = StringHelp:StringToInt(idstr)
    local pos = APoint:SFromString(tab.pos)
    local rot = APoint:SFromString(tab.rot)
    local scale = APoint:SFromString(tab.scale)

    local group = tab.group
    local hp = tab.hp

    local act = PX2_CREATER:CreateActor()

    act:SetID(id)
    act:SetUserDataString("typeid", ""..typeid)
    act:GetAIAgentBase():SetPosition(pos)
    act:GetAIAgentBase():SetRotateDegreeAPoint(rot)
    act.LocalTransform:SetScale(scale)
    local schara = act:GetSkillChara()
    schara:SetTypeID(typeid)
    if -1~=hp then
        schara:SetCurHP(hp)
    end
    
    p_actor:_sSetGroup(act, group)

    if uin and ""~=uin and "0"~=uin and 0~=uin then
        act:SetXMLNodeDoSave(false)
        act:SetUserDataString("uin", ""..uin)
    end

    if itemid~=nil and itemid>0 then
        self:_ReduceItemNum(uin, itemid, 1)
    end

    local scene = self._scenes[mapid]
    if scene then
        scene:AddActor(act)
        if self._isDoSceneSave then      
            self:_SaveScene(scene, nil)
        end
    end

    return true
end
-------------------------------------------------------------------------------
function p_holoserver:_DeleteActor(tab)
    local mapid = tab.mid
    local id = tab.id

    local scene = self._scenes[mapid]
    if scene then
        local act = scene:GetActorFromMap(id)
        if act then
            scene:RemoveActor(act)
        end
        if self._isDoSceneSave then
            self:_SaveScene(scene, nil)
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_TransActor(tab)
    local mapid = tab.mid
    local id = tab.id

    local scale = APoint:SFromString(tab.scale)
    local rot = APoint:SFromString(tab.rot)
    local pos = APoint:SFromString(tab.pos)

    local scene = self._scenes[mapid]
    if scene then
        local act = scene:GetActorFromMap(id)
        if act then
            local diff0 = Mathf:FAbs(scale:X() - scale:Y())
            local diff1 = Mathf:FAbs(scale:X() - scale:Z())
            if diff0<0.001 and diff1<0.001 then
                act.LocalTransform:SetUniformScale(scale:X())
            else
                act.LocalTransform:SetScale(scale)
            end
            act:GetAIAgentBase():SetPosition(pos)
            act:GetAIAgentBase():SetRotateDegreeAPoint(rot)
        else
            local skillMap = scene:GetSkillMap()
            if skillMap then
                local sc = skillMap:GetSkillChara(id)
                if sc then
                    sc:SetPosition(pos)
                    sc:SetRotation(rot)
                end
            end
        end
        if self._isDoSceneSave then
            self:_SaveScene(scene, nil)
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_SetMapObj(tab)
    print(self._name.." p_holoserver:_SetMapObj")
    local mapid = tab.mid
    local id = tab.id
    local properties = tab.data.properties
    local scene = self._scenes[mapid]
    if scene then
        local act = scene:GetActorFromMap(id)
        if act then
            local propsstr = PX2JSon.encode(properties)
            print("propsstr:")
            print(propsstr)
            PX2_CREATER:UpdatePropertyFromJSON(act, propsstr, "Actor")
            self:_SaveScene(scene, nil)
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_ReduceItemNum(uin, itemid, num)
end
-------------------------------------------------------------------------------
function p_holoserver:_SetQuickBarItem(tab)
    print("_SetQuickBarItem")

    local mapid = tab.mapid
    local charaid = tab.charaid
    local tag = tab.tag
    local index = tab.index
    local itemid = tab.itemid

    print("mapid:"..mapid)
    print("charaid:"..charaid)
    print("tag:"..tag)
    print("index:"..index)
    print("itemid:"..itemid)

    local scene = self._scenes[mapid]
    if scene then
        local map = scene:GetSkillMap()
        if map then
            local skillChara = map:GetSkillChara(charaid)
            if skillChara then
                if 0==itemid then
                    skillChara:SetQuickBarItem(index, nil)
                else
                    local item = skillChara:GetItemByID(itemid)
                    if item then
                        skillChara:SetQuickBarItem(index, item)
                    else
                        skillChara:SetQuickBarItem(index, nil)
                    end 
                end
            end

            if self._isDoSceneSave then
                map:SaveState()
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_EquipItemOrNot(scene, tab)
    print("_EquipItemOrNotttttttttttttttttttttttt")

    local mapid = tab.mapid
    local charaid = tab.charaid
    local tag = tab.tag
    local index = tab.index
    local itemid = tab.itemid
    local isequip = tab.isequip==1

    print("mapid:"..mapid)
    print("charaid:"..charaid)
    print("tag:"..tag)
    print("index:"..index)
    print("itemid:"..itemid)
    print("tab.isequip:"..tab.isequip)

    local scene = self._scenes[mapid]
    if scene then
        local map = scene:GetSkillMap()
        if map then
            local skillChara = map:GetSkillChara(charaid)
            if skillChara then
                local skillItem = skillChara:GetItemByID(itemid)

                if skillItem then
                    if isequip then
                        skillChara:EquipItem(tag, skillItem)
                        skillItem:SetEquipIndex(index)
                    else
                        skillChara:UnEquipItem(tag, skillItem)
                        skillItem:SetEquipIndex(-1)
                    end
                end

                if self._isDoSceneSave then
                    map:SaveState()
                end
            end
        end
    end
end
-------------------------------------------------------------------------------