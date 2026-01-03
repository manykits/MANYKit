-- g_manykit.lua

function manykit_l(doopen)
	if g_manykit._isEnableLogMK then
		if doopen then
			PX2_LOGGER:GetConsoleHandler():SetLevels(LT_INFO + LT_ERROR + LT_USER)
		else
			PX2_LOGGER:GetConsoleHandler():SetLevels(0)
		end
	end
end

g_manykit =
{
	-- log
	_isEnableLogMK = true, -- enable, can only print your care logs
	
	-- system mode
	_isMKSystem = true,
	_isRaspberry = false,
	_systemControlMode = 0, --0keyboard, 1mr
	_isRobot = false,
	_lessfullmode = 0, -- 0 less, 1 full

	-- uin
	_uin = 100, -- defalut uin

	-- anim 
	_animUpdateTime = 0.0,
	_mkSendStateTime = 0.2,

	-- red blue
	_isUsePathAllRB = false, -- follower path use all points with proto
	_isShowSkillLine = true,
	_speedPostureRunRB = 3.1,

	-- general configs
	_isShowMe = true, -- show me actor in sense
	_isTerrainMultiThread = true, -- is terrain load multithread
	_isUsePhysics = false,
	_isUseViewDistance = true,

	_writePathProj = "",

	-- ui mk
	_isFullScreen = false,
	_isUIDockSide = true,
	_isUIShowSide = true,
	_colorBackGround = Float3(0.0, 0.0, 0.0),
	_wBtn = 100.0,
	_hBtn = 40.0,
	_dockSideWidth = 160.0,

	_isShowRight = false,
	_inspectorWidth = 600.0,

	_frameRoot = nil,
	_frameLeft = nil,
	_treePlugins = nil,
	_frameCnt = nil,
	_frameCntCnt = nil,
	_frameTouch = nil,
	_frameInfoPopUp = nil,

	-- plugins
	_pluginRegists = {},
	_pluginTreeInstances = {},
	_curPluginInstance = nil,
	_startProject = nil,

	-- input system
	_keyState= {},
	_isPressed_Ctrl = false,
	_isPressed_Shift = false,
	_isPressed_W = false,
	_isPressed_S = false,
	_isPressed_A = false,
	_isPressed_D = false,
	_isPressed_Space = false,
	_isPressed_Left = false,
	_isPressed_Right = false,
	_isPressed_Up = false,
	_isPressed_Down = false,
	_isPressed_E = false,
	_isPressed_1 = false,
	_isPressed_3 = false,
	_isPressed_X = false,
	_isPressed_C = false,
	_isPressed_Z = false,
	_isPressed_Q = false,
	_isDown_Left = false,
	_isDown_Right = false,

	_mouseHorAdjust = 1.0,
    _mouseVerAdjust = 1.0,
	_mouseHorAdjust_r = 1.0,
    _mouseVerAdjust_r = 1.0,
    _mouseWheelAdjust = 1.0,
	_mouseHorDragAdjust = 1.0,
	_mouseVerDragAdjust = 1.0,
	_inputControlParam = {},

	-- map view size
	_mapMaxSize = 100.0,
	_defaultViewDistanceMax = 100.0,
	_defaultViewDistance = 100.0,
	_defaultViewDistanceThird = 50.0,

	-- mr
	_isMRMode = false,
	_isUI3DMode = false,
	_isInSandBox = false,

	_isUseCameraHot = false,
	_isUseCameraIP = false,
	
	_mrControlMode = 0,

	_canvasSceneUINode = nil,
	_canvasSceneUINode1 = nil,
	_bdCanvasSceneUI = nil,
	_followCtrl = nil,
	_canvasSceneUI = nil,
	_isUI3DFollow = false,
	_3DUIFollowDistance = 4.0,
	_3DUIFollowStringForceParam = 70.0,
	_3DUIFollowResistance = 30.0,

	_mrCameraScreenWidth = 1920,
	_mrCameraScreenHeight = 990,
	_mrCameraNear = 0.1,
	_mrCameraFar = 1000.0,
	_mrHeightAdjust = 1.0,

	-- slam
	_slamPosScale = 1.0,
	_mapPos = APoint.ORIGIN,
	_mapRot = AVector.ZERO,
	_mapRotOffset = AVector.ZERO,
	_camObjOffset = AVector.ZERO,
	_camObjOffsetRot = AVector.ZERO,
	_slamEyeTransScale = 0.3,

	_mapPosSlam = APoint.ORIGIN,
	_mapRotSlam = AVector.ZERO,
	_mapSlamTrans = Transform(),

	_boxVSlam = nil,
	_boxIMU = nil,
	_boxSlam = nil,
	_nodeHandsRoot = nil,
	_nodeHandLeft = nil,
	_nodeHandRight = nil,
	_handmarks={},
	_nodeAprilTag = nil,
	_isShowAprilTag = false,
	_nodeAprilTagBox0 = nil,
	_nodeAprilTagBox1 = nil,
	_isNeedReCalcuateHand = false,

	-- videos
	_cameraTexture2D = nil,
	_cameraTexture2D1 = nil,
	_cameraTexture2D2 = nil,
	_fPicBoxHot = nil,
	_fPicBoxCameraIP = nil,
	_frameVLCCameraIP = nil,

	-- media
	_channelMusic = 1,
	_soundVolume = 1.0,
	_soundVolumeTalk = 1.0,

	_media = {
        ui_slect = "common/media/audio/click3.mp3",
        ui_open = "common/media/audio/book.mp3",
        ui_close = "common/media/audio/click1.mp3",
        scene_put = "common/media/audio/put.wav",
        scene_select = "common/media/audio/click.mp3",
        scene_unselect = "common/media/audio/click1.mp3",
        scene_delete = "common/media/audio/delete.mp3"
    }
}
-------------------------------------------------------------------------------
function g_manykit:PluginsCallFile()
	local startproject = p_project.cfg.startproject

	local startProj = nil
	for key, value in pairs(p_project.projects) do
		if startproject == value.name then
			startProj = value
		end
	end
	self._startProject = startProj
	
	if startProj then
		local startCata = nil
		for key, value in pairs(p_project.treecatas) do
			local na = value.name			
			if manykit_IsInArray (na, startProj.treecatas) then
				if value.plugins then 
					for keyPlugin, valuePluginDir in pairs(value.plugins) do
						local path = "Data/MANYKit/scripts/lua/plugins/"..valuePluginDir.."/"
						local initFile = path.."init.lua"

						if PX2_RM:IsFileFloderExist(initFile) then
							print("initFile, path:"..initFile)

							require(initFile)
						else
                            print("no initFile, path:"..path)

							local dir = DirP()
							dir:GetAllFiles(path, "");
							local numFiles = dir:GetNumFiles()
							for i=0,numFiles-1,1 do
								local filename = dir:GetFile(i)
								local ext = StringHelp:SplitFullFilename_OutExt(filename)
								if "lua"==ext then
									print("plugin filename:")
									print(filename)

									require(filename)
								end
							end
						end
					end
				end
			end
		end
	end
end
function g_manykit:GetPluginRegistByName(name)
	for i=1, #self._pluginRegists, 1 do
		local plug = self._pluginRegists[i]
		if name == plug._name then
			return plug
		end
	end

	return nil
end
function g_manykit:PluginsRegistedCalRequireIndex()
	for i=1, #self._pluginRegists, 1 do
		local plug = self._pluginRegists[i]

		if 0==#plug._requires then
			plug._requireindex = 1
		else
			for j=1,#plug._requires,1 do
				local reqname = plug._requires[j]
				local reqpg = self:GetPluginRegistByName(reqname)
				if nil~=reqpg then
					plug._requireindex = plug._requireindex + reqpg._requireindex * 10
				end
			end
		end
	end
end
function g_manykit:PluginsRegistedSortByRequireIndex()
	table.sort(self._pluginRegists, function(a, b)
		return a._requireindex < b._requireindex
	end)
end
function g_manykit:PluginsRegistedPreCreate()
	for i=1, #self._pluginRegists, 1 do
		local plug = self._pluginRegists[i]
		plug:OnPluginPreCreate()
	end
end
function g_manykit:PluginsRegistedCreateTreeInstances()
	for i=1, #self._pluginRegists, 1 do
		local plug = self._pluginRegists[i]
		local plugInst = self:PluginRegistedCreateTreeInstance(plug)
	end
end
function g_manykit:PluginTreeInstancesAfterAttached()
	for i=1, #self._pluginTreeInstances, 1 do
		local plugInst = self._pluginTreeInstances[i]
		plugInst:OnPluginTreeInstanceAfterAttached()
	end
end
function g_manykit:GetPluginTreeInstanceByName(name)
	for i=1, #self._pluginTreeInstances, 1 do
		local plugInst = self._pluginTreeInstances[i]
		if name==plugInst._name then
			return plugInst
		end
	end
end
function g_manykit:SelectPlugin(pluginName)
    print("g_manykit:SelectPlugin pluginName:"..pluginName)

	if not pluginName or pluginName == "" then
		return
	end

	if PX2_SS then
		PX2_SS:PlayASound(g_manykit._media.ui_slect, g_manykit._soundVolume, 2.0)
	end

	if g_manykit._frameCntCnt then
		g_manykit._frameCntCnt:SetActiveChild(pluginName, false)
	end

	if g_manykit._curPluginInstance then
		g_manykit._curPluginInstance:OnPluginInstanceSelected(false)
	end

	local plugInst = g_manykit:GetPluginTreeInstanceByName(pluginName)
	if plugInst then
		g_manykit._curPluginInstance = plugInst
		plugInst:OnPluginInstanceSelected(true)
	end
end
function g_manykit:PluginRegistedCreateTreeInstance(plug)
    local sctrl = plug:New()
	sctrl._isTreeInstancePlugin = true
    local sctrl_controller = Cast:ToSC(sctrl.__object)
    self._frameRoot:AttachController(sctrl_controller)

	local frameback = sctrl._frameback
	if frameback then
		self._frameCntCnt:AttachChild(frameback)
	end

	table.insert(self._pluginTreeInstances, #self._pluginTreeInstances + 1, sctrl)

	return sctrl
end
function g_manykit:plugin_regist(plug)
	local isexist = false
	for key, value in pairs(self._pluginRegists) do
		if plug._name == value._name then
			isexist = true
		end
	end

	if not isexist then
		table.insert(self._pluginRegists, #self._pluginRegists + 1, plug)
		plug:OnPluginRegisted()
		return true
	end

	return false
end
-------------------------------------------------------------------------------
function g_manykit:CheckSystemConfig()
	local isExistRobot = PX2_RM:IsFileFloderExist("./keepme_systemisrobot.txt")
	local isExistMR = PX2_RM:IsFileFloderExist("./keepme_systemismr.txt")
	local isExistRaspberry = PX2_RM:IsFileFloderExist("./keepme_platformisraspberry.txt")

    g_manykit._animUpdateTime = 0.0

    if isExistRobot then
        p_project.cfg.startproject = "Robot"
        g_manykit._systemControlMode = 0
        g_manykit._isRobot = true
        g_manykit._isShowMe = false
    else
        g_manykit._isUsePhysics = true

        if isExistMR then
            g_manykit._systemControlMode = 1
            g_manykit._isShowMe = false
        else
            g_manykit._isShowMe = true
        end
    end

	if isExistRaspberry then
		g_manykit._isRaspberry = true
	end

	local platType = PX2_APP:GetPlatformType()
	if Application.PLT_UWP == platType then
		g_manykit._lessfullmode = 0
		g_manykit._uin = 101

		if PX2_GH:IsHololens() then
			g_manykit._systemControlMode = 1
		else
			g_manykit._systemControlMode = 0
		end
	elseif Application.PLT_WINDOWS==platType then
	elseif Application.PLT_LINUX==platType then
	end
end
-------------------------------------------------------------------------------
function g_manykit:Initlize()
	print("g_manykit:Initlize")

	self._handmarks.leftside = {}
	self._handmarks.rightside = {}

	local uinstr = PX2_PROJ:GetConfig("uin")
	g_manykit._uin = StringHelp:StringToInt(uinstr, g_manykit._uin)

	self:_InitUI()

    -- write path
	local wp = "Write_" .. PX2_PROJ:GetName() .. "/"
	self._writePathProj = ResourceManager:GetWriteablePath()..wp
    if not PX2_RM:IsFileFloderExist(g_manykit._writePathProj) then
        PX2_RM:CreateFloder(ResourceManager:GetWriteablePath(), wp)
    end
    local parentPath = self._writePathProj
    if not PX2_RM:IsFileFloderExist(parentPath.."maps/") then
        PX2_RM:CreateFloder(parentPath, "maps/")
    end
    if not PX2_RM:IsFileFloderExist(parentPath.."maps/voxels/") then
        PX2_RM:CreateFloder(parentPath.."maps/", "voxels/")
    end
	V_SectionData:SetSavePath(parentPath.."maps/voxels/")
	PX2_VOXELM:Initlize(VoxelManager.T_TEX)
	if not PX2_RM:IsFileFloderExist(parentPath.."maps/pathes/") then
        PX2_RM:CreateFloder(parentPath.."maps/", "pathes/")
    end

	-- cfg
	local sttstr = PX2_PROJ:GetConfig("snaptoterrain")
	PX2_EDIT.IsSnapToTerrain = ("1" == sttstr) and 1 or 0
	local stgstr = PX2_PROJ:GetConfig("snaptogrid")
	PX2_EDIT.IsSnapToGrid = ("1" == stgstr) and 1 or 0

	g_manykit._mouseHorAdjust = PX2_PROJ:GetConfigFloat("mousehoradjust", g_manykit._mouseHorAdjust)
    g_manykit._mouseVerAdjust = PX2_PROJ:GetConfigFloat("mouseveradjust", g_manykit._mouseVerAdjust)
    g_manykit._mouseHorAdjust_r = PX2_PROJ:GetConfigFloat("mousehoradjust_r", g_manykit._mouseHorAdjust_r)
    g_manykit._mouseVerAdjust_r = PX2_PROJ:GetConfigFloat("mouseveradjust_r", g_manykit._mouseVerAdjust_r)
    g_manykit._mouseWheelAdjust = PX2_PROJ:GetConfigFloat("mousewheeladjust", g_manykit._mouseWheelAdjust)
    g_manykit._mouseHorDragAdjust = PX2_PROJ:GetConfigFloat("firstviewhoradjust", g_manykit._mouseHorDragAdjust)
    g_manykit._mouseVerDragAdjust = PX2_PROJ:GetConfigFloat("firstviewveradjust", g_manykit._mouseVerDragAdjust)

    g_manykit._mrCameraNear = PX2_PROJ:GetConfigFloat("cam_near", g_manykit._mrCameraNear)
    g_manykit._mrCameraFar = PX2_PROJ:GetConfigFloat("cam_far", g_manykit._mrCameraFar)
    g_manykit._slamPosScale = PX2_PROJ:GetConfigFloat("cam_scale", g_manykit._slamPosScale)
    g_manykit._slamEyeTransScale = PX2_PROJ:GetConfigFloat("slameyetransscale", g_manykit._slamEyeTransScale)
    g_manykit._mrHeightAdjust = PX2_PROJ:GetConfigFloat("mrheightadjust", g_manykit._mrHeightAdjust)

	local str = PX2_PROJ:GetConfig("camobjoffset")
    g_manykit._camObjOffset = AVector:SFromString(str)
	local str = PX2_PROJ:GetConfig("camobjoffsetrot")
    g_manykit._camObjOffsetRot = AVector:SFromString(str)

    -- plugins
	self:PluginsCallFile()
	self:PluginsRegistedCalRequireIndex()
	self:PluginsRegistedSortByRequireIndex()
	self:PluginsRegistedPreCreate()
	self:PluginsRegistedCreateTreeInstances()
	self:PluginTreeInstancesAfterAttached()
	self:_AddPluginTreeItems()

	RegistEventObjectFunction("InputEventSpace::KeyPressed", self, function(myself, keyStr)
		if not UIEditBox:IsHasAttachedIME() then
			if "KC_LCONTROL"==keyStr then
				g_manykit._isPressed_Ctrl = true
			elseif "KC_RCONTROL"==keyStr then
				g_manykit._isPressed_Ctrl = true
			elseif "KC_LSHIFT"==keyStr then
				g_manykit._isPressed_Shift = true
			elseif "KC_RSHIFT"==keyStr then
				g_manykit._isPressed_Shift = true
			elseif "KC_W" == keyStr then
				g_manykit._isPressed_W = true
				g_manykit._keyState.w=1
			elseif "KC_S" == keyStr then
				g_manykit._isPressed_S = true
				g_manykit._keyState.s=1
			elseif "KC_A" == keyStr then
				g_manykit._isPressed_A = true
				g_manykit._keyState.a=1
			elseif "KC_D" == keyStr then
				g_manykit._isPressed_D = true
				g_manykit._keyState.d=1
			elseif "KC_SPACE" == keyStr then
				g_manykit._isPressed_Space = true
			elseif "KC_LEFT" == keyStr then
				g_manykit._isPressed_Left = true
			elseif "KC_RIGHT" == keyStr then
				g_manykit._isPressed_Right = true
			elseif "KC_DOWN" == keyStr then
				g_manykit._isPressed_Down = true
			elseif "KC_UP" == keyStr then
				g_manykit._isPressed_Up = true
			elseif "KC_E" == keyStr then
				g_manykit._isPressed_E = true
				g_manykit._keyState.e=1
			elseif "KC_X" == keyStr then
				g_manykit._isPressed_X = true
				g_manykit._keyState.x=1
			elseif "KC_C" == keyStr then
				g_manykit._isPressed_C = true
				g_manykit._keyState.c=1
			elseif "KC_Z" == keyStr then
				g_manykit._isPressed_Z = true
				g_manykit._keyState.z=1
			elseif "KC_Q" == keyStr then
				g_manykit._isPressed_Q = true
				g_manykit._keyState.q=1
			elseif "KC_1" == keyStr then
				g_manykit._isPressed_1 = true
				g_manykit._keyState.one=1
			elseif "KC_3" == keyStr then
				g_manykit._isPressed_3 = true
				g_manykit._keyState.three=1
			elseif "KC_4" == keyStr then
			end
		end
	end)

	RegistEventObjectFunction("InputEventSpace::KeyReleased", self, function(myself, keyStr)
		if not UIEditBox:IsHasAttachedIME() then
			if "KC_LCONTROL"==keyStr then
				g_manykit._isPressed_Ctrl = false
			elseif "KC_RCONTROL"==keyStr then
				g_manykit._isPressed_Ctrl = false
			elseif "KC_LSHIFT"==keyStr then
				g_manykit._isPressed_Shift = false
			elseif "KC_RSHIFT"==keyStr then
				g_manykit._isPressed_Shift = false
			elseif "KC_W" == keyStr then
				g_manykit._isPressed_W = false
				g_manykit._keyState.w=0
			elseif "KC_S" == keyStr then
				g_manykit._isPressed_S = false
				g_manykit._keyState.s=0
			elseif "KC_A" == keyStr then
				g_manykit._isPressed_A = false
				g_manykit._keyState.a=0
			elseif "KC_D" == keyStr then
				g_manykit._isPressed_D = false
				g_manykit._keyState.d=0
			elseif "KC_SPACE" == keyStr then
				g_manykit._isPressed_Space = false
			elseif "KC_LEFT" == keyStr then
				g_manykit._isPressed_Left = false
			elseif "KC_RIGHT" == keyStr then
				g_manykit._isPressed_Right = false
			elseif "KC_DOWN" == keyStr then
				g_manykit._isPressed_Down = false
			elseif "KC_UP" == keyStr then
				g_manykit._isPressed_Up = false
			elseif "KC_E" == keyStr then
				g_manykit._isPressed_E = false
				g_manykit._keyState.e=0
			elseif "KC_ESCAPE" == keyStr then
				if g_manykit._isPressed_Ctrl then
				end
			elseif "KC_X" == keyStr then
				g_manykit._isPressed_X = false
				g_manykit._keyState.x=0
			elseif "KC_C" == keyStr then
				g_manykit._isPressed_C = false
				g_manykit._keyState.c=0
			elseif "KC_Z" == keyStr then
				g_manykit._isPressed_Z = false
				g_manykit._keyState.z=0
			elseif "KC_Q" == keyStr then
				g_manykit._isPressed_Q = false
				g_manykit._keyState.q=0
			elseif "KC_1" == keyStr then
				g_manykit._isPressed_1 = false
				g_manykit._keyState.one=0
			elseif "KC_3" == keyStr then
				g_manykit._isPressed_3 = false
				g_manykit._keyState.three=0				
			elseif "KC_4" == keyStr then
			end
		end
	end)

	RegistEventObjectFunction("InputEventSpace::MousePressed", self, function(myself, id)
		if "0"==id then
			g_manykit._isDown_Left = true
		elseif "1"==id then
			g_manykit._isDown_Right = true
		elseif "2"==id then
		end
	end)

	RegistEventObjectFunction("InputEventSpace::MouseReleased", self, function(myself, id)
		if "0"==id then
			g_manykit._isDown_Left = false
		elseif "1"==id then
			g_manykit._isDown_Right = false
		elseif "2"==id then
		end
	end)

    RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
		if "minna_setplugin"==str then
			local plugin = str1
            print("plugin:"..plugin)
			g_manykit:SelectPlugin(plugin)
		end
	end)
end
function g_manykit:Terminate()
end
-------------------------------------------------------------------------------
-- ui
function g_manykit:_InitUI()
    print("g_manykit:_InitUI")

	local ui = PX2_PROJ:GetUI()

	local frame = UIFrame:New("UIFrameRoot")
	PX2_PROJ:PoolSet("_frameRoot", frame)
	self._frameRoot = frame
	ui:AttachChild(frame)
	frame:LLY(-1.0)
	frame:SetAnchorHor(0.0, 1.0)
	frame:SetAnchorVer(0.0, 1.0)
	local frameLeft = self:_CreateFrameLeft()
	self._frameLeft = frameLeft
	frame:AttachChild(frameLeft)
	frameLeft:LLY(-50.0)
	frameLeft:SetAnchorHor(0.0, 0.0)
    frameLeft:SetAnchorVer(0.0, 1.0)
	frameLeft:SetPivot(0.0, 0.5)
	frameLeft:SetWidth(200.0)

	local frameCnt = UIFrame:New()
	self._frameCnt = frameCnt
	frame:AttachChild(frameCnt)
	frameCnt:LLY(-1.0)
	frameCnt:SetAnchorHor(0.0, 1.0)
    frameCnt:SetAnchorVer(0.0, 1.0)
	frameCnt:SetAnchorParamHor(200.0, 0.0)

	local frameTouch = UIFrame:New()
	self._frameTouch = frameTouch
	ui:AttachChild(frameTouch)
	frameTouch:LLY(-8.0)
	PX2_PROJ:PoolSet("_frameTouch", frameTouch)
	frameTouch:SetAnchorHor(0.0, 1.0)
    frameTouch:SetAnchorVer(0.0, 1.0)
	frameTouch:SetWidget(true)
	-- local back = frameTouch:CreateAddBackgroundPicBox(true, Float3(0.5, 0.5, 0.5))
	-- back:SetAlpha(0.7)
	-- back:UseAlphaBlend(true)

	local frameCntCnt = UIFrame:New()
	self._frameCntCnt = frameCntCnt
	frameCnt:AttachChild(frameCntCnt)
	frameCntCnt:SetAnchorHor(0.0, 1.0)
    frameCntCnt:SetAnchorVer(0.0, 1.0)
	frameCntCnt:LLY(-1.0)

	local framePopUp = manykit_CreateFramePopUpInfo()
	self._frameInfoPopUp = framePopUp
    frame:AttachChild(framePopUp)
    framePopUp:LLY(-50.0)
	framePopUp:Show(false)

	local docksidestr = PX2_PROJ:GetConfig("dockside")
	if "1"==docksidestr then
		self:_DockSide(true)
	end
end
-------------------------------------------------------------------------------
function g_manykit:_CreateFrameLeft()
    print("g_manykit:_CreateFrameLeft")

	local leftTitleHeight = self._hBtn

	local frameLeft = UIFrame:New("UIFrameLeft")
    frameLeft:LLY(0.0)
	local backC = frameLeft:CreateAddBackgroundPicBox()
	backC:SetColor(Float3.BLACK)

	local frameLeftTitle = UIFrame:New()
	frameLeft:AttachChild(frameLeftTitle)
	frameLeftTitle:LLY(-1.0)
	frameLeftTitle:SetAnchorHor(0.0, 1.0)
	frameLeftTitle:SetAnchorVer(1.0, 1.0)
	frameLeftTitle:SetHeight(leftTitleHeight)
	frameLeftTitle:SetPivot(0.5, 1.0)

	local btnSide = UIButton:New("BtnSide")
	frameLeftTitle:AttachChild(btnSide)
	btnSide:LLY(-1.0)
	btnSide:SetAnchorHor(1.0, 1.0)
	btnSide:SetAnchorParamHor(-self._hBtn*0.5, -self._hBtn*0.5)
	btnSide:SetSize(self._hBtn-2, self._hBtn-2)
	manykit_uiProcessBtn(btnSide)
	btnSide:SetScriptHandler("g_manykit_UICallback")

	local fPicBox = UIFPicBox:New("FPicBoxBtnSide")
	btnSide:AttachChild(fPicBox)
	fPicBox:LLY(-1.0)
	fPicBox:GetUIPicBox():SetTexture("common/images/ui/return.png")
	fPicBox:SetAnchorHor(0.0, 1.0)
	fPicBox:SetAnchorVer(0.0, 1.0)
	fPicBox:SetColor(Float3.RED)
	fPicBox:SetUserScriptName("FPicBoxBtnSide")
	fPicBox:RegistToScriptSystem()

	local treePlugins = UITree:New("TreePlugins")
	self._treePlugins = treePlugins
	frameLeft:AttachChild(treePlugins)
	treePlugins:LLY(-1.0)
	treePlugins:SetAnchorHor(0.0, 1.0)
	treePlugins:SetAnchorVer(0.0, 1.0)
	treePlugins:SetAnchorParamVer(0.0, -leftTitleHeight)
	manykit_uiProcessTree(treePlugins)
	treePlugins:CreateRoot()
	local itemRoot = g_manykit._treePlugins:GetRootItem()
	treePlugins:ShowRootItem(false)
	treePlugins:SetScriptHandler("g_manykit_UICallback")

	return frameLeft
end
-------------------------------------------------------------------------------
function g_manykit:_AddPluginTreeItems()
    if nil==g_manykit._treePlugins then
        return
    end

	local itemRoot = g_manykit._treePlugins:GetRootItem()

	local cfg_dockside = true
	local cfg_showside = true
	local startproject = ""
	cfg_showside = p_project.cfg.showside
	cfg_dockside = p_project.cfg.dockside
	startproject = p_project.cfg.startproject

	local startProj = nil
	for key, value in pairs(p_project.projects) do
		if startproject == value.name then
			startProj = value
		end
	end
	if startProj then
		local startCata = nil
		local startCataItemFirst = nil

		-- 按照 startProj.treecatas 定义的顺序遍历
		for i=1, #startProj.treecatas, 1 do
			local cataName = startProj.treecatas[i]
			
			-- 在 p_project.treecatas 中查找对应的分类对象
			for key, value in pairs(p_project.treecatas) do
				local na = value.name
				if na == cataName then
					local sh = value.show
					local isstartcata = false

					if startProj.startcata == na then
						startCata = value
						isstartcata = true
					end

					if sh then
						local tit = value.title
						local exp = value.expand
						local items = value.treeitems

						local itemCata = g_manykit._treePlugins:AddItem(itemRoot, tit, na)
						local ck = itemCata:CreateButArrow()
						ck:SetName("BtnArrow")
						ck:SetScriptHandler("g_manykit_UICallback")
						ck:SetUserDataPointer("Item", itemCata)
						ck:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/triangle.png")
						ck:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetTexture("engine/trianglea.png")
						ck:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetAlpha(0.5)
						ck:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetAlpha(0.5)
						itemCata:RegistToScriptSystem()

						for j=1, #items, 1 do
							local pname = items[j]

							local item = g_manykit._treePlugins:AddItem(itemCata, PX2_LM_APP:V(""..pname), pname)
							item:SetUserDataString("plugin", pname)

							if isstartcata then
								if 1==j then
									startCataItemFirst = item
								end
							end
						end
						itemCata:Expand(exp)
					end
					break  -- 找到匹配项后跳出内层循环
				end
			end
		end

		if startCataItemFirst then
			g_manykit._treePlugins:AddSelectItem(startCataItemFirst, false, true)
		end
	end

	self:_DockSide(cfg_dockside)
	self:_ShowSide(cfg_showside)
end
function g_manykit:_DockSide(isDockSide)
	self._isUIDockSide = isDockSide

	local rv = 0.0

	if isDockSide then
		FPicBoxBtnSide.LocalTransform:SetRotateDegree(0, 180, 0)

		self._frameLeft:SetAnchorHor(0.0, 0.0)
		self._frameLeft:SetAnchorParamHor(self._hBtn, self._hBtn)
		self._frameLeft:SetAnchorVer(0.0, 1.0)
		self._frameLeft:SetPivot(1.0, 0.5)
		self._frameLeft:SetWidth(self._dockSideWidth)

		self._frameCnt:SetAnchorHor(0.0, 1.0)
		self._frameCnt:SetAnchorParamHor(self._hBtn, rv)
	else
		FPicBoxBtnSide.LocalTransform:SetRotateDegree(0, 0, 0)

		self._frameLeft:SetAnchorHor(0.0, 0.0)
		self._frameLeft:SetAnchorParamHor(0.0, 0.0)
		self._frameLeft:SetAnchorVer(0.0, 1.0)
		self._frameLeft:SetPivot(0.0, 0.5)
		self._frameLeft:SetWidth(self._dockSideWidth)

		self._frameCnt:SetAnchorHor(0.0, 1.0)
		self._frameCnt:SetAnchorParamHor(self._dockSideWidth, rv)
	end

	if isDockSide then
		PX2_PROJ:SetConfig("dockside", "1")
	else
		PX2_PROJ:SetConfig("dockside", "0")
	end
end
function g_manykit:_ShowSide(isShowSide)
	self._isUIShowSide = isShowSide

	local rv = 0.0

	self._frameLeft:Show(isShowSide)

	if isShowSide then
		self:_DockSide(self._isUIDockSide)
	else
		self._frameCnt:SetAnchorHor(0.0, 1.0)
		self._frameCnt:SetAnchorParamHor(0.0, rv)
	end
end
function g_manykit_UICallback(ptr, callType)
    local obj = Cast:ToO(ptr) 
    local name = obj:GetName()

	if UICT_PRESSED==callType then
        PX2_PlayFrameScale(obj)

	elseif UICT_RELEASED==callType then
        PX2_PlayFrameNormal(obj)

		if "BtnSide"==name then
			g_manykit._isUIDockSide = not g_manykit._isUIDockSide
			g_manykit:_DockSide(g_manykit._isUIDockSide)
		end
	elseif UICT_CHECKED==callType then
		if "BtnArrow"==name then
			local ptr = obj:GetUserDataPointer("Item")
			local item = Cast:ToObject(ptr)
			item:Expand(not item:IsExpand())
		end
	elseif UICT_DISCHECKED==callType then
		if "BtnArrow"==name then
			local ptr = obj:GetUserDataPointer("Item")
			local item = Cast:ToObject(ptr)
			item:Expand(not item:IsExpand())
		end
	elseif UICT_RELEASED_NOTPICK==callType then
        PX2_PlayFrameNormal(obj)
	elseif UICT_TREE_SELECTED==callType then
		if "TreePlugins"==name then
			local item = g_manykit._treePlugins:GetSelectedItem()
			if item then
				local pluginName = item:GetUserDataString("plugin")
				g_manykit:SelectPlugin(pluginName)
			end
		end
	elseif UICT_TREE_DOUBLE_SELECTED==callType then
		if "TreePlugins"==name then
			local item = obj:GetSelectedItem()
			if item then
				item:Expand(not item:IsExpand())
			end
		end
	end
end
-------------------------------------------------------------------------------