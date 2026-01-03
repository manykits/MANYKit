-- p_mworldserver.lua

-------------------------------------------------------------------------------
function p_mworld:_ServerReset()
    print(self._name.." p_mworld:_ServerReset")

    local net = p_net._g_net
    if net then
        net:_SendCmd("serverrest")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ServerMapRemovePlayers()
    print(self._name.." p_mworld:_ServerMapRemovePlayers")

    local net = p_net._g_net
    if net then
        net:_SendCmd("servermapremoveplayers")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ServerSaveState()
    print(self._name.." p_mworld:_ServerSaveState")
    -- only server cando this

    local net = p_net._g_net
    if net then
        net:_SendCmd("serversavestate")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ServerLoadState()
    print(self._name.." p_mworld:_ServerLoadState")

    local net = p_net._g_net
    if net then
        net:_SendCmd("serverloadstate")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ServerLoadMap()
    print(self._name.." p_mworld:_ServerLoadMap")

    local item = self._listMap:GetItemByUserDataString("id", ""..self._curmapid)
    if item then
        local url = item:GetUserDataString("url")
        local filename = item:GetUserDataString("filename")

        print("id:"..self._curmapid)
        print("url:"..url)
        print("filename:"..filename)

        local tab = {
            t = "map_load",
            mapid = self._curmapid,
            url = url,
            filename = filename,
        }
        local jstr = PX2JSon.encode(tab)

        -- only server cando this
        print("self._curroomid:"..self._curroomid)
        if self._curroomid>0 then
            local room = PX2_SRMM:GetRoomByID(self._curroomid)
            if room then        
                room:BroadcastJSON(jstr)
            end
        end
    end
end
-------------------------------------------------------------------------------