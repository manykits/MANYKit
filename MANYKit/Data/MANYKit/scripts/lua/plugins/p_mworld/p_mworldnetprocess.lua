-- p_mworldnetprocess.lua

-------------------------------------------------------------------------------
function p_mworld:_OnRequestAddObject(id, typeid, fromitemid, pos, rot,
    uin, 
    scale, items, itemsequip, group, hp, allname, posliststr)

	print(self._name.." p_mworld:_OnRequestAddObject:")
    print("id:"..id)
    print("typeid:"..typeid)


    if PX2_SS then
        PX2_SS:PlayASound(g_manykit._media.scene_put, g_manykit._soundVolume, 1.0)
    end
    
    local scene = PX2_PROJ:GetScene()
    if scene then
        local ter = scene:GetTerrain()
        local actGet = scene:GetActorFromMap(id)
        if nil == actGet then
            local nodeObject = scene:GetObjectByID(p_holospace._g_IDNodeObject)
            if nodeObject then
                local act, asc = self:_CreateOrUpdateActor(id, typeid, pos, nil, uin, true, allname)
                if act then                
                    nodeObject:AttachChild(act)
                    scene:AddActor(act)
                    self:_ListMapItemAdd(act, asc)

                    act:GetAIAgentBase():SetPosition(pos)
                    act:GetAIAgentBase():SetRotateDegreeAPoint(rot)
                    if scale then
                        act.LocalTransform:SetScale(scale)
                    end

                    local model = act:GetModel()
                    if model then
                        if posliststr then
                            print("posliststrposliststrposliststrposliststrposliststrposliststr")
            
                            print(posliststr)

                            local nodeModel = act:GetNodeModel()
                            local poslist = PX2JSon.decode(posliststr)
                            local poses = {}
                            local fromP = {}
                            local toP = {}

                            for i, v in ipairs(poslist) do
                                local p = APoint():FromString(v)
                                local diff = p-pos
                                local lp = APoint(diff:X(), diff:Y(), diff:Z())
                                table.insert(poses, lp)
                            end

                            local numP = #poses
                            for i, v in ipairs(poses) do
                                if i<numP then
                                    table.insert(fromP, poses[i])
                                    table.insert(toP, poses[i+1])
                                end
                            end

                            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!numP"..numP)
                            
                            local defModel = act:GetSkillChara():GetDefModel()
                            if defModel then
                                local defModelID = defModel.ID
                                print("defModelID:"..defModelID)

                                local objLength = defModel.ObjLength
                                if 0==objLength then
                                    objLength = 2
                                end

                                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!objLength"..objLength)
         
                                for i, v in ipairs(fromP) do
                                    local pF = fromP[i]
                                    local pT = toP[i]
    
                                    local diff = pT - pF
                                    local length = diff:Normalize()
                                    local num = Mathf:Ceil(length/objLength)

                                    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!num"..num)

                                    local dir = diff
                                    for i=0, num-1, 1 do 
                                        local p = pF + diff * length * (i*1.0)/((num-1)*1.0)

                                        local wp = pos + p
                                        local wh, wnormal = asc:_PickHeight(wp, true, true)
                                        local diffH = wh - wp:Z()

                                        local rotZ = 90.0 * DEG_TO_RAD

                                        local dir = AVector(-Mathf:Sin(rotZ), Mathf:Cos(rotZ), 0.0)
                                        local up = wnormal
                                        local right = dir:Cross(up)
                                        right:Normalize()
                                        local dir = up:Cross(right)
                                        dir:Normalize()
                                        local hmat = HMatrix()
                                        hmat:SetRotatePos(right, dir, up, APoint(0,0,0), true)
                                        print("2")
                                        local trans = Transform()
                                        trans:SetRotate(hmat)
                                        local diff1 = trans:Multip(diff)
                                        
                                        local cpObj = model:Copy("")
                                        local mov = Cast:ToMovable(cpObj)
                                        if mov then
                                            mov.LocalTransform:SetUniformScale(defModel.ModelScale)
                                            p:SetZ(p:Z() + diffH)
                                            mov.LocalTransform:SetTranslate(p)
                                            mov.LocalTransform:SetDU(diff1, wnormal)

                                            act:AttachChild(mov)
                                        end
                                    end    
                                end

                                if numP>1 then
                                    act:GetModel():Show(false)
                                end
                            end
                        end
                    end

                    local sc = act:GetSkillChara()

                    if uin>0 then
                        sc:SetBeMyS(true)
                    end

                    if group then
                        asc:_SetGroup(group)

                        asc._node:BeginPropertyCata("Actor")                
                        PX2Table2Vector({ "0", "1", "2" })
                        asc._node:AddPropertyEnum("Group", "阵营", sc:GetGroupTypes(), PX2_GH:Vec(), asc._enablegp, asc._enablegp)                 	
                        asc._node:EndPropertyCata()        
                    end                

                    if hp and hp~=-1 then
                        sc:SetCurHP(hp)
                    end

                    sc:SetRoomID(self._curroomid)
                    local ag = act:GetAIAgent()
                    if ag then
                        ag:HumanTakePossession(AIAgent.HTPM_NONE)
                    end

                    -- me
                    local net = p_net._g_net
                    if net then
                        if uin == g_manykit._uin then
                            asc._isMe = true

                            self:_CharaAddItems(sc, items)
                            scene:SetMeActor(act)
                        end
                    end
                    
                    asc:_Simu(self._isSimuing)
                    act:Update()
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnRequestDeleteObj(id)
	print(self._name.." p_mworld:_OnRequestDeleteObj:"..id)

    self:_OnDisSelectObj(false)

    if PX2_SS then
        PX2_SS:PlayASound(g_manykit._media.scene_delete, g_manykit._soundVolume, 1.0)
    end

    local scene = PX2_PROJ:GetScene()
    if scene then
        local nodeObject = scene:GetObjectByID(p_holospace._g_IDNodeObject)
        if nodeObject then
            local obj = nodeObject:GetObjectByID(id)
            local act = Cast:ToActor(obj)
            if act then
                local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_actor")
                if scCtrl then
                    scCtrl:_Cleanup()
                end

                scene:RemoveActor(act)
                act:DetachFromParent()

                if self._listMapItems then
                    local item = self._listMapItems:GetItemByUserDataString("id", ""..id)
                    if item then
                        self._listMapItems:RemoveItem(item)
                    end
                end

                scene:SetNeedReCalCollect(true)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnRequestTranslateObj(id, scale, rot, pos, isstate)
    if not isstate then
        print(self._name.." p_mworld:_OnRequestTranslateObj:"..id)
    end

    local net = p_net._g_net
    local scene = PX2_PROJ:GetScene()
    if scene then
        local act = scene:GetActorFromMap(id)
        if act then     
            if isstate then
                local skillChara = act:GetSkillChara()
                local sp = skillChara:GetSkillPlayer()
                if sp then
                    if sp.UIN==g_manykit._uin then
                    else
                        act.LocalTransform:SetScale(scale)
                        act:GetAIAgentBase():SetRotateDegreeAPoint(rot)
                        act.LocalTransform:SetTranslate(pos)
                    end
                end
            else
                act.LocalTransform:SetScale(scale)
                act:GetAIAgentBase():SetRotateDegreeAPoint(rot)
                act.LocalTransform:SetTranslate(pos)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnRequestStateMachine(charaid, sm, userdata, statemode)
    print(self._name.." p_mworld:_OnRequestStateMachine:"..charaid)

    local scene = PX2_PROJ:GetScene()
    if scene then
        local act = scene:GetActorFromMap(charaid)
        if act then
            if userdata and ""~=userdata then
                act:SetUserDataString("simuuserdata", userdata)
            end

            if sm and ""~=sm then
                print("sm:"..sm)
                local agent = act:GetAIAgent()
                if agent then
                    if statemode then
                        if "action"==statemode then
                            agent:GetFSM_Action():ChangeState(sm)
                        elseif "movement"==statemode then
                            agent:GetFSM_Movement():ChangeState(sm)
                        elseif "posture"==statemode then
                            agent:GetFSM_Posture():ChangeState(sm)
                        end
                    else
                        agent:GetFSM_Logic():ChangeState(sm)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnRequestState(dt)
    print(self._name.." p_mworld:_OnRequestState")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local charaid = dt.charaid
        --print("charaid:"..charaid)

        local act1 = scene:GetActorFromMap(charaid)
        if act1 then
            self:_OnProcessState(true, act1, dt)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnProcessState(isclient, act, dt)
    --print(self._name.." p_mworld:_OnProcessStateeeeeeeeeeeeee")

    print("isclient:")
    print_i_b(isclient)

    local skillChara = act:GetSkillChara()
    if dt.hp then
        if dt.hp~=skillChara:GetCurHP() then
            skillChara:SetCurHP(dt.hp)
        end
    end

    local ctrl = nil
    local scCtrl = nil
    local scCtrlHuman = nil
    if isclient then
        print("st 111")

        ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
        ctrl, scCtrlHuman = g_manykit_GetControllerDriverFrom(act, "p_human")
        ctrl, scCtrlLight = g_manykit_GetControllerDriverFrom(act, "p_light")
        if scCtrl then
            scCtrl:_CheckGetProto()
            
            print("st 222")

            if dt.posture then
                if dt.posture~=scCtrl._posture then
                    scCtrl:_CheckSetPosture(dt.posture)
                end
            end

            print("st 333")

            if dt.group then
                if dt.group ~=scCtrl._group then
                    scCtrl:_SetGroup(dt.group)
                end
            end

            print("st 444")

            if dt.rot then
                local rot = APoint:SFromString(dt.rot)
                rot:SetX(0.0)
                rot:SetY(0.0)
                
                scCtrl._rotateDegreeAPointFromServer = APoint(rot:X(), rot:Y(), rot:Z())
            end  

            print("st 555")
 
            if dt.upper then
                if scCtrlHuman then
                    scCtrlHuman:_SetUpperDegree(dt.upper)
                end
            end

            print("st 666")

            if dt.pos then
                local p = APoint:SFromString(dt.pos)
                scCtrl._agent:SetPosition(p)
                scCtrl._agent:ClearPath()
            end
            
            print("st 777")
        elseif scCtrlLight then
            if dt.upper then
                if scCtrlLight then
                    scCtrlLight:_SetLightRange(dt.upper)
                end
            end
        end
    else
        -- server place
    end 

    local calobjects = true
    if isclient then
        if scCtrl then
            if scCtrl._lastSubobjectStr == dt.subobjects then
                calobjects = false
            else
                scCtrl._lastSubobjectStr = dt.subobjects
            end
        end
    end

    if calobjects and skillChara then
        if dt.subobjects then
            local addeditems = {}
            local isAddItem = false
            local isEquipItem = false

            print("st 888")

            local subobjs = PX2JSon.decode(dt.subobjects)
            if subobjs then
                for k,v in pairs(subobjs) do
                    local subobj = v
                
                    local id = subobj.id
                    local typeid = subobj.typeid
                    local rotstr = subobj.rot
                    local rot = APoint:SFromString(rotstr)  
                    print("rotstr:")
                    print(rotstr)

                    local isExistItem = false
                    local item = skillChara:GetItemByTypeID(typeid)  
                    if nil == item then
                        isExistItem = false                         
                        item = SkillItem:New()
                        item:SetID(id)
                        item:SetTypeID(typeid)
                        item:SetFixed(false)
                        item:SetNum(1)
                        item:SetUserDataString("isrb", "1")

                        table.insert(addeditems, #addeditems + 1, item)
                    else
                        isExistItem = true
                    end

                    --item:ClearSubObjectTypes()                
                    if subobj.subobjects then
                        for k1,v1 in pairs(subobj.subobjects) do
                            local subobj1 = v1

                            local id1 = subobj1.id
                            local typeid1 = subobj1.typeid
                            local nummax = subobj1.nummax
                            local num = subobj1.num

                            local item1 = skillChara:GetItemByTypeID(typeid1)
                            if nil== item1 then                     
                                item1 = SkillItem:New()
                                item1:SetID(id1)
                                item1:SetTypeID(typeid1)
                                item1:SetFixed(false)
                                skillChara:AddItem(item1)
                                item1:SetUserDataString("isrb", "1")

                                isAddItem = true
                            end   
                            if nummax then
                                item1:SetNumMax(nummax)
                            end
                            if num then       
                                item1:SetNum(num)
                            end

                            if not item:IsHasSubObjectType(typeid1) then
                                item:AddSubObjectType(typeid1)
                            end
                            item:SetSubObjectNumMax(typeid1, 20)
                            --item:SetSubObjectNum(typeid1, 0)
                        end
                    end

                    if not isExistItem then
                        skillChara:AddItem(item)
                        isAddItem = true
                    end
                    item:SetCurrentUseSubObjectIndex(0)
                
                    if isclient then
                        if scCtrl then
                            print("scCtrl:_SetItemRot 0")
                            scCtrl:_SetItemRot(typeid, rot)
                            print("scCtrl:_SetItemRot 1")
                        end
                    end
                end
            end

            print("st 999")

            if #addeditems>0 then
                print("addeditems 0")

                skillChara:EquipItem("def", addeditems[1])
                print("addeditems 1")

                isEquipItem = true
            end

            print("st 000")

            if isclient then
                local charaid = skillChara:GetID()
                if isAddItem then
                    PX2_GH:SendGeneralEvent("SkillCharaAddItems", ""..charaid)
                end

                print("st 0001")

                if isEquipItem then
                    PX2_GH:SendGeneralEvent("SkillCharaEquipItems", ""..charaid)
                end

                print("st 0002")
            end
        end
    end

    if dt.userdatastr then
        local json = PX2JSon.decode(dt.userdatastr)
        local orglevel = json.orglevel
        local orgid = json.orgid
        local feature = json.feature
        local entityid = json.entityid

        act:SetUserDataString("orglevel", ""..orglevel)
        act:SetUserDataString("orgid", ""..orgid)
        act:SetUserDataString("feature", ""..feature)
        if entityid then
            print("isclient 0003")

            act:SetUserDataString("entityid", ""..entityid)
        end

        print("isclient 0004")
    end 
end
-------------------------------------------------------------------------------
function p_mworld:_OnRequestEquipItem_RB(dt)
    print(self._name.." p_mworld:_OnRequestEquipItem_RB")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local charaid = dt.charaid
        local weaponid = dt.weaponid
        local itemtypeid = dt.itemtypeid

        print("charaid:"..charaid)

        if weaponid then
            print("weaponid:"..weaponid)
        end
        if itemtypeid then
            print("itemtypeid:"..itemtypeid)
        end

        local act = scene:GetActorFromMap(charaid)
        if act then
            local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
            if scCtrl then
                local skillChara = scCtrl._skillChara

                print("addddddddddddddddddddddddddddddddddddddd itemtypeid:"..itemtypeid)
                
                local item1 = skillChara:GetItemByTypeID(itemtypeid)
                if nil== item1 then      
                    print("exist a weapon create one add equip")

                    skillChara:UnEquipAllItems("def", false)
                    
                    item1 = SkillItem:New()
                    item1:SetID(weaponid)
                    item1:SetTypeID(itemtypeid)                    
                    item1:SetFixed(false)
                    skillChara:AddItem(item1)
                    item1:SetUserDataString("isrb", "1")
                    item1:SetNumEquip("def", 1) 
                    
                    skillChara:EquipItem("def", item1) 

                    PX2_GH:SendGeneralEvent("SkillCharaAddItems", ""..charaid)
                    PX2_GH:SendGeneralEvent("SkillCharaEquipItems", ""..charaid)
                else
                    skillChara:UnEquipAllItems("def", false)

                    skillChara:EquipItem("def", item1) 

                    PX2_GH:SendGeneralEvent("SkillCharaAddItems", ""..charaid)
                    PX2_GH:SendGeneralEvent("SkillCharaEquipItems", ""..charaid)
                end   
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnUpdateItem(dt)
    print(self._name.." p_mworld:_OnUpdateItem")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local charaid = dt.charaid

        local act = scene:GetActorFromMap(charaid)
        if act then
            local skillChara = act:GetSkillChara()
            if skillChara then
                local itemid = dt.itemid
                local num = dt.num

                local item = skillChara:GetItemByID(itemid)
                if item then
                    item:SetNum(num)

                    print("num:".. num)
      
                    for k,v in pairs(dt.subobjs) do
                        local typeid = v.typeid
                        local num = v.num

                        item:SetSubObjectNum(typeid, num)
                    end
                end

                local info = ""..charaid.."_"..itemid
                PX2_GH:SendGeneralEvent("SkillCharaItemUpdate", ""..info)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnSteeringBehavior(dt)
    local charaid = dt.charaid
    local tp = dt.type
    local data = dt.data
    local pos = APoint:SFromString(dt.pos)
    local rotDegree = APoint:SFromString(dt.rot)
    
    print(self._name.." p_mworld:_OnSteeringBehavior")
    print("charaid:")
    if charaid then
        print(charaid)
    end
    print("tp:")
    if tp then
        print(tp)
    end
    print("data:")
    if data then
        print(data)
    end
    print("dt.pos:")
    if dt.pos then
        print(dt.pos)
    end
    print("dt.rot:")
    if dt.rot then
        print(dt.rot)
    end

    local idt = StringHelp:StringToInt(""..data)

    local scene = PX2_PROJ:GetScene()
    if scene then
        local act = scene:GetActorFromMap(charaid)
        if act then
            if "Path_SetWayPointIndex"==tp then
                local agbase = act:GetAIAgentBase()
                if agbase then
                    agbase:SetPosition(pos)
                    agbase:SetRotateDegreeAPoint(rotDegree)
                    local behav = act:GetAIAgentBase():GetAISteeringBehavior()
                    if behav then
                        local pth = behav:GetAISteeringPath()
                        if pth then
                            pth:SetWayPointIndex(idt, true)
                        end
                    end
                end
            end            
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnSetCharaState(charaid, hp, pos, rot, sm, ud)
	print(self._name.." p_mworld:_OnSetCharaState:"..charaid.." hp:"..hp)

    local scene = PX2_PROJ:GetScene()
    if scene then
        local actor = scene:GetActorFromMap(charaid)
        if actor then
            local agentBase = actor:GetAIAgentBase()
            local skillChara = actor:GetSkillChara()
            if skillChara then
                print("SetCurHP:"..hp)
                skillChara:SetCurHP(hp)

                if pos then
                    agentBase:SetPosition(pos)
                end
                if rot then
                    agentBase:SetRotateDegreeAPoint(rot)
                end

                if sm and ""~=sm then
                    self:_OnRequestStateMachine(charaid, sm, ud)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnSetCharaItems(charaid, items)
    print("_OnSetCharaItems")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local actor = scene:GetActorFromMap(charaid)
        if actor then
            local agentBase = actor:GetAIAgentBase()
            local skillChara = actor:GetSkillChara()
            if skillChara then
                skillChara:RemoveAllItems()
                self:_CharaAddItems(skillChara, items)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnMapMembersInitEquipItems(charaid, items)
    print("_OnMapMembersInitEquipItems")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local actor = scene:GetActorFromMap(charaid)
        if actor then
            local agentBase = actor:GetAIAgentBase()
            local skillChara = actor:GetSkillChara()
            if skillChara then
                self:_CharaEquipItemsInit(skillChara, items)              
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnSetCharaQuicklBarItems(charaid, items)
    print("_OnSetCharaQuicklBarItems")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local actor = scene:GetActorFromMap(charaid)
        if actor then
            local agentBase = actor:GetAIAgentBase()
            local skillChara = actor:GetSkillChara()
            if skillChara then
                self:_CharaSetQuickBarItems(skillChara, items)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_MapPropertySetFromNet(mid, props, propname)
    print(self._name.." p_mworld:_MapPropertySetFromNet")
    print("propname:")
    if propname then
        print(propname)
    end

    self:_PropertyValueSceneGetFromProps(mid, props)

    if mid == self._curmapid then
        self:_RegistSceneProperiesFromValue()
        self:_PropertyValueActivate(propname)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnMapPropertyObjectSetFromNet(mid, id, props)
    print(self._name.." p_mworld:_OnMapPropertyObjectSetFromNet")
    print("mid:"..mid)
    print("id:"..id)

    if mid == self._curmapid then
        local scene = PX2_PROJ:GetScene()
        if scene then
            local act = scene:GetActorFromMap(id)
            if act then
                local propsstr = PX2JSon.encode(props)
                PX2_CREATER:UpdatePropertyFromJSON(act, propsstr, "Actor")

                local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_actor")
                if scCtrl then
                    scCtrl:_OnPropertyAct()
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_EquipItemOrNot(isclient, scene0, tab)
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

    local scene = scene0
    if scene then
        local skillChara = nil
        if isclient then
            local actor = scene:GetActorFromMap(charaid)
            if actor then
                skillChara = actor:GetSkillChara()
            end
        else
            local map = scene:GetSkillMap()
            if map then
                skillChara = map:GetSkillChara(charaid)
            end
        end

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
        end
    end
end
-------------------------------------------------------------------------------