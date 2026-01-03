-- p_netmk.lua
-------------------------------------------------------------------------------
-- heart
function p_net:_SendHeart_Logic()
    local dt = {
        t = "h",
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
-- login 0
function p_net:_OnBtnLogin()
	print(self._name.." p_net:_OnBtnLogin")

	local username = self._scriptControl:PString("username")
	local password = self._scriptControl:PString("password")

	print("username:"..username)
	print("password:"..password)

	if ""~=username and ""~=password then
	    self:_manykit_login(username, password)
	end
end
-------------------------------------------------------------------------------
function p_net:_OnBtnLogout()
	print(self._name.." p_net:_OnBtnLogout")

	self:_manykit_logout()
end
-------------------------------------------------------------------------------
function p_net:_OnNetIDChanged_MK()
	print(self._name.." p_net:_OnNetIDChanged_MK")

	local netid = PX2_PROJ:GetConfig("netid_mk")
	if ""~=netid then
		self:_SendNetID_MK(netid)
	end
end
-------------------------------------------------------------------------------
function p_net:_SendNetID_MK(netid)
    print(self._name.." p_net:_SendNetID_MK")

    print("netid:"..netid)

	if self._nc_mk then
		local sendStr = "t 1 ".. netid .."\n"
		self._nc_mk:SendRawBuffer(sendStr)
	end
end
-------------------------------------------------------------------------------
function p_net:_CreateNetNC_MK()
	print(self._name.." p_net:_CreateNetNC_MK")

	local cnt = PX2_APP:CreateGetGeneralClientConnector("NetConnector_MK")
    self._nc_mk = cnt
    cnt:AddOnConnectCallback("_OnNetConnect", self._scriptControl)
    cnt:AddOnDisconnectCallback("_OnNetDisConnect", self._scriptControl)
    cnt:AddRawRecvCallback("_OnNetRawRecvCallback", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_net:_OnNetDisConnect_mk()
	print(self._name.." p_net:_OnNetDisConnect_mk")

	self._recvHeartSeconds_mk = 0.0
end
-------------------------------------------------------------------------------
function p_net:_SendHeart_mk()
	local sendStr = "h\n"
	self._nc_mk:SendRawBuffer(sendStr)
end
-------------------------------------------------------------------------------
function p_net:_manykit_login(username, password)
	print(self._name.." p_net:_manykit_login")

	local url = p_net.g_url_mk.."/users/login?emailphone="..username.."&password="..password.."&remember=true"
	local curlObj = CurlObj:NewThread()
	curlObj:SetUserDataString("username", username)
	curlObj:Get(url, "_on_manykit_login", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_net:_on_manykit_login(ptr)
	local curlObj = Cast:ToO(ptr)
    if curlObj:IsGettedOK() then
		local username = curlObj:GetUserDataString("username")

        local strMem = curlObj:GetGettedString()
        print("strMem:"..strMem)

		local dt = PX2JSon.decode(strMem)
		if 0==dt.code then
			local accesstoken = dt.data.access_token

			PX2_PROJ:SetConfig("username_mk", ""..username)
			self:_manykit_SetAccessToken(accesstoken)

			self:_RegistOnProperty()
		end
	end
end
-------------------------------------------------------------------------------
function p_net:_manykit_SetAccessToken(accesstoken)
	print(self._name.." p_net:_manykit_SetAccessToken")
	print("accesstoken:"..accesstoken)

	PX2_PROJ:SetConfig("accesstoken_mk", ""..accesstoken)
	self._accesstoken_mk = accesstoken
	if ""==accesstoken then
		self._nc_mk:Disconnect()
		self:_OnNetDisConnect_mk()
	end
end
-------------------------------------------------------------------------------
function p_net:_manykit_logout()
	print(self._name.." p_net:_manykit_logout")

	local url = p_net.g_url_mk.."/users/logout"
	local curlObj = CurlObj:NewThread()
	curlObj:Get(url, "_on_manykit_logout", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_net:_on_manykit_logout(ptr)
	local curlObj = Cast:ToO(ptr)
    if curlObj:IsGettedOK() then
		local strMem = curlObj:GetGettedString()
        print("strMem:")
        print(strMem)

		local dt = PX2JSon.decode(strMem)
		if 0==dt.code then
			self:_manykit_SetAccessToken("")

			self:_RegistOnProperty()
		end
	end
end
-------------------------------------------------------------------------------