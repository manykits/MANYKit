-- p_holoserver.lua
-------------------------------------------------------------------------------
p_holoserver = class(p_ctrl,
{
	_name = "p_holoserver",

    _requires = {},

    -- property
	_propertyGrid = nil,

    _ip_http_appserver_s = "127.0.0.1",
    _port_http_appserver_s = 6606,

    _ipindex_localnetclients = 0,

    _cloudSceneData = {},
    _scenes = {},
    _IsLoadSceneState = false,

    -- cfg
    _isDoSceneSave = true,
})
-------------------------------------------------------------------------------
function p_holoserver:OnAttached()
	PX2_LM_APP:AddItem(self._name, "HoloServer", "服务器")

    p_ctrl.OnAttached(self)
	print(self._name.." p_holoserver:OnAttached")

    PX2_APPSERVER:AddScriptHandler("_OnServerCallback", self._scriptControl)
    local serverMapPath = g_manykit._writePathProj.."server/maps/"
    PX2_APPSERVER:HttpRouterUpload("/uploadterrain", serverMapPath)

    -- defs
    PX2_SDM:ReLoadAllDefs("MANYKit")

    -- cnt
    self:_CreateContentFrame()

    self:_ReStartHttpServer()
end
-------------------------------------------------------------------------------
function p_holoserver:OnInitUpdate()
	print(self._name.." p_holoserver:OnInitUpdate")

    -- local map
    self:_LoadMaps()
end
-------------------------------------------------------------------------------
function p_holoserver:_ReStartHttpServer()
	print(self._name.." p_holoserver:_ReStartHttpServer")
    print("self._ip_http_appserver_s:"..self._ip_http_appserver_s)

    PX2_APPSERVER:StopHttpServer()

    PX2_APPSERVER:SetHttpServerIP(self._ip_http_appserver_s)
	local wp = "Write_" .. PX2_PROJ:GetName() .. "/"
	local wp1 = ResourceManager:GetWriteablePath()..wp
    PX2_APPSERVER:StartHttpServer(wp1, self._port_http_appserver_s)
end
-------------------------------------------------------------------------------
function p_holoserver:_Cleanup()
	print(self._name.." p_holoserver:_Cleanup")

    PX2_APPSERVER:Shutdown()
end
-------------------------------------------------------------------------------
function p_holoserver:OnPluginInstanceSelected(act)
    print(self._name.." p_holoserver:OnPluginInstanceSelected")

    p_ctrl.OnPluginInstanceSelected(self, act)

    self:_RegistOnProperty()
end
-------------------------------------------------------------------------------
-- ui
function p_holoserver:_CreateContentFrame()
    print(self._name.." p_holoserver:_CreateContentFrame")

    local frame = UIFrame:New()
    self._frameContent = frame
	self._frame:AttachChild(frame)
    frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
	frame:SetAnchorVer(0.0, 1.0)
    frame:SetWidget(true)

	local back = frame:CreateAddBackgroundPicBox(true, Float3(0.0, 0.0, 0.0))
    back:UseAlphaBlend(true)
    back:SetAlpha(0.65)

    local pg = UIPropertyGrid:New("PropertyGrid")
    self._propertyGrid = pg
    frame:AttachChild(pg)
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.0, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl)
    pg:GetUISplitterFrame():SetAnchorHor(0.45, 0.45)
	
	self:_RegistOnProperty()

    return frame
end
-------------------------------------------------------------------------------
function p_holoserver:_RegistOnProperty()
    print(self._name.." p_holoserver:_RegistOnProperty")

	self._scriptControl:RemoveProperties("HoloServer")
    self._scriptControl:BeginPropertyCata("HoloServer")

    self._scriptControl:AddPropertyClass("AppServer", "AppServer")

    local isappserveropenstr = PX2_PROJ:GetConfig("isappserveropen")
    if "1"==isappserveropenstr then
        PX2_APPSERVER:Start()
    end
	self._scriptControl:AddPropertyBool("IsAppServerOpen", "是否开启", PX2_APPSERVER:IsStarted(), true, false)

    self._scriptControl:AddPropertyInt("PortServer", "PortServer", PX2_APPSERVER:GetPort(), false, false)

    local iptabs = {}
	local numAddr = PX2_APP:GetLocalAddressSize()
    for i=0, numAddr-1, 1 do
        local ip = PX2_APP:GetLocalAddressStr(i)
        if ""~=ip then
            table.insert(iptabs, #iptabs + 1, ip)
        end
    end
    local ip_http_appserver_s = PX2_PROJ:GetConfig("ip_http_appserver_s")
    if ""~=ip_http_appserver_s then
        self._ip_http_appserver_s = ip_http_appserver_s
    end
	PX2Table2Vector(iptabs)
	local vec = PX2_GH:Vec()
	PX2Table2Vector(iptabs)
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData1("IPHttpServer", "IPHttpServer", self._ip_http_appserver_s, vec, vec1, vec2, true, false)

    self._scriptControl:AddPropertyInt("PortHttpServer", "PortHttp", self._port_http_appserver_s, false, false)
	
    -- local map
    self._scriptControl:AddPropertyClass("LocalMap", "本地地图")
    local l = self:_GetMapList()    
    for key, value in pairs(l) do
        local id = value.id
        local n = value.n
        local f = value.filename
        self._scriptControl:AddPropertyString(""..id, ""..id, n, false, false)
    end

    -- local
    self._scriptControl:AddPropertyClass("LocalNetDevicesClass", "局域网设备")
    PX2Table2Vector({})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
    self._scriptControl:AddPropertyEnumUserData("LocalNetDevices", "局域网设备", self._ipindex_localnetclients, vec, vec1, vec2, true, false)
    self._scriptControl:AddPropertyButton("ConnectMe", "连接我")

	self._scriptControl:EndPropertyCata()

	self._propertyGrid:RegistOnObject(self._scriptControl, "HoloServer")

    self:_RefreshUDPNetInfo()
end
-------------------------------------------------------------------------------
function p_holoserver:_RefreshAppServerStart()
    print("p_holoserver:_RefreshAppServerStart")

    self._scriptControl:BeginPropertyCata("HoloServer")
	self._scriptControl:AddPropertyBool("IsAppServerOpen", "是否开启", PX2_APPSERVER:IsStarted(), true, false)
    self._scriptControl:EndPropertyCata()
    
    self._propertyGrid:UpdateOnObject(self._scriptControl, "HoloServer", "IsAppServerOpen")
end
-------------------------------------------------------------------------------
function p_holoserver:_RefreshUDPNetInfo()
    print("p_holoserver:_RefreshUDPNetInfo")

    local tabs = {}
    local numInfos = PX2_APP:GetNumUDPNetInfo()
    for i=0, numInfos-1, 1 do
        local info = PX2_APP:GetUDPNetInfo(i)
        local ip = info.IP

        print("ip:"..ip)

        table.insert(tabs, #tabs + 1, ip)
    end

    PX2Table2Vector(tabs)
	local vec = PX2_GH:Vec()
	PX2Table2Vector(tabs)
    self._scriptControl:BeginPropertyCata("HoloServer")
    self._scriptControl:AddPropertyEnum("LocalNetDevices", "局域网设备", self._ipindex_localnetclients, vec, true, false)
    self._scriptControl:EndPropertyCata()
    
    self._propertyGrid:UpdateOnObject(self._scriptControl, "HoloServer", "LocalNetDevices")
end
-------------------------------------------------------------------------------
function p_holoserver:_OnServerCallback(ptr, t, clientstr, data)
    --print("p_holoserver:_OnServerCallback t:")
    --print(t)

    local cid = StringHelp:StringToInt(clientstr)
    local player = PX2_SPM:GetPlayerByClientID(cid)

    if t=="connect" then
        local svr = p_net._g_net._ncLogic:GetAppServerLocalDirect()
        if svr==PX2_APPSERVER then
            p_net._g_net._ncLogic:SetAppServerLocalDirectClientID(cid)
        end
    elseif t=="disconnect" then

    elseif t=="json" then
        local tab = PX2JSon.decode(data)

        if "m_a_state_trans"~=tab.t and "h"~=tab.t and tab.t~="m_a_steeringbehavior" then
            print("t:"..t)
            print("data:"..data)
            print("cid:"..cid)
        end

        if "h"==tab.t then     
            --print("server heart cid:"..cid)
            
            local dt = {
                t = "h",
            }
            local dtjsonstr = PX2JSon.encode(dt)            
            PX2_APPSERVER:SendClientJSON(cid, dtjsonstr)
        elseif "in"==tab.t then
            local uin = tab.uin
            player:SetUIN(uin)
            player:SetState(PST_IN_APP)
        elseif "out"==tab.t then
            player:SetState(PST_INIT)
        elseif "in_room"==tab.t then
            local roomstr = tab.room
            local typeid = tab.typeid

            local room = PX2_SRMM:GetRoomByName(roomstr)
            if room then
                local uin = player.UIN
                room:ComeInChara(cid, uin, typeid, 0, SkillChara.GT_0, true)
            end
            player:SetState(PST_IN_ROOM)
        elseif "out_room"==tab.t then
            local roomstr = tab.room
            local room = PX2_SRMM:GetRoomByName(roomstr)
            if room then
                local sc = player:GetChara()
				local id = sc:GetID()
				room:GoOutChara(id)
            end
            player:SetState(PST_IN_APP)
        elseif "in_map"==tab.t then
            print("in_map")

            local mapid = tab.mid
            local pos = APoint:SFromString(tab.pos)
            local rot = APoint:SFromString(tab.rot)
            local transgetfromserver = tab.transgetfromserver

            local sc = player:GetChara()
            if sc then
                local id = sc:GetID()
                local roomid = sc:GetRoomID()
                local room = PX2_SRMM:GetRoomByID(roomid)
                if room then
                    if "1"==transgetfromserver then
                        pos = sc:GetPosition()
                        rot = sc:GetRotation()
                    end

                    self:_CheckLoadMapState(mapid, sc)

                    print("room begin EnterMap")
                    room:EnterMap(mapid, id, pos, rot);
                    print("room begin LeaveMap")
                end
            end
            print("in_map end")
        elseif "map_close"==tab.t then
            print("map_close")

            player:SetState(PST_IN_ROOM)

            local sc = player:GetChara()
            local id = sc:GetID()
            local roomid = sc:GetRoomID()
            local room = PX2_SRMM:GetRoomByID(roomid)
            if room then
                room:LeaveMap(id)
            end

            local dtjsonstr = PX2JSon.encode(tab)            
            PX2_APPSERVER:SendClientJSON(cid, dtjsonstr)
        elseif "map_add"==tab.t then
            print("map_add")
            local name = tab.name
            self:_CreateMap(name)

            local dtjsonstr = PX2JSon.encode(tab)            
            PX2_APPSERVER:SendClientJSON(cid, dtjsonstr)
        elseif "map_list"==tab.t then
            print("map_list")

            local l = self:_GetMapList()        
            local dt = {
                t = "map_list",
                data=l,
            }
            local dtjsonstr = PX2JSon.encode(dt)   
            
            print("dtjsonstr:")
            print(dtjsonstr)
            
            PX2_APPSERVER:SendClientJSON(cid, dtjsonstr)
        elseif "map_delete"==tab.t then
            print("map_delete")
            local id = tab.id
            local idi = StringHelp:StringToInt(id)
            self:_DeleteScene(idi)
            local dtjsonstr = PX2JSon.encode(tab)       
            PX2_APPSERVER:SendClientJSON(cid, dtjsonstr)
        elseif "map_set"==tab.t then
            print("map_set")

            local mid = tab.mid
            self:_SetScene(mid, tab)

            local jsstr = PX2JSon.encode(tab)
            PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr)
        elseif "map_reset"==tab.t then
            print("map_reset")

            local mapid = tab.mapid
            print("mapid:"..mapid)

            self:_ResetMapPlayers(mapid)   
                            
        elseif "m_addobj"==tab.t then
            print("m_addobj")
            
            local uin = tab.uin
            if uin and ""~=uin and 0~=uin and "0"~=uin then
                tab.id = uin
            else
                tab.id = self:_GenNextMapObjID()
            end

            local iID = StringHelp:StringToInt(""..tab.id)
            local mapid = tab.mid
            local scene = self._scenes[mapid]
            if scene then
                local actor = scene:GetActorFromMap(iID)
                if nil==actor then
                    local ret = self:_CreateActor(tab)
                    if ret then
                        local jsstr = PX2JSon.encode(tab)     
                        PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr)
                    end
                end
            end
        elseif "m_delobj"==tab.t then
            print("m_delobj")
            local id = tab.id
            print("id:"..id)

            self:_DeleteActor(tab)

            local jsstr = PX2JSon.encode(tab)             
            PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr)
        elseif "m_transobj"==tab.t then
            print("m_transobj")

            self:_TransActor(tab)

            local a = tab.a
            local jsstr = PX2JSon.encode(tab)             
            PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr, a~="b1")
        elseif "m_setobj"==tab.t then
            print("m_setobj")
            self:_SetMapObj(tab)

            local jsstr = PX2JSon.encode(tab)               
            PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr)
        elseif "map_simu"==tab.t then
            print("map_simu")

            local sc = player:GetChara()
            if sc then
                local id = sc:GetID()
                local roomid = sc:GetRoomID()

                local jsstr = PX2JSon.encode(tab)
                PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr)
            end
        elseif "m_a_state_trans"==tab.t then
            --print("m_a_state:")
            if player then
                local chara = player:GetChara()
                if chara then                   
                    local pos = APoint:SFromString(tab.pos)
                    local rot = APoint:SFromString(tab.rot)
                    chara:SetPosition(pos)
                    chara:SetRotation(rot)
                end
                local jsstr = PX2JSon.encode(tab)
                PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr, true)
            end
        elseif "m_a_statemachine"==tab.t then
            local mapid = tab.mapid
            local charaid = tab.charaid
            local userdata = tab.userdata
            local scene = self._scenes[mapid]
            if scene then
                local act = scene:GetActorFromMap(charaid)
                if act then
                    local sc = act:GetSkillChara()
                    sc:SetStateMachine(tab.sm)
                    if userdata then
                        sc:SetUserDataString("userdata", userdata)
                    end
                end
            end
            if player then   
                local jsstr = PX2JSon.encode(tab)
                PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr, true)
            end
        elseif "m_a_state"==tab.t then
            local mapid = tab.mapid
            local charaid = tab.charaid
            local scene = self._scenes[mapid]
            
            if scene then
                local act = scene:GetActorFromMap(charaid)
                p_mworld._OnProcessState(p_mworld, false, act, tab)
            end

            if player then   
                local jsstr = PX2JSon.encode(tab)
                PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr, true)
            end
        elseif "m_a_equipitem_rb"==tab.t then
            if player then   
                local jsstr = PX2JSon.encode(tab)
                PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr, true)
            end
        elseif "m_a_steeringbehavior"==tab.t then
            if player then
                local jsstr = PX2JSon.encode(tab)
                PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr, true)
            end
        elseif "m_a_quickbaritem"==tab.t then
            self:_SetQuickBarItem(tab)
        elseif "m_a_itemequipornot"==tab.t then
            local mapid = tab.mapid
            local scene = self._scenes[mapid]
            p_mworld._EquipItemOrNot(p_mworld, false, scene, tab)

            if self._isDoSceneSave then
                local map = scene:GetSkillMap()
                if map then
                    map:SaveState()
                end
            end
            
            local jsstr = PX2JSon.encode(tab)
            PX2_APPSERVER:BoradCastClientRoomJSON(cid, jsstr, false)
        elseif "cmd_send"==tab.t then
            local txt = tab.text
            print("server cmd_send:"..txt)

            txt = txt:gsub("[%c]", "")

            local stk = StringTokenizer(txt, " ")
            local cnt = stk:Count()
            local cmd = ""
            local cmd1 = ""
            local cmd2 = ""
            local cmd3 = ""
            if cnt>0 then
                cmd = stk:GetAt(0)
            end
            if cnt>1 then
                cmd1 = stk:GetAt(1)
            end
            if cnt>2 then
                cmd2 = stk:GetAt(2)
            end
            if cnt>3 then
                cmd3 = stk:GetAt(3)
            end

            print("cmd:"..cmd)
            print("cmd1:"..cmd1)
            print("cmd2:"..cmd2)
            print("cmd3:"..cmd3)

            local sc = player:GetChara()
            if sc then
                local skillMap = sc:GetSkillMap()                
                if skillMap then                
                    local mapid = skillMap:GetID()
                    print("mapid:"..mapid)
                    local scene = self:_GetSceneByID(mapid)            
                    if scene then
                        print("-----------------------")

                        if "itemaddall"==cmd then
                            local targetsc = sc
                            if ""~=cmd1 then
                                local charaid = StringHelp:StringToInt(cmd1)
                                targetsc = skillMap:GetSkillChara(charaid)
                            end
                            if targetsc then
                                targetsc:RemoveAllItems()              
                                targetsc:AddDefItemsByCata("all", 1)

                                if self._isDoSceneSave then
                                    skillMap:SaveState()   
                                end                     
                                PX2_SNF:BroadcastCharaItems(targetsc)
                            end
                        elseif "itemclear"==cmd then
                            print("itemclearrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")

                            local targetsc = sc
                            if ""~=cmd1 then
                                local charaid = StringHelp:StringToInt(cmd1)
                                targetsc = skillMap:GetSkillChara(charaid)
                            end
                            if targetsc then
                                targetsc:RemoveAllItems()
                                if self._isDoSceneSave then
                                    skillMap:SaveState()
                                end                    
                                PX2_SNF:BroadcastCharaItems(targetsc)
                            end                            
                        elseif "itemaddcata"==cmd then
                            print("itemaddcata:")

                            local targetsc = sc
                            local cata = "army"

                            if ""~=cmd1 and ""~=cmd2 then
                                local charaid = StringHelp:StringToInt(cmd1)
                                print("charaiddddddddddddddddd:"..charaid)
                                targetsc = skillMap:GetSkillChara(charaid)
                                cata = cmd2
                            elseif ""~=cmd1 then
                                targetsc = sc
                                cata = cmd1
                            end
                            if targetsc then
                                print("itemaddcata AddDefItemsByCata:"..cata)
                                print("cata:")
                                print(cata)

                                targetsc:AddDefItemsByCata(""..cata, 1)
                                
                                if self._isDoSceneSave then
                                    skillMap:SaveState()       
                                end                 
                                PX2_SNF:BroadcastCharaItems(targetsc)
                            end
                        elseif "itemadd"==cmd then
                            local targetsc = sc
                            local itemidstr = 0
                            if ""~=cmd1 and ""~=cmd2 then
                                local charaid = StringHelp:StringToInt(cmd1)
                                targetsc = skillMap:GetSkillChara(charaid)
                                itemidstr = cmd2
                            elseif ""~=cmd1 then
                                targetsc = sc
                                itemidstr = cmd1
                            end

                            local itemid = StringHelp:StringToInt(itemidstr)
                            if targetsc then
                                targetsc:AddDefItem(itemid, 1)
                                if self._isDoSceneSave then
                                    skillMap:SaveState()       
                                end                 
                                PX2_SNF:BroadcastCharaItems(targetsc)
                            end
                        elseif "serverrest"==cmd then
                            skillMap:ResetMapActors()
                        elseif "servermapremoveplayers"==cmd then
                            skillMap:RemoveCharaNoPlayers()

                        elseif "serversavestate"==cmd then
                            skillMap:SaveState()
                        elseif "serverloadstate"==cmd then
                            skillMap:LoadState()
                        end
                    end
                end
            end
        end
    elseif t=="/uploadterrain" then
        print("/uploadterrain suc")

        print("data:"..data)
        local outExt = StringHelp:SplitFullFilename_OutExt(data)
        print("outExt:"..outExt)
        local outBase = StringHelp:SplitFullFilename_OutBase(data)
        print("dataBase:"..outBase)
        local fp = outBase.."."..outExt

		local stk = StringTokenizer(outBase, "_")
		if stk:Count() == 2 then
			local st0 = stk:GetAt(0)
			local st1 = stk:GetAt(1)
            print("st0:"..st0)
            print("st1:"..st1)

            local id = StringHelp:StringToInt(st1)
            if 0~=id then
                print("id:")
                print(id)

                local scene = self:_GetSceneByID(id)
                if scene then
                    print("TerrainPath:")
                    print(fp)

                    scene:BeginPropertyCata("Scene")
                    scene:AddPropertyString("TerrainPath", "TerrainPath", fp, true, true)
                    scene:EndPropertyCata()
                    self:_SaveScene(scene, nil)
                end
            end
        end    
    elseif t=="/httprequest" then
        print("httprequesttttttttttttttttttttttttttttttttttttttttttttt")
        print("data:")
        print(data)

        local dt = PX2JSon.decode(data)
        print("dt.type:"..dt.type)
        print("dt.name:"..dt.name)
        --print("dt.code:"..dt.code)

        if "syncode"==dt.type then
            local parentPath = ResourceManager:GetWriteablePath().."Write_MANYKit/"
            if not PX2_RM:IsFileFloderExist(parentPath.."genscripts/") then
                PX2_RM:CreateFloder(parentPath, "genscripts/")
            end
    
            local fpth = parentPath.."genscripts/"..dt.name..".lua"
            local save = FileIO:Save(fpth, ""..dt.code)
        end
    end    
end
-------------------------------------------------------------------------------
-- callback
function p_holoserver:_UICallback(ptr, callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()
    local platType = PX2_APP:GetPlatformType()

	if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)

    elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

    elseif UICT_RELEASED_NOTPICK==callType then
        PX2_GH:PlayNormal(obj)

    elseif UICT_PROPERTY_CHANGED==callType then
        print("UICT_PROPERTY_CHANGED "..name)
        if "PropertyGrid"==name then
            local pObj = obj:GetPorpertyObject()
            print("obj.Name:"..pObj.Name)

            if "IsAppServerOpen"==pObj.Name then
                local isopen = pObj:PBool()
                self:_OpenAppServer(isopen)
            elseif "IPHttpServer"==pObj.Name then
				self._ip_http_appserver_s = pObj:PString()
                print("_ip_http_appserver_s:"..self._ip_http_appserver_s)

                PX2_PROJ:SetConfig("ip_http_appserver_s", self._ip_http_appserver_s)

                self:_ReStartHttpServer()
            elseif "ConnectMe"==pObj.Name then
                print("ConnectMe")
                self:_SendConnectMe()
			end
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_OpenAppServer(doopen)
    print("p_holoserver:_OpenAppServer")
    print_i_b(doopen)

    if doopen then
        PX2_PROJ:SetConfig("isappserveropen", "1")
    else
        PX2_PROJ:SetConfig("isappserveropen", "0")
    end

    if doopen then
        if not PX2_APPSERVER:IsStarted() then
            PX2_APPSERVER:Start()
            self:_RefreshAppServerStart()
        end
    else
        if PX2_APPSERVER:IsStarted() then
            PX2_APPSERVER:Shutdown()
            self:_RefreshAppServerStart()
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_SendConnectMe()
    print("p_holoserver:_SendConnectMe")

    local lnd = self._scriptControl:PInt("LocalNetDevices")

    local info = PX2_APP:GetUDPNetInfo(lnd)
    if info then
        print("info:"..info.IP)

        local ds = DatagramSocket()
        ds:SendTo("hs_connectme", info.IP, 9908)
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_holoserver)
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_net/p_holoserveractor.lua")
require("scripts/lua/plugins/p_net/p_holoservermap.lua")
-------------------------------------------------------------------------------