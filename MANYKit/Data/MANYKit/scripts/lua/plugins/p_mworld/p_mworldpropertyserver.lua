-- p_mworldpropertyserver.lua

-------------------------------------------------------------------------------
function p_mworld:_RegistPropertyOnServer()
    print(self._name.." p_mworld:_RegistPropertyOnServer")

    self._scriptControl:RemoveProperties("Server")

    self._scriptControl:BeginPropertyCata("Server")

    self._scriptControl:AddPropertyClass("Server", "服务器")
    self._scriptControl:AddPropertyButton("ResetState", "状态重置")
    self._scriptControl:AddPropertyButton("SaveState", "状态保存")
    self._scriptControl:AddPropertyButton("LoadState", "状态加载")
    self._scriptControl:AddPropertyButton("RemovePlayers", "移除用户")
    self._scriptControl:AddPropertyButton("OpenMap", "打开地图")

    self:_RefreshSetMapInfo()

    self._scriptControl:EndPropertyCata()

    if self._propertyGridServer then
        self._propertyGridServer:RegistOnObject(self._scriptControl, "Server")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnPropertyChangedServer(pObj)
    if "ResetState"==pObj.Name then
        self:_ServerReset()
    elseif "RemovePlayers"==pObj.Name then
        self:_ServerMapRemovePlayers()
    elseif "SaveState"==pObj.Name then
        self:_ServerSaveState()
    elseif "LoadState"==pObj.Name then
        self:_ServerLoadState()
    elseif "OpenMap"==pObj.Name then
        self:_ServerLoadMap()
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshSetMapInfo()
    local numRooms = PX2_SRMM:GetNumRooms()
    self._scriptControl:AddPropertyInt("NumRooms", "房间数", numRooms, false, false)

    local numMaps = 0
    local numCharas = 0
    if numRooms>0 then
        local sr = PX2_SRMM:GetRoomByIndex(0)
        if sr then
            numMaps = sr:GetNumMaps()
            if numMaps>0 then
                local sm = sr:GetMapByIndex(0)
                if sm then
                    numCharas = sm:GetNumSkillCharas()
                end
            end
        end
    end
    self._scriptControl:AddPropertyInt("NumMaps", "1房间地图数", numMaps, false, false)
    self._scriptControl:AddPropertyInt("NumCharas", "1房间1地图角色数", numCharas, false, false)
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshMapInfo()
    print(self._name.." p_holoserver:_RefreshMapInfo")

    self._scriptControl:BeginPropertyCata("Set")
    self:_RefreshSetMapInfo()
    self._scriptControl:EndPropertyCata()

    if self._propertyGridSet then
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "NumRooms")
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "NumMaps")
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "NumCharas")
    end
end
-------------------------------------------------------------------------------