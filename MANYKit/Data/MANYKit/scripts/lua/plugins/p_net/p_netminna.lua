-- p_netminna.lua
-------------------------------------------------------------------------------
function p_net:_ReCreateNet_Minna()
	self:_DestoryNetNC_Minna()

	self:_CreateNetNC_Minna()
end
-------------------------------------------------------------------------------
function p_net:_DestoryNetNC_Minna()
    print(self._name.." p_net:_DestoryNetNC_Minna")

	if self._ncLogic_minna then
		self._ncLogic_minna:Disconnect()
	end
	self._ncLogic_minna = nil
end
-------------------------------------------------------------------------------
function p_net:_CreateNetNC_Minna()
	if nil==self._ncLogic_minna then
		print("_CreateNetNC_Minna")

		local cntLogicMT = PX2_APP:CreateGetGeneralClientConnector("NetConnector_Logic_Minna")
		self._ncLogic_minna = cntLogicMT
		cntLogicMT:AddOnConnectCallback("_OnNetConnect", self._scriptControl)
		cntLogicMT:AddOnDisconnectCallback("_OnNetDisConnect", self._scriptControl)
		cntLogicMT:AddRawRecvCallback("_OnNetRawRecvCallback", self._scriptControl)
	end
end
-------------------------------------------------------------------------------
function p_net:_OnBtnLoginMinna()
	print(self._name.." p_net:_OnBtnLoginMinna")

	local username = self._scriptControl:PString("username_minna")
	local password = self._scriptControl:PString("password_minna")

	print("username:"..username)
	print("password:"..password)

	if ""~=username and ""~=password then
	    self:_minna_Login(username, password)
	end
end
-------------------------------------------------------------------------------
function p_net:_minna_Login(username, password)
	print(self._name.." p_net:_minna_Login")

	local url = "" .. p_net.g_ip_minna .. ":" .. p_net.g_port_minna_http .. "/users/login?username="..username.."&password="..password
	print("url:"..url)

	local curlObj = CurlObj:NewThread()
	curlObj:Get(url, "_minna_OnLogin", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_net:_minna_OnLogin(ptr)
	print(self._name.." p_net:_minna_OnLogin")

	local curlObj = Cast:ToO(ptr)
	local strMem = curlObj:GetGettedString()
	
	local jsonData = JSONData()
	jsonData:LoadBuffer(strMem)
	local cStr = jsonData:GetMember("code")
	local cInt = cStr:ToInt()
	print("cInt:"..cInt)
	if 0==cInt then
		print("login suc")

		local data = jsonData:GetMember("data")			
		local id = data:GetMember("id")
		local nickname = data:GetMember("nickname")
		local token = data:GetMember("access_token")
		local usrname = data:GetMember("username")

		local idstr = id:ToString()
		local usernamestr = usrname:ToString()
		local tokenstr = token:ToString()

		PX2_PROJ:SetConfig("useruin_minna", ""..idstr)
		PX2_PROJ:SetConfig("username_minna", ""..usernamestr)
		PX2_PROJ:SetConfig("accesstoken_minna", ""..tokenstr)

		self._userid_minna = idstr
		self._username_minna = usernamestr
		self._accesstoken_minna = tokenstr
		self:_UnBindDeviceLogin()

		if self._ncLogic_minna then
			self._ncLogic_minna:Disconnect()
		end

        self:_RegistOnProperty()
	else
		print("login failed")
	end
end
-------------------------------------------------------------------------------
function p_net:_OnBtnLogoutMT()
	print(self._name.." p_net:_OnBtnLogoutMT")

	self:_minna_logout()
end
-------------------------------------------------------------------------------
function p_net:_minna_logout()
	print(self._name.." p_net:_manykit_logout")

	local url = p_net.g_url_mk.."/users/logout"
	local curlObj = CurlObj:NewThread()
	curlObj:Get(url, "_on_minna_logout", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_net:_on_minna_logout(ptr)
	local curlObj = Cast:ToO(ptr)
    if curlObj:IsGettedOK() then
		local strMem = curlObj:GetGettedString()
        print("strMem:")
        print(strMem)

		local dt = PX2JSon.decode(strMem)
		if 0==dt.code then
			PX2_PROJ:SetConfig("accesstoken_minna", "")
			PX2_PROJ:SetConfig("netid_minna", "")

            self:_RegistOnProperty()
		end
	end
end
-------------------------------------------------------------------------------
function p_net:_OnNetDisConnect_minna()
	print(self._name.." p_net:_onNetDisConnectHeart_WebClient")

	self._isbindlogined_minna = false
	self._recvHeartSeconds_Logic_minna =  0.0

	PX2_GH:SendGeneralEvent("WebClientDisConnecteded")
end
-------------------------------------------------------------------------------
function p_net:_minna_SendHeart()
    local sendStr = "h\n"
    self._ncLogic_minna:SendRawBuffer(sendStr)
end
-------------------------------------------------------------------------------
function p_net:_minna_UserBindDeviceLogin(tokenStr, deviceid)
    print(self._name.." p_net:_minna_UserBindDeviceLogin")
	print("tokenStr:"..tokenStr)
	print("deviceid:"..deviceid)

	local url = "" .. p_net.g_ip_minna .. ":" .. p_net.g_port_minna_http .. "/users/connectlogin?OMT_TOKEN="..tokenStr.."&deviceid="..deviceid
	print("url:"..url)

	local curl = CurlObj:NewThread()
	curl:Get(url, "_minna_OnUserBindDeviceLogin", self._scriptControl) 
end
-------------------------------------------------------------------------------
function p_net:_OnNetIDChanged_Minna()
	print(self._name.." p_net:_OnNetIDChanged_Minna")

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
end
-------------------------------------------------------------------------------
function p_net:_SendNetID_Minna(netid, useruin)
    print(self._name.." p_net:_SendNetID_Minna")

    print("netid:"..netid)

    if self._ncLogic_minna then
        local sendStr = "t&1&".. netid .."&"..useruin.."\n"
        self._ncLogic_minna:SendRawBuffer(sendStr)
    end
end
-------------------------------------------------------------------------------
function p_net:_UnBindDeviceLogin()
	self._isbindlogined_minna = false
end
-------------------------------------------------------------------------------
function p_net:_minna_OnUserBindDeviceLogin(ptr)
	print(self._name.." p_net:_minna_OnUserBindDeviceLogin")

	local curlObj = Cast:ToO(ptr)

	local strMem = curlObj:GetGettedString()
	local jsonData = JSONData()
	jsonData:LoadBuffer(strMem)
	local cStr = jsonData:GetMember("code")
	local cInt = cStr:ToInt()
	if 0==cInt then
		local data = jsonData:GetMember("data")
		local idstr = data:GetMember("id"):ToString()
		local usernamestr = data:GetMember("username"):ToString()
		local adminlevelstr = data:GetMember("adminlevel"):ToString()

		print(self._name.." p_net:_minna_OnUserBindDeviceLogin")

		self._userid_minna = idstr
		self._username_minna = usernamestr
		self._adminlevelstr_minna = adminlevelstr
		self._isbindlogined_minna = true

		PX2_GH:SendGeneralEvent("UserBindDeviceSuc")
	else
		PX2_GH:SendGeneralEvent("UserBindDeviceFailed")
	end
end
-------------------------------------------------------------------------------
function p_net:_send_minna_json(dt)
    local sendStr = dt:GetWriteString()
    local sdStr = StringHelp:StringRemoveChar(sendStr, "\n")
    sdStr = "d&" .. sdStr .. "\n"
	if self._ncLogic_minna then
    	self._ncLogic_minna:SendRawBuffer(sdStr)
	end
end
-------------------------------------------------------------------------------