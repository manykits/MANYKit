-- p_netsendcase.lua
-- 
-------------------------------------------------------------------------------
function p_net:_SendStateTrans(agent)
	--print("p_net:_SendStateTrans:"..agent)
	local scene = PX2_PROJ:GetScene()
	if scene and agent then
		local mid = scene:GetID()
		local pos = agent:GetPosition()
		local rot = agent:GetRotateDegreeXYZ()

		local net = p_net._g_net
		if net then
			net:_n_SendStateTrans(mid, agent:GetID(), pos:ToString(), rot:ToString())
		end
	end
end
-------------------------------------------------------------------------------
function p_net:_SendProperty(actor)
	print("p_net:_SendProperty")
	local scene = PX2_PROJ:GetScene()
	if scene and actor then
		local mapid = scene:GetID()	

		local pjsonstr = PX2_CREATER:PropertyToJSON(actor, "Actor")
		local pjson = PX2JSon.decode(pjsonstr)

		local net = p_net._g_net
		if net then
			net:_n_SendProperty(mapid, actor:GetID(), pjson)
		end
	end
end
-------------------------------------------------------------------------------
function p_net:_GetRefreshMap(listMap)
	print("p_net:_GetRefreshMap:")
    local net = p_net._g_net
    if net then
        net:_n_GetRefreshMap(listMap)--add 5
    end
end
-------------------------------------------------------------------------------
function p_net:_RequestAddMap(name)
	print("p_net:_RequestAddMap:"..name)
    local net = p_net._g_net
    if net then
        net:_n_RequestAddMap(name)
    end
end
-------------------------------------------------------------------------------
function p_net:_RequestResetMap(mid)
	print("p_net:_RequestResetMap:")
    print("mid:"..mid)

    local net = p_net._g_net
    if net then
        net:_n_RequestResetMap(mid)
    end
end
-------------------------------------------------------------------------------
function p_net:_SendCloseMap(mapid)
	print("p_net:_SendCloseMap:"..mapid)
    local net = p_net._g_net
    if net then
        print("1")
        local scene = PX2_PROJ:GetScene()
        if scene then
            net:_n_SendCloseMap(mapid)     
        end
    end
end
-------------------------------------------------------------------------------
function p_net:_RequestDeleteMap(id)
	print("p_net:_RequestDeleteMap:"..id)
    local net = p_net._g_net
    if net then
        net:_n_RequestDeleteMap(id)
    end
end
-------------------------------------------------------------------------------
function p_net:_RequestAddObject(itemid, typeid, posstr, uinn, rotstr,scalestr, 
    group, hp, curmapid, allname, posliststr)
	print("p_net:_RequestAddObject:"..typeid)
    print("uinn:"..uinn)
    print("posstr:"..posstr)

    if rotstr then
        print("rotstr:"..rotstr)
    end
    if scalestr then
        print("scalestr:"..scalestr)
    end

    local net = p_net._g_net
    if net then
		net:_n_RequestAddObject(itemid, typeid, posstr, uinn,
            rotstr, scalestr, group, hp, curmapid, allname, posliststr)  
    end
end
-------------------------------------------------------------------------------
function p_net:_SendQuickBarItem(skillChara, tag, index, skillItem)
    print(" p_net:_SendQuickBarItem")

    local skillMap = skillChara:GetSkillMap()
    local skillMapID = skillMap:GetID()
    local charaID = skillChara:GetID()
    local itemID = 0
    if skillItem then
        itemID = skillItem:GetID()
    end

    print("skillMapID:"..skillMapID)
    print("charaID:"..charaID)
    print("itemID:"..itemID)
    print("index:"..index)
    print("tag:"..tag)

	local net = p_net._g_net
    if net then
        net:_n_SendQuickBarItem(skillMapID,charaID, tag, index, itemID)
    end
end
-------------------------------------------------------------------------------
function p_net:_RequestDeleteObj(id, curmapid)
	print("p_net:_RequestDeleteObj:"..id)

    local net = p_net._g_net
    if net then
        net:_n_RequestDeleteObj(id, curmapid)
    end
end
-------------------------------------------------------------------------------
function p_net:_RequestSetObjDirect(id, group, hp, curmapid)
    print(self._name.." p_net:_RequestSetObjProperty:"..id)
    local dt = {
        t = "m_setobjdirect",
        mid = curmapid,
        id = id,
        group = group,
        hp = hp,
    }
    local net = p_net._g_net
    if net then
        net:_n_RequestSetObjDirect(id, group, hp, curmapid)
    end
end
-------------------------------------------------------------------------------
function p_net:_RequestTranslateObj(id, reset, exceptme, curmapid)
    print(self._name.." p_net:_RequestTranslateObj:"..id)

    local scene = PX2_PROJ:GetScene()
    if scene then
        local act = scene:GetActorFromMap(id)
        if act then
            local scale = act.LocalTransform:GetScale()
            local rot = act.LocalTransform:GetRotateDegreeXYZ()
            local pos = act.LocalTransform:GetTranslate()

            if reset then
                scale = APoint(1,1,1)
                rot = APoint(0,0,0)
            end

            -- important for physics
            act:GetAIAgentBase():SetPosition(pos)
            act:GetAIAgentBase():SetRotateDegreeAPoint(rot)

            local scalestr = scale:ToString()
            local rotstr = rot:ToString()
            local posstr = pos:ToString()


            local net = p_net._g_net
            if net then
                net:_n_RequestTranslateObj(id, exceptme, scalestr, rotstr, posstr, curmapid)
            end          
        end
    end
end
-------------------------------------------------------------------------------
function p_net:_GetScenePropertyAndSend(obj, propName, curmapid)
    print(self._name.." p_net:_GetScenePropertyAndSend")

    local scene = PX2_PROJ:GetScene()
    if scene then
        obj:_GetPropertyValueOfSceneObject(scene)

        local pjsonstr = PX2_CREATER:PropertyToJSON(scene, "Scene")
        --print("pjsonstr:")
        --print(pjsonstr)

        local pjson = PX2JSon.decode(pjsonstr)

        local net = p_net._g_net
        if net then
            net:_n_GetScenePropertyAndSend(propName, pjson, curmapid)
        end
    end
end
-------------------------------------------------------------------------------
function p_net:_SendSimu(simu,curmapid)
    local net = p_net._g_net
    if net then
        local dt = {
            t = "map_simu",
            mid = curmapid,
        }

        local scene = PX2_PROJ:GetScene()
        if scene then
            local mc = scene:GetMainActor()
            if mc then
                dt.charaid = mc:GetID()
            end
        end

        if simu then
            dt.simu = 1
        else
            dt.simu = 0
        end
        net:_NetLogicSendJSon(dt)
    end
end
-------------------------------------------------------------------------------
function p_net:_SendComeInRoom(uin)
	print(self._name.." p_net:_SendComeInRoom:"..uin)
	-- in app
	local dt = {
		t="in",
		uin=uin,
	}
	self:_NetLogicSendJSon(dt)

	-- in room
	local dt = {
		t="in_room",
		room="public",
		typeid=10002,
	}
	self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
function p_net:_SendInMap(mapid, pos, rot, transgetfromserver)
	print(self._name.." p_net:_SendInMap:"..mapid.." pos:"..pos:ToString().." rot:"..rot:ToString())

    local dt = {
        t="in_map",
        mid = mapid,
		pos = pos:ToString(),
		rot = rot:ToString(),
    }
	if transgetfromserver then
		dt.transgetfromserver = "1"
	else
		dt.transgetfromserver = "0"
	end
	self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
function p_net:_SendCmd(txt)
	print(self._name.." p_net:_SendCmd:"..txt)

    local dt = {
        t="cmd_send",
        text = txt,
    }
	self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
function p_net:_SendItemEquipOrUnEquip(skillChara, tag, index, skillItem, isequip)
    print(self._name.." p_net:_SendItemEquipOrUnEquip")

    local skillMap = skillChara:GetSkillMap()
    local skillMapID = skillMap:GetID()
    local charaID = skillChara:GetID()
    local itemID = 0
    if skillItem then
        itemID = skillItem:GetID()
    end

    print("skillMapID:"..skillMapID)
    print("charaID:"..charaID)
    print("itemID:"..itemID)

    local iseq = 0
    if isequip then
        iseq = 1
    end

	local net = p_net._g_net
    if net then
        net:_n_SendItemEquipOrUnEquip(skillMapID, tag, index, iseq,itemID,charaID)
    end
end
-------------------------------------------------------------------------------
function p_net:_SendSetWayPointIndex(typestr, idxstr, id, agent)
	print(self._name.." p_net:_SendSetWayPointIndex:")

    print("typestr:"..typestr)

    if "Path_SetWayPointIndex"==typestr  then
        print("Path_SetWayPointIndex:"..idxstr)

        local idx = StringHelp:StringToInt(idxstr)
        print("idx:"..idx)

        local scene = PX2_PROJ:GetScene()
        if scene then
            local mid = scene:GetID()
            local net = p_net._g_net
            if net then
                net:_n_SendSetWayPointIndex(typestr, idx, mid, id, agent)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_net:_RequestStateMachine(statemachinestr, userdata, id, statemode)
	print(self._name.." p_net:_RequestStateMachine:")
	local scene = PX2_PROJ:GetScene()
	if scene then
		local mid = scene:GetID()
		local net = p_net._g_net
		if net then
			net:_n_RequestStateMachine(statemachinestr, mid, userdata,
                id, statemode)
		end
	end
end
-------------------------------------------------------------------------------
function p_net:_SRequestState(mapid, charaid, posture, group, hp, rot, upper,
	subobjectsstr, userdatastr, posstrdirect)
	local net = p_net._g_net
	if net then
		net:_n_SRequestState(mapid, charaid, posture, group, hp, rot, upper,
			subobjectsstr, userdatastr, posstrdirect)
	end
end
-------------------------------------------------------------------------------
function p_net:_RequestEquipItem_RB(weaponid, itemtypeid,charaid)
	print(self._name.." p_net:_RequestEquipItem_RB")
    local scene = PX2_PROJ:GetScene()
    if scene then
        local mid = scene:GetID()
        local net = p_net._g_net
        if net then
            net:_n_RequestEquipItem_RB(weaponid, mid, itemtypeid, charaid)
        end
	end
end
-------------------------------------------------------------------------------