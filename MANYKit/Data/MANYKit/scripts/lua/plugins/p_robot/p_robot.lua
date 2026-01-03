-- p_robot.lua

-- enmus
RobotMoveType = 
{
	RMT_NONE = 1,
	RMT_FORWARD = 2,
	RMT_BACKWARD = 3,
	RMT_LEFT = 4,
	RMT_RIGHT = 5,
	RMT_MAX_TYPE = 6,
}
-------------------------------------------------------------------------------
RobotActionState = 
{
	RAS_NORMAL = 1,
	RAS_GOCHARGEFRONT = 2,
	RAS_GOCHARGING_REAL = 3,
	RAS_GOCHARGING_RETRY = 4,
	RAS_CHARGING = 5,
	RAS_MAX_STATE = 6,
}
-------------------------------------------------------------------------------
-- base
p_robot = class(p_ctrl,
{
    _requires = {"p_holospace",},

	_name = "p_robot",
	_id = 10000,

	-- save the ininstance create in scene
	_g_sceneInst = nil,

	-- ui
	-- ui cnt
	_frameContent = nil,
	_frameSetting = nil,
	_listDevice = nil,	
	_btnDeviceConnect = nil,
	_listSerial = nil,
	_btnSerialConnect = nil,
	_listLidar = nil,
	_comboxLidarType = nil,
	_btnLidarConnect = nil,

	-- ui map option
	_frameMapOption = nil,
	_mapObstDrawType = 0, --0 none,1 obst,2 remove
	_isLidarSlamScaleBig = false,
	_isLidarSlamFrameCenter = false,
	_mapPicBoxIsPressed = false,
	_mapPicBoxIsMoved = false,
	_mapPickPos = APoint(0,0,0),
	_frameLidarSlam = nil,
	_frameLidar = nil,
	_frameSlam = nil,
	_textureMapInit = nil,
	_textureMapCur = nil,
	_fTextPostion = nil,
	_fTextSpeed = nil,
	_fTextPostionPick = nil,

	-- ui ctrl pad
	_frameCtrlPad = nil,
	_moveType = 0,
    _IsLeftPressed = false,
	_IsRightPressed = false,
	_IsUpPressed = false,
	_IsDownPressed = false,
	_IsSpacePressed = false,
	_IsDirectionChanged = false,

	-- connect
	_isDeviceAutoCnt = true,
	_ipDeviceConnect = "",
	_ismoto_usepid = true,
	_ismoto_use298n = false,
	
	-- 0 is arduino, 1 is 625
	_controlMode = 0,

	_serialport_lidar = "",
    _serialport_arduino = "",
	_isuseraxis = false,	
	_serialport_axis = "",

	-- robot
	_g_ispluginloaded = false,
	_g_slamname = "SlamHector",
    _maxspeed = 0.5,

    _pinLidar = Arduino.P_11,
    _pinChargeCheck0 = Arduino.P_12,
    _pinChargeCheck1 = Arduino.P_13,

    _roboActor = nil,
    _roboAgent = nil,
	_slamRunner = nil,
	_modelSlamReusltSetted = nil,

	_sceneMapTexInit = nil,
	_sceneMapTexCur = nil,

    -- state
    _moveType = RobotMoveType.RMT_NONE,
	_actionState = RobotActionState.RAS_NORMAL,

    -- running
	_IsAdjustToDirection = false,
	_IsRobotMoveSpeedChanged = false,
	_AdjustDir = AVector(1.0, 0.0, 0.0),

	-- way
	_indexwaypoint = 0,

	-- charge
	_pinChargeCheck0 = Arduino.P_12,
	_pinChargeCheck1 = Arduino.P_13,
	_isdowaypatrolbeforecharging = false,
    _isdowaypatrol = false,
	_chargeUpdateSeconds = 0.0,
	_checkSeconds = 0.0,
	_lowpower = 2,
	_highpower = 9,
	
	-- ESKF
	_isUseESKF = false,
	_isUseESKFInited = false,
	_axisAccel = AVector.ZERO,
	_axisGyro = AVector.ZERO,
	_axisAngle = AVector.ZERO,

	-- serials
	_serials_check = {},
	_serial_axis = nil,
})
-------------------------------------------------------------------------------
function p_robot:OnAttached()
	print(self._name.." p_robot:OnAttached")

	p_ctrl.OnAttached(self)

	if g_manykit._isRaspberry then
		print("g_manykit._isRaspberry")

		self._controlMode = 0
		p_robot._g_slamname = "SlamGMapping"
	else
		print("not g_manykit._isRaspberry")

		self._controlMode = 0
		p_robot._g_slamname = "SlamHector"
	end
	print("slamname:"..p_robot._g_slamname)

	if nil==p_robot._g_sceneInst then
    	PX2_LM_APP:AddItem(self._name, "Robot", "机器人")
		PX2_LM_APP:AddItem("Scan", "Scan", "扫描")
		PX2_LM_APP:AddItem("Connect", "Connect", "连接")
		PX2_LM_APP:AddItem("DisConnect", "DisConnect", "断开")
		PX2_LM_APP:AddItem("AutoConnect", "AutoConnect", "自动连接")
		PX2_LM_APP:AddItem("Device", "Device", "设备")
		PX2_LM_APP:AddItem("Serial", "Serial", "串口")
		PX2_LM_APP:AddItem("Encoder", "Encoder", "编码器")
		PX2_LM_APP:AddItem("298N", "298N", "298N")
		PX2_LM_APP:AddItem("Lidar", "Lidar", "雷达")
		PX2_LM_APP:AddItem("lidarsw", "lidarsw", "开雷达")

		PX2_LM_APP:AddItem("master", "master", "主机")
		PX2_LM_APP:AddItem("connector", "connector", "连接器")
		PX2_LM_APP:AddItem("master_sendlidar", "master_sendlidar", "主机发送雷达数据")
		PX2_LM_APP:AddItem("master_connector_calculate", "master_connector_calculate", "主机连接器接受雷达数据计算")

		PX2_LM_APP:AddItem("ClearObst", "ClearObst", "清除障碍")
		PX2_LM_APP:AddItem("AddObst", "AddObst", "增加障碍")
		PX2_LM_APP:AddItem("RemoveObst", "RemoveObst", "移除障碍")
		PX2_LM_APP:AddItem("ClearPath", "ClearPath", "清除路径")
		PX2_LM_APP:AddItem("MapUpdate", "MapUpdate", "地图更新")
		PX2_LM_APP:AddItem("SaveMap", "SaveMap", "地图保存")
		PX2_LM_APP:AddItem("LoadMap", "LoadMap", "地图加载")
		PX2_LM_APP:AddItem("GoCharge", "GoCharge", "充电")
		PX2_LM_APP:AddItem("map", "map", "地图")
		PX2_LM_APP:AddItem("lidarcur", "lidarcur", "当前雷达")
		PX2_LM_APP:AddItem("Debug", "Debug", "调试")
		PX2_LM_APP:AddItem("Pos", "Pos", "位置")
		PX2_LM_APP:AddItem("Speed", "Speed", "速度")
		PX2_LM_APP:AddItem("PickPos", "PickPos", "点击位置")

		PX2_LM_APP:AddItem("Init", "Init", "初始")
		PX2_LM_APP:AddItem("Cur", "Cur", "当前")

		PX2_LM_APP:AddItem("PadCtrl", "PadCtrl", "遥控")

		PX2_LM_APP:AddItem("RobotShow", "RobotShow", "机器人显示")

		p_ctrl.OnAttached(self)
		self:_CreateContentFrame()

		if g_manykit._isRobot then
			print("slamname:"..p_robot._g_slamname)

			-- robot create add to nodeActorAIOT
			-- create a robot in scene
			local scene = PX2_PROJ:GetScene()
			if scene then
				local nodeActorAIOT = scene:GetObjectByID(p_holospace._g_IDNodeActorAIOT)
				if nodeActorAIOT then
					local robotSCtrl = p_robot:New()
					p_robot._g_sceneInst = robotSCtrl
					print("slamnameeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee:"..p_robot._g_slamname)

					local roboActor = robotSCtrl:_CreateRobot()
					nodeActorAIOT:AttachChild(roboActor)
					roboActor.LocalTransform:SetTranslateZ(0.0)
					roboActor:ResetPlay()		

					robotSCtrl._roboAgent:SetControlMode(self._controlMode)
					
					print("self._controlModeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee:"..self._controlMode)

					if self._controlMode == 1 then
						local serial = Serial()
						serial:UpdatePortList()
						local numPorts = serial:GetNumPorts()
						for i=0, numPorts-1 do
							local portStr = serial:GetPort(i)
							local portDesc = serial:GetPortDesc(i)
							local hardID = serial:GetPortHardID(i)
							local platType = PX2_APP:GetPlatformType()
							
							print("portStr:::::::::::::::::"..portStr)
							print("portDesc::::::::::::::::"..portDesc)
							print("hardID::::::::::::::::::"..hardID)
						end

						robotSCtrl._roboAgent:GetMototDriver():Open("/dev/ttyUSB0", 9600)

						coroutine.wrap(function()
							sleep(2.0)
							robotSCtrl._roboAgent:GetLidar():SetLiDarType(LiDar.LT_WR)
							robotSCtrl._roboAgent:LidarOpen("192.168.1.51", 2112)
						end)()
					else
						-- serial check who am i
						robotSCtrl:_serialCheckWhoAmI()
					end
				end
			end
		end

		local frameMapOption = self:_CreateUIMapOption()
		self._frameContent:AttachChild(frameMapOption)
		self._frameMapOption = frameMapOption
		frameMapOption:LLY(-10)

		if g_manykit._isRobot then
			RegistEventObjectFunction("InputEventSpace::KeyPressed", self, function(myself, keyStr)
				if "KC_W" == keyStr then
					myself:_MoveControl(3, true)
				elseif "KC_S" == keyStr then
					myself:_MoveControl(4, true)
				elseif "KC_A" == keyStr then
					myself:_MoveControl(1, true)
				elseif "KC_D" == keyStr then
					myself:_MoveControl(2, true)
				elseif "KC_SPACE" == keyStr then
					myself:_MoveControl(0, true)
				end
			end)
			RegistEventObjectFunction("InputEventSpace::KeyReleased", self, function(myself, keyStr)
				if "KC_W" == keyStr then
					myself:_MoveControl(3, false)
				elseif "KC_S" == keyStr then
					myself:_MoveControl(4, false)
				elseif "KC_A" == keyStr then
					myself:_MoveControl(1, false)
				elseif "KC_D" == keyStr then
					myself:_MoveControl(2, false)
				elseif "KC_SPACE" == keyStr then
					myself:_MoveControl(0, false)
				end
			end)
		end
	end

	self._movable:ResetPlay()
end
-------------------------------------------------------------------------------
function p_robot:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_robot:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_robot:OnPPlay()
	print(self._name.." p_robot:OnPPlay")
end
-------------------------------------------------------------------------------
function p_robot:OnPUpdate()
	-- only agent in scene, can do update tex
	local es = PX2_APP:GetElapsedSecondsWidthSpeed()

	local roboAgent = self._roboAgent
	if roboAgent then
		if self._controlMode == 0 then
			if self._serial_axis then
				self._serial_axis:Update()
			end

			local num = 0
			for key, value in pairs(self._serials_check) do
				local port = key
				local ser = value
				if ser then
					ser:Update()
					num = num + 1
				end
			end
			if num > 0 then
				local didclear = false
				if self._isuseraxis then
					if self._serialport_axis~="" and self._serialport_arduino~="" then
						didclear = true
					end
				else
					if self._serialport_arduino~="" then
						didclear = true
					end
				end

				if didclear then
					self:_ClearSerialCheck()
					self:_serialCheckWhoIsLidar()

					local platType = PX2_APP:GetPlatformType()
					--if Application.PLT_LINUX==platType and PX2_APP:IsARM() then
					PX2_GH:SendGeneralEvent("autoconnectlidar", "", 2.0)
					--end
				end
			end
		end

		local mapResoInit = roboAgent:GetInitMapResolution()
		local mWInit = roboAgent:GetInitMapWidth()
		local mHInit = roboAgent:GetCurMapHeight()
		local wInit = mWInit * mapResoInit
		local hInit = mHInit * mapResoInit

		local mapReso = roboAgent:GetCurMapResolution()
		local mW = roboAgent:GetCurMapWidth()
		local mH = roboAgent:GetCurMapHeight()
		local w = mW * mapReso
		local h = mH * mapReso

		if self._sceneMapTexInit then
			self._sceneMapTexInit:GetUIPicBox():SetTexture(roboAgent:GetTextureMapInit())			
            if wInit>0.0 and hInit>0.0 then
				self._sceneMapTexInit:SetSize(wInit, hInit)
			 end
		end
		if self._sceneMapTexCur then
			self._sceneMapTexCur:GetUIPicBox():SetTexture(roboAgent:GetTextureMap())

            if w>0.0 and h>0.0 then
				self._sceneMapTexCur:SetSize(w, h)
            end
		end

		-- running
		self:_RobotUpdate()
	else
		self:_RobotInfoUpdate()
		self:_PadCtrlUpdate()
	end
end
-------------------------------------------------------------------------------
function p_robot:_Cleanup()
	print(self._name.." p_robot:_Cleanup")

	if self._serial_axis then
		self._serial_axis:Close()
		Serial:Delete(self._serial_axis)
		self._serial_axis = nil
	end

    PX2_PROJ:PoolSet("Arduino"..self._id, nil)

	if self._slamRunner then
		self._slamRunner:Terminate()

		if "SlamGMapping"==p_robot._g_slamname then
			SlamGMappingRunner:Delete(self._slamRunner)
		elseif "SlamHector"==p_robot._g_slamname then
			SlamHectorRunner:Delete(self._slamRunner)
		end
	end
	self._slamRunner = nil

	if self._roboActor then
		self._roboActor:DetachFromParent()
	end
end
-------------------------------------------------------------------------------
function p_robot:OnPluginRegisted()
	print(self._name.." p_robot:OnPluginRegisted")
end
-------------------------------------------------------------------------------
-- ui create robot connect ui, only support one robot now
function p_robot:_CreateContentFrame()
    print(self._name.." p_robot:_CreateContentFrame")

	local frame = UIFrame:New()
    self._frame:AttachChild(frame)
	self._frameContent = frame
	frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

	local btnSetting = UIButton:New("BtnList")
	frame:AttachChild(btnSetting)
	btnSetting:LLY(-18)
	btnSetting:SetAnchorHor(0.0, 0.0)
	btnSetting:SetAnchorVer(1.0, 1.0)
	btnSetting:SetAnchorParamHor(25.0, 25.0)
	btnSetting:SetAnchorParamVer(-25.0, -25.0)
	btnSetting:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
	btnSetting:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/setting.png")
	btnSetting:SetScriptHandler("_UICallback", self._scriptControl)

	local frameSetting = self:_CreateFrameSetting()
	frame:AttachChild(frameSetting)
	self._frameSetting = frameSetting
	frameSetting:LLY(-20)
	frameSetting:Show(false)

	local frameCtrl = self:_CreatePadFrame()
	frame:AttachChild(frameCtrl)
	frameCtrl:Show(false)
	self._frameCtrlPad = frameCtrl
	frameCtrl:LLY(-15)

	return frame
end
-------------------------------------------------------------------------------
function p_robot:_CreateFrameSetting()
	local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-10, -10, "连接")
	self._FrameSetting = uiFrameBack
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

	local frameTab = UITabFrame:New("TableFrameSetting")
    uiFrame:AttachChild(frameTab)
    frameTab:LLY(-1.0)
    frameTab:SetAnchorHor(0.0, 1.0)
    frameTab:SetAnchorVer(0.0, 1.0)
    frameTab:SetAnchorParamVer(0.0, 0.0)
    frameTab:SetTabWidth(160)
    frameTab:SetTabBarHeight(g_manykit._hBtn)
    frameTab:SetTabHeight(g_manykit._hBtn)
    frameTab:SetFontColor(Float3.WHITE)
	frameTab:SetScriptHandler("_UICallback", self._scriptControl)

    local frameDevice = self:_CreateDeviceFrame()
    frameTab:AddTab("Device", PX2_LM_APP:V("Device"), frameDevice)

    local frameBle = self:_CreateBleSerial()
    frameTab:AddTab("Serial", PX2_LM_APP:V("Serial"), frameBle)

    local frameLidar = self:_CreateLidarConnect()
    frameTab:AddTab("Lidar", PX2_LM_APP:V("Lidar"), frameLidar)

    frameTab:SetActiveTab("Device")

	return uiFrameBack
end
function p_robot:_ShowSetting(show)
	self._FrameSetting:Show(show)

	if show then
		if PX2_SS then
        	PX2_SS:PlayASound("common/media/audio/book.mp3", g_manykit._soundVolume, 2.0)
		end
	else
		if PX2_SS then
			PX2_SS:PlayASound("common/media/audio/click1.mp3", g_manykit._soundVolume, 2.0)
		end
	end
end
-------------------------------------------------------------------------------
-- ui device
function p_robot:_CreateDeviceFrame()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
    uiFrame:SetAnchorVer(0.0, 1.0)
    
    local list = UIList:New("ListDevice")
	self._listDevice = list
    uiFrame:AttachChild(list)
    list:LLY(-2.0)
    list:SetAnchorHor(0.0, 1.0)
    list:SetAnchorParamHor(50.0, -50.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamVer(100.0, -50.0)
    list:SetReleasedDoSelect(true)
	manykit_uiProcessList(list)

    local btnLeft = UIButton:New("BtnDlgLeft")
    uiFrame:AttachChild(btnLeft)
    btnLeft:LLY(-1.0)
    btnLeft:SetSize(150, 50)
    btnLeft:SetAnchorHor(0.5, 0.5)
    btnLeft:SetAnchorParamHor(-120.0, -120.0)
    btnLeft:SetAnchorVer(0.0, 0.0)
    btnLeft:SetAnchorParamVer(60.0, 60.0)
    btnLeft:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnLeft:CreateAddFText(""..PX2_LM_APP:V("Scan"))
	manykit_uiProcessBtn(btnLeft)
	btnLeft:SetUserDataString("type", "device")
    btnLeft:SetScriptHandler("_UICallback", self._scriptControl)

	local btnRight = UIButton:New("BtnDlgRight")
	uiFrame:AttachChild(btnRight)
	self._btnDeviceConnect = btnRight
	btnRight:LLY(-1.0)
	btnRight:SetSize(150, 50)
	btnRight:SetAnchorHor(0.5, 0.5)
	btnRight:SetAnchorParamHor(120.0, 120.0)
	btnRight:SetAnchorVer(0.0, 0.0)
	btnRight:SetAnchorParamVer(60.0, 60.0)
	btnRight:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnRight:CreateAddFText(""..PX2_LM_APP:V("Connect"))
    manykit_uiProcessBtn(btnRight)
	btnRight:SetUserDataString("type", "dOnInitUpdate192.1evice")
    btnRight:SetScriptHandler("_UICallback", self._scriptControl)

    local autoConnectCheck = UICheckButton:New("CheckAutoConnect")
    uiFrame:AttachChild(autoConnectCheck)
	autoConnectCheck:LLY(-2.0)
	autoConnectCheck:SetAnchorHor(1.0, 1.0)
	autoConnectCheck:SetAnchorParamHor(-120.0, -120.0)
	autoConnectCheck:SetAnchorVer(0.0, 0.0)
	autoConnectCheck:SetAnchorParamVer(60.0, 60.0)
    autoConnectCheck:SetSize(g_manykit._hBtn, g_manykit._hBtn)
	autoConnectCheck:CreateAddFText("" .. PX2_LM_APP:V("AutoConnect"))
	manykit_uiProcessCheck(autoConnectCheck)
    autoConnectCheck:SetScriptHandler("_UICallback", self._scriptControl)

    local autocntip = PX2_PROJ:GetConfig("deviceautocntip")
    if ""~=autocntip then
        self._isDeviceAutoCnt = true
		self._ipDeviceConnect = autocntip
    else
		self._isDeviceAutoCnt = false
		self._ipDeviceConnect = ""
    end
    autoConnectCheck:Check(self._isDeviceAutoCnt, false)

    local clientConnector = PX2_APP:GetEngineClientConnector()
	if clientConnector then
		clientConnector:SetAutoConnect(self._isDeviceAutoCnt)
		clientConnector:SetAutoConnectIP(self._ipDeviceConnect)
		clientConnector:AddOnConnectCallback("_onDeviceConnect", self._scriptControl)
		clientConnector:AddOnDisconnectCallback("_onDeviceDisconnect", self._scriptControl)
	end

	UnRegistAllEventFunctions("EngineNetES::EngineClientUDPInfoChanged")
	RegistEventObjectFunction("EngineNetES::EngineClientUDPInfoChanged", self, function(myself)
		myself:_RefreshDevices()
	end)

    return uiFrame
end
function p_robot:_onDeviceConnect(connector)
	self._btnDeviceConnect:GetText():SetText(""..PX2_LM_APP:V("DisConnect"))
end
function p_robot:_onDeviceDisconnect(connector)
	self._btnDeviceConnect:GetText():SetText(""..PX2_LM_APP:V("Connect"))
end
function p_robot:_RefreshDevices()
	self._listDevice:RemoveAllItems()

	local numInfos = PX2_APP:GetNumUDPNetInfo()
    for i=1,numInfos,1 do
        local netInfo = PX2_APP:GetUDPNetInfo(i-1)
        if nil~=netInfo then
            local name = netInfo:GetName()
            local ip = netInfo:GetIP()
            local allStr = name..":"..ip

            local item = self._listDevice:AddItem(allStr)
            item:SetUserDataString("IP", ip)
        end
    end
end
-------------------------------------------------------------------------------
-- ui ble serial
function p_robot:_CreateBleSerial()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
    uiFrame:SetAnchorVer(0.0, 1.0)

	local list = UIList:New("ListBluetooth")
	self._listSerial = list
    uiFrame:AttachChild(list)
    list:LLY(-2.0)
    list:SetAnchorHor(0.0, 1.0)
    list:SetAnchorParamHor(50.0, -50.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamVer(100.0, -50.0)
    list:SetReleasedDoSelect(true)
	manykit_uiProcessList(list)

    local btnLeft = UIButton:New("BtnDlgLeft")
    uiFrame:AttachChild(btnLeft)
    btnLeft:LLY(-1.0)
    btnLeft:SetSize(150, 50)
    btnLeft:SetAnchorHor(0.5, 0.5)
    btnLeft:SetAnchorParamHor(-120.0, -120.0)
    btnLeft:SetAnchorVer(0.0, 0.0)
    btnLeft:SetAnchorParamVer(60.0, 60.0)
    btnLeft:SetSize(g_manykit._wBtn, g_manykit._hBtn)
    btnLeft:CreateAddFText(""..PX2_LM_APP:V("Scan"))
    manykit_uiProcessBtn(btnLeft)
	btnLeft:SetUserDataString("type", "serial")
    btnLeft:SetScriptHandler("_UICallback", self._scriptControl)

	local btnRight = UIButton:New("BtnDlgRight")
	uiFrame:AttachChild(btnRight)
	self._btnSerialConnect = btnRight
	btnRight:LLY(-1.0)
	btnRight:SetSize(150, 50)
	btnRight:SetAnchorHor(0.5, 0.5)
	btnRight:SetAnchorParamHor(120.0, 120.0)
	btnRight:SetAnchorVer(0.0, 0.0)
	btnRight:SetAnchorParamVer(60.0, 60.0)
    btnRight:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnRight:CreateAddFText(""..PX2_LM_APP:V("Connect"))
	manykit_uiProcessBtn(btnRight)
	btnRight:SetUserDataString("type", "serial")
    btnRight:SetScriptHandler("_UICallback", self._scriptControl)

    local motoSpeedCheck = UICheckButton:New("MotoSpeedCheckButton")
    uiFrame:AttachChild(motoSpeedCheck)
	motoSpeedCheck:LLY(-1.0)
	motoSpeedCheck:SetAnchorHor(1.0, 1.0)
	motoSpeedCheck:SetAnchorParamHor(-90.0, -90.0)
	motoSpeedCheck:SetAnchorVer(0.0, 0.0)
	motoSpeedCheck:SetAnchorParamVer(60.0, 60.0)
    motoSpeedCheck:SetSize(g_manykit._hBtn, g_manykit._hBtn)
    motoSpeedCheck:CreateAddFText(""..PX2_LM_APP:V("Encoder"))
    motoSpeedCheck:SetScriptHandler("_UICallback", self._scriptControl)
    motoSpeedCheck:Check(self._ismoto_usepid, false)
	manykit_uiProcessCheck(motoSpeedCheck)

    local moto298NCheck = UICheckButton:New("298NCheckButton")
    uiFrame:AttachChild(moto298NCheck)
	moto298NCheck:LLY(-1.0)
	moto298NCheck:SetAnchorHor(1.0, 1.0)
	moto298NCheck:SetAnchorParamHor(-140.0, -140.0)
	moto298NCheck:SetAnchorVer(0.0, 0.0)
	moto298NCheck:SetAnchorParamVer(60.0, 60.0)
    moto298NCheck:SetSize(g_manykit._hBtn, g_manykit._hBtn)
    moto298NCheck:CreateAddFText(""..PX2_LM_APP:V("298N"))
    moto298NCheck:SetScriptHandler("_UICallback", self._scriptControl)
    moto298NCheck:Check(self._ismoto_use298n, false)
	manykit_uiProcessCheck(moto298NCheck)

    local lidarSWCheck = UICheckButton:New("LidarSwitch")
    uiFrame:AttachChild(lidarSWCheck)
	lidarSWCheck:LLY(-1.0)
	lidarSWCheck:SetAnchorHor(1.0, 1.0)
	lidarSWCheck:SetAnchorParamHor(-190.0, -190.0)
	lidarSWCheck:SetAnchorVer(0.0, 0.0)
	lidarSWCheck:SetAnchorParamVer(60.0, 60.0)
    lidarSWCheck:SetSize(40, 40)
    lidarSWCheck:CreateAddFText(""..PX2_LM_APP:V("lidarsw"))
    lidarSWCheck:SetScriptHandler("_UICallback", self._scriptControl)
    lidarSWCheck:Check(true, false)
	manykit_uiProcessCheck(lidarSWCheck)

    UnRegistAllEventFunctions("EngineNetES::OnEngineServerBeConnected")
    RegistEventObjectFunction("EngineNetES::OnEngineServerBeConnected", self, function(myself, clientID, ip)
		--p_robot._g_sceneInst:_OnArduinoConnected()
    end)

    RegistEventObjectFunction("SerialES::Open", self, function(myself, tag)
		print(self._name.." SerialES::Open")
		print("SerialES::Open:"..tag)
		
		if p_robot._g_sceneInst then
			print("myself._serialport_arduino:"..p_robot._g_sceneInst._serialport_arduino)

			if tag==p_robot._g_sceneInst._serialport_arduino then

				if nil~=myself._btnSerialConnect then
					myself._btnSerialConnect:GetText():SetText(""..PX2_LM_APP:V("DisConnect"))
				end

				p_robot._g_sceneInst:_OnArduinoConnected()
			end
		end
    end)
    RegistEventObjectFunction("SerialES::Close", self, function(myself, tag)
		if p_robot._g_sceneInst then
			if tag==p_robot._g_sceneInst._serialport_arduino then
				if nil~=myself._btnSerialConnect then
					myself._btnSerialConnect:GetText():SetText(""..PX2_LM_APP:V("Connect"))
				end
			end
		end
    end)

	return uiFrame
end
function p_robot:_ScanSerial()
	print(self._name.." p_robot:_ScanSerial")

	self._listSerial:RemoveAllItems()

    local serial = Serial()
    serial:UpdatePortList()
    local numPorts = serial:GetNumPorts()
    for i=0, numPorts-1 do
        local portStr = serial:GetPort(i)
        local portDesc = serial:GetPortDesc(i)
        local hardID = serial:GetPortHardID(i)
		
        local item = self._listSerial:AddItem(portStr.."---"..portDesc)
        item:GetFText():GetText():SetFontScale(0.7)
        item:SetUserDataString("NamePath", portStr)
    end  
end
function p_robot:_ScanBle()
	print(self._name.." p_robot:_ScanBle")

    if PX2_BLUETOOTH and self._listSerial then
		self._listSerial:RemoveAllItems()
		PX2_BLUETOOTH:GetPairedDevices()
		local numPairedDevices = PX2_BLUETOOTH:GetNumPairedDevices()
		for i=1, numPairedDevices, 1 do
			local deviceStr = PX2_BLUETOOTH:GetPairedDevice(i-1)
			local stk = StringTokenizer(deviceStr, "$")
			if stk:Count() >= 2 then
				local strName = stk:GetAt(0)
				local strAddress = stk:GetAt(1)

				local useStrName = strName

				local uiItem = self._listSerial:AddItem(useStrName)

				local text = UIFText:New()
				uiItem:AttachChild(text)
				text:LLY(-1.0)
				text:SetAnchorHor(0.5, 1.0)
				text:SetAnchorVer(0.0, 1.0)
				text:GetText():SetFontColor(Float3.WHITE)
				text:GetText():SetText(""..PX2_LM_APP:V("IsPaired"))

				uiItem:SetUserDataString("NamePath", deviceStr)
			end
		end
        PX2_BLUETOOTH:DoDiscovery()
    end
end
function p_robot:_SerialTryToConnect()
	print(self._name.." p_robot:_SerialTryToConnect")

    local item = self._listSerial:GetSelectedItem()

    if item then
        local namePath = item:GetUserDataString("NamePath")
        print("NamePath:"..namePath)        
        if ""~=namePath then
			p_robot._g_sceneInst._serialport_arduino = namePath
			p_robot._g_sceneInst._roboAgent:GetArduino():Initlize(Arduino.M_SERIAL, namePath, 9600)
        end
    end
end
function p_robot:_BluetoothTryToConnect()
    local item = self._listSerial:GetSelectedItem()

    if item then
        local namePath = item:GetUserDataString("NamePath")
        print("NamePath:"..namePath)
        if ""~=namePath then
            local stk = StringTokenizer(namePath, "$")
            if stk:Count() >= 2 then
                local strName = stk:GetAt(0)
                local strAddress = stk:GetAt(1)
                local rssi = stk:GetAt(2)

                if ""~=strAddress then
					if PX2_BLUETOOTH then
						PX2_BLUETOOTH:Connect(strAddress)
					end
                end
            end
        end
    end
end
function p_robot:_OnArduinoConnected()
	print(self._name.." p_robot:_OnArduinoConnected")

	coroutine.wrap(function()
		self:_InitlizeMotoDriver()
		self._roboAgent:GetArduino():PinMode(self._pinLidar, Arduino.PM_OUTPUT)
		self._roboAgent:GetArduino():DigitalWrite(self._pinLidar, true)
		self._roboAgent:GetArduino():PinMode(self._pinChargeCheck0, Arduino.PM_INPUT_PULLUP)
		self._roboAgent:GetArduino():PinMode(self._pinChargeCheck1, Arduino.PM_INPUT_PULLUP)
		-- init check
		self._roboAgent:GetArduino():DigitalRead(self._pinChargeCheck0, false)
		self._roboAgent:GetArduino():DigitalRead(self._pinChargeCheck1, false)
	end)()
end
-------------------------------------------------------------------------------
function p_robot:_InitlizeMotoDriver()
	print(self._name.." p_robot:_InitlizeMotoDriver")

	if not self._ismoto_use298n then
        print("VehicleInitMotoBoard4567")
        self._roboAgent:GetArduino():VehicleInitMotoBoard4567("def")
        if self._ismoto_usepid then
            print("VehiclePidInit_2_8_3_9")
            self._roboAgent:GetArduino():VehiclePidInit("def", Arduino.P_2, Arduino.P_8, Arduino.P_3, Arduino.P_9)
        end
    else
        print("VehicleInitMotoBoard298N")
        self._roboAgent:GetArduino():VehicleInitMotoBoard298N("def", Arduino.P_5, Arduino.P_4, Arduino.P_6, Arduino.P_7, Arduino.P_8, Arduino.P_9)
        if self._ismoto_usepid then
            print("VehiclePidInit_2_3_21_20")
            self._roboAgent:GetArduino():VehiclePidInit("def", Arduino.P_2, Arduino.P_3, Arduino.P_21, Arduino.P_20)
        end
    end
end
-------------------------------------------------------------------------------
-- ui lidar
function p_robot:_CreateLidarConnect()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
    uiFrame:SetAnchorVer(0.0, 1.0)

	local cbLidarType = UIComboBox:New("BtnComboxBoxLidarType")
    uiFrame:AttachChild(cbLidarType)
	self._comboxLidarType = cbLidarType
    cbLidarType:LLY(-3.0)
	cbLidarType:GetChooseList():SetItemHeight(30.0)
	cbLidarType:GetChooseList():SetPivot(0.5, 0.0)
	cbLidarType:GetChooseList():SetAnchorVer(1.0, 1.0)
    cbLidarType:AddChooseStr("3i_old")
    cbLidarType:AddChooseStr("3i")
    cbLidarType:AddChooseStr("RP")
    cbLidarType:AddChooseStr("WR")
    cbLidarType:AddChooseStr("fake")
    cbLidarType:SetChooseListHeightSameWithChooses()
	cbLidarType:SetPivot(0.0, 0.5)
    cbLidarType:SetAnchorHor(0.0, 0.0)
    cbLidarType:SetAnchorParamHor(60.0, 60.0)
    cbLidarType:SetAnchorVer(0.0, 0.0)
    cbLidarType:SetAnchorParamVer(60.0, 60.0)
    cbLidarType:SetSize(g_manykit._wBtn, g_manykit._hBtn)
    cbLidarType:SetScriptHandler("_UICallback", self._scriptControl)
    cbLidarType:Choose(1)
	manykit_uiProcessBtn(cbLidarType:GetSelectButton())

    local list = UIList:New("ListLidar")
	self._listLidar = list
    uiFrame:AttachChild(list)
    list:LLY(-1.0)
    list:SetAnchorHor(0.0, 1.0)
    list:SetAnchorParamHor(50.0, -50.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamVer(100.0, -50.0)
    list:SetReleasedDoSelect(true)
	manykit_uiProcessList(list)

    local btnLeft = UIButton:New("BtnDlgLeft")
    uiFrame:AttachChild(btnLeft)
    btnLeft:LLY(-1.0)
    btnLeft:SetAnchorHor(0.5, 0.5)
    btnLeft:SetAnchorParamHor(-120.0, -120.0)
    btnLeft:SetAnchorVer(0.0, 0.0)
    btnLeft:SetAnchorParamVer(60.0, 60.0)
    btnLeft:SetSize(g_manykit._wBtn, g_manykit._hBtn)
    btnLeft:CreateAddFText(""..PX2_LM_APP:V("Scan"))
	manykit_uiProcessBtn(btnLeft)
	btnLeft:SetUserDataString("type", "lidar")
    btnLeft:SetScriptHandler("_UICallback", self._scriptControl)

	local btnRight = UIButton:New("BtnDlgRight")
	uiFrame:AttachChild(btnRight)
	btnRight:LLY(-1.0)
	btnRight:SetAnchorHor(0.5, 0.5)
	btnRight:SetAnchorParamHor(120.0, 120.0)
	btnRight:SetAnchorVer(0.0, 0.0)
	btnRight:SetAnchorParamVer(60.0, 60.0)
    btnRight:SetSize(g_manykit._wBtn, g_manykit._hBtn)
	btnRight:CreateAddFText(""..PX2_LM_APP:V("Connect"))
	manykit_uiProcessBtn(btnRight)
	btnRight:SetUserDataString("type", "lidar")
    btnRight:SetScriptHandler("_UICallback", self._scriptControl)
	self._btnLidarConnect = btnRight

    RegistEventObjectFunction("AIES::LiDarOpen", self, function(myself, tag)
        if tag==myself._serialport_lidar or tag=="fake" then
            myself._btnLidarConnect:GetFText():GetText():SetText(""..PX2_LM_APP:V("DisConnect"))
        end 
    end)
    RegistEventObjectFunction("AIES::LiDarClose", self, function(myself, tag)
        if tag==myself._serialport_lidar or tag=="fake" then
            myself._btnLidarConnect:GetText():SetText(""..PX2_LM_APP:V("Connect"))
        end
    end)

	return uiFrame
end
function p_robot:_ScanLidar()
    self._listLidar:RemoveAllItems()

    local serial = Serial()
    serial:UpdatePortList()
    local numPorts = serial:GetNumPorts()
    for i=0, numPorts-1 do
        local portStr = serial:GetPort(i)
        local portDesc = serial:GetPortDesc(i)
        local hardID = serial:GetPortHardID(i)
        local item = self._listLidar:AddItem(portStr.."—"..portDesc)
        item:GetFText():GetText():SetFontScale(0.7)
        item:SetUserDataString("NamePath", portStr)
    end  
end
function p_robot:_SetLidarType()
	local chooseStr = self._comboxLidarType:GetChooseStr()
	if p_robot._g_sceneInst then
		local roboAgent = p_robot._g_sceneInst._roboAgent
		if "3i_old" == chooseStr then
			roboAgent:GetLidar():SetLiDarType(LiDar.LT_III)
		elseif "3i" == chooseStr then
			roboAgent:GetLidar():SetLiDarType(LiDar.LT_III)
		elseif "RP"==chooseStr then
			roboAgent:GetLidar():SetLiDarType(LiDar.LT_RP)    
		elseif "WR"==chooseStr then
			roboAgent:GetLidar():SetLiDarType(LiDar.LT_WR)
		elseif "fake"==chooseStr then
			roboAgent:GetLidar():SetLiDarType(LiDar.LT_FAKE)
		end
	end
end
function p_robot:_LidarTryToConnect()
	self:_SetLidarType()

    local roboAgent = p_robot._g_sceneInst._roboAgent
    local lidarType = roboAgent:GetLidar():GetLiDarType()

	p_robot._g_sceneInst._modelSlamReusltSetted:Show(true)

    if LiDar.LT_SICK ==lidarType then
        roboAgent:LidarOpen("169.254.177.161", 2111)
    elseif LiDar.LT_WR == lidarType then
        roboAgent:LidarOpen("192.168.1.51", 2112)
    elseif LiDar.LT_FAKE == lidarType then
        roboAgent:LidarOpenFake()
    else
        local item = self._listLidar:GetSelectedItem()               
        if item then
            local namePath = item:GetUserDataString("NamePath")
            print( "NamePath:"..namePath)
            if ""~=namePath then
				self._serialport_lidar = namePath
				
                if LiDar.LT_III==lidarType or LiDar.LT_III3==lidarType or LiDar.LT_RP==lidarType then
                    if LiDar.LT_III ==lidarType or LiDar.LT_III3==lidarType then
						local chooseStr = self._comboxLidarType:GetChooseStr()
                        if "3i_old" == chooseStr then
                            roboAgent:LidarOpen(namePath, 115200)
                        else
                            roboAgent:LidarOpen(namePath, 230400)
                        end
                    else
                        roboAgent:LidarOpen(namePath, 115200)
                    end
                end 
            end
        end
    end
end
-------------------------------------------------------------------------------
-- ui map
function p_robot:_CreateUIMapOption()
	local frame = UIFrame:New()
	frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

	local ver = -25.0
    local comboWidth = 120
    local comboHeight = g_manykit._hBtn
	local hBtn = g_manykit._hBtn
	local hCK = hBtn + 4.0
	local fs = 0.7

    local hor = 50.0 + comboWidth * 0.5
    local comBoxChara = UIComboBox:New("ComboxBoxChara")
    frame:AttachChild(comBoxChara)
	comBoxChara:GetChooseList():SetItemHeight(comboHeight)
    comBoxChara:AddChooseStr(""..PX2_LM_APP:V("master"))
    comBoxChara:AddChooseStr(""..PX2_LM_APP:V("connector"))
    comBoxChara:AddChooseStr(""..PX2_LM_APP:V("master_sendlidar"))
    comBoxChara:AddChooseStr(""..PX2_LM_APP:V("master_connector_calculate"))
    comBoxChara:SetChooseListHeightSameWithChooses()
    comBoxChara:SetAnchorHor(0.0, 0.0)
    comBoxChara:SetAnchorVer(1.0, 1.0)
    comBoxChara:SetAnchorParamHor(hor, hor)
    comBoxChara:SetAnchorParamVer(ver, ver)
    comBoxChara:SetSize(comboWidth, comboHeight)
    comBoxChara:SetScriptHandler("_UICallback", self._scriptControl)
    comBoxChara:Choose(0)
	manykit_uiProcessBtn(comBoxChara:GetSelectButton())

    hor = hor + comboWidth + 5.0
    local comBoxEdit = UIComboBox:New("ComboxBoxEdit")
    frame:AttachChild(comBoxEdit)
	comBoxEdit:GetChooseList():SetItemHeight(comboHeight)
    comBoxEdit:AddChooseStr(""..PX2_LM_APP:V("ClearObst"))
    comBoxEdit:AddChooseStr(""..PX2_LM_APP:V("AddObst"))
    comBoxEdit:AddChooseStr(""..PX2_LM_APP:V("RemoveObst"))
    comBoxEdit:SetChooseListHeightSameWithChooses()
    comBoxEdit:SetAnchorHor(0.0, 0.0)
    comBoxEdit:SetAnchorVer(1.0, 1.0)
    comBoxEdit:SetAnchorParamHor(hor, hor)
    comBoxEdit:SetAnchorParamVer(ver, ver)
    comBoxEdit:SetSize(comboWidth, comboHeight)
    comBoxEdit:SetScriptHandler("_UICallback", self._scriptControl)
    comBoxEdit:Choose(0)
	manykit_uiProcessBtn(comBoxEdit:GetSelectButton())

    hor = hor + comboWidth*0.5 + hBtn * 0.5 + 5.0
    local btnClearPath = UIButton:New("BtnClearPath")
    frame:AttachChild(btnClearPath)
    btnClearPath:CreateAddFText(""..PX2_LM_APP:V("ClearPath"))
    btnClearPath:SetAnchorHor(0.0, 0.0)
    btnClearPath:SetAnchorVer(1.0, 1.0)
    btnClearPath:SetAnchorParamHor(hor, hor)
    btnClearPath:SetAnchorParamVer(ver, ver)
    btnClearPath:SetSize(hBtn, hBtn)
    btnClearPath:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnClearPath)
	btnClearPath:GetFText():GetText():SetFontScale(fs)

    hor = hor + hBtn*0.5 + 5.0 + hBtn * 0.5 + 10.0

    local btnSaveMap = UIButton:New("BtnSaveMap")
    frame:AttachChild(btnSaveMap)
    btnSaveMap:SetAnchorHor(0.0, 0.0)
    btnSaveMap:SetAnchorVer(1.0, 1.0)
    btnSaveMap:SetAnchorParamHor(hor, hor)
    btnSaveMap:SetAnchorParamVer(ver, ver)
    btnSaveMap:SetSize(comboHeight, comboHeight)
    local fText = btnSaveMap:CreateAddFText(""..PX2_LM_APP:V("SaveMap"))
    btnSaveMap:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnSaveMap)
	btnSaveMap:GetFText():GetText():SetFontScale(fs)

    hor = hor + hBtn + 10.0

    local btnLoadMap = UIButton:New("BtnLoadMap")
    frame:AttachChild(btnLoadMap)
    btnLoadMap:SetAnchorHor(0.0, 0.0)
    btnLoadMap:SetAnchorVer(1.0, 1.0)
    btnLoadMap:SetAnchorParamHor(hor, hor)
    btnLoadMap:SetAnchorParamVer(ver, ver)
    btnLoadMap:SetSize(comboHeight, comboHeight)
    local fText = btnLoadMap:CreateAddFText(""..PX2_LM_APP:V("LoadMap"))
    btnLoadMap:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnLoadMap)
	btnLoadMap:GetFText():GetText():SetFontScale(fs)

	hor = hor + hBtn + 5.0

	local slamCheck = UICheckButton:New("SlamCheckButton")
    frame:AttachChild(slamCheck)
    slamCheck:SetAnchorHor(0.0, 0.0)
    slamCheck:SetAnchorVer(1.0, 1.0)
    slamCheck:SetAnchorParamHor(hor, hor)
    slamCheck:SetAnchorParamVer(ver, ver)
    slamCheck:SetSize(hCK, hCK)
    local fText = slamCheck:CreateAddFText("" .. PX2_LM_APP:V("MapUpdate"))
    fText:GetText():SetFontColor(Float3.BLACK)
    fText:GetText():SetFontScale(fs)
    slamCheck:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessCheck(slamCheck)
	local smustr = PX2_PROJ:GetConfig("robot_slammapupdate")
	if "1"==smustr then
		slamCheck:Check(true, false)
	else
		slamCheck:Check(false, false)		
	end

    hor = hor + hBtn + 10.0 + 10.0

    local btnGoCharge = UIButton:New("BtnGoCharge")
    frame:AttachChild(btnGoCharge)
    btnGoCharge:SetAnchorHor(0.0, 0.0)
    btnGoCharge:SetAnchorVer(1.0, 1.0)
    btnGoCharge:SetAnchorParamHor(hor, hor)
    btnGoCharge:SetAnchorParamVer(ver, ver)
    btnGoCharge:SetSize(hBtn, hBtn)
    local fText = btnGoCharge:CreateAddFText(""..PX2_LM_APP:V("GoCharge"))
    btnGoCharge:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnGoCharge)
	btnGoCharge:GetFText():GetText():SetFontScale(fs)

	hor = hor + hBtn + 10.0 + 10.0

	local checkShowRobot = UICheckButton:New("CheckShowRobot")
    frame:AttachChild(checkShowRobot)
    checkShowRobot:SetAnchorHor(0.0, 0.0)
    checkShowRobot:SetAnchorVer(1.0, 1.0)
    checkShowRobot:SetAnchorParamHor(hor, hor)
    checkShowRobot:SetAnchorParamVer(ver, ver)
    checkShowRobot:SetSize(hCK, hCK)
    local fText = checkShowRobot:CreateAddFText("" .. PX2_LM_APP:V("RobotShow"))
    fText:GetText():SetFontColor(Float3.BLACK)
    fText:GetText():SetFontScale(fs)
    checkShowRobot:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessCheck(checkShowRobot)
	local issrs = PX2_PROJ:GetConfig("isshowrobotscene")
	if ""==issrs or "0"==issrs then
		checkShowRobot:Check(false, true)
	else
		checkShowRobot:Check(true, true)
	end

	-- from right

    local posHor = -hBtn * 0.5 - 5.0
    local checkSlamMap = UICheckButton:New("CheckSlamMap")
    frame:AttachChild(checkSlamMap)
    checkSlamMap:SetAnchorHor(1.0, 1.0)
    checkSlamMap:SetAnchorVer(1.0, 1.0)
    checkSlamMap:SetAnchorParamHor(posHor, posHor)
    checkSlamMap:SetAnchorParamVer(ver, ver)
    checkSlamMap:SetSize(hCK, hCK)
    checkSlamMap:SetScriptHandler("_UICallback", self._scriptControl)
    checkSlamMap:Check(false, false)
    checkSlamMap:CreateAddFText(""..PX2_LM_APP:V("map"))
	manykit_uiProcessCheck(checkSlamMap)

	local btnCtrlPad= UIButton:New("BtnPadCtrl")
    frame:AttachChild(btnCtrlPad)
    btnCtrlPad:SetAnchorHor(1.0, 1.0)
    btnCtrlPad:SetAnchorVer(1.0, 1.0)
    btnCtrlPad:SetAnchorParamHor(posHor, posHor)
    btnCtrlPad:SetAnchorParamVer(ver-hBtn - 5.0, ver-hBtn - 5.0)
    btnCtrlPad:SetSize(comboHeight, comboHeight)
    btnCtrlPad:CreateAddFText(""..PX2_LM_APP:V("PadCtrl"))
    btnCtrlPad:SetScriptHandler("_UICallback", self._scriptControl)
	manykit_uiProcessBtn(btnCtrlPad)
	btnCtrlPad:GetFText():GetText():SetFontScale(fs)

    posHor = posHor - hBtn - 5.0

    local checkLidarCur = UICheckButton:New("CheckLidarCur")
    frame:AttachChild(checkLidarCur)
    checkLidarCur:SetAnchorHor(1.0, 1.0)
    checkLidarCur:SetAnchorVer(1.0, 1.0)
    checkLidarCur:SetAnchorParamHor(posHor, posHor)
    checkLidarCur:SetAnchorParamVer(ver, ver)
    checkLidarCur:SetSize(hCK, hCK)
    checkLidarCur:SetScriptHandler("_UICallback", self._scriptControl)
    checkLidarCur:Check(false, false)
    local fTextLiDarCur = checkLidarCur:CreateAddFText(""..PX2_LM_APP:V("lidarcur"))
	manykit_uiProcessCheck(checkLidarCur)

    local checkShowPhysicsDebug = UICheckButton:New("CheckShowPhysicsDebug")
    frame:AttachChild(checkShowPhysicsDebug)
    checkShowPhysicsDebug:SetAnchorHor(1.0, 1.0)
    checkShowPhysicsDebug:SetAnchorVer(1.0, 1.0)
    checkShowPhysicsDebug:SetAnchorParamHor(posHor, posHor)
    checkShowPhysicsDebug:SetAnchorParamVer(ver-hBtn - 5.0, ver-hBtn - 5.0)
    checkShowPhysicsDebug:SetSize(hCK, hCK)
    checkShowPhysicsDebug:SetScriptHandler("_UICallback", self._scriptControl)
    checkShowPhysicsDebug:Check(false, false)
    local fTextShowPhysicsDebug = checkShowPhysicsDebug:CreateAddFText(""..PX2_LM_APP:V("Debug"))
	manykit_uiProcessCheck(checkShowPhysicsDebug)

    posHor = posHor - hBtn - 5.0

    local btnScaleMap = UICheckButton:New("LidarSlamMapScale")
    frame:AttachChild(btnScaleMap)
    btnScaleMap:SetAnchorHor(1.0, 1.0)
    btnScaleMap:SetAnchorVer(1.0, 1.0)
    btnScaleMap:SetAnchorParamHor(posHor, posHor)
    btnScaleMap:SetAnchorParamVer(ver, ver)
    btnScaleMap:SetSize(hCK, hCK)
	btnScaleMap:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnScaleMap:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/scale_down.png")
    btnScaleMap:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnScaleMap:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetTexture("common/images/ui/scale_up.png")
    btnScaleMap:SetScriptHandler("_UICallback", self._scriptControl)
	btnScaleMap:Check(true, false)

    posHor = posHor - hBtn - 5.0

    local btnLidarSlamCenter = UICheckButton:New("LidarSlamMapCenter")
    frame:AttachChild(btnLidarSlamCenter)
    btnLidarSlamCenter:SetAnchorHor(1.0, 1.0)
    btnLidarSlamCenter:SetAnchorVer(1.0, 1.0)
    btnLidarSlamCenter:SetAnchorParamHor(posHor, posHor)
    btnLidarSlamCenter:SetAnchorParamVer(ver, ver)
    btnLidarSlamCenter:SetSize(hCK, hCK)
    btnLidarSlamCenter:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnLidarSlamCenter:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/center.png")
    btnLidarSlamCenter:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnLidarSlamCenter:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetTexture("common/images/ui/center.png")
    btnLidarSlamCenter:SetStateColor(UIButtonBase.BS_PRESSED, Float3(1.0, 0.0, 0.0))
    btnLidarSlamCenter:SetScriptHandler("_UICallback", self._scriptControl)

    -- text position
	local tV = ver - hBtn - 5.0
    local fTextPosition = UIFText:New()
    frame:AttachChild(fTextPosition)
	self._fTextPostion = fTextPosition
    fTextPosition:GetText():SetFontSize(24)
    fTextPosition:SetAnchorHor(0.0, 0.0)
    fTextPosition:SetAnchorVer(1.0, 1.0)
    fTextPosition:SetAnchorParamHor(10.0, 10.0)
    fTextPosition:SetAnchorParamVer(tV, tV)
    fTextPosition:SetSize(500.0, 100.0)
    fTextPosition:GetText():SetAutoWarp(true)
    fTextPosition:GetText():SetAligns(TEXTALIGN_LEFT+TEXTALIGN_VCENTER)
    fTextPosition:SetPivot(0.0, 0.5)
	fTextPosition:GetText():SetFontColor(Float3.WHITE)
	fTextPosition:GetText():SetDrawStyle(FD_SHADOW)
	fTextPosition:GetText():SetBorderShadowColor(Float3.BLACK)
    fTextPosition:GetText():SetFontScale(0.7);
    fTextPosition:GetText():SetText(""..PX2_LM_APP:V("Pos")..":")

    local fTextSpeed = UIFText:New()
    frame:AttachChild(fTextSpeed)
	self._fTextSpeed = fTextSpeed
    fTextSpeed:GetText():SetFontSize(24)
    fTextSpeed:SetAnchorHor(0.0, 0.0)
    fTextSpeed:SetAnchorVer(1.0, 1.0)
    fTextSpeed:SetAnchorParamHor(10.0, 10.0)
    fTextSpeed:SetAnchorParamVer(tV-20.0, tV-20.0)
    fTextSpeed:SetSize(500.0, 100.0)
    fTextSpeed:GetText():SetAutoWarp(true)
    fTextSpeed:GetText():SetAligns(TEXTALIGN_LEFT+TEXTALIGN_VCENTER)
    fTextSpeed:SetPivot(0.0, 0.5)
	fTextSpeed:GetText():SetFontColor(Float3.WHITE)
	fTextSpeed:GetText():SetDrawStyle(FD_SHADOW)
	fTextSpeed:GetText():SetBorderShadowColor(Float3.BLACK)
    fTextSpeed:GetText():SetFontScale(0.7);
    fTextSpeed:GetText():SetText(""..PX2_LM_APP:V("Speed")..":")

    local fTextPositionPick = UIFText:New()
    frame:AttachChild(fTextPositionPick)
	self._fTextPostionPick = fTextPositionPick
    fTextPositionPick:GetText():SetFontSize(24)
    fTextPositionPick:SetAnchorHor(0.0, 0.0)
    fTextPositionPick:SetAnchorVer(1.0, 1.0)
    fTextPositionPick:SetAnchorParamHor(10.0, 10.0)
    fTextPositionPick:SetAnchorParamVer(tV-40.0, tV-40.0)
    fTextPositionPick:SetSize(500.0, 100.0)
    fTextPositionPick:GetText():SetAutoWarp(true)
    fTextPositionPick:GetText():SetAligns(TEXTALIGN_LEFT+TEXTALIGN_VCENTER)
    fTextPositionPick:SetPivot(0.0, 0.5)
	fTextPositionPick:GetText():SetFontColor(Float3.WHITE)
	fTextPositionPick:GetText():SetDrawStyle(FD_SHADOW)
	fTextPositionPick:GetText():SetBorderShadowColor(Float3.BLACK)
    fTextPositionPick:GetText():SetFontScale(0.7);
    fTextPositionPick:GetText():SetText(""..PX2_LM_APP:V("PickPos")..":")

	-- lidar slam frame

	if p_robot._g_sceneInst then
		local roboAgent = p_robot._g_sceneInst._roboAgent
		if roboAgent then
			-- lidar and slam
			local frameLidarSlam = UIFrame:New()
			self._frameLidarSlam = frameLidarSlam
			frame:AttachChild(frameLidarSlam)
			frameLidarSlam:LLY(0.0)
			frameLidarSlam:SetAnchorHor(0.0, 1.0)
			frameLidarSlam:SetAnchorVer(0.0, 1.0)
			frameLidarSlam:SetAnchorParamVer(0.0, 0.0)

			-- lidar
			local frameLidar = UIFrame:New()
			frameLidarSlam:AttachChild(frameLidar)
			self._frameLidar = frameLidar
			frameLidar:SetAnchorHor(-1.0, -1.0)
			frameLidar:SetAnchorVer(-1.0, -1.0)
			frameLidar:SetAnchorParamHor(1.0, 0.0)
			frameLidar:SetAnchorParamVer(1.0, 0.0)
			frameLidar:Show(false)

			local picBoxCur = roboAgent:GetLidar():GetUIFPicBoxLidar()
			frameLidar:AttachChild(picBoxCur)
			picBoxCur:LLY(-1.0)
			picBoxCur:SetAnchorHor(0.0, 1.0)
			picBoxCur:SetAnchorVer(0.0, 1.0)
			picBoxCur:SetAlpha(0.5)

			-- slam
			local frameSlam = UIFrame:New()
			frameLidarSlam:AttachChild(frameSlam)
			self._frameSlam = frameSlam
			frameSlam:LLY(-1.0)
			frameSlam:SetAnchorHor(-1.0, -1.0)
			frameSlam:SetAnchorVer(-1.0, -1.0)
			frameSlam:SetAnchorParamHor(1.0, 0.0)
			frameSlam:SetAnchorParamVer(1.0, 0.0)
			frameSlam:Show(false)

			local checkMapInit = UICheckButton:New("CheckMapInit")
			frameSlam:AttachChild(checkMapInit)
			checkMapInit:LLY(-2.0)
			checkMapInit:SetAnchorHor(0.5, 0.5)
			checkMapInit:SetAnchorParamHor(-40.0, -40.0)
			checkMapInit:SetAnchorVer(0.0, 0.0)
			checkMapInit:SetAnchorParamVer(60.0, 60.0)
			checkMapInit:SetSize(40, 40)
			checkMapInit:CreateAddFText(""..PX2_LM_APP:V("Init"))
			manykit_uiProcessCheck(checkMapInit)
			checkMapInit:SetScriptHandler("_UICallback", self._scriptControl)
			checkMapInit:Check(true, false)

			local checkMapCur = UICheckButton:New("CheckMapCur")
			frameSlam:AttachChild(checkMapCur)
			checkMapCur:LLY(-2.0)
			checkMapCur:SetAnchorHor(0.5, 0.5)
			checkMapCur:SetAnchorParamHor(40.0, 40.0)
			checkMapCur:SetAnchorVer(0.0, 0.0)
			checkMapCur:SetAnchorParamVer(60.0, 60.0)
			checkMapCur:SetSize(40, 40)
			checkMapCur:CreateAddFText(""..PX2_LM_APP:V("Cur"))
			manykit_uiProcessCheck(checkMapCur)
			checkMapCur:SetScriptHandler("_UICallback", self._scriptControl)
			checkMapCur:Check(true, false)

			local picBoxInit = roboAgent:GetUIFPicBoxMapInit()
			frameSlam:AttachChild(picBoxInit)
			picBoxInit:LLY(-1.0)
			picBoxInit:SetAnchorHor(0.0, 1.0)
			picBoxInit:SetAnchorVer(0.0, 1.0)
			picBoxInit:SetAlpha(0.5)
			picBoxInit:SetScriptHandlerWidgetPicked("_MapPicBoxCallback", self._scriptControl)
			picBoxInit:RegistToScriptSystem() -- need this, so callback can know "ptr"
			picBoxInit:SetWidget(true)
			self._textureMapInit = picBoxInit

			local picBoxCur = roboAgent:GetUIFPicBoxMap()
			frameSlam:AttachChild(picBoxCur)
			picBoxCur:LLY(-1.5)
			picBoxCur:SetAnchorHor(0.0, 1.0)
			picBoxCur:SetAnchorVer(0.0, 1.0)
			picBoxCur:SetAlpha(0.5)
			picBoxCur:SetScriptHandlerWidgetPicked("_MapPicBoxCallback", self._scriptControl)
			picBoxCur:RegistToScriptSystem() -- need this, so callback can know "ptr"
			picBoxCur:SetWidget(true)
			self._textureMapCur = picBoxCur

			self:_LidarSlamMapScale(false)
		end
	end

	return frame
end
function p_robot:_LidarSlamMapScale(scaleBig)
    self._isLidarSlamScaleBig = scaleBig

	if self._frameLidarSlam then
		if scaleBig then
			self._frameLidarSlam:SetAnchorHor(0.0, 1.0)
			self._frameLidarSlam:SetAnchorVer(0.0, 1.0)
			self._frameLidarSlam:SetAnchorParamVer(0.0, -60.0)
			self._frameLidarSlam:SetPivot(0.5, 0.5)
		else
			if self._isLidarSlamFrameCenter then
			self._frameLidarSlam:SetAnchorHor(0.5, 0.5)
			self._frameLidarSlam:SetAnchorVer(1.0, 1.0)
			self._frameLidarSlam:SetAnchorParamVer(-60.0, -60.0)
			self._frameLidarSlam:SetPivot(0.5, 1.0)
			self._frameLidarSlam:SetSize(220.0, 220.0)
			else
			self._frameLidarSlam:SetAnchorHor(1.0, 1.0)
			self._frameLidarSlam:SetAnchorVer(0.5, 0.5)
			self._frameLidarSlam:SetAnchorParamVer(0.0, 0.0)
			self._frameLidarSlam:SetPivot(1.0, 0.5)
			self._frameLidarSlam:SetSize(220.0, 220.0)
			end
		end
	end
end
function p_robot:_LidarSlamMapCenter(doCenter)
	self._isLidarSlamFrameCenter = doCenter
	self:_LidarSlamMapScale(self._isLidarSlamScaleBig)
end
-------------------------------------------------------------------------------
 -- callback
function p_robot:_UICallback(ptr, callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()
    local platType = PX2_APP:GetPlatformType()

	local roboAgent = nil
	if p_robot._g_sceneInst then
		roboAgent = p_robot._g_sceneInst._roboAgent
	end

	if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)

		if "BtnLeft0" == name then
			self:_MoveControl(1, true)
		end
		if "BtnLeft1" == name then
			self:_MoveControl(2, true)
		end
		if "BtnRight0" == name then
			self:_MoveControl(3, true)
		end
		if "BtnRight1" == name then
			self:_MoveControl(4, true)
		end
	elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

		if "BtnDlgClose"==name then
			self:_ShowSetting(false)
		elseif "BtnList"==name then
			self:_ShowSetting(true)
		elseif "BtnDlgLeft"==name then
			local tstr = obj:GetUserDataString("type")
			if "device"==tstr then

			elseif "serial"==tstr then
				if Application.PLT_WINDOWS==platType or Application.PLT_LINUX==platType then
					self:_ScanSerial()
				else
					self:_ScanBle()
				end   
			elseif "lidar"==tstr then
				self:_ScanLidar()
			end
		elseif "BtnDlgRight"==name then			
			local tstr = obj:GetUserDataString("type")
			if "device"==tstr then
				self:_RefreshDevices()
			elseif "serial"==tstr then
				if Application.PLT_WINDOWS==platType or Application.PLT_LINUX==platType then
					if not p_robot._g_sceneInst._roboAgent:GetArduino():IsInitlized() then
						self:_SerialTryToConnect()
					else
						p_robot._g_sceneInst._roboAgent:GetArduino():Terminate()
					end
				else
					if PX2_BLUETOOTH then
						if not PX2_BLUETOOTH:IsConnected() then
							self:_BluetoothTryToConnect()
						else
							PX2_BLUETOOTH:DisConnect()
						end
					end
				end
			elseif "lidar"==tstr then
                if Application.PLT_WINDOWS==platType or Application.PLT_LINUX==platType then
					if roboAgent and roboAgent:GetLidar() then
                        if roboAgent:GetLidar():IsOpened() then
                            roboAgent:GetLidar():Close()
                        else
							self:_LidarTryToConnect()
                        end
                    end
				end
			end
		elseif "BtnSaveMap"==name then
			if roboAgent then
				print("save map")
				roboAgent:SaveMap("map.px2obj")
			end
		elseif "BtnClearPath"==name then
			if roboAgent then
				roboAgent:ClearPathFinder()
				if p_robot._g_sceneInst then
					p_robot._g_sceneInst:_ResetToActionNormal()
				end
			end
		elseif "BtnGoCharge"==name then
			if p_robot._g_sceneInst then
				p_robot._g_sceneInst._isdowaypatrolbeforecharging = p_robot._g_sceneInst._isdowaypatrol
				p_robot._g_sceneInst._isdowaypatrol = false
				p_robot._g_sceneInst:_GoChargeFront()
			end
		elseif "BtnLoadMap"==name then
			if roboAgent then
				print("load map")
				roboAgent:LoadMap("map.px2obj")
			end
		elseif "BtnPadCtrl"==name then
			self._frameCtrlPad:Show(not self._frameCtrlPad:IsShow())
		end

        if "BtnLeft0" == name then
            self:_MoveControl(1, false)
        end
        if "BtnLeft1" == name then
            self:_MoveControl(2, false)
        end
        if "BtnRight0" == name then
            self:_MoveControl(3, false)
        end
        if "BtnRight1" == name then
            self:_MoveControl(4, false)
        end
	elseif UICT_RELEASED_NOTPICK==callType then
        PX2_GH:PlayNormal(obj)

		if "BtnLeft0" == name then
            self:_MoveControl(1, false)
        end
        if "BtnLeft1" == name then
            self:_MoveControl(2, false)
        end
        if "BtnRight0" == name then
            self:_MoveControl(3, false)
        end
        if "BtnRight1" == name then
            self:_MoveControl(4, false)
        end
	elseif UICT_CHECKED==callType then
		if "LidarSwitch"==name then
			p_robot._g_sceneInst:_LidarSwitchOpen(true)
		elseif "CheckSlamMap"==name then
			if self._frameSlam then
				self._frameSlam:Show(true)
			end
		elseif "CheckLidarCur"==name then
			if self._frameLidar then
				self._frameLidar:Show(true)
			end
		elseif "LidarSlamMapScale"==name then
			self:_LidarSlamMapScale(false)
		elseif "LidarSlamMapCenter"==name then
			self:_LidarSlamMapCenter(true)
		elseif "SlamCheckButton"==name then
			if roboAgent then
				PX2_PROJ:SetConfig("robot_slammapupdate", "1")
            	roboAgent:SetSlamMapUpdate(true)
			end
		elseif "CheckShowPhysicsDebug"==name then
			PX2_GH:SetDebugNavigations(true)
            PX2_GH:SetDebugPhysics(true)
		elseif "CheckMapInit"==name then
			self._textureMapInit:Show(true)
			if p_robot._g_sceneInst then
				p_robot._g_sceneInst._sceneMapTexInit:Show(true)
			end
		elseif "CheckMapCur"==name then
			self._textureMapCur:Show(true)
			if p_robot._g_sceneInst then
				p_robot._g_sceneInst._sceneMapTexCur:Show(true)
			end
		elseif "CheckShowRobot"==name then
			if p_robot._g_sceneInst then
				p_robot._g_sceneInst:_ShowRobot(true)
			end
		end
	elseif UICT_DISCHECKED==callType then
		if "LidarSwitch"==name then
			p_robot._g_sceneInst:_LidarSwitchOpen(false)
		elseif "CheckSlamMap"==name then
			if self._frameSlam then
            	self._frameSlam:Show(false)
			end
        elseif "CheckLidarCur"==name then
			if self._frameLidar then
            	self._frameLidar:Show(false)
			end
        elseif "LidarSlamMapScale"==name then
			self:_LidarSlamMapScale(true)
        elseif "LidarSlamMapCenter"==name then
			self:_LidarSlamMapCenter(false)
        elseif "SlamCheckButton"==name then
			if roboAgent then
				PX2_PROJ:SetConfig("robot_slammapupdate", "0")
            	roboAgent:SetSlamMapUpdate(false)
			end
        elseif "CheckShowPhysicsDebug"==name then
            PX2_GH:SetDebugNavigations(false)
            PX2_GH:SetDebugPhysics(false)
        elseif "CheckMapInit"==name then
			self._textureMapInit:Show(false)
			if p_robot._g_sceneInst then
				p_robot._g_sceneInst._sceneMapTexInit:Show(false)
			end
        elseif "CheckMapCur"==name then
			self._textureMapCur:Show(false)
			if p_robot._g_sceneInst then
				p_robot._g_sceneInst._sceneMapTexCur:Show(false)
			end
		elseif "CheckShowRobot"==name then
			if p_robot._g_sceneInst then
				p_robot._g_sceneInst:_ShowRobot(false)
			end
        end
	elseif UICT_LIST_SELECTED==callType then
	elseif UICT_COMBOBOX_CHOOSED==callType then
		if "BtnComboxBoxLidarType"==name then
			self:_SetLidarType()
		elseif "ComboxBoxChara"==name then
			local ch = obj:GetChoose()
			if roboAgent then
				if 0==ch then
					roboAgent:SetRoleType(Robot.RT_MASTER)
				elseif 1==ch then
					roboAgent:SetRoleType(Robot.RT_CONNECTOR)
				elseif 2==ch then
					roboAgent:SetRoleType(Robot.RT_MASTER_ONLY_SENDLIDAR)
				elseif 3==ch then
					roboAgent:SetRoleType(Robot.RT_CONNECTOR_CALCULATE)
				end
			end
		elseif "ComboxBoxEdit"==name then
			local ch = obj:GetChoose()
			if 0==ch then
                self._mapObstDrawType = 0
            elseif 1==ch then
                self._mapObstDrawType = 1
            elseif 2==ch then
                self._mapObstDrawType = 2
            end	
		end
	elseif UICT_TABFRAME_SETACTIVE==callType then
		if "TableFrameSetting"==name then
			--PX2_SS:PlayASound("common/media/audio/click3.mp3", g_manykit._soundVolume, 2.0)
		end
	end
end
-------------------------------------------------------------------------------
function p_robot:_MapPicBoxCallback(ptr)
    local obj = Cast:ToO(ptr)

    if obj then
        local lastPickData = obj:GetLastPickData()
        local logicPos = lastPickData.LogicPos

        if UIPT_PRESSED == lastPickData.PickType then
            self:_SetMapPickPos(obj, logicPos)
            self._mapPicBoxIsPressed = true
            self._mapPicBoxIsMoved = false
            
        elseif UIPT_RELEASED == lastPickData.PickType then
			self._mapPicBoxIsPressed = false
            if not self._mapPicBoxIsMoved then
				local robo  = p_robot._g_sceneInst
				if robo then
					robo:_GoTarget(self._mapPickPos)
				end
            end
        elseif UIPT_MOVED == lastPickData.PickType then
            self._mapPicBoxIsMoved = true
            if self._mapPicBoxIsPressed then
                self:_SetObst(obj, logicPos)
            end
		end
	end
end
function p_robot:_SetMapPickPos(obj, logicPos)
    local worldRect = obj:GetWorldRect(nil)
    local width = worldRect:Width()
    local height = worldRect:Height()
    local picX = logicPos:X() - worldRect.Left
    local picY = logicPos:Z() - worldRect.Bottom
    local percX = (picX*1.0)/(width*1.0)
    local percY = (picY*1.0)/(height*1.0)

	local roboAgent = p_robot._g_sceneInst._roboAgent
	if roboAgent then
		local mapWidth = roboAgent:GetCurMapWidth()
		local mapHeight = roboAgent:GetCurMapHeight()
		local mapReso = roboAgent:GetCurMapResolution()
		local x = (percX-0.5) * mapWidth * mapReso
		local y = (percY-0.5) * mapHeight * mapReso
		self._mapPickPos:SetX(x)
		self._mapPickPos:SetY(y)
	end
end
function p_robot:_SetObst(obj, logicPos)
    local worldRect = obj:GetWorldRect(nil)
    local width = worldRect:Width()
    local height = worldRect:Height()
    local picX = logicPos:X() - worldRect.Left
    local picY = logicPos:Z() - worldRect.Bottom
    local percX = (picX*1.0)/(width*1.0)
    local percY = (picY*1.0)/(height*1.0)

	local roboAgent = p_robot._g_sceneInst._roboAgent
	if roboAgent then
		local mapWidth = roboAgent:GetCurMapWidth()
		local mapHeight = roboAgent:GetCurMapHeight()
		local mapReso = roboAgent:GetCurMapResolution()
		local mapAllWidth = mapWidth * mapReso
		local mapAllHeight = mapHeight * mapReso
		local x = (percX-0.5) * mapAllWidth
		local y = (percY-0.5) * mapAllHeight

		local pos = APoint(x, y, 0.0)

		if 0 == self._mapObstDrawType then -- clear
			roboAgent:SetObstMapValueAtPos(pos, 0.25, 10)    
		elseif 1 == self._mapObstDrawType then -- obst
			roboAgent:SetObstMapValueAtPos(pos, 0.1, 0)
		elseif 2 == self._mapObstDrawType then -- can go
			roboAgent:SetObstMapValueAtPos(pos, 0.1, 200) -- space can go
		end
	end
end
-------------------------------------------------------------------------------
-- create robot
function p_robot:_CreateRobot()
	-- plugin	

	if not p_robot._g_ispluginloaded then
		if ""~=p_robot._g_slamname then
			print("p_robot LoadPluginnnnnnnnnnnnnnnnnnnnnnnnnnnn:"..p_robot._g_slamname)
			PX2_APP:LoadPlugin(p_robot._g_slamname, p_robot._g_slamname)
		end
		
		p_robot._g_ispluginloaded = true
	end

	-- sc
	local sc = Cast:ToSC(self.__object)

    -- 1. create robot actor
    local roboActor = PX2_CREATER:CreateActor(Actor.AIT_ROBOT)
	self._roboActor = roboActor
	roboActor:SetID(self._id)
	roboActor:RegistToScriptSystem()
	roboActor:AttachController(sc)
	sc:ResetPlay()

	-- 2. arduino
	local arduino = Arduino:New()
	PX2_PROJ:PoolSet("Arduino"..self._id, arduino)
	local clientConnector = PX2_APP:GetEngineClientConnector()
	if clientConnector then
   		arduino:InitlizeSocketTCP_Connector(clientConnector)
	end

	-- 3. robot actor reset agent, agent set arduino
    local robot = nil
    if nil~=RobotExt then
		print("RobotExt New")
        robot = RobotExt:New()
        roboActor:ReSetAgent(Actor.AIT_ROBOT, robot)
    else
        robot = roboActor:GetRobot()
    end
    self._roboAgent = robot
    robot:SetArduino(arduino)

    -- 4. set robot params
    local realHeight = 0.2
    robot:SetHeight(realHeight) -- use 0.0 for bullet physics btCapsuleShapeZ
    robot:SetMass(5)
    robot:SetMaxForce(5)
    robot:SetMinSpeed(0.0)

	if self._controlMode == 0 then
		if "SlamHector"==p_robot._g_slamname then self._maxspeed = 0.15
		elseif "SlamGMapping"==p_robot._g_slamname then self._maxspeed = 0.22 end
		robot:SetMaxSpeed(self._maxspeed)
		robot:SetPredictTime(2.7)
		robot:SetPhysicsRadius(0.162)
		robot:SetRadius(0.162)
		robot:SetLidarIngoreRadius(0.165) -- near datas from lidar we ingore
		robot:SetObstacleRadius(0.165)
		robot:SetLidarOffset(-0.12)
		robot:SetMotoRate(35)   -- how many rounds of the motor when wheel do 1 round
		robot:SetWheelRadius(0.03)
	else
		self._maxspeed = 0.35
		robot:SetMaxSpeed(self._maxspeed)
		robot:SetPredictTime(2.7)
		robot:SetPhysicsRadius(0.3)
		robot:SetPhysicsRadius(0.3)
		robot:SetLidarIngoreRadius(0.3)
		robot:SetObstacleRadius(0.3)
		robot:SetLidarOffset(0.2)
		robot:SetMotoRate(35)
		robot:SetWheelRadius(0.11)
	end

	local gridMapSize = 80
    if "SlamHector"==p_robot._g_slamname then gridMapSize = 80
    elseif "SlamGMapping"==p_robot._g_slamname then gridMapSize = 120 end
	robot:SetPathFinderGridMapSize(gridMapSize, gridMapSize)
    robot:GetAISteeringBehavior():SetWaypointSeekDist(0.8)
    robot:GetAISteeringBehavior():SetWaypointSeekDistLast(0.2)
    robot:SetNeedUpdateLiDarMapTexture(true)

    -- 5. create lidar
    local lidar = robot:CreateLidar()
    lidar:SetNumLaserPerRound(100)
    lidar:SetMotoRate(6)

    -- 7. create robot virtual objects
    self:_CreateRobotActorVirtual(roboActor)

    -- 8. resetplay
    roboActor:ResetPlay()

    -- 9. slam plugin, set robot SlamRunner, slam map params
    local slamR = nil
    if "SlamHector"==p_robot._g_slamname then
		if SlamHectorRunner then
			slamR = SlamHectorRunner:New()
			slamR:SetMapSizeWant(600, 600)
			slamR:SetResolution(0.025)
			slamR:Initlize()
		end
    elseif "SlamGMapping"==p_robot._g_slamname then
		if SlamGMappingRunner then
			slamR = SlamGMappingRunner:New()
			slamR:SetUseMultiThread(true)
			slamR:SetMapSizeWant(600, 600)
			slamR:SetResolution(0.04)
			slamR:Initlize()
		end
    end
	self._slamRunner = slamR
	robot:SetSlamRunner(slamR)
    
	-- 10. map textures
    local mapSizeW = robot:GetCurMapWidth()
    local mapSizeH = robot:GetCurMapHeight()
    local mapReso = robot:GetCurMapResolution()
    local mapWidth = mapSizeW * mapReso
    local mapHeight = mapSizeH * mapReso
    print("mapWidth:"..mapWidth)
    print("mapHeight:"..mapHeight)

	local scene = PX2_PROJ:GetScene()
	local nodeHelp = scene:GetObjectByID(p_holospace._g_IDNodeHelp)

    local sceneMapTexInit = UIFPicBox:New()
	self._sceneMapTexInit = sceneMapTexInit
    nodeHelp:AttachChild(sceneMapTexInit)
    sceneMapTexInit:EnableAnchorLayout(false)
    sceneMapTexInit.LocalTransform:SetTranslateZ(0.02)
    sceneMapTexInit.LocalTransform:SetRotateDegree(-90.0, 0.0, 0.0)
    sceneMapTexInit:SetSize(10, 10)
    sceneMapTexInit:SetAlpha(1.0)
    sceneMapTexInit:Show(true)
    sceneMapTexInit:GetUIPicBox():SetRenderLayer(Renderable.RL_SCENE, 1)
	sceneMapTexInit:SetColorSelfCtrled(true)
	sceneMapTexInit:SetAlphaSelfCtrled(true)
	sceneMapTexInit:SetBrightnessSelfCtrled(true)

    local sceneMapTexCur = UIFPicBox:New()
	self._sceneMapTexCur = sceneMapTexCur
    nodeHelp:AttachChild(sceneMapTexCur)
    sceneMapTexCur:EnableAnchorLayout(false)
    sceneMapTexCur.LocalTransform:SetTranslateZ(0.04)
    sceneMapTexCur.LocalTransform:SetRotateDegree(-90.0, 0.0, 0.0)
    sceneMapTexCur:SetSize(10, 10)
    sceneMapTexCur:SetAlpha(1.0)
    sceneMapTexCur:Show(true)
    sceneMapTexCur:GetUIPicBox():SetRenderLayer(Renderable.RL_SCENE, 2)
	sceneMapTexCur:SetColorSelfCtrled(true)
	sceneMapTexCur:SetAlphaSelfCtrled(true)
	sceneMapTexCur:SetBrightnessSelfCtrled(true)

	local str = PX2_PROJ:GetConfig("robot_slammapupdate")
	if ""==str or "1"==str then
		robot:SetSlamMapUpdate(true)
		PX2_PROJ:SetConfig("robot_slammapupdate", "1")
	else
		robot:SetSlamMapUpdate(false)
	end

	print(self._name.." GraphicsES::GeneralString")
	RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
		if "autoconnectlidar"==str then
			myself:_LidarAxisArduinoAutoOpen()
		elseif "TARGET_FOUND" == retstr then
			myself:_WayFindAdjustToDirections()
		elseif "TARGET_NOT_FOUND" == retstr then
		end
	end)

	return roboActor
end
-------------------------------------------------------------------------------
function p_robot:_CreateRobotActorVirtual(roboActor)
	print(self._name.." p_robot:_CreateRobotActorVirtual")

	local robot = self._roboAgent
    local robotRadius = robot:GetRadius()
    local height = robot:GetHeight()

	-- model
	local model = PX2_CREATER:CreateMovable_Box()
    roboActor:AttachChild(model)
    roboActor:SetDoPick(false)
    model.LocalTransform:SetScale(APoint(robotRadius, robotRadius, height))
    model.LocalTransform:SetTranslateZ(height * 0.5)
 
	-- result
	local modelSlamReusltSetted = PX2_CREATER:CreateMovable_Box()
	self._modelSlamReusltSetted = modelSlamReusltSetted
    modelSlamReusltSetted:SetDoPick(false)
    modelSlamReusltSetted:Show(false)
    modelSlamReusltSetted:RegistToScriptSystem()
    modelSlamReusltSetted:SetRenderLayer(Renderable.RL_SCENE, 0)
	modelSlamReusltSetted.LocalTransform:SetScale(APoint(robotRadius, robotRadius, height))
	modelSlamReusltSetted.LocalTransform:SetTranslateZ(height*0.5)

	-- radius
    local bdRadius = Billboard:New()
    bdRadius:SetDynamic(false)
    bdRadius:SetDynamic(false)
    bdRadius:SetSizeImmediate(robotRadius*2.0, robotRadius*2.0, 1.0)
    bdRadius:SetFaceType(Effectable.FT_Z)
    bdRadius:SetTex("engine/circle.png")
    bdRadius:SetEmitColor(Float3(0.0, 1.0, 0.0))
    roboActor:AttachChild(bdRadius)
	bdRadius:SetRenderLayer(Renderable.RL_SCENE, 4)
	bdRadius.LocalTransform:SetTranslateZ(0.06)
    bdRadius:ResetPlay()

	-- obst
	local obRadius = robot:GetObstacleRadius()
    local bdObstRadius = Billboard:New()
    bdObstRadius:SetDynamic(false)
    bdObstRadius:SetDynamic(false)
    bdObstRadius:SetSizeImmediate(obRadius*2.0, obRadius*2.0,  1.0)
    bdObstRadius:SetFaceType(Effectable.FT_Z)
    bdObstRadius:SetTex("engine/circle.png")
    bdObstRadius:SetEmitColor(Float3(1.0, 0.0, 0.0))
	bdObstRadius:SetRenderLayer(Renderable.RL_SCENE, 5)
    bdObstRadius.LocalTransform:SetTranslateZ(0.08)
    roboActor:AttachChild(bdObstRadius)
end
-------------------------------------------------------------------------------
function p_robot:_serialCheckWhoAmI()
	print(self._name.." p_robot:_serialCheckWhoAmI")

	local serial = Serial()
	serial:UpdatePortList()
	local numPorts = serial:GetNumPorts()
	for i=0, numPorts-1 do
        local portStr = serial:GetPort(i)
        local portDesc = serial:GetPortDesc(i)
		local hardID = serial:GetPortHardID(i)
        local platType = PX2_APP:GetPlatformType()
        
        print("portStr:::::::::::::::::"..portStr)
        print("portDesc::::::::::::::::"..portDesc)
        print("hardID::::::::::::::::::"..hardID)

		local serial = Serial:New()	
		self._serials_check[portStr] = serial
		serial:SetDoProcessRecvType(Serial.RPT_PX)
		serial:AddScriptHandler("_OnSerialCallback", self._scriptControl)
		local ret = serial:Open(portStr, 9600, true)
		if ret then
			print("serial opened suc:"..portStr)
		else
			print("serial opened failed"..portStr)
		end
	end
end
-------------------------------------------------------------------------------
function p_robot:_ClearSerialCheck()
	print(self._name.." p_robot:_ClearSerialCheckk")

	for key, value in pairs(self._serials_check) do
		local port = key
		local ser = value
		if ser then
			ser:Close()
			Serial:Delete(ser)
		end
	end

	self._serials_check = {}
end
-------------------------------------------------------------------------------
function p_robot:_serialCheckWhoIsLidar()
	print(self._name.." p_robot:_serialCheckWhoIsLidar")

	local serial = Serial()
	serial:UpdatePortList()
	local numPorts = serial:GetNumPorts()
	for i=0, numPorts-1 do
        local portStr = serial:GetPort(i)
        local portDesc = serial:GetPortDesc(i)
		local hardID = serial:GetPortHardID(i)
        local platType = PX2_APP:GetPlatformType()
		
		if Application.PLT_LINUX==platType then
			if string.find(portDesc, "UART") then
				if portStr~=self._serialport_axis then
					self._serialport_lidar = portStr
				end
			elseif string.find(portDesc, "USB2.0") then -- Raspberry
				-- arduino
            elseif string.find(portDesc, "USB Serial") then
                -- arduino
			end
		elseif Application.PLT_WINDOWS==platType then
			if string.find(portDesc, "UART") then
				if portStr~=self._serialport_axis then
					self._serialport_lidar = portStr
				end
			elseif string.find(portDesc, "SERIAL") and string.find(hardID, "REV_0254") then
				-- arduino
			end
		end		
	end

	print("_serialport_axis:"..self._serialport_axis)
	print("_serialport_arduino:"..self._serialport_arduino)
	print("_serialport_lidar:"..self._serialport_lidar)
end
-------------------------------------------------------------------------------
function p_robot:_LidarAxisArduinoAutoOpen()
	print("_LidarAxisArduinoAutoOpen")
	print("serial autoConnect lidar:"..self._serialport_lidar)
    print("serial autoConnect arduino:"..self._serialport_arduino)

	if ""~=self._serialport_arduino then
		self._roboAgent:GetArduino():Initlize(Arduino.M_SERIAL, self._serialport_arduino, 9600)

		self._roboAgent:GetLidar():SetLiDarType(LiDar.LT_III)
		
		local lidarVal = PX2_APP:GetCommand():GetInt("lidar")
		if 1==lidarVal then
			print("lidar 1, set RT_MASTER_ONLY_SENDLIDAR")
			self._roboAgent:SetRoleType(Robot.RT_MASTER_ONLY_SENDLIDAR)
		else
			print("lidar 0, set RT_MASTER")
			self._roboAgent:SetRoleType(Robot.RT_MASTER)
		end
	end
    
	if ""~=self._serialport_lidar then
    	self._roboAgent:LidarOpen(self._serialport_lidar, 230400)
	end

	if ""~=self._serialport_axis then
		local serial = Serial:New()
		self._serial_axis = serial
		serial:SetDoProcessRecvType(Serial.RPT_PX)
		serial:AddScriptHandler("_OnSerialCallbackAxis", self._scriptControl)
		local ret = serial:Open(self._serialport_axis, 9600, true)
		if ret then
			print("serial opened suc:"..self._serialport_axis)
		else
			print("serial opened failed"..self._serialport_axis)
		end
	end
end
-------------------------------------------------------------------------------
function p_robot:_ShowRobot(sh)
	if sh then
		PX2_PROJ:SetConfig("isshowrobotscene", "1")
	else
		PX2_PROJ:SetConfig("isshowrobotscene", "0")
	end

	if self._roboActor then
		self._roboActor:Show(sh)
	end

	if self._sceneMapTexInit then
		self._sceneMapTexInit:Show(sh)
	end

	if self._sceneMapTexCur then
		self._sceneMapTexCur:Show(sh)
	end
end
-------------------------------------------------------------------------------
function p_robot:_OnSerialCallback(ptr, type, port, data)
	print(self._name.." p_robot:_OnSerialCallbackkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk")
	print(type)
	print(port)
	print(data)
	
	if "cmd"==type then
		print(type)
		print(port)
		print(data)

		--0000200 def
		--a;0.02,-0.13,-0.98;0.00,0.00,0.00;-172.75,-0.99,-146.22;

		local substr = string.sub(data, 1, 2)
		if "a;"==substr then
			self._serialport_axis = port
			print("_serialport_axis:"..self._serialport_axis)
		elseif "00"==substr then
			self._serialport_arduino = port
			print("_serialport_arduino:"..self._serialport_arduino)
		end
	end
end
-------------------------------------------------------------------------------
function p_robot:_OnSerialCallbackAxis(ptr, type, port, data)
	if "cmd"==type then
		--print(data)

		local stk = StringTokenizer(data, ";")
		if stk:Count() == 4 then
			local str1 = stk:GetAt(1)
			local str2 = stk:GetAt(2)
			local str3 = stk:GetAt(3)

			local vec1 = AVector():FromString("("..str1..")")
			local vec2 = AVector():FromString("("..str2..")")
			local vec3 = AVector():FromString("("..str3..")")
			self._axisAccel = vec1
			self._axisGyro = vec2
			self._axisAngle = vec3

			-- print(self._axisAccel:ToString())
			-- print(self._axisGyro:ToString())
			-- print(self._axisAngle:ToString())
		end
	end
end
-------------------------------------------------------------------------------
-- robot run
function p_robot:_RobotInfoUpdate()
	if p_robot._g_sceneInst then
		local roboAgent = p_robot._g_sceneInst._roboAgent
		if roboAgent then
			local pos = roboAgent:GetPosition()
			local dir = roboAgent:GetDirection()
			local up = roboAgent:GetUp()
			local right = roboAgent:GetRight()
			if lidar and lidar:IsFake() then
				pos = roboAgent:GetPositionSlamResultSetted()
				dir = roboAgent:GetDirectionSlamResultSetted()
				up = roboAgent:GetUpSlamResultSetted()
				right = roboAgent:GetRightSlamResultSetted()
			end

			local degree = roboAgent:GetSlam2DDegree()
			local spdLeft = roboAgent:GetSpeedLeftCur()
			local spdRight = roboAgent:GetSpeedRightCur()
			local allSpeed = (spdLeft + spdRight) * 0.5

			local mpp = self._mapPickPos
			if self._fTextPostion then
				local txt0 = ""..StringHelp:FloatToString(pos:X())..", "..StringHelp:FloatToString(pos:Y())..", "..StringHelp:FloatToString(pos:Z())
				local txt = PX2_LM_APP:GetValue("Pos")..":"..txt0.." dir:"..StringHelp:FloatToString(degree)
				self._fTextPostion:GetText():SetText(txt)
			end
			if self._fTextSpeed then
				local txtSpeed = PX2_LM_APP:GetValue("Speed")..":l"..StringHelp:FloatToString(spdLeft) ..", r"..StringHelp:FloatToString(spdRight)..", lr"..StringHelp:FloatToString(allSpeed)
				self._fTextSpeed:GetText():SetText(txtSpeed)
			end
			if self._fTextPostionPick then
				local txtCur = PX2_LM_APP:GetValue("PickPos")..":"..StringHelp:FloatToString(mpp:X()) ..", "..StringHelp:FloatToString(mpp:Y())
				self._fTextPostionPick:GetText():SetText(txtCur)
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_robot:_RobotUpdate()
	local elapsedSeconds = PX2_APP:GetElapsedSecondsWidthSpeed()

    local roboAgent = self._roboAgent
	local obstRadius = roboAgent:GetObstacleRadius()
	local rt = roboAgent:GetRoleType()

	local arduino = self._roboAgent:GetArduino()
	
	if Robot.RT_MASTER == rt or Robot.RT_CONNECTOR == rt or Robot.RT_CONNECTOR_CALCULATE == rt then
		local initMapData = roboAgent:GetInitMapData()
		local curMapData = roboAgent:GetCurMapData()
		local slam2dPos = roboAgent:GetSlam2DPostion()
		local slam2ddegree = roboAgent:GetSlam2DDegree()

		if arduino and arduino:IsInitlized() then

			if self._isUseESKF then
				local ag_c = AVector(self._axisGyro:X()*DEG_TO_RAD, self._axisGyro:Y()*DEG_TO_RAD, self._axisGyro:Z()*DEG_TO_RAD)
				local appt = PX2_APP:GetAppSeconds()
				if not self._isUseESKFInited then
					self._isUseESKFInited = true
					local initAngle = AVector(0.0, 0.0, slam2ddegree)
					PX2_OPENCVM:InitESKF(appt, self._axisAccel, ag_c, self._axisAngle, slam2dPos)
				else					
					PX2_OPENCVM:ESKFPredict(appt, self._axisAccel, ag_c, self._axisAngle)
					PX2_OPENCVM:ESKFSetVelocity(vec)
					PX2_OPENCVM:ESKFCorrect(appt, slam2dPos)

					local pos = PX2_OPENCVM:GetESKF_Pos()
				end
			end
		end

		-- set pos angle
		roboAgent:SetPositionAngle(slam2dPos, slam2ddegree)
		roboAgent:UpdateNearObstacles(obstRadius*3.0)
	end

	if Robot.RT_MASTER == rt then
		if self._IsAdjustToDirection then
			self:_UpdateAdjustDirection(self._AdjustDir, elapsedSeconds)
		else
			roboAgent:UpdateRobotRun(elapsedSeconds)
		end
	elseif Robot.RT_CONNECTOR == rt then
		if self._IsRobotMoveSpeedChanged then
			self._IsRobotMoveSpeedChanged = false
			local clientCnt = PX2_APP:GetEngineClientConnector()
			if nil~=clientCnt then
				local rds = RobotToDoStruct()
				rds.Type = 1
				rds.LeftSpeed = roboAgent:GetSpeedLeftWant()
				rds.RightSpeed = roboAgent:GetSpeedRightWant()
				clientCnt:SendRobotToDo(rds);

				print("SendRobotToDo type = 1")
			end
		end
	elseif Robot.RT_CONNECTOR_CALCULATE == rt then	
		if self._IsAdjustToDirection then
			self:_UpdateAdjustDirection(self._AdjustDir, elapsedSeconds)
		else
			roboAgent:UpdateRobotRun(elapsedSeconds)
		end
	end

	if Robot.RT_MASTER == rt or Robot.RT_CONNECTOR == rt or Robot.RT_CONNECTOR_CALCULATE == rt then
		roboAgent:UpdateLidarDataToMapData()
		roboAgent:UpdateSlamMapTexs()
	end

	local bat =  self._roboAgent:GetArduino():RobotBatteryValue("def")

	self._chargeUpdateSeconds = self._chargeUpdateSeconds + elapsedSeconds
	if self._chargeUpdateSeconds > 0.1 then
		local check0 = self._roboAgent:GetArduino():DigitalRead(self._pinChargeCheck0, false)
		local check1 = self._roboAgent:GetArduino():DigitalRead(self._pinChargeCheck1, false)

		-- charging
		local path = roboAgent:GetAISteeringPath()
		local curPos = roboAgent:GetPosition()

		if self._isdowaypatrol then	
			if RobotActionState.RAS_NORMAL == self._actionState then
				local numP = path:GetNumWayPoints()
				if 0~=numP and path:IsFinished() then
					local numPos = roboAgent:GetNumTargetPosList()
	
					self._indexwaypoint = self._indexwaypoint + 1
					if self._indexwaypoint == numPos then
						self._indexwaypoint = 0
					end
	
					local pos = roboAgent:GetTargetListPos(self._indexwaypoint)				
					self:_GoTarget(pos)
				end

				if bat < self._lowpower then
					self._isdowaypatrolbeforecharging = self._isdowaypatrol
					self._isdowaypatrol = false
					self:_GoChargeFront()
				end
			end
		else
			-- RAS_NORMAL = 1,
			-- RAS_GOCHARGEFRONT = 2,
			-- RAS_GOCHARGING_REAL = 3,
			-- RAS_GOCHARGING_RETRY = 4,
			-- RAS_CHARGING = 5,

			if RobotActionState.RAS_NORMAL == self._actionState then	
			elseif RobotActionState.RAS_GOCHARGEFRONT == self._actionState then
				local numP = path:GetNumWayPoints()
				if 0~=numP and path:IsFinished() then
					self:_GoChargingReal()
				else
					print("go CHARGEFRONT")
				end
			elseif RobotActionState.RAS_GOCHARGING_REAL == self._actionState then
				local maxSpeed = 0.05
				local spLeft = -maxSpeed
				local spRight = -maxSpeed
				roboAgent:SetSpeedLeftWant(spLeft)
				roboAgent:SetSpeedRightWant(spRight)

				print("check0:"..check0)
				print("check1:"..check1)

				self._checkSeconds = self._checkSeconds + elapsedSeconds

				if 0==check0 and 0== check1 then
					self:_DoChargeing()
				else
					if self._checkSeconds > 8.0 then
						self._checkSeconds = 0.0
						self:_GoChargeingRetry()
					end
				end
			elseif RobotActionState.RAS_GOCHARGING_RETRY == self._actionState then
			elseif RobotActionState.RAS_CHARGING == self._actionState then
				if bat > 10 then
					print("bat:"..bat)
				end

				if bat > self._highpower and bat<10 then
					print("bat:"..bat)

					self._isdowaypatrol = self._isdowaypatrolbeforecharging
					self._isdowaypatrolbeforecharging = false
					if self._isdowaypatrol then
						self._indexwaypoint = 0
						self:_gotargetpoints()
					else
						self:_ResetToActionNormal()
					end
				end
			end
		end

		self._chargeUpdateSeconds = 0.0
	end

	if self._modelSlamReusltSetted then
		local height = roboAgent:GetHeight() + 2.0 * roboAgent:GetRadius()
		local pos = roboAgent:GetPositionSlamResultSetted()
		local posD = roboAgent:GetDirectionSlamResultSetted()
		local posR = roboAgent:GetRightSlamResultSetted()
		local posU = roboAgent:GetUpSlamResultSetted()
		local pos1 = APoint(pos:X(), pos:Y(), height*0.5)
		self._modelSlamReusltSetted.LocalTransform:SetTranslate(pos1)
		self._modelSlamReusltSetted.LocalTransform:SetRotate(posR, posD, posU)
	end
end
function p_robot:_WayFindAdjustToDirections()
	local roboAgent = self._roboAgent
	if roboAgent then
		local path = roboAgent:GetAISteeringBehavior()
		local obstRadius = roboAgent:GetObstacleRadius()
		local curPos = roboAgent:GetPosition()
		local rt = roboAgent:GetRoleType()

		local wp = path:GetWayPointWithDistance(obstRadius)
		local isFinded = path:IsWayPointDistFinded()
		if isFinded then
			if Robot.RT_MASTER == rt or Robot.RT_CONNECTOR_CALCULATE == rt then
				local numP = path:GetNumWayPoints()
				if numP >= 3 then
					local dir = Vec3:FromVec(wp) - Vec3:FromVec(curPos)
					if robot:IsRevertDirection() then
						dir = Vec3:FromVec(curPos) - Vec3:FromVec(wp)
					end
					local len = dir:Normalize()
					if len > 0.0 then    
						self:_IsAdjustToDirection(dir:ToAVector())
					end
				end
			end
		end
	end
end
function p_robot:_AdjustToDegree(degree)
	print("_AdjustToDegree")
	print(degree)
	local rad = degree * 3.1415926/180.0
	print("rad")
	print(rad)
	local dir = AVector(Mathf:Cos(rad), Mathf:Sin(rad), 0.0)
	self:_AdjustToDirection(dir)
end
function p_robot:_AdjustToDirection(dir)
	print("_AdjustToDirection")
	print(dir:X())
	print(dir:Y())
	print(dir:Z())

	self._IsAdjustToDirection = true
	self._AdjustDir = dir
end
function p_robot:_IsInRightDirection (dir0, dir1)
	local dotVal = dir0:Dot(dir1)
	local degree = Mathf:ACos(dotVal) * RAD_TO_DEG
	
	if degree < 20.0 then
		return true
	end

	return false
end
-------------------------------------------------------------------------------
function p_robot:_UpdateAdjustDirection(dir, elapsedSeconds)
	local robot = self._roboAgent
	local lidar = robot:GetLidar()
	local maxSpd = robot:GetMaxSpeed()
	local maxSpdRot = maxSpd * 0.3
	local direction = robot:GetDirection()
	if lidar and lidar:IsFake() then
		direction = robot:GetDirectionSlamResultSetted()
	end
	
	local isInRightDir = self:_IsInRightDirection(self._AdjustDir, direction)

	if isInRightDir then
		self._IsAdjustToDirection = false
		self:_SetSpeedWant(0.0, 0.0)
		robot:RunSpeed(elapsedSeconds)
	else
		if direction ~= AVector.ZERO then
			local maxRotSpd = maxSpd * 0.3
			local right = self._AdjustDir:Cross(direction)
			if right:Z() > 0.0 then
				self:_SetSpeedWant(maxSpdRot, -maxSpdRot)
			else
				self:_SetSpeedWant(-maxSpdRot, maxSpdRot)
			end

			robot:RunSpeed(elapsedSeconds)
		end
	end
end
function p_robot:_GoTarget(pos, t)
	print(self._name.." p_robot:_GoTarget")

	local roboAgent = self._roboAgent
	if t then
		roboAgent:GoPathTarget(pos, t)
	else
		roboAgent:GoPathTarget(pos)
	end
end
function p_robot:_SetSpeedWant(lSpd, rSpd)
	local roboAgent = self._roboAgent
	local lsw = roboAgent:GetSpeedLeftWant()
	local rsw = roboAgent:GetSpeedRightWant()

	if lsw~=lSpd or rsw~=rSpd then
		roboAgent:SetSpeedLeftWant(lSpd)
		roboAgent:SetSpeedRightWant(rSpd)
		self._IsRobotMoveSpeedChanged = true
	end		
end
function p_robot:_ResetToActionNormal()
	print("p_robot:_ResetToActionNormal")
	p_robot._g_sceneInst:_LidarSwitchOpen(true)

	self._actionState = RobotActionState.RAS_NORMAL
	local roboAgent = self._roboAgent
	roboAgent:SetRevertDirection(false)
	roboAgent:GetAISteeringBehavior():SetWaypointSeekDist(0.8)
    roboAgent:GetAISteeringBehavior():SetWaypointSeekDistLast(0.25)
	roboAgent:SetMaxSpeed(self._maxspeed)
end
-------------------------------------------------------------------------------
function p_robot:_LidarSwitchOpen(isopen)
	PX2_LOGGER:LogInfo("script_lua", ""..self._name.." _LidarSwitchOpen")

	if isopen then
		self._roboAgent:GetArduino():DigitalWrite(self._pinLidar, true)
	else
		self._roboAgent:GetArduino():DigitalWrite(self._pinLidar, false)
	end
end
-------------------------------------------------------------------------------
function p_robot:_GoChargeFront()
	print(self._name.." p_robot:_GoChargeFront")

	-- do init read
	self._actionState = RobotActionState.RAS_GOCHARGEFRONT
    local roboAgent = self._roboAgent
	roboAgent:SetRevertDirection(false)
	local chargePosFront = roboAgent:GetChargerPosFront()
	roboAgent:GetAISteeringBehavior():SetWaypointSeekDistLast(0.2)
	self:_GoTarget(chargePosFront)
end
function p_robot:_GoChargingReal()
	print(self._name.." p_robot:_GoChargingReal")

    local roboAgent = self._roboAgent
	roboAgent:ClearPathFinder()

	roboAgent:SetMaxSpeed(0.08)

	self._actionState = RobotActionState.RAS_GOCHARGING_REAL
	self._checkSeconds = 0.0

    local roboAgent = self._roboAgent
	local chargePos = roboAgent:GetChargerPos()
	local robotPos = roboAgent:GetPosition()
	local dir = robotPos - chargePos
	dir:Normalize()
	roboAgent:SetRevertDirection(true)
	self:_AdjustToDirection(dir)
    roboAgent:GetAISteeringBehavior():SetWaypointSeekDist(0.2)
    roboAgent:GetAISteeringBehavior():SetWaypointSeekDistLast(0.2)
	self:_GoTarget(chargePos, Robot.GPTM_BATTERYCHARGE)
end
function p_robot:_LeftRunDistance(distance, speed)
	print(self._name.." p_robot:_LeftRunDistance")

	local time = distance/Mathf:FAbs(speed)

    local roboAgent = self._roboAgent
	local radius = roboAgent:GetRadius()
	local motoRate = roboAgent:GetMotoRate()
	local wheelRadius = roboAgent:GetWheelRadius()

	coroutine.wrap(function()
		roboAgent:SetSpeedLeftWant(speed)
		sleep(time)
		roboAgent:SetSpeedLeftWant(0.0)
	end)()
end
function p_robot:_RightRunDistance(distance, speed)
	print(self._name.." p_robot:_RightRunDistance")

	local time = distance/Mathf:FAbs(speed)

    local roboAgent = self._roboAgent

	coroutine.wrap(function()
		roboAgent:SetSpeedRightWant(speed)
		sleep(time)
		roboAgent:SetSpeedRightWant(0.0)
	end)()
end
function p_robot:_DoChargeing()
	print(self._name.." p_robot:_DoChargeing")

	self._actionState = RobotActionState.RAS_CHARGING

    local roboAgent = self._roboAgent
	roboAgent:SetRevertDirection(false)
	roboAgent:ClearPathFinder()
	roboAgent:SetSpeedLeftWant(0.0)
	roboAgent:SetSpeedRightWant(0.0)	
	p_robot._g_sceneInst:_LidarSwitchOpen(false)
end
function p_robot:_GoChargeingRetry()
	print(self._name.." p_robot:_GoChargeingRetry")

    local roboAgent = self._roboAgent
	roboAgent:ClearPathFinder()

	self:_GoChargeFront()

	self._actionState = RobotActionState.RAS_GOCHARGING_RETRY
	coroutine.wrap(function()
		sleep(4.0)
		self:_GoChargingReal()
	end)()
end
-------------------------------------------------------------------------------
-- ctrl pad
function p_robot:_CreatePadFrame()
    local frame = UIFrame:New()
    frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

	local uiFrameLeft = UIFrame:New("FrameLeft")
    frame:AttachChild(uiFrameLeft)
    uiFrameLeft:LLY(-1.0)
    uiFrameLeft:SetAnchorHor(0.0, 0.0)
    uiFrameLeft:SetAnchorVer(0.0, 0.0)
    uiFrameLeft:SetAnchorParamHor(200.0, 200.0)
    uiFrameLeft:SetAnchorParamVer(200.0, 200.0)
    uiFrameLeft:SetSize(360, 360)
    local picBack = uiFrameLeft:CreateAddBackgroundPicBox(true, Float3:MakeColor(255, 255, 255))
    picBack:SetTexture("scripts/lua/plugins/p_robot/images/ctrlbackleftright.png")
	picBack:UseAlphaBlend(true)
    picBack:SetFakeTransparent(false)
	 
    local btnLeft0 = UIButton:New("BtnLeft0")
    uiFrameLeft:AttachChild(btnLeft0)
    btnLeft0:LLY(-2.0)
    btnLeft0:SetAnchorHor(0.0, 0.5)
    btnLeft0:SetAnchorVer(0.0, 1.0)
    btnLeft0:SetButType(UIButtonBase.BT_PICBOXSWAP)
    btnLeft0:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("scripts/lua/plugins/p_robot/images/btnleft.png")
    btnLeft0:GetPicBoxAtState(UIButtonBase.BS_NORMAL):UseAlphaBlendMode(1)
    btnLeft0:GetPicBoxAtState(UIButtonBase.BS_HOVERED):SetTexture("scripts/lua/plugins/p_robot/images/btnleft.png")
    btnLeft0:GetPicBoxAtState(UIButtonBase.BS_HOVERED):UseAlphaBlendMode(1)
    btnLeft0:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetTexture("scripts/lua/plugins/p_robot/images/btnleft.png")
    btnLeft0:GetPicBoxAtState(UIButtonBase.BS_PRESSED):UseAlphaBlendMode(1)
    btnLeft0:SetScriptHandler("_UICallback", self._scriptControl)

    local btnLeft1 = UIButton:New("BtnLeft1")
    uiFrameLeft:AttachChild(btnLeft1)
    btnLeft1:LLY(-2.0)
    btnLeft1:SetAnchorHor(0.5, 1.0)
    btnLeft1:SetAnchorVer(0.0, 1.0)
    btnLeft1:SetButType(UIButtonBase.BT_PICBOXSWAP)
    btnLeft1:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("scripts/lua/plugins/p_robot/images/btnright.png")
    btnLeft1:GetPicBoxAtState(UIButtonBase.BS_NORMAL):UseAlphaBlendMode(1)
    btnLeft1:GetPicBoxAtState(UIButtonBase.BS_HOVERED):SetTexture("scripts/lua/plugins/p_robot/images/btnright.png")
    btnLeft1:GetPicBoxAtState(UIButtonBase.BS_HOVERED):UseAlphaBlendMode(1)
    btnLeft1:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetTexture("scripts/lua/plugins/p_robot/images/btnright.png")
    btnLeft1:GetPicBoxAtState(UIButtonBase.BS_PRESSED):UseAlphaBlendMode(1)
    btnLeft1:SetScriptHandler("_UICallback", self._scriptControl)

    local uiFrameRight = UIFrame:New("FrameRight")
    frame:AttachChild(uiFrameRight)
    uiFrameRight:LLY(-1.0)
    uiFrameRight:SetAnchorHor(1.0, 1.0)
    uiFrameRight:SetAnchorVer(0.0, 0.0)
    uiFrameRight:SetAnchorParamHor(-200.0, -200.0)
    uiFrameRight:SetAnchorParamVer(200.0, 200.0)
    uiFrameRight:SetSize(360, 360)
    local picBack = uiFrameRight:CreateAddBackgroundPicBox(true, Float3:MakeColor(255, 255, 255))
    picBack:SetTexture("scripts/lua/plugins/p_robot/images/ctrlbackupdown.png")
	picBack:UseAlphaBlend(true)
    picBack:SetFakeTransparent(false)
    
    local btnRight0 = UIButton:New("BtnRight0")
    uiFrameRight:AttachChild(btnRight0)
    btnRight0:LLY(-2.0)
    btnRight0:SetAnchorHor(0.0, 1.0)
    btnRight0:SetAnchorVer(0.5, 1.0)
    btnRight0:SetStateColorDefaultWhite()
    btnRight0:SetButType(UIButtonBase.BT_PICBOXSWAP)
    btnRight0:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("scripts/lua/plugins/p_robot/images/btnup.png")
    btnRight0:GetPicBoxAtState(UIButtonBase.BS_NORMAL):UseAlphaBlendMode(1)
    btnRight0:GetPicBoxAtState(UIButtonBase.BS_HOVERED):SetTexture("scripts/lua/plugins/p_robot/images/btnup.png")
    btnRight0:GetPicBoxAtState(UIButtonBase.BS_HOVERED):UseAlphaBlendMode(1)
    btnRight0:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetTexture("scripts/lua/plugins/p_robot/images/btnup.png")
    btnRight0:GetPicBoxAtState(UIButtonBase.BS_PRESSED):UseAlphaBlendMode(1)
    btnRight0:SetScriptHandler("_UICallback", self._scriptControl)

    local btnRight1 = UIButton:New("BtnRight1")
    uiFrameRight:AttachChild(btnRight1)
    btnRight1:LLY(-2.0)
    btnRight1:SetAnchorHor(0.0, 1.0)
    btnRight1:SetAnchorVer(0.0, 0.5)
    btnRight1:SetStateColorDefaultWhite()
    btnRight1:SetButType(UIButtonBase.BT_PICBOXSWAP)
    btnRight1:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("scripts/lua/plugins/p_robot/images/btndown.png")
    btnRight1:GetPicBoxAtState(UIButtonBase.BS_NORMAL):UseAlphaBlendMode(1)
    btnRight1:GetPicBoxAtState(UIButtonBase.BS_HOVERED):SetTexture("scripts/lua/plugins/p_robot/images/btndown.png")
    btnRight1:GetPicBoxAtState(UIButtonBase.BS_HOVERED):UseAlphaBlendMode(1)
    btnRight1:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetTexture("scripts/lua/plugins/p_robot/images/btndown.png")
    btnRight1:GetPicBoxAtState(UIButtonBase.BS_PRESSED):UseAlphaBlendMode(1)
    btnRight1:SetScriptHandler("_UICallback", self._scriptControl)

	return frame
end
-------------------------------------------------------------------------------
-- move
-- 0,1,2,3,4 none left right up down
function p_robot:_MoveControl(type, isPresssed)
    local isPStr = "0"
    if isPresssed then
        isPStr = "1"
    end
    print("p_robot _MoveControl type:"..type.."_isPresssed:"..isPStr)
    
	if 0==type then
		if self._IsSpacePressed~=isPresssed then
			self._IsSpacePressed = isPresssed
			self._IsDirectionChanged = true
		end
	elseif 1==type then
		if self._IsLeftPressed~=isPresssed then
			self._IsLeftPressed = isPresssed
			self._IsDirectionChanged = true
		end
	elseif 2==type then
		if self._IsRightPressed~=isPresssed then
			self._IsRightPressed = isPresssed
			self._IsDirectionChanged = true
		end
	elseif 3==type then
		if self._IsUpPressed~=isPresssed then
			self._IsUpPressed = isPresssed
			self._IsDirectionChanged = true
		end
	elseif 4==type then
		if self._IsDownPressed~=isPresssed then
			self._IsDownPressed = isPresssed
			self._IsDirectionChanged = true
		end
	end
end
function p_robot:_PadCtrlUpdate()
    if self._IsDirectionChanged then
		if not self._IsLeftPressed and not self._IsRightPressed and not self._IsUpPressed and not self._IsDownPressed then
			self:_PadCtrlMove(RobotMoveType.RMT_NONE)
		else
            if self._IsUpPressed then
                self:_PadCtrlMove(RobotMoveType.RMT_FORWARD)
            end
            
            if self._IsDownPressed then
                self:_PadCtrlMove(RobotMoveType.RMT_BACKWARD)
            end

            if self._IsLeftPressed then
                self:_PadCtrlMove(RobotMoveType.RMT_LEFT)
            end
    
            if self._IsRightPressed then
                self:_PadCtrlMove(RobotMoveType.RMT_RIGHT)
            end 
		end

		if self._IsSpacePressed then
			self:_PadCtrlMove(RobotMoveType.RMT_NONE)
		end

		self._IsDirectionChanged = false
	end
end
function p_robot:_PadCtrlMove(moveType)  
	if self._moveType==moveType then
		return
	end

    self._moveType = moveType

	local robot = p_robot._g_sceneInst
	if robot then
		local roboAgent = robot._roboAgent
		if roboAgent then 
			local runSpeed = roboAgent:GetMaxSpeed()
			local turnSpeed = runSpeed * 0.3

			print("runSpeed:"..runSpeed)
			print("turnSpeed:"..turnSpeed)

			if moveType == RobotMoveType.RMT_NONE then
				robot:_SetSpeedWant(0.0, 0.0)
			elseif moveType == RobotMoveType.RMT_FORWARD then
				robot:_SetSpeedWant(runSpeed, runSpeed)
			elseif moveType == RobotMoveType.RMT_BACKWARD then
				robot:_SetSpeedWant(-runSpeed, -runSpeed)
			elseif moveType == RobotMoveType.RMT_LEFT then
				robot:_SetSpeedWant(-turnSpeed, turnSpeed)
			elseif moveType == RobotMoveType.RMT_RIGHT then
				robot:_SetSpeedWant(turnSpeed, -turnSpeed)
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_robot:_gotargetpoints()
    local roboAgent = self._roboAgent

	coroutine.wrap(function()
		self:_ResetToActionNormal()
		sleep(2.0)
		local numPos = roboAgent:GetNumTargetPosList()
		if  self._indexwaypoint < numPos then
			local na = roboAgent:GetTargetListName(self._indexwaypoint)
			local pos = roboAgent:GetTargetListPos(self._indexwaypoint)
	
			self:_GoTarget(pos)
		end
	end)()
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_robot)
-------------------------------------------------------------------------------