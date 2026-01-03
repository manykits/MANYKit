-- p_net.lua
-------------------------------------------------------------------------------
p_net = class(p_ctrl,
{
	_g_net = nil,

	_name = "p_net",

	-- property
	_frameContent = nil,
	_propertyGrid = nil,

	-- logic
	_islogicserver = false,

	g_port_localudp = 11140,

	_g_ip_weapontrigger = "192.168.6.52",

	_g_port_triggerudp = 2334,
	_udpSocket_trigger = DatagramSocket(),
	_triggerSendHeartTiming = 0.0,
	_triggerSendHeartTime = 1,

	g_ip_logic = "127.0.0.1",
    g_port_logic_tcp = 28186,
	_hs_connectmeip = "",

	_ncLogic = nil,
	_isAutoCnt_Logic = true,
	_heartTimeSend_Logic = 1.0,
	_notRecvDisconnecTime_Logic = 10.0,
	_autoConnectTime_Logic = 2.0,
	_isNcLogicDoHeartConnect = false,
	_recvHeartSeconds_Logic = 0.0,
    _sendHeartSeconds_Logic  = 0.0,
    _connectSeconds_Logic = 0.0,
	_isNCLogicEverConnected = false,

	_port_http_appserver = 6606,

	-- udp
	_udpServer = nil,

	-- web client
	g_ip_minna = "127.0.0.1",
	g_port_minna_tcp = 9802,
	g_ipindex_minna = 0,
	_ncLogic_minna = nil,
	_isAutoCnt_Logic_minna = true,
	_heartTimeSend_Logic_minna = 1.0,
	_autoConnectTime_Logic_minna = 2.0,
	_sendHeartSeconds_Logic_minna  = 0.0,
	_recvHeartSeconds_Logic_minna = 0.0,
	_connectSeconds_Logic_minna = 0.0,
	_isbindlogined_minna = false,
	_allRecvStr_minna = "",
	_cmdStr_minna = "",
	_allProcLength_minna = 0,
	_procLen_minna = 0,

	g_port_minna_http = 6700,

	-- account
	_userid_minna = "",
	_username_minna = "",
	_accesstoken_minna = "",
	_adminlevelstr_minna = "0",
    _peopleActorPartyStr = "",

	-- datas
	_activetrainid = 0,
	_g_peoplesall = {},

	-- mk
	g_ip_mk = "182.254.213.85",
	g_url_mk = "http://182.254.213.85",
	_accesstoken_mk = "",
	g_port_manykit_tcp = 9801,
	_nc_mk = nil,
	_isAutoCnt_mk = true,
	_heartTimeSend_mk = 2.0,
	_notRecvDisconnecTime_mk = 12.0,
	_autoConnectTime_mk = 2.0,
	_recvHeartSeconds_mk = 0.0,
    _sendHeartSeconds_mk  = 0.0,
    _connectSeconds_mk = 0.0,
	_allRecvStr_mk = "",
	_cmdStr_mk = "",
	_allProcLength_mk = 0,
	_procLen_mk = 0,
	_rectHandTimingLeft = 0.0,
	_rectHandTimingRight = 0.0,

	-- cfg
	g_sttprocessserverindex = 0, --local, minna, manykit
	g_talkprocessserverindex = 0, --minna, manykit
})
-------------------------------------------------------------------------------
function p_net:OnAttached()
	PX2_LM_APP:AddItem(self._name, "Net", "客户端")

	p_ctrl.OnAttached(self)
	print(self._name.." p_net:OnAttached")

	p_net._g_net = self

	self:_CreateNetNC_MK()
	self:_CreateNetNC_Minna()

	local cntmeip = PX2_PROJ:GetConfig("connectmeip")
	if ""~=cntmeip then
		p_net._hs_connectmeip = cntmeip
	end
	local g_ip_logic = PX2_PROJ:GetConfig("g_ip_logic")
	if ""~=g_ip_logic then
		p_net.g_ip_logic = g_ip_logic
	end
	print("p_net.g_ip_logic:"..p_net.g_ip_logic)

	local islogicserver = PX2_PROJ:GetConfig("islogicserver")
	self._islogicserver = islogicserver=="1"
	print_i_b(p_net._g_net._islogicserver)
	
    RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
		if "hs_connectme"==str then
			local ipstr = str1

			myself._hs_connectmeip = ipstr
			p_net.g_ip_logic = ipstr

			PX2_PROJ:SetConfig("g_ip_logic", ipstr)
			PX2_PROJ:SetConfig("connectmeip", ipstr)

			myself:_ReCreateNet_APP()
			myself:_RefreshPropertyConnect()
		end
	end)
end
-------------------------------------------------------------------------------
function p_net:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_net:OnInitUpdate")

	self:_CreateContentFrame()
end
-------------------------------------------------------------------------------
function p_net:OnPPlay()
	print(self._name.." p_net:OnPPlay")
end
-------------------------------------------------------------------------------
function p_net:OnFixUpdate()
	local t = self._dt

    local esec = t

    self._triggerSendHeartTiming = self._triggerSendHeartTiming + t
    if self._triggerSendHeartTiming>self._triggerSendHeartTime then
        self._udpSocket_trigger:SendTo("heart", p_net._g_ip_weapontrigger, p_net._g_port_triggerudp)
        
        self._triggerSendHeartTiming = 0.0
    end

	if self._udpServer then
		self._udpServer:Update(esec)
	end

	if self._ncLogic and self._isAutoCnt_Logic then
		local isconnected = self._ncLogic:IsConnected()
		if isconnected then
			if self._isNcLogicDoHeartConnect then
				self._recvHeartSeconds_Logic = self._recvHeartSeconds_Logic + esec				
				if self._recvHeartSeconds_Logic > self._notRecvDisconnecTime_Logic then
					self._recvHeartSeconds_Logic = 0.0
					print( "self._recvHeartSeconds_Logic > self._notRecvDisconnecTime_Logic, try to dis connect!")
					self._ncLogic:Disconnect()
					self:_OnNetDisConnectLogic()
				end
			end

			self._sendHeartSeconds_Logic = self._sendHeartSeconds_Logic + esec
			if self._sendHeartSeconds_Logic > self._heartTimeSend_Logic then
				self._sendHeartSeconds_Logic = 0.0
				self:_SendHeart_Logic()
			end    
		else
			if p_net.g_ip_logic and ""~=p_net.g_ip_logic then
				self._connectSeconds_Logic = self._connectSeconds_Logic + esec
				if self._connectSeconds_Logic > self._autoConnectTime_Logic then
					self._ncLogic:ConnectNB(p_net.g_ip_logic, p_net.g_port_logic_tcp)
					print("self._ncLogic:ConnectNB:"..p_net.g_ip_logic..":"..p_net.g_port_logic_tcp)
					self._connectSeconds_Logic = 0.0
				end
			end
		end
	end

	if self._ncLogic_minna and self._isAutoCnt_Logic_minna then
		local isconnected = self._ncLogic_minna:IsConnected()
		if isconnected then
			self._recvHeartSeconds_Logic_minna = self._recvHeartSeconds_Logic_minna + esec
			if self._recvHeartSeconds_Logic_minna > self._notRecvDisconnecTime_Logic then
				print( "self._recvHeartSeconds_Logic_minna > self._notRecvDisconnecTime_Logic, try to dis connect!")
                self._ncLogic_minna:Disconnect()

				self:_OnNetDisConnect_minna()
            end

			self._sendHeartSeconds_Logic_minna = self._sendHeartSeconds_Logic_minna + esec
			if self._sendHeartSeconds_Logic_minna > self._heartTimeSend_Logic_minna then
				self._sendHeartSeconds_Logic_minna = 0.0

				self:_minna_SendHeart()
			end 
		else
            if p_net.g_ip_minna and ""~=p_net.g_ip_minna then
				self._connectSeconds_Logic_minna = self._connectSeconds_Logic_minna + esec
				if self._connectSeconds_Logic_minna > self._autoConnectTime_Logic_minna then
					self._ncLogic_minna:ConnectNB(p_net.g_ip_minna, p_net.g_port_minna_tcp)
					print("self._ncLogic_minna:ConnectNB:"..p_net.g_ip_minna..":"..p_net.g_port_minna_tcp)
					self._connectSeconds_Logic_minna = 0.0
				end
            end
		end
	end

	if self._nc_mk and self._isAutoCnt_mk then	
		local isconnected = self._nc_mk:IsConnected()
		if isconnected then
			self._recvHeartSeconds_mk = self._recvHeartSeconds_mk + esec
			if self._recvHeartSeconds_mk > self._notRecvDisconnecTime_mk then
				print( "self._recvHeartSeconds_mk > self._notRecvDisconnecTime_mk, try to dis connect!")
				self._nc_mk:Disconnect()

				self:_OnNetDisConnect_mk()
			end

			self._sendHeartSeconds_mk = self._sendHeartSeconds_mk + esec
			if self._sendHeartSeconds_mk > self._heartTimeSend_mk then
				self._sendHeartSeconds_mk = 0.0
				self:_SendHeart_mk()
			end
		else
			if self._accesstoken_mk~="" then
			    if p_net.g_ip_mk and ""~=p_net.g_ip_mk then
				    self._connectSeconds_mk = self._connectSeconds_mk + esec
				    if self._connectSeconds_mk > self._autoConnectTime_mk then
					    self._nc_mk:ConnectNB(p_net.g_ip_mk, p_net.g_port_manykit_tcp)
					    print("self._nc_mk:ConnectNB:"..p_net.g_ip_mk..":"..p_net.g_port_manykit_tcp)
					    self._connectSeconds_mk = 0.0
				    end
			    end
		    end
		end
	end

    if g_manykit._nodeHandLeft then
        local tadj = 0.7
        g_manykit._nodeHandLeft:Show(self._rectHandTimingLeft<=tadj)
        self._rectHandTimingLeft = self._rectHandTimingLeft + t
    
        g_manykit._nodeHandRight:Show(self._rectHandTimingRight<=tadj)
        self._rectHandTimingRight = self._rectHandTimingRight + t
    end
end
-------------------------------------------------------------------------------
function p_net:_Cleanup()
	print(self._name.." p_net:_Cleanup")  

	p_net._g_net = nil
end
-------------------------------------------------------------------------------
function p_net:_CreateContentFrame()
    print(self._name.." p_net:_CreateContentFrame")

    local frame = UIFrame:New()
	self._frame:AttachChild(frame)
	self._frameContent = frame    
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
function p_net:_RegistOnProperty()
    print(self._name.." p_net:_RegistOnProperty")

	self._scriptControl:RemoveProperties("Net")
    self._scriptControl:BeginPropertyCata("Net")

	self._scriptControl:AddPropertyClass("LocalUDP", "LocalUDP")
	self._scriptControl:AddPropertyInt("PortLocalUDP", "PortLocalUDP", p_net.g_port_localudp, false, false)

	-- AppServerConnecter
	self._scriptControl:AddPropertyClass("AppServer", "AppServer")

	self:_SetPropertyIPServer()

	self._scriptControl:AddPropertyInt("PortServer", "PortServer", p_net.g_port_logic_tcp, false, false)
	local isconnectedNCLogic = false
	if self._ncLogic then
	    isconnectedNCLogic = self._ncLogic:IsConnected()
	end
	self._scriptControl:AddPropertyBool("IsConnectedServerTCP", "IsConnectedTCP",  isconnectedNCLogic, false, false)
	
	self._scriptControl:AddPropertyInt("ServerPortHttp", "PortHttp", self._port_http_appserver, false, false)

	self._scriptControl:AddPropertyBool("IsLogicServer", "IsLogicServer",  self._islogicserver, true, false)
	
	self._scriptControl:AddPropertyInt("UIN", "UIN", g_manykit._uin, true, false)

	-- Minna
	local g_ip_minna = PX2_PROJ:GetConfig("g_ip_minna")
	if ""~=g_ip_minna then
		p_net.g_ip_minna = g_ip_minna
	end
	self._scriptControl:AddPropertyClass("Minna", "Minna")
	self._scriptControl:AddPropertyString("IPMinna", "IPMinna", p_net.g_ip_minna, true, false)	
	self._scriptControl:AddPropertyInt("WebServerPortTCP", "PortTCP", p_net.g_port_minna_tcp, false, false)
	local isconnectedMinna = false
	if self._ncLogic_minna then
	    isconnectedMinna = self._ncLogic_minna:IsConnected()
	end
	self._scriptControl:AddPropertyBool("IsConnectedMTTCP", "IsConnectedTCP",  isconnectedMinna, false, false)

	self._scriptControl:AddPropertyInt("WebServerPortHttp", "PortHttp", p_net.g_port_minna_http, false, false)

	local netID_Minna = PX2_PROJ:GetConfig("netid_minna")
	self._scriptControl:AddPropertyString("netid_minna", "网络ID", netID_Minna, true, false)	
	
	local usernamestr_minna = PX2_PROJ:GetConfig("username_minna")
	local accesstoken_minna = PX2_PROJ:GetConfig("accesstoken_minna")
	self._accesstoken_minna = accesstoken_minna
	self._scriptControl:AddPropertyString("username_minna", "用户名", usernamestr_minna, ""==accesstoken_minna, false)
	self._scriptControl:AddPropertyString("password_minna", "密码", "", ""==accesstoken_minna, false)
	self._scriptControl:AddPropertyString("accesstoken_minna", "token", accesstoken_minna, false, false)
	if ""==accesstoken_minna then
		self._scriptControl:AddPropertyButton("BtnLoginMT", "Login", "登录")
	else
		self._scriptControl:AddPropertyButton("BtnLogoutMT", "Logout", "登出")
	end

	self._scriptControl:EndPropertyCata()

	self._propertyGrid:RegistOnObject(self._scriptControl, "Net")
end
-------------------------------------------------------------------------------
function p_net:_SetPropertyIPServer()
	print(self._name.." p_net:_SetPropertyIPServer")

	local iptabs = {}
	local numAddr = PX2_APP:GetLocalAddressSize()
    for i=0, numAddr-1, 1 do
        local ip = PX2_APP:GetLocalAddressStr(i)
        if ""~=ip then
            table.insert(iptabs, #iptabs + 1, ip)
        end
    end
	local cntmeip = PX2_PROJ:GetConfig("connectmeip")
	if ""~=cntmeip then
		p_net._hs_connectmeip = cntmeip
		table.insert(iptabs, #iptabs+1, cntmeip)
	end
	local g_ip_logic = PX2_PROJ:GetConfig("g_ip_logic")
	if ""~=g_ip_logic then
		p_net.g_ip_logic = g_ip_logic
	end
	PX2Table2Vector(iptabs)
	local vec = PX2_GH:Vec()
	PX2Table2Vector(iptabs)
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData1("IPServer", "IPServer", p_net.g_ip_logic, vec, vec1, vec2, true, false)	
end
-------------------------------------------------------------------------------
function p_net:_RefreshPropertyConnect()
    print(self._name.." p_net:_RefreshPropertyConnect")

	self._scriptControl:BeginPropertyCata("Net")

	-- ips
	self:_SetPropertyIPServer()

	local isconnectedNCLogic = false
	if self._ncLogic then
	    isconnectedNCLogic = self._ncLogic:IsConnected()
	end
	self._scriptControl:AddPropertyBool("IsConnectedServerTCP", "IsConnectedTCP",  isconnectedNCLogic, false, false)

	local isconnectedMinna = false
	if self._ncLogic_minna then
	    isconnectedMinna = self._ncLogic_minna:IsConnected()
	end
	self._scriptControl:AddPropertyBool("IsConnectedMTTCP", "IsConnectedTCP",  isconnectedMinna, false, false)

	local isconnectedMK = false
	if self._nc_mk then
	    isconnectedMK = self._nc_mk:IsConnected()
	end
	self._scriptControl:AddPropertyBool("IsConnectedMKTCP", "IsConnectedTCP",  isconnectedMK, false, false)

	self._scriptControl:EndPropertyCata()

	self._propertyGrid:UpdateOnObject(self._scriptControl, "Net", "IPServer")
	self._propertyGrid:UpdateOnObject(self._scriptControl, "Net", "IsConnectedServerTCP")
	self._propertyGrid:UpdateOnObject(self._scriptControl, "Net", "IsConnectedMTTCP")
	self._propertyGrid:UpdateOnObject(self._scriptControl, "Net", "IsConnectedMKTCP")
end
-------------------------------------------------------------------------------
function p_net:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

	if UICT_PROPERTY_CHANGED==callType then
        print("UICT_PROPERTY_CHANGED "..name)
        if "PropertyGrid"==name then
			local pObj = obj:GetPorpertyObject()

			if "IPServer"==pObj.Name then
				p_net.g_ip_logic = pObj:PString()
				PX2_PROJ:SetConfig("g_ip_logic", p_net.g_ip_logic)
				self:_ReCreateNet_APP()
			elseif "IsLogicServer"==pObj.Name then
				self._islogicserver = pObj:PBool()
				if self._islogicserver then
					PX2_PROJ:SetConfig("islogicserver", "1")
				else
					PX2_PROJ:SetConfig("islogicserver", "0")
				end
			elseif "BtnLogin"==pObj.Name then
				self:_OnBtnLogin()
			elseif "BtnLogout"==pObj.Name then
				self:_OnBtnLogout()
			elseif "IPMinna"==pObj.Name then
				p_net.g_ip_minna = pObj:PString()

				PX2_PROJ:SetConfig("g_ip_minna", p_net.g_ip_minna)

				print("g_ip_minna:"..p_net.g_ip_minna)

				self:_ReCreateNet_Minna()
			elseif "netid_mk"==pObj.Name then
				local netid = pObj:PString()
				PX2_PROJ:SetConfig("netid_mk", netid)
				self:_OnNetIDChanged_MK()
			elseif "BtnLoginMT"==pObj.Name then
				self:_OnBtnLoginMinna()
			elseif "BtnLogoutMT"==pObj.Name then
				self:_OnBtnLogoutMT()
			elseif "netid_minna"==pObj.Name then
				local netid = pObj:PString()
				PX2_PROJ:SetConfig("netid_minna", netid)
				self:_OnNetIDChanged_Minna()
			elseif "UIN"==pObj.Name then
				local uin = pObj:PInt()
				print("uin:"..uin)
				g_manykit._uin = uin

				PX2_PROJ:SetConfig("uin", ""..uin)
				--PX2_APP:SetConfig("MANYKit", "account", "uin", ""..uin)
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_net:_OnNetConnect(cnt)
	print(self._name.." p_net:_OnNetConnect")

	local cntt = Cast:ToObject(cnt)
	if cntt==self._ncLogic then
		self._recvHeartSeconds_Logic = 0.0	

		if g_manykit._uin and 0~=g_manykit._uin then
			self:_SendComeInRoom(g_manykit._uin)
			
			if self._isNCLogicEverConnected then
				print("ReConnecttttttttttttttttttttttttttt")
				PX2_GH:SendGeneralEvent("ReConnect")
			end	
		end
		self._isNCLogicEverConnected = true
	elseif cntt == self._ncLogic_minna then
    	local useruin = PX2_PROJ:GetConfig("useruin_minna")
		local netid_minna = PX2_PROJ:GetConfig("netid_minna")
		local tokenStr = PX2_PROJ:GetConfig("access_token_minna")

		-- bind deviceid and userin
		if  netid_minna~="" and useruin~="" then
			self:_SendNetID_Minna(netid_minna, useruin)
		end

		-- bind deviceid and token
		if  netid_minna~="" and tokenStr~="" then
		    self:_minna_UserBindDeviceLogin(tokenStr, netid_minna)		
		end

		PX2_GH:SendGeneralEvent("WebClientConnected")
	elseif cntt == self._nc_mk then
		self._recvHeartSeconds_mk = 0.0

		local netid = PX2_PROJ:GetConfig("netid_mk")
		if ""~=netid then
			self:_SendNetID_MK(netid)
		end
	end
	
	self:_RefreshPropertyConnect()
end
-------------------------------------------------------------------------------
function p_net:_OnNetDisConnect(cnt)
	print(self._name.." p_net:_OnNetDisConnect")

	local cntt = Cast:ToObject(cnt)

	if cntt==self._ncLogic then
		self:_OnNetDisConnectLogic()
	elseif cntt==self._ncLogic_minna then
		self:_OnNetDisConnect_minna()
	elseif cntt==self._nc_mk then
		self:_OnNetDisConnect_mk()
	end

	self:_RefreshPropertyConnect()
end
-------------------------------------------------------------------------------
function p_net:_OnNetRawRecvCallback(cnt, dataStr)
	local netcnt = Cast:ToGCC(cnt)
	if netcnt == self._ncLogic_minna then
		self._allRecvStr_minna = self._allRecvStr_minna..dataStr

		self._allProcLength_minna = 0
		self._procLen_minna = 0
		self._cmdStr_minna = ""

		for i=1,#self._allRecvStr_minna do
			local ch = string.sub(self._allRecvStr_minna,i,i)
			if "\n" == ch then
				-- got a cmd
				--print("cmd:"..self._cmdStr_minna)

				self._procLen_minna = self._procLen_minna+1              
				self._allProcLength_minna = self._allProcLength_minna+self._procLen_minna

				local cmdStrs = Utils.Split("&", self._cmdStr_minna)

				local cmd1 = cmdStrs[1]
				local cmd2 = cmdStrs[2]
				local cmd3 = cmdStrs[3]

				self._recvHeartSeconds_Logic_minna = 0.0

				if "h"==cmd1 then
                    --console.log("heart")
				elseif "d"==cmd1 then
					local dt = JSONData()
					dt:LoadBuffer(cmd2)
	
					local typejson = dt:GetMember("type")
					local typeStr = ""..typejson:ToString()

                    if "event"==typeStr then
                        local msgType1 = dt:GetMember("type1")
                        local msgType1Str = msgType1:ToString()
                        local datajson = dt:GetMember("data")
                        local datastr = datajson:ToString()

                        print("event msgType1Str datastr:")
                        print(msgType1Str)
                        print(datastr)
                        
                        PX2_GH:SendGeneralEvent(msgType1Str, datastr)
					elseif "openrtmp"==typeStr then
						local isdoopenjson = dt:GetMember("isdoopen")
						local isdoopenstr = isdoopenjson:ToString()
						PX2_GH:SendGeneralEvent("openrtmp", isdoopenstr)
					elseif "music_playgroup"==typeStr then
						local groupjson =  dt:GetMember("group")
						local groupstr = groupjson:ToString()
	
						p_net:_act_music_playgroup(groupstr)
					elseif "music_play"==typeStr then
						local namejson =  dt:GetMember("name")
						local name = namejson:ToString()

						p_net:_act_music_play(name)
					elseif "voice_say"==typeStr then
						local textjson =  dt:GetMember("text")
						local text = textjson:ToString()
						p_net:_act_voice_tts(text)
					elseif "robot_charge"==typeStr then

						p_net:_act_robot_charge()
					elseif "robot_followpath"==typeStr then
						local namejson =  dt:GetMember("name")
						local name = namejson:ToString()

						p_net:_act_robot_followpath(name)
					elseif "robot_gopos"==typeStr then
						local namejson =  dt:GetMember("name")
						local name = namejson:ToString()

						p_net:_act_robot_gopos(name)
					end
				end

				self._cmdStr_minna = ""
			else
				self._cmdStr_minna = self._cmdStr_minna..ch
				self._procLen_minna = self._procLen_minna+1
			end
		end

		self._allRecvStr_minna = string.sub(self._allRecvStr_minna, self._allProcLength_minna+1, #self._allRecvStr_minna)
	elseif netcnt == self._nc_mk then
		self._allRecvStr_mk = self._allRecvStr_mk..dataStr

		self._allProcLength_mk = 0
		self._procLen_mk = 0
		self._cmdStr_mk = ""

		for i=1, #self._allRecvStr_mk, 1 do
			local ch = string.sub(self._allRecvStr_mk,i,i)
			if "\n" == ch then
				-- got a cmd
				--print("cmd:"..self._cmdStr_mk)
	
				self._procLen_mk = self._procLen_mk+1              
				self._allProcLength_mk = self._allProcLength_mk+self._procLen_mk
	
				local cmdStrs = Utils.Split(" ", self._cmdStr_mk)
	
				local cmd1 = cmdStrs[1]
				local cmd2 = cmdStrs[2]
				local cmd3 = cmdStrs[3]
	
				if "h"==cmd1 then
					self._recvHeartSeconds_mk = 0
				elseif "n"==cmd1 then
					if "music_hot" == cmd2 then
		
					elseif "music_stop" == cmd2 then
	
					elseif "move_forward"==cmd2 then
					elseif "move_forward_up"==cmd2 then 
					elseif "move_back"==cmd2 then
					elseif "move_back_up"==cmd2 then
					elseif "move_left"==cmd2 then
					elseif "move_left_up"==cmd2 then
					elseif "move_right"==cmd2 then
					elseif "move_right_up"==cmd2 then
					elseif "move_stop"==cmd2 then
					elseif "move_stop_up"==cmd2 then	
					elseif "move_target"==cmd2 then	
					elseif "cmd"==cmd2 then
					end
				elseif "d"==cmd1 then
					if "talkwakeup"==cmd2 then						
					elseif "talk"==cmd2 then
					end
				end
	
				self._cmdStr_mk = ""
			else
				self._cmdStr_mk = self._cmdStr_mk..ch
				self._procLen_mk = self._procLen_mk+1
			end
		end
		self._allRecvStr_mk = string.sub(self._allRecvStr_mk, self._allProcLength_mk+1, #self._allRecvStr_mk)
	end
end
-------------------------------------------------------------------------------
function p_net:_OnNetCallback(ptr, t0, data)
    local dt = PX2JSon.decode(data)
    local t = dt.t
    if t=="h" then
    	self._recvHeartSeconds_Logic = 0.0
	end
end
-------------------------------------------------------------------------------
function p_net:_NetLogicConnect()
	print(self._name.." p_net:_NetLogicConnect")

	if ""~=p_net.g_ip_logic and ""~=p_net.g_port_logic_tcp and self._ncLogic then
		print("self._ncLogic:ConnectNB:")
		print("p_net.g_ip_logic:"..p_net.g_ip_logic)
		print("p_net.g_port_logic_tcp:"..p_net.g_port_logic_tcp)

        self._ncLogic:ConnectNB(p_net.g_ip_logic, p_net.g_port_logic_tcp)
    end
end
-------------------------------------------------------------------------------
-- udp
function p_net:_UDPServerCallback(udpServer, recvStr)
    local stk = StringTokenizer(recvStr, "&")

    if stk:Count() >= 2 then
        local ip = stk:GetAt(0)
        local contentStr = stk:GetAt(1)

		local jd = PX2JSon.decode(contentStr)
		if jd.t=="hand" then
			local hand = jd.hand_id
            local gesture = jd.gesture
            local image_side = jd.image_side
            local landmarks = jd.landmarks

            local lms = {}
            lms.hand = hand
            lms.gesture = gesture
            lms.landmarks = {}
            --lms
            for i, v in ipairs(landmarks) do
                local id = v.id
                local pos2d = APoint(v.x * 640, v.y * 480, v.z)

                local lm = {}
                lm.id = id
                lm.pos2d = pos2d
                table.insert(lms.landmarks, lm)
            end

            if "left"==image_side then
                if hand=="left" then
                    g_manykit._handmarks.leftside.lefthand = lms
                else
                    g_manykit._handmarks.leftside.righthand = lms
                end
            elseif "right"==image_side then
                if hand=="left" then
                    g_manykit._handmarks.rightside.lefthand = lms
                else
                    g_manykit._handmarks.rightside.righthand = lms
                end

                manykit_UpdateHand(0)
                manykit_UpdateHand(1)
            end
		elseif jd.t == "trigger" then
			print("trigger")
			print("ip:"..ip)

			if ip == p_net._g_ip_weapontrigger then
				PX2_GH:SendGeneralEvent("trigger")
			end
		elseif jd.t == "doormgr" then
			local id = jd.id
			local act = jd.act
			local id_virtual = jd.id_virtual

			local opt = {
				t = t,
				id = id,
				act = act,
				id_virtual = id_virtual,
			}					
			local str = PX2JSon.encode(opt)
			PX2_GH:SendGeneralEvent("doormgr", str)
		end
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_net)
-------------------------------------------------------------------------------