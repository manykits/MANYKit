-- p_netapp.lua
-------------------------------------------------------------------------------
function p_net:_ReCreateNet_APP()
	self:_DestoryNetNC_APP()

	self:_CreateNetNC_APP()
end
-------------------------------------------------------------------------------
function p_net:_DestoryNetNC_APP()
	print(self._name.." p_net:_DestoryNetNC_APP")

	if self._udpServer then
        self._udpServer:Stop()
    end
	self._udpServer = nil

	if self._ncLogic then
		self._ncLogic:Disconnect()
	end

	PX2_PROJ:PoolSet("UDPServerNet", nil)  
end
-------------------------------------------------------------------------------
function p_net:_CreateNetNC_APP()
	print(self._name.." p_net:_CreateNetNC_APP")

	if nil==self._udpServer then
        local udpServer = UDPServer:New()
        self._udpServer = udpServer
        PX2_PROJ:PoolSet("UDPServerNet", udpServer)
        udpServer:RegistToScriptSystem()
        udpServer:Bind(p_net.g_port_localudp)   
        udpServer:AddOnRecvCallback("_UDPServerCallback", self._scriptControl)
        udpServer:Start()
	end

	if nil==self._ncLogic then
		local cntLogic = PX2_APP:CreateGetGeneralClientConnector("NetConnector_Logic")
		self._ncLogic = cntLogic

		cntLogic:AddOnConnectCallback("_OnNetConnect", self._scriptControl)
		cntLogic:AddOnDisconnectCallback("_OnNetDisConnect", self._scriptControl)
		cntLogic:AddRawRecvCallback("_OnNetRawRecvCallback", self._scriptControl)
		cntLogic:AddScriptHandler("_OnNetCallback", self._scriptControl)
	else
		print("self._ncLogic is not nil")
	end
end
-------------------------------------------------------------------------------
function p_net:_OnNetDisConnectLogic()
	print(self._name.." p_net:_OnNetDisConnectLogiccccccccccccccccccccc")

	self._recvHeartSeconds_Logic = 0.0

	PX2_GH:SendGeneralEvent("LogicDisConnecteded")
end
-------------------------------------------------------------------------------
function p_net:_NetLogicSendJSon(tb)
	local jstr = PX2JSon.encode(tb)
	if self._ncLogic then
		self._ncLogic:SendJString(jstr)
	end
end
-------------------------------------------------------------------------------
function p_net:_SetUINAndSendComeInRoom(uin)
	if self._ncLogic then
		local isconnected = self._ncLogic:IsConnected()
		if isconnected then
			if uin and 0~=uin then
				self:_SendComeInRoom(uin)
			end
		end
	end
end
-------------------------------------------------------------------------------
