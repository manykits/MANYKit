-- p_robottime.lua

p_robottime = class(p_ctrl,
{
    _requires = {"p_robotmusic", },

	_name = "p_robottime",

    -- setting ui
	_frameMgr = nil,

    _fTextCurTime = nil,
    _listTimeAlarm = nil,
	_editboxTime = nil,
	_checkEveryDay = nil,
	_editBoxMsg = nil,
	_comboBoxMusic = nil,
	_timeAlarams = {},
})
-------------------------------------------------------------------------------
function p_robottime:OnAttached()
	PX2_LM_APP:AddItem(self._name, "ROBOTTime", "时间")
    PX2_LM_APP:AddItem("CurTime", "CurTime", "当前时间")
	PX2_LM_APP:AddItem("Test", "Test", "测试")
    PX2_LM_APP:AddItem("Stop", "Stop", "停止")
	PX2_LM_APP:AddItem("AlarmTimeTip", "time format:2020/6/23/16:06", "时间格式:2020/6/23/16:06")
	PX2_LM_APP:AddItem("AlarmTime", "AlarmTime", "提醒时间")
	PX2_LM_APP:AddItem("EveryDay", "EveryDay", "每天")
	PX2_LM_APP:AddItem("AlarmMsg", "AlarmMsg", "提醒信息")
	PX2_LM_APP:AddItem("AlarmMusic", "AlarmMusic", "提醒音乐")

	p_ctrl.OnAttached(self)
	print(self._name.." p_robottime:OnAttached")

    self:_CreateContentFrame()
end
-------------------------------------------------------------------------------
function p_robottime:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_robottime:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_robottime:OnPPlay()
	print(self._name.." p_robottime:OnPPlay")
end
-------------------------------------------------------------------------------
function p_robottime:OnFixUpdate()
	self:_TimeUpdate()
end
-------------------------------------------------------------------------------
-- ui
function p_robottime:_CreateContentFrame()
    print(self._name.." p_robottime:_CreateContentFrame")

    local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-10, -10, "")
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    self._frame:AttachChild(uiFrameBack)

    btnClose:Show(false)

    local frame = UIFrame:New() 
	uiFrame:AttachChild(frame)
	frame:LLY(-2)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
    local back = frame:CreateAddBackgroundPicBox(true, Float3:MakeColor(90.0, 90.0, 90.0))

	local frame1 = UIFrame:New()
    frame:AttachChild(frame1)
    frame1:LLY(-10.0)
    frame1:SetAnchorHor(0.0, 1.0)
    frame1:SetAnchorParamHor(10.0, -10.0)
    frame1:SetAnchorVer(0.0, 1.0)
    frame1:SetAnchorParamVer(10.0, -10.0)

    local posVer = -40.0
	local textCurTime = UIFText:New()
	frame1:AttachChild(textCurTime)
	textCurTime:LLY(-1.0)
	textCurTime:SetAnchorHor(0.0, 0.0)
	textCurTime:SetAnchorParamHor(5.0, 5.0)
	textCurTime:SetAnchorVer(1.0, 1.0)
	textCurTime:SetAnchorParamVer(posVer, posVer)
	textCurTime:SetPivot(0.0, 0.5)
	textCurTime:SetSize(128, 80)
	textCurTime:GetText():SetText(""..PX2_LM_APP:GetValue("CurTime"))
	textCurTime:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
	manykit_uiProcessTextFont(textCurTime:GetText(), 32)
	textCurTime:GetText():SetFontColor(Float3.WHITE)

    local fTextCurTime = UIFText:New("TextTime")
	frame1:AttachChild(fTextCurTime)
    self._fTextCurTime = fTextCurTime
	fTextCurTime:LLY(-1.0)
	fTextCurTime:SetAnchorHor(0.0, 1.0)
	fTextCurTime:SetAnchorParamHor(160.0, -5.0)
	fTextCurTime:SetAnchorVer(1.0, 1.0)
	fTextCurTime:SetAnchorParamVer(posVer, posVer)
    fTextCurTime:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    fTextCurTime:GetText():SetText("0:0:0")
    fTextCurTime:GetText():SetFontSize(24)
	fTextCurTime:GetText():SetFontColor(Float3.WHITE)

    self:_StartCoroutineLoop()

    -- list
    local list = UIList:New("ListTime")
    self._listTimeAlarm = list
    frame1:AttachChild(list)
    list:LLY(-2.0)
    list:SetAnchorHor(0.0, 0.5)
    list:SetAnchorParamHor(5.0, -40.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamVer(120.0, -100.0)
    list:SetItemBackColor(Float3(0.7, 0.7, 0.7))
    list:SetReleasedDoSelect(true)
    list:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessList(list)

    local posVer = -120.0

    local textAlarmTimeTip = UIFText:New()
	frame:AttachChild(textAlarmTimeTip)
	textAlarmTimeTip:LLY(-4.0)
	textAlarmTimeTip:SetAnchorHor(0.5, 1.0)
    textAlarmTimeTip:SetAnchorVer(1.0, 1.0)
    textAlarmTimeTip:SetAnchorParamHor(0.0, -20.0)
    textAlarmTimeTip:SetAnchorParamVer(posVer, posVer)
    textAlarmTimeTip:GetText():SetText(""..PX2_LM_APP:GetValue("AlarmTimeTip"))
    textAlarmTimeTip:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    textAlarmTimeTip:SetPivot(0.0, 0.5)
	textAlarmTimeTip:GetText():SetFontColor(Float3.WHITE)
    manykit_uiProcessTextFont(textAlarmTimeTip:GetText(), 24)
    
    posVer = -200.0

    local textAlarmTime = UIFText:New()
	frame1:AttachChild(textAlarmTime)
	textAlarmTime:LLY(-2.0)
	textAlarmTime:SetAnchorHor(0.5, 0.5)
    textAlarmTime:SetAnchorVer(1.0, 1.0)
    textAlarmTime:SetAnchorParamHor(0.0, 100.0)
    textAlarmTime:SetAnchorParamVer(posVer, posVer)
    textAlarmTime:GetText():SetText(""..PX2_LM_APP:GetValue("AlarmTime"))
    textAlarmTime:SetPivot(0.0, 0.5)
    textAlarmTime:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
	textAlarmTime:GetText():SetFontColor(Float3.WHITE)
	manykit_uiProcessTextFont(textAlarmTime:GetText(), 24)
    local uiEditBoxAlarmTime = UIEditBox:New("EditBoxAlarmTime")
	frame1:AttachChild(uiEditBoxAlarmTime)
	uiEditBoxAlarmTime:LLY(-2.0)
	uiEditBoxAlarmTime:SetAnchorHor(0.5, 1.0)
	uiEditBoxAlarmTime:SetAnchorParamHor(100.0, -60.0)
    uiEditBoxAlarmTime:SetAnchorVer(1.0, 1.0)
    uiEditBoxAlarmTime:SetAnchorParamVer(posVer, posVer)
	uiEditBoxAlarmTime:SetPivot(0.5, 0.5)
    self._editboxTime = uiEditBoxAlarmTime

    local checkEveryData = UICheckButton:New("CheckEveryDay")
	frame1:AttachChild(checkEveryData)
	checkEveryData:LLY(-2.0)
	checkEveryData:SetAnchorHor(1.0, 1.0)
	checkEveryData:SetAnchorParamHor(-40.0, -40.0)
    checkEveryData:SetAnchorVer(1.0, 1.0)
    checkEveryData:SetAnchorParamVer(posVer, posVer)
	checkEveryData:SetPivot(0.5, 0.5)
    checkEveryData:SetSize(40.0, 40.0)
    local fText = checkEveryData:CreateAddFText(""..PX2_LM_APP:GetValue("EveryDay"))
    fText:GetText():SetFontColor(Float3.WHITE)
    fText:GetText():SetFontScale(0.7)
    self._checkEveryDay = checkEveryData
	manykit_uiProcessCheck(checkEveryData)

    posVer = posVer-80.0

    local textAlarm = UIFText:New()
	frame1:AttachChild(textAlarm)
	textAlarm:LLY(-2.0)
	textAlarm:SetAnchorHor(0.5, 0.5)
    textAlarm:SetAnchorVer(1.0, 1.0)
    textAlarm:SetAnchorParamHor(0.0, 100.0)
    textAlarm:SetAnchorParamVer(posVer, posVer)
    textAlarm:GetText():SetText(""..PX2_LM_APP:GetValue("AlarmMsg"))
    textAlarm:SetPivot(0.0, 0.5)
    textAlarm:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
	manykit_uiProcessTextFont(textAlarm:GetText(), 24)
	textAlarm:GetText():SetFontColor(Float3.WHITE)
    local uiEditBoxAlarmMsg = UIEditBox:New("EditBoxAlarmMsg")
	frame1:AttachChild(uiEditBoxAlarmMsg)
	uiEditBoxAlarmMsg:LLY(-2.0)
	uiEditBoxAlarmMsg:SetAnchorHor(0.5, 1.0)
	uiEditBoxAlarmMsg:SetAnchorParamHor(100.0, -20.0)
    uiEditBoxAlarmMsg:SetAnchorVer(1.0, 1.0)
    uiEditBoxAlarmMsg:SetAnchorParamVer(posVer, posVer)
	uiEditBoxAlarmMsg:SetPivot(0.5, 0.5)
    self._editBoxMsg = uiEditBoxAlarmMsg

    posVer = posVer-80.0

    local textAlarmMusic = UIFText:New()
	frame1:AttachChild(textAlarmMusic)
	textAlarmMusic:LLY(-2.0)
	textAlarmMusic:SetAnchorHor(0.5, 0.5)
    textAlarmMusic:SetAnchorVer(1.0, 1.0)
    textAlarmMusic:SetAnchorParamHor(0.0, 150.0)
    textAlarmMusic:SetAnchorParamVer(posVer, posVer)
    textAlarmMusic:GetText():SetText(""..PX2_LM_APP:GetValue("AlarmMusic"))
    textAlarmMusic:SetPivot(0.0, 0.5)
    textAlarmMusic:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
	textAlarmMusic:GetText():SetFontColor(Float3.WHITE)
	manykit_uiProcessTextFont(textAlarmMusic:GetText(), 24)
    local comboBoxAlarmMusic = UIComboBox:New("ComboBoxAlarmMusic")
	frame1:AttachChild(comboBoxAlarmMusic)
	self._comboBoxMusic = comboBoxAlarmMusic
	comboBoxAlarmMusic:LLY(-2.0)
	comboBoxAlarmMusic:SetAnchorHor(0.5, 1.0)
	comboBoxAlarmMusic:SetAnchorParamHor(100.0, -20.0)
    comboBoxAlarmMusic:SetAnchorVer(1.0, 1.0)
    comboBoxAlarmMusic:SetAnchorParamVer(posVer, posVer)
	comboBoxAlarmMusic:SetPivot(0.5, 0.5)
    self:_RefreshTimeAlaramMusic()
	manykit_uiProcessBtn(comboBoxAlarmMusic:GetSelectButton())
	manykit_uiProcessList(comboBoxAlarmMusic:GetChooseList())

    local btnRemove = UIButton:New("BtnRemoveTime")
	frame1:AttachChild(btnRemove)
	btnRemove:LLY(-1.0)
	btnRemove:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnRemove:SetAnchorHor(0, 0)
    btnRemove:SetAnchorParamHor(g_manykit._wBtn*2.5 + 15.0, g_manykit._wBtn*2.5 + 15.0)
	btnRemove:SetAnchorVer(0.0, 0.0)
	btnRemove:SetAnchorParamVer(60.0, 60.0)
	local fText = btnRemove:CreateAddFText(""..PX2_LM_APP:GetValue("Remove"))
    manykit_uiProcessTextFont(fText:GetText(), 24)
    btnRemove:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnRemove)

    local btnUpdate = UIButton:New("BtnUpdateTime")
	frame1:AttachChild(btnUpdate)
	btnUpdate:LLY(-1.0)
	btnUpdate:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnUpdate:SetAnchorHor(0.0, 0.0)
	btnUpdate:SetAnchorVer(0.0, 0.0)
    btnUpdate:SetAnchorParamHor(g_manykit._wBtn*0.5 + 5, g_manykit._wBtn*0.5 + 5)
	btnUpdate:SetAnchorParamVer(60.0, 60.0)
	local fText = btnUpdate:CreateAddFText(""..PX2_LM_APP:GetValue("Update"))
    manykit_uiProcessTextFont(fText:GetText(), 24)
    btnUpdate:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnUpdate)

	local btnAdd = UIButton:New("BtnAddTime")
	frame1:AttachChild(btnAdd)
	btnAdd:LLY(-1.0)
	btnAdd:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnAdd:SetAnchorHor(0.0, 0.0)
    btnAdd:SetAnchorParamHor(g_manykit._wBtn*1.5 + 10, g_manykit._wBtn*1.5 + 10)
	btnAdd:SetAnchorVer(0.0, 0.0)
	btnAdd:SetAnchorParamVer(60.0, 60.0)
	local fText = btnAdd:CreateAddFText(""..PX2_LM_APP:GetValue("Add"))
    manykit_uiProcessTextFont(fText:GetText(), 24)
    btnAdd:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnAdd)

    local btnTest = UIButton:New("BtnTest")
	frame1:AttachChild(btnTest)
	btnTest:LLY(-1.0)
	btnTest:SetSize(g_manykit._hBtn, g_manykit._hBtn)
	btnTest:SetAnchorHor(0.0, 0.0)
    btnTest:SetAnchorParamHor(g_manykit._wBtn*3 + g_manykit._hBtn*0.5 + 20.0, g_manykit._wBtn*2 + g_manykit._hBtn*0.5 + 20.0)
	btnTest:SetAnchorVer(0.0, 0.0)
	btnTest:SetAnchorParamVer(60.0, 60.0)
	local fText = btnTest:CreateAddFText(""..PX2_LM_APP:GetValue("Test"))
    manykit_uiProcessTextFont(fText:GetText(), 16)
    btnTest:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnTest)

    local btnStop = UIButton:New("BtnStop")
	frame1:AttachChild(btnStop)
	btnStop:LLY(-1.0)
	btnStop:SetSize(g_manykit._hBtn, g_manykit._hBtn)
	btnStop:SetAnchorHor(0.0, 0.0)
    btnStop:SetAnchorParamHor(g_manykit._wBtn*3 + g_manykit._hBtn*1.5 + 25.0, g_manykit._wBtn*2 + g_manykit._hBtn*1.5 + 25.0)
	btnStop:SetAnchorVer(0.0, 0.0)
	btnStop:SetAnchorParamVer(60.0, 60.0)
	local fText = btnStop:CreateAddFText(""..PX2_LM_APP:GetValue("Stop"))
    manykit_uiProcessTextFont(fText:GetText(), 16)
    btnStop:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnStop)

	self:_LoadTimeAlarms()
end
-------------------------------------------------------------------------------
function p_robottime:_StartCoroutineLoop()
	coroutine.wrap(function()  
		local ldt = LocalDateTime()
		local tStr = ""
		tStr = ""..DateTimeFormatter:Format(ldt, "%Y/%n/%e-%H:%M:%S %W")
		self._fTextCurTime:GetText():SetText(tStr)
		sleep(0.2) 
		self:_StartCoroutineLoop()    
	end)()
end
-------------------------------------------------------------------------------
-- ui call back
function p_robottime:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

    if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)
    elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

		if "BtnAddTime"==name then
			self:_AddTimeAlarm()
		elseif "BtnUpdateTime"==name then
			self:_UpdateTimeAlarm()
			self:_TimeCheckUpdateSave()
		elseif "BtnRemoveTime"==name then
			self:_OnRemoveSelectTimeAlarm() 
		elseif "BtnTest"==name then
			self:_TestTime()
        elseif "BtnStop"==name then
            self:_StopTimeAlarm()
		end

    elseif UICT_RELEASED_NOTPICK==callType then
        PX2_GH:PlayNormal(obj)
	elseif UICT_LIST_SELECTED==callType then
		if "ListTime"==name then
            self:_OnSelectTimeAlarm()
        end
    end
end
-------------------------------------------------------------------------------
function p_robottime:_RefreshTimeAlaramMusic()
    print(self._name.." p_robotmusic:_RefreshTimeAlaramMusic")

    self._comboBoxMusic:RemoveAllChooseStr()

    local cfgInstMusic = g_manykit:GetPluginTreeInstanceByName("p_robotmusic")
	if cfgInstMusic then
		for i=1, #cfgInstMusic._musicStore, 1 do
			local mu = cfgInstMusic._musicStore[i]

			local name = mu.name
			local islocal = mu.islocal
			local urlpath = mu.urlpath

			print(name)
			print(islocal)
			print(urlpath)

			local item = self._comboBoxMusic:AddChooseStr(name)
			item:SetUserDataString("urlpath", urlpath)
			item:SetUserDataString("islocal", islocal)
		end
	end
end
-------------------------------------------------------------------------------
function p_robottime:_AddTimeAlarm()
    print(self._name.." p_robotmusic:_AddTimeAlarm")

    local tStr = self._editboxTime:GetText()
    print(tStr)
    local ms = self._editBoxMsg:GetText()
    print(ms)
    local evdStr = "false"
    if self._checkEveryDay:IsCheck() then
        evdStr = "true"
    end
    local chooseStr = self._comboBoxMusic:GetChooseStr()
    print("chooseStr")
    print(chooseStr)

    if ""~=tStr then
        local tA = {
            time=tStr,
            msg=ms,
            music=chooseStr,
            everyday=evdStr
        }
        table.insert(self._timeAlarams, #self._timeAlarams+1,tA)
        self:_RefreshTimeAlarm()
        self:_SaveTimeAlarms()
    end
end
-------------------------------------------------------------------------------
function p_robottime:_RefreshTimeAlarm()
    print(self._name.." p_robotmusic:_RefreshTimeAlarm")

    self._listTimeAlarm:RemoveAllItems()
    for i=1,#self._timeAlarams,1 do
        local val = self._timeAlarams[i]
        local str = val.time
        local item = self._listTimeAlarm:AddItem(str)
        item:SetUserDataString("index", i)
    end
end
-------------------------------------------------------------------------------
function p_robottime:_UpdateTimeAlarm()
    print(self._name.." p_robotmusic:_UpdateTimeAlarm")

    local selectItem = self._listTimeAlarm:GetSelectedItem()
    if nil~=selectItem then
        local index = selectItem:GetUserDataString("index") + 0

        local tStr = self._editboxTime:GetText()
        local musicStr = self._comboBoxMusic:GetChooseStr()
        local msgStr = self._editBoxMsg:GetText()
        local ischecked = self._checkEveryDay:IsCheck()

        self._timeAlarams[index].time = tStr
        self._timeAlarams[index].msg = msgStr
        self._timeAlarams[index].music = musicStr

        if ischecked then
            self._timeAlarams[index].everyday = "true"
        else
            self._timeAlarams[index].everyday = "false"
        end

        selectItem:SetLabel(tStr)

        self:_SaveTimeAlarms()
    end

    self:_StopTimeAlarm()
end
-------------------------------------------------------------------------------
function p_robottime:_StopTimeAlarm()
    if PX2_SS then
        PX2_SS:ClearAllSounds()
        PX2_SS:PlayMusic(g_manykit._channel_music, nil, true, 0.0)
    end
end
-------------------------------------------------------------------------------
function p_robottime:_OnSelectTimeAlarm()
    print(self._name.." p_robotmusic:_OnSelectTimeAlarm")

    local selectItem = self._listTimeAlarm:GetSelectedItem()
    if nil~=selectItem then      
        local index = selectItem:GetUserDataString("index") + 0
        print("selectindex")
        print(index)

        local timA = self._timeAlarams[index]
        print(timA.time)
        print(timA.music)
        print(timA.msg)
        print(timA.everyday)

        self._editboxTime:SetText(timA.time)
        self._comboBoxMusic:ChooseStr(timA.music, false)
        self._editBoxMsg:SetText(timA.msg)

        if "true"==timA.everyday then
            self._checkEveryDay:Check(true)
        else
            self._checkEveryDay:Check(false)
        end
    end
end
-------------------------------------------------------------------------------
function p_robottime:_OnRemoveSelectTimeAlarm()
    print(self._name.." p_robotmusic:_OnRemoveSelectTimeAlarm")

    local selectItem = self._listTimeAlarm:GetSelectedItem()
    if nil~=selectItem then      
        local index = selectItem:GetUserDataString("index") + 0
        print("selectindex")
        print(index)

        table.remove(self._timeAlarams, index)

        self:_RefreshTimeAlarm()
        self:_SaveTimeAlarms()
    end
end
-------------------------------------------------------------------------------
function p_robottime:_SaveTimeAlarms()
	print(self._name.." p_robotmusic:_SaveTimeAlarms")

    local data = XMLData()
    data:Create()
    local boostNode = data:NewChild("timealaras");

    for i=1,#self._timeAlarams,1 do
        local ta = self._timeAlarams[i]

        local taNode = boostNode:NewChild("TimeAlarm")
        taNode:SetAttributeString("time", ta.time)
        taNode:SetAttributeString("msg", ta.msg)
        taNode:SetAttributeString("music", ta.music)
        taNode:SetAttributeString("isactived", ta.isactived)
        taNode:SetAttributeString("everyday", ta.everyday)
    end

	local wp = ResourceManager:GetWriteablePath()
	local projName = PX2_PROJ:GetName()
	local writePath = "" .. wp .. "Write_" .. projName .. "/timealarm.xml"
    data:SaveFile(writePath)
    data:Clear()
end
-------------------------------------------------------------------------------
function p_robottime:_LoadTimeAlarms()
	print(self._name.." p_robotmusic:_LoadTimeAlarms")

    local wp = ResourceManager:GetWriteablePath()
    local projName = PX2_PROJ:GetName()
	local writePath = "" .. wp .. "Write_" .. projName .. "/timealarm.xml" 
    self._timeAlarams = {}
    local ret = PX2_RM:LoadXML(writePath)  
    local data = PX2_RM:GetXMLData()  
    local rootNode = data:GetRootNode()
    if ret and data:IsOpened() and not rootNode:IsNull() then
        local nodeChild = rootNode:IterateChild()
        local num = 1
        while not nodeChild:IsNull() do
            local name = nodeChild:GetName()

            local ti = nodeChild:AttributeToString("time")
            local ms = nodeChild:AttributeToString("msg")
            local mus = nodeChild:AttributeToString("music")
            local evd = nodeChild:AttributeToString("everyday")
            local actd = nodeChild:AttributeToString("isactived")

            local val = {
                time=ti,
                msg=ms,
                music=mus,
                everyday=evd,
                isactived=actd
            }

            table.insert(self._timeAlarams, num, val)

            num = num + 1
            nodeChild = rootNode:IterateChild(nodeChild)
        end
    end

    PX2_RM:ClearRes(writePath)
    
    self:_RefreshTimeAlarm()
end
-------------------------------------------------------------------------------
function p_robottime:_TestTime()
	print(self._name.." p_robotmusic:_TestTime")

    local selectItem = self._listTimeAlarm:GetSelectedItem()
    if nil~=selectItem then      
        local index = selectItem:GetUserDataString("index") + 0

        local timA = self._timeAlarams[index]
        self:_PlayTime(timA)
    end
end
-------------------------------------------------------------------------------
function p_robottime:_PlayTime(timeVal)
	print(self._name.." p_robotmusic:_PlayTime")

	local cfgInstMusic = g_manykit:GetPluginTreeInstanceByName("p_robotmusic")
	if cfgInstMusic then
		for i=1, #cfgInstMusic._musicStore, 1 do

			if timeVal.music == cfgInstMusic._musicStore[i].name then
				local musicVal = cfgInstMusic._musicStore[i]  
	
				print(musicVal.name)
				print(musicVal.islocal)
				print(musicVal.urlpath)
				
				local urlPath = ""..musicVal.urlpath
	
                if PX2_SS then
				    PX2_SS:ClearAllSounds()
                end
	
                if musicVal.islocal=="true" then
                    if PX2_SS then
                        PX2_SS:PlayMusic(g_manykit._channel_music, urlPath, true, 0.0)
                    end
                else
                    cfgInstMusic:_PlayMusicHash(urlPath)
                end

                p_net._g_net:_act_voice_tts(timeVal.msg)
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_robottime:_TimeUpdate()
    for i=1, #self._timeAlarams, 1 do
        local ta = self._timeAlarams[i]

        local isEveryday = ta.everyday

        if "false"==ta.isactived or ""==ta.isactived then
            local dt = DateTimeParser:Parse("%Y/%n/%e/%H:%M:%S", ta.time, 0)
            local dtTime = DateTime() + Timespan(8*3600, 0.0)
            if dtTime >= dt then   
                self:_PlayTime(ta)

                if "true"==ta.everyday then
                    local dtTime1 = dtTime + Timespan(24*3600, 0.0)
                    local tStr = ""..DateTimeFormatter:Format(dtTime1, "%Y/%n/%e/%H:%M:%S")
                    self._timeAlarams[i].time = tStr

                    self:_RefreshTimeAlarm()
                else
                    self._timeAlarams[i].isactived = "true"
                end
                
                self:_SaveTimeAlarms()
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_robottime:_TimeCheckUpdateSave()
    for i=1, #self._timeAlarams, 1 do
        local ta = self._timeAlarams[i]

        local dt = DateTimeParser:Parse("%Y/%n/%e/%H:%M:%S", ta.time, 0)
        local dtTime = DateTime() + Timespan(8*3600, 0.0)
        if dtTime >= dt then   
            self._timeAlarams[i].isactived = "true"
        else
            self._timeAlarams[i].isactived = "false"
        end
    end

    self:_SaveTimeAlarms()
end
-------------------------------------------------------------------------------
function p_robottime:_OnSelectTimeAlarm()
	print(self._name.." p_robotmusic:_OnSelectTimeAlarm")

    local selectItem = self._listTimeAlarm:GetSelectedItem()
    if selectItem then      
        local index = selectItem:GetUserDataString("index") + 0
        print("selectindex")
        print(index)

        local timA = self._timeAlarams[index]
        print(timA.time)
        print(timA.music)
        print(timA.msg)
        print(timA.everyday)

        self._editboxTime:SetText(timA.time)
        self._comboBoxMusic:ChooseStr(timA.music, false)
        self._editBoxMsg:SetText(timA.msg)
        if "true"==timA.everyday then
            self._checkEveryDay:Check(true)
        else
            self._checkEveryDay:Check(false)
        end
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_robottime)
-------------------------------------------------------------------------------