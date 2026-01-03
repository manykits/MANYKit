-- p_mworldmappeople.lua

-------------------------------------------------------------------------------
function p_mworld:_MapPeopleRemoveIDs(ids)
    local net = p_net._g_net
    if net then
        local scene = PX2_PROJ:GetScene()
        if scene then
            self:_OnDisSelectObj(false)

            for key, value in pairs(ids) do
                local id = value
                print("remove id:"..id)
                
                if self._listPeoples then
                    local item = self._listPeoples:GetItemByUserDataString("id", ""..id)
                    if item then
                        local peo = p_net._g_peoplesall[id]
                        if peo then
                            local uidstr = id..":"..peo.name
                            if ""~=peo.nickname then
                                uidstr = uidstr.."-"..peo.nickname
                            end
                            item:GetFText():GetText():SetText(uidstr)
                            item:SetUserDataString("isin", "0")
                        end    
                        self:_OnRequestDeleteObj(id)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshMapItemListCataPeople(cata)
	print(self._name.." p_mworld:_RefreshMapItemListCataPeople:"..cata)

    self._peopleCata = cata

    self:_PeopleListSyn()
end
-------------------------------------------------------------------------------
function p_mworld:_PeopleListSyn()
    print(self._name.." p_mworld:_PeopleListSyn")

    if self._listPeoples then
        self._listPeoples:RemoveAllItems()
    end

    local scene = PX2_PROJ:GetScene()
    local net = p_net._g_net
    if net then
        for key, value in pairs(p_net._g_peoplesall) do
            local cid = key
            local uin = key
            local peo = value
            if peo and "1"==peo.state and peo.party=="" or peo.party==p_net._g_net._peopleActorPartyStr or ""==p_net._g_net._peopleActorPartyStr then
                local uidstr = cid..":"..peo.name
                if ""~=peo.nickname then
                    uidstr = uidstr.."-"..peo.nickname
                end

                local add = false
                if "all" == self._peopleCata then
                    add = true
                end

                local act = scene:GetActorFromMap(cid)
                if act then
                    uidstr = uidstr.."-在图"

                    if "inmap"==self._peopleCata then
                        add = true
                    end
                else
                    if "outmap"==self._peopleCata then
                        add = true
                    end
                end

                if add then 
                    if self._listPeoples then
                        local item = self._listPeoples:AddItem(uidstr)
                        item:SetUserDataString("uin", ""..uin)
                        item:SetUserDataString("id", ""..cid)
                        item:GetFText():GetText():SetFontScale(0.65)
                        item:GetFText():SetAnchorParamHor(2.0, 0.0)
                        if act then
                            item:SetUserDataString("isin", "1")
                            if not manykit_IsInArray(cid, self._CharactersEverIn) then
                                table.insert(self._CharactersEverIn, #self._CharactersEverIn, cid)
                            end
                        else
                            item:SetUserDataString("isin", "0")
                        end
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_MapPeopleAdd(uin, cid, pos, rot, items, itemsequip)
    print(self._name.." p_mworld:_MapPeopleAdd")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local tm = 0
        local terrain = scene:GetTerrain()
        if terrain then
            tm = terrain:GetTerrainMode()
        end
        local act = scene:GetActorFromMap(cid)
        if nil==act then
            local net = p_net._g_net
            if net then
                print("uin:"..uin)
                print("g_manykit._uin:"..g_manykit._uin)

                local actID = 10002
                self:_OnRequestAddObject(cid, actID, 0, pos, rot, uin, nil, items, itemsequip)
    
                if uin == g_manykit._uin then     
                    if 1==self._mapOpenRunMode then       
                        if tm~=Terrain.TM_GISING then
                            PX2_GH:SendGeneralEvent("TerrainHeightUpdateMePos")
                        end
                    end
                end
            end
        end
    end

    local net = p_net._g_net
    if net then
        if self._listPeoples then
            local item = self._listPeoples:GetItemByUserDataString("uin", ""..uin)
            if item then
                local cidstr = item:GetUserDataString("id")
                local cid = StringHelp:SToI(cidstr)

                local peo = p_net._g_peoplesall[cid]
                if peo then
                    local uidstr = cid..":"..peo.name
                    if ""~=peo.nickname then
                        uidstr = uidstr.."-"..peo.nickname
                    end
                    uidstr = uidstr.."-在图"

                    item:SetUserDataString("isin", "1")
                    item:GetFText():GetText():SetText(uidstr)

                    if not manykit_IsInArray(cid, self._CharactersEverIn) then
                        table.insert(self._CharactersEverIn, #self._CharactersEverIn, cid)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_MapPeopleRemove(uin, cid)
    local net = p_net._g_net
    if net then
        self:_OnRequestDeleteObj(cid)
    
        if self._listPeoples then
            local item = self._listPeoples:GetItemByUserDataString("uin", ""..uin)
            if item then
                local peo = p_net._g_peoplesall[cid]
                if peo then
                    local uidstr = cid..":"..peo.name
                    if ""~=peo.nickname then
                        uidstr = uidstr.."-"..peo.nickname
                    end
                    item:GetFText():GetText():SetText(uidstr)
                    item:SetUserDataString("isin", "0")
                end
            end
        end
    end
end
-------------------------------------------------------------------------------