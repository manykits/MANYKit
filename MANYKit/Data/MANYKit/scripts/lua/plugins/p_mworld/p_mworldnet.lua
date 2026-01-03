-- p_mowrldnet.lua

-------------------------------------------------------------------------------
function p_mworld:_OnLogicCallback(ptr, t, data)
    --print(self._name.." p_mworld:_OnLogicCallback")

    local dt = PX2JSon.decode(data)
    local t = dt.t

    if t=="h" then
        local net = p_net._g_net
        if net then
            p_net._recvHeartSeconds_Logic = 0.0
        end
    elseif t=="s_in_room" then
        print("s_in_room0:")

        local roomid = dt.roomid
        local mapuimode = dt.mapuimode
        local ctrlmode = dt.ctrlmode
        local runmode = dt.runmode
        local slammode = dt.slammode
        local lockmapid = dt.lockmapid
        local lockmapfilename = dt.lockmapfilename

        print("s_in_room1:")

        print("roomid:"..roomid)
        print("mapuimode:"..mapuimode)
        print("ctrlmode:"..ctrlmode)
        print("runmode:"..runmode)
        print("slammode:"..slammode)
        print("lockmapid:"..lockmapid)
        print("lockmapfilename:"..lockmapfilename)

        local url1 = ""
        local net = p_net._g_net
        if net then
            --_OpenMap:http://192.168.6.10:6606/10013.xml
            local outPath = StringHelp:SplitFullFilename_OutPath(lockmapfilename)
			local outBase = StringHelp:SplitFullFilename_OutBase(lockmapfilename)
			local outExt = StringHelp:SplitFullFilename_OutExt(lockmapfilename)

            url1 = "http://"..p_net.g_ip_logic..":6606/server/maps/"..outBase.."."..outExt
            print("url1:"..url1)

            --/Write_MANYKit/maps/10013.xml
            local filename = outBase.."."..outExt

            local charaid = dt.charaid
            local typeid = dt.typeid
            local uin = dt.uin

            print("charaid:"..charaid)
            print("uin:"..uin)
            print("p_net.uin:"..g_manykit._uin)

            if uin==g_manykit._uin then
                self._curroomid = roomid

                local cntLogic = PX2_APP:CreateGetGeneralClientConnector("NetConnector_Logic")
                if cntLogic then
                    cntLogic:SetUserDataString("roomid", roomid)
                end
               
                local url = PX2_PROJ:GetConfig("lastmap_url")
                local id = PX2_PROJ:GetConfig("lastmap_id")
                local filename = PX2_PROJ:GetConfig("lastmap_filename")
                if ""~=url then
                    local url = "http://"..p_net.g_ip_logic..":6606/server/maps/"..filename
                    self:_OpenMap(url, id, filename)
                end
            end
        end
    elseif t=="s_in_map" then
        print("s_in_map")
        print("t:"..t)
        --print("data:"..data)

        local mid = dt.mapid
        local cid = dt.charaid
        local uin = dt.uin
        local typeid = dt.typeid

        print("mid:"..mid)
        print("cid:"..cid)
        print("typeid:"..typeid)
        print("uin:"..uin)

        local pos = APoint:SFromString(dt.pos)
        local rot = APoint:SFromString(dt.rot)

        if mid == self._curmapid then
            self:_MapPeopleAdd(uin, cid, pos, rot, dt.items, dt.itemsequip)
        end
    elseif t=="s_map_members" then
        print("s_map_members")

        local roomid = dt.roomid
        local mid = dt.mapid

        if mid == self._curmapid then
            local idsmembers = {}
            for key, value in pairs(dt.members) do
                local mem = value
                local cid = mem.id
                table.insert(idsmembers, #idsmembers + 1, cid)
            end
            local idsnotinmember = {}
            if self._listPeoples then
                local numItems = self._listPeoples:GetNumItems()
                for i=0, numItems-1, 1 do
                    local item = self._listPeoples:GetItemByIndex(i)
                    if item then
                        local idstr = item:GetUserDataString("id")
                        local id = StringHelp:SToI(idstr)
                        local isIn = item:GetUserDataString("isin")=="1"

                        if not manykit_IsInArray(id, idsmembers) and isIn then
                            table.insert(idsnotinmember, #idsnotinmember + 1, id)
                        end
                    end
                end
            end

            self:_MapPeopleRemoveIDs(idsnotinmember)

            for key, value in pairs(dt.members) do
                local mem = value
                local cid = mem.id
                local groupid = mem.groupid
                local typeid = mem.typeid
                local monsterid = mem.monsterid
                local uin = mem.uin
                local pos = APoint:SFromString(mem.pos)
                local rot = APoint:SFromString(mem.rot)
                local hp = mem.hp
                local sm = mem.sm
                local ud = mem.userdata
                local items = mem.items
                local quickbaritems = mem.quickbaritems
                local equipitems = mem.equipitems

                print("cid:"..cid.." uin:"..uin)
                
                if uin>0 then
                    self:_MapPeopleAdd(uin, cid, pos, rot, nil, nil)
                end

                self:_OnSetCharaState(cid, hp, pos, rot, sm, ud)
                self:_OnSetCharaItems(cid, items)
                self:_OnSetCharaQuicklBarItems(cid, quickbaritems)
                if equipitems then
                    self:_OnMapMembersInitEquipItems(cid, equipitems)
                end
            end     

            if not self._isMapFirstInited then
                local scene = PX2_PROJ:GetScene()
                if scene then
                    scene:Update()
                    self:_UpdateScemeNav()
                end
                
                self._isMapFirstInited = true
            end
        end
    elseif t=="s_out_map" then
        print("s_out_map")

        local net = p_net._g_net
        if net then
            local roomid = dt.roomid
            local mid = dt.mapid
            local cid = dt.charaid
            local uin = dt.uin
            self:_MapPeopleRemove(uin, cid)
        end
    elseif t=="map_close" then
        local mid = dt.mid
        local uin = dt.uin
        local net = p_net._g_net
        if net then
            if uin == g_manykit._uin then
                self:_OnCloseMap(mid)
            end
        end
    elseif t=="m_addobj" then
        print("m_addobj")
        local uin = dt.uin
        local id = dt.id
        local mid = dt.mid
        local typeid = dt.typeid
        local itemid = dt.itemid
        local posstr = dt.pos
        local rotstr = dt.rot
        local scalestr = dt.scale
        local group = dt.group
        local hp = dt.hp
        local allname = dt.allname
        local posliststr = dt.posliststr

        local pos = APoint:SFromString(posstr)
        local rot = APoint:SFromString(rotstr)
        local scale = APoint:SFromString(scalestr)

        if self._curmapid == mid then
            self:_OnRequestAddObject(id, typeid, itemid, pos, rot, 
                uin, 
                scale,
                nil, nil, group, hp, allname, posliststr)
        end
    elseif t=="m_delobj" then
        local id = dt.id
        local mid = dt.mid
        if self._curmapid == mid then
            self:_OnRequestDeleteObj(id)
        end
    elseif t=="m_transobj" then
        local id = dt.id
        local mid = dt.mid
        local scale = APoint:SFromString(dt.scale)
        local rot = APoint:SFromString(dt.rot)
        local pos = APoint:SFromString(dt.pos)
        if self._curmapid == mid then
            self:_OnRequestTranslateObj(id, scale, rot, pos, false)
        end
    elseif t=="m_setobj" then
        local id = dt.id
        local mid = dt.mid
        local dtdata = dt.data
        local props = dtdata.properties
        self:_OnMapPropertyObjectSetFromNet(mid, id, props)
    elseif t=="map_add" then
        print("map_add")
        p_net._g_net:_GetRefreshMap(self._listMap)
    elseif t=="map_delete" then
        print("map_delete")
        p_net._g_net:_GetRefreshMap(self._listMap)
    elseif t=="map_list" then
        print("map_list")
        local dtdata = dt.data

        if self._listMap then
            self._listMap:RemoveAllItems()
        end

        for i=1, #dtdata, 1 do
            local dd = dtdata[i]

            print("name:"..dd.n)
            print("id:"..dd.id)
            print("filename:"..dd.f)
            print("trainid:"..dd.trainid)
            print("isoverdate:")
            print_i_b(dd.isoverdate)

            local net = p_net._g_net
            if net then
                if 0==dd.trainid or dd.trainid == p_net._activetrainid then
                    local url1 = "http://"..p_net.g_ip_logic..":6606/server/maps/"..dd.f
                    print("url1:"..url1)

                    local textName = dd.n..":"..dd.id
                    local item = self._listMap:AddItem(textName)
                    item:SetUserDataString("filename", dd.f)
                    item:SetUserDataString("id", dd.id)
                    item:SetUserDataString("url", url1)
                end
            end
        end
    elseif t=="map_set" then
        print("map_set")
        local mid = dt.mid
        local propname = dt.propname
        local dtdata = dt.data
        local props = dtdata.properties
        self:_MapPropertySetFromNet(mid, props, propname)
    elseif t=="map_simu" then
        local mid = dt.mid
        local simu = dt.simu
        if self._curmapid == mid then
            self:_OnSimu(1==simu)
        end
    elseif t=="m_a_state_trans" then
        local mid = dt.mid
        local id = dt.id
        local pos = APoint:SFromString(dt.pos)
        local rot = APoint:SFromString(dt.rot)
        local scale = APoint(1.0, 1.0, 1.0)
        if self._curmapid == mid then
            self:_OnRequestTranslateObj(id, scale, rot, pos, true)
        end
    elseif t=="s_chara_state" then
        print("s_chara_state")

        local charaid = dt.idto
        local hp = dt.hp

        self:_OnSetCharaState(charaid, hp, nil, nil, nil, nil)
    elseif t=="s_skillinstance" then
        local roomid = dt.roomid
        local mapid = dt.mapid
        local fromcharaid = dt.fromcharaid
        local fromskillid = dt.fromskillid
        local fromskilltypeid = dt.fromskilltypeid
        local frompos = APoint:SFromString(dt.frompos)
        local fromdir = AVector:SFromString(dt.fromdir)
        local aimtargetid = dt.aimtargetid
        local targetpos = APoint:SFromString(dt.targetpos)
        local pointstr = dt.pointstr
        PX2_SKILLB:S2C_CharacterActivateSkillInstance(roomid, mapid, fromcharaid, fromskillid, fromskilltypeid, frompos, fromdir, aimtargetid, targetpos, pointstr)
    elseif t=="m_a_statemachine" then
        print("m_a_statemachine")

        local mid = dt.mapid
        local charaid = dt.charaid
        local sm = dt.sm
        local userdata = dt.userdata
        local statemode = dt.statemode

        if mid == self._curmapid then
            self:_OnRequestStateMachine(charaid, sm, userdata, statemode)
        end
    elseif t=="m_a_state" then
        local mid = dt.mapid
        local charaid = dt.charaid
        if mid == self._curmapid then
            self:_OnRequestState(dt)
        end
    elseif t=="m_a_equipitem_rb" then
        print("m_a_equipitem_rb")

        local mid = dt.mapid
        local charaid = dt.charaid

        print("mid:"..mid)
        print("charaid:"..charaid)

        if mid == self._curmapid then
            self:_OnRequestEquipItem_RB(dt)
        end
    elseif t=="s_itemupdate" then
        print("s_itemupdate")
        
        local str = PX2JSon.encode(dt)
        print(str)

        local mid = dt.mapid
        local charaid = dt.charaid

        print("mid:"..mid)
        print("charaid:"..charaid)

        if mid == self._curmapid then
            self:_OnUpdateItem(dt)
        end
    elseif t=="map_load" then
        print("map_load")

        local url = dt.url
        local mid = dt.mapid
        local filename = dt.filename

        if not p_net._g_net._islogicserver  then
            self:_OpenMap(url, mid, filename)
        end
    elseif t=="m_a_steeringbehavior" then
        --print("m_a_steeringbehavior")

        local mid = dt.mid
        if mid == self._curmapid then
            self:_OnSteeringBehavior(dt)
        end
    elseif t=="s_items" then
        local cid = dt.charaid
        self:_CharacterSetItems(dt)
    elseif t=="m_a_itemequipornot" then
        local scene = PX2_PROJ:GetScene()
        self:_EquipItemOrNot(true, scene, dt)
    end   
end
-------------------------------------------------------------------------------
function p_mworld:_SendReConnect()
    print(self._name.." p_mworld:_SendReConnect")

    if self._curmapid > 0 then
        local scene = PX2_PROJ:GetScene()
        if scene then
            local mainActor = scene:GetMainActor()
            if mainActor then
                local agentBase = mainActor:GetAIAgentBase()
                local pos = agentBase:GetPosition()
                local rotXYZ = agentBase:GetRotateDegreeXYZ()
                local net = p_net._g_net
                if net then
                    net:_SendInMap(self._curmapid, pos, rotXYZ, false)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RequestAddObject(itemid, typeid, posstr, uinn, rotstr,
    scalestr, group, hp, allname, posliststr)

    p_net._g_net:_RequestAddObject(itemid, typeid, posstr, uinn,
        rotstr, scalestr, group, hp, self._curmapid, allname, posliststr)
end
-------------------------------------------------------------------------------
function p_mworld:_RequestDeleteObj(id)
	print(self._name.." p_mworld:_RequestDeleteObj:"..id)
    p_net._g_net:_RequestDeleteObj(id, self._curmapid)
end
-------------------------------------------------------------------------------
function p_mworld:_GetScenePropertyAndSend(propName)
    print(self._name.." p_mworld:_GetScenePropertyAndSend")
    p_net._g_net:_GetScenePropertyAndSend(self, propName,self._curmapid)
end
-------------------------------------------------------------------------------