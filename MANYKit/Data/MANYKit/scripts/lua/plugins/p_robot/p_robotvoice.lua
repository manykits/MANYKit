-- p_robotvoice.lua

-------------------------------------------------------------------------------
p_robotvoice = class(p_ctrl,
{
	_name = "p_robotvoice",

    -- setting ui
	_frameMgr = nil,

    _propertyGridEdit = nil,

	_isStream = false,
	_isStreamDoAwaken = false,	
	_isDoAwaken = false,
	_awakensdkindex = 0,
	_kedaxunfeiappid = "",
})
-------------------------------------------------------------------------------
function p_robotvoice:OnAttached()
	PX2_LM_APP:AddItem(self._name, "ROBOTVoice", "语音")

	p_ctrl.OnAttached(self)
	print(self._name.." p_robotvoice:OnAttached")

	PX2_APP:LoadPlugin("PFastASR", "PFastASR")

	local streamvoice = PX2_PROJ:GetConfig("robot_voice_stream")
	self._isStream = streamvoice=="1"
	if self._isStream then
		self:_UseStream(true)
	end

	local kedaxunfeiappidstr = PX2_PROJ:GetConfig("kedaxunfeiappid")
	self._kedaxunfeiappid = kedaxunfeiappidstr
	if PFastASR then
		PFastASR:SetKeDa_ProdcutID(kedaxunfeiappidstr)
	end

	local awakensdkindexstr = PX2_PROJ:GetConfig("awakensdkindex")
	if ""~=awakensdkindexstr then
		self._awakensdkindex = StringHelp:StringToInt(awakensdkindexstr)
	end

	local processserverindexstr = PX2_PROJ:GetConfig("talkprocessserverindex")
	if ""~=processserverindexstr then
		p_net.g_talkprocessserverindex = StringHelp:StringToInt(processserverindexstr)
	end

	local sttprocessserverindexstr = PX2_PROJ:GetConfig("sttprocessserverindex")
	if ""~=sttprocessserverindexstr then
		p_net.g_sttprocessserverindex = StringHelp:StringToInt(sttprocessserverindexstr)
	end

	if PFastASR then
		PFastASR:SetSnowboyResourceFilename("common_ext/snowboy/common.res")
		-- PFastASR:SetSnowboyModelFilename("common_ext/snowboy/minatongxue.pmdl,common_ext/snowboy/xiaonatongxue.pmdl,common_ext/snowboy/minamina.pmdl,common_ext/snowboy/xiaonaxiaona.pmdl")
		-- PFastASR:SetSnowboySensitivity("0.48,0.45,0.47,0.485")
		
		PFastASR:SetSnowboyModelFilename("common_ext/snowboy/xiaohaoxiaohao.pmdl,common_ext/snowboy/xiaohaotongxue.pmdl")
		PFastASR:SetSnowboySensitivity("0.48,0.45")

		if 0==self._awakensdkindex then
			PFastASR:SetAwaken_SDK("snowboy")
		else
			PFastASR:SetAwaken_SDK("kedaxunfei")
		end

		PFastASR:SetAwakingStopStreamStrSameKeepTime(2.0);
	end

	local doawaken = PX2_PROJ:GetConfig("robot_voice_doawaken")
	self._isDoAwaken = doawaken=="1"
	if self._isDoAwaken then
		self:_UseAwaken(true)
	end

    self:_CreateContentFrame()
end
-------------------------------------------------------------------------------
function p_robotvoice:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_robotvoice:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_robotvoice:OnPPlay()
	print(self._name.." p_robotvoice:OnPPlay")
end
-------------------------------------------------------------------------------
function p_robotvoice:OnPUpdate()
end
-------------------------------------------------------------------------------
function p_robotvoice:_CreateContentFrame()
	print(self._name.." p_robotvoice:_CreateContentFrame")

    local frame = UIFrame:New()
    self._frame:AttachChild(frame)
	frame:LLY(-20.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    local uiFrameBack = self:_CreateMgrFrame()
	frame:AttachChild(uiFrameBack)
	uiFrameBack:LLY(-10)
	self._frameMgr = uiFrameBack

    self._scriptControl:ResetPlay()

	self:_ShowSetting(true)
end
-------------------------------------------------------------------------------
function p_robotvoice:_CreateMgrFrame()
	local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-10, -10, "")
	self._frameMgr = uiFrameBack
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    local frameTable = UITabFrame:New("TabFrameInfo")
    uiFrame:AttachChild(frameTable)
    frameTable:AddTab(self._name, ""..PX2_LM_APP:V(self._name), self:_CreateFrameSetting())
    frameTable:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessTable(frameTable)
    frameTable:SetActiveTab(self._name)

	btnClose:SetName("BtnRefresh")
	btnClose:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/refresh.png")

	return uiFrameBack
end
-------------------------------------------------------------------------------
function p_robotvoice:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

	if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)

	elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

		if "BtnDlgClose"==name then
			self:_ShowSetting(false)
		elseif "BtnRefresh"==name then
			self:_ShowSetting(true)
		end
	elseif UICT_RELEASED_NOTPICK == callType then
        PX2_GH:PlayNormal(obj)

	elseif UICT_LIST_SELECTED == callType then

	elseif UICT_PROPERTY_CHANGED==callType then
        print("UICT_PROPERTY_CHANGED "..name)
        if "PropertyGridEdit"==name then
            local pObj = obj:GetPorpertyObject()
            print("obj.Name:"..pObj.Name)

			if "IsStream"==pObj.Name then
				local b = pObj:PBool()
				if b then
					PX2_PROJ:SetConfig("robot_voice_stream", "1")
				else
					PX2_PROJ:SetConfig("robot_voice_stream", "0")
				end
				self:_UseStream(b)
			elseif "IsAwaken"==pObj.Name then
				local b = pObj:PBool()
				if b then
					PX2_PROJ:SetConfig("robot_voice_doawaken", "1")
				else
					PX2_PROJ:SetConfig("robot_voice_doawaken", "0")
				end
				self:_UseAwaken(b)
			elseif "AwakenType"==pObj.Name then
				local v = pObj:PInt()
				print("v:"..v)
				self._awakensdkindex = v

				local awtypestr = pObj:PEnumData2()
				print("AwakenType:"..awtypestr)

				if PFastASR then
					PFastASR:SetAwaken_SDK(awtypestr)
				end

				PX2_PROJ:SetConfig("awakensdkindex", v)	
			elseif "TalkProcessServerType"==pObj.Name then
				local v = pObj:PInt()
				print("v:"..v)
				p_net.g_talkprocessserverindex = v

				PX2_PROJ:SetConfig("talkprocessserverindex", v)	
			elseif "STTProcessServerType"==pObj.Name then
				local v = pObj:PInt()
				print("v:"..v)
				p_net.g_sttprocessserverindex = v

				PX2_PROJ:SetConfig("sttprocessserverindex", v)	

			elseif "kedaxunfeiappid"==pObj.Name then
				local v = pObj:PString()
				print("v:"..v)

				self._kedaxunfeiappid = v
				PX2_PROJ:SetConfig("kedaxunfeiappid", v)

				if PFastASR then
					PFastASR:SetAWaken_ProdcutID(v)
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_robotvoice:_ShowSetting(show)
	print("p_robotvoice:_ShowSetting")
	print_i_b(show)

	self._frameMgr:Show(show)

    if show then
        self:_RegistPropertyOnSetting()
    end
end
-------------------------------------------------------------------------------
function p_robotvoice:_CreateFrameSetting()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
	uiFrame:SetAnchorVer(0.0, 1.0)

	local pg = UIPropertyGrid:New("PropertyGridEdit")
    self._propertyGridEdit = pg
    uiFrame:AttachChild(pg)
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

	return uiFrame
end
-------------------------------------------------------------------------------
function p_robotvoice:_RegistPropertyOnSetting()
	print(self._name.." p_robotvoice:_RegistPropertyOnSetting")

	self._scriptControl:RemoveProperties("EditSetting")
    self._scriptControl:BeginPropertyCata("EditSetting")
    self._scriptControl:AddPropertyClass("Setting", "设置")

	self._scriptControl:AddPropertyBool("IsStream", "流式识别", self._isStream, true, false)

    self._scriptControl:AddPropertyClass("Awaken", "唤醒")
	self._scriptControl:AddPropertyBool("IsAwaken", "唤醒", self._isDoAwaken, true, false)
	PX2Table2Vector({"snowboy", "kedaxuefei"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({"snowboy", "kedaxuefei"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData("AwakenType", "唤醒SDK", self._awakensdkindex, vec, vec1, vec2, true, true)
	self._scriptControl:AddPropertyString("kedaxunfeiappid", "科大APPID", self._kedaxunfeiappid, true, false)

	self._scriptControl:AddPropertyClass("Process", "处理")
	
	PX2Table2Vector({"local", "minna", "manykit:6900"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({"local", "minna", "manykit:6900"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData("STTProcessServerType", "语音转文字处理服务器", p_net.g_sttprocessserverindex, vec, vec1, vec2, true, true)

	
	PX2Table2Vector({"minna", "manykit:6900"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({"minna", "manykit:6900"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData("TalkProcessServerType", "对话处理服务器", p_net.g_talkprocessserverindex, vec, vec1, vec2, true, true)

    self._scriptControl:EndPropertyCata()

    self._propertyGridEdit:RegistOnObject(self._scriptControl, "EditSetting")
end
-------------------------------------------------------------------------------
function p_robotvoice:_UseStream(b)
	print(self._name.." p_robotvoice:_UseStream")
	print_i_b(b)

	if PFastASR then
		local isv = PFastASR:IsVoiceStreamSTTStarted()
		if isv~=b then
			if b then
				PFastASR:StartVoiceStreamSTT()
			else
				PFastASR:StopVoiceStreamSTT()
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_robotvoice:_UseAwaken(b)
	print(self._name.." p_robotvoice:_UseAwaken")
	print_i_b(b)

	if PFastASR then
		local isv = PFastASR:IsDoAwaken()
		if isv~=b then
			if b then
				PFastASR:StartAwaken()
			else
				PFastASR:StopAwaken()
			end
		end
	end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_robotvoice)
-------------------------------------------------------------------------------