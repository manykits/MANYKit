-- p_mworld.lua
-------------------------------------------------------------------------------
p_mworld = class(p_holospace,
{
    _requires = {"p_holospace"},

	_name = "p_mworld",

	-- cfg
	_isUseVoxel = false,

	-- ui
	_frameContent = nil,
	_frameCover = nil,

	-- web
	_frameWeb = nil,

	-- noinput
	_frameNoInput = nil,	

	-- map
	_frameMapList = nil,
	_listMap = nil,
	_listMap1 = nil,
	_editboxMapName = "",
	_editboxMapName1 = "",
	_nodeCameraSmallMap = nil,

	-- property
	_propertyGrid = nil,
    _propertyGridEdit = nil,
    _propertyGridSet = nil,
    _propertyGridServer = nil,

	-- property map objects
    _fTextListInfo = nil,
    _listMapItems = nil,--add 5
    _listPeoples = nil,
    _peopleCata = "all",

	-- flowgraph
	_frameBluePrint = nil,

	-- bar
	_bh = 70.0,
	_bhspace_border = 10.0, 
	_numBar = 10,
	_frameBar = nil,
	_frameMapTool = nil,
	_frameQuickBarTopSkill = nil,
	_frameQuickBarLeftItem = nil,

	_frameHead = nil,
	_progressbarHP = nil,
	_progressbarExp = nil,

	-- bag
	_frameBagBar = nil,
	_frameBag = nil,
	_frameUI = nil,
	_frameInspector = nil,
	_frameBagItemsCnt = nil,
	_frameMe = nil,
	_frameMeEquipItems = nil,
	_frameSelectInfo = nil,
	_bagItemTouchID = -1,

	_frameSelectBox = nil,
	_frameSelectBox1 = nil,
	_uifPicBoxSelectItem = nil,

	_frameSelectBoxOfEquip = nil,
	_frameFire = nil,
	_frameInfor = nil,

	-- bat
	_fPicBoxAim = nil,
	_fPicCompass = nil,
	_fPicCompassSub = nil,
	_fPicCompassSubChe = nil,
	_compassShowBtn = nil,
	_frameSmallMap = nil,

	-- btn
	_fBtnList = nil,

	-- sunmoon
	_sunmoonparam0 = 1024.0,
    _sunmoonparam1 = 0.2,
    _sunmoonparam2 = 512.0,
    _sunmoonparam3 = 0.2,
	_skytechindex = 0,

	_isUseBloom = false,
	_bloomParam = Float4(0,0,0,0),

	-- vs
	_vs = nil,

	_LandscapeOctaves = 4,
	_LandscapePersistence = 0.5,
	_LandscapeScale = 0.012,
	_MountainOctaves = 2,
	_MountainPersistence = 0.9,
	_MountainScale = 0.012,
	_MountainMultiplier = 1.2,

	-- terrain
	_isTerrainHeightUpdateMePosOK = false,

	_terSelectInfo = "info",
	_terEditMode = 0,
    _terBrushSize = 2.0,
    _terBrushStrength = 0.1,  

	_terHighMode = 0,
    _terTexLayer = 1,
	_terBaseLayer = 1,
	_terTexRepeatU = 12,
	_terTexRepeatV = 12,
    _terTexTexture = 0,

	_terTexTextureNames = {
        "农田",
        "森林1",
		"森林2",
        "草地1",
		"草地2",
        "泥土1",
        "泥土2",
		"泥土3",
		"泥土4",
        "石头1",
        "石头2",
        "雪地",
		"冰面",
		"沙石",
        "沙石1",
        "道路",
        "道路1",
		"暗草地",
    },
    _terTexTextures = {
        "scripts/lua/plugins/p_mworld/images/terrain/farmland.png",
        "scripts/lua/plugins/p_mworld/images/terrain/forest.png",
		"scripts/lua/plugins/p_mworld/images/terrain/forest2.png",
        "scripts/lua/plugins/p_mworld/images/terrain/grass.png",
		"scripts/lua/plugins/p_mworld/images/terrain/grass2.png",
        "scripts/lua/plugins/p_mworld/images/terrain/mud.png",
        "scripts/lua/plugins/p_mworld/images/terrain/mud2.png",
		"scripts/lua/plugins/p_mworld/images/terrain/mud3.png",
		"scripts/lua/plugins/p_mworld/images/terrain/mud4.png",
        "scripts/lua/plugins/p_mworld/images/terrain/rock.png",
        "scripts/lua/plugins/p_mworld/images/terrain/rock2.png",
        "scripts/lua/plugins/p_mworld/images/terrain/snow.png",
		"scripts/lua/plugins/p_mworld/images/terrain/snow1.png",
		"scripts/lua/plugins/p_mworld/images/terrain/sand.png",
		"scripts/lua/plugins/p_mworld/images/terrain/sand1.png",
		"scripts/lua/plugins/p_mworld/images/terrain/road.png",
		"scripts/lua/plugins/p_mworld/images/terrain/road1.png",
		"scripts/lua/plugins/p_mworld/images/terrain/drakgrass.png",
    },
    _terGrassWidth = 1.4,
    _terGrassHigh = 1.4,
    _terGrassLower = 0.05,
    _terGrassTexture = 0,
    _terGrassTextureName = {
        "草0",
        "草1",
        "草2",
		"草3",
		"草4",
		"草5",
		"草6",
    },
    _terGrassTextures = {
        "scripts/lua/plugins/p_mworld/images/grass/grass0.png",
        "scripts/lua/plugins/p_mworld/images/grass/grass1.png",
        "scripts/lua/plugins/p_mworld/images/grass/grass2.png",
		"scripts/lua/plugins/p_mworld/images/grass/grass3.png",
		"scripts/lua/plugins/p_mworld/images/grass/grass4.png",
		"scripts/lua/plugins/p_mworld/images/grass/grass5.png",
		"scripts/lua/plugins/p_mworld/images/grass/grass6.png",
    },

	_terObject = 0,
    _terObjects = {
        21053,
        21054,
        21055,
        21056,
        21057,
        21058,
        21059,
        21060,
        21061,
		21062,
    },
    _terObjectSize = 1.8,
    _terObjectSizeBig = 3.0,
    _terObjectLower = 0.0,

	_fireTrans = {
		ss_you = "首上装甲右",  --坦克
		ss_zuo = "首上装甲左",
		sx_you = "首下装甲右",
		sx_zuo = "首下装甲左",
		lv_you_z = "右侧履带正面",
		lv_zuo_z = "左侧履带正面",
		t_you_q = "车体右侧面前部",
		t_you_zh = "车体右侧面中部",
		t_you_h = "车体右侧面后部",
		t_zuo_q = "车体左侧面前部",
		t_zuo_zh = "车体左侧面中部",
		t_zuo_h = "车体左侧面后部",
		lv_you_h = "右侧履带后面",
		lv_zuo_h = "左侧履带后面",
		paodun = "火炮及防盾",
		pt_zuo_z = "炮塔正面左侧",
		pt_you_z = "炮塔正面右侧",
		jiqiang = "高射机枪",
		pt_zuo = "炮塔左侧",
		pt_you = "炮塔右侧",
		pt_zuo_h = "炮塔后部左侧",
		pt_you_h = "炮塔后部右侧",
		lunzi = "轮子",  --（共用）
		t_all = "整车",
		tou = "头",  --士兵
		xiong = "胸",
		fu = "腹",
		zuobi0 = "左臂上",
		zuobi1 = "左臂下",
		youbi0 = "右臂上",
		youbi1 = "右臂下",
		zuotui0 = "左腿上",
		zuotui1 = "左腿下",
		youtui0 = "右腿上",
		youtui1 = "右腿下",
		pengu = "盆骨",
		jiao_z = "左脚",
		jiao_y = "右脚",
		zc_zuoqian = "车辆左前部",  --步战车
		zc_qian = "车辆前部",
		zc_youqian = "车辆右前部",
		zc_zuoce = "车辆左侧部",
		zc_youce = "车辆右侧部",
		zc_zuohou = "车辆左后部",
		zc_hou = "车辆后部",
		zc_youhou = "车辆右后部",
		zc_di = "车辆底盘",
		zc_all = "整车",
		t_qian = "前部",  --通用车辆 
		t_hou = "后部",
		t_zuo = "左部",
		t_you = "右部",
		luoxuan0 = "螺旋桨(顶部）",
		luoxuan1 = "不同方向螺旋桨（尾部）",
		tongyong = "整体",
	},

	-- mr
	_sandBoxUse = false,
	_sandBoxScale = 0.01,
	_sandBoxPosX = 0.0,
	_sandBoxPosY = 0.0,
	_sandBoxPosZ = 1.0,
	_sandBoxRot = 0.0,

	-- navigation
	_isShowNav = false,
	_navigationType = 0,

	-- vision
	_hotUse = false,
	_frameHot = nil,
	_frameCameraIP = nil,

	--snappy
	_frameSnappy = nil,

	-- edit
	_curSelectBarItemIDForPutting = -1,
	_curSelectActorID = -1,
	
    _currentCatchObjectByID = -1,
    _currentCatchObjectID = -1,
    _handTypeCatch = -1,

	_uiitemSelectBagOrEquip = nil,
	_itemSelectIDBagOrEquip = 0,
	_itemSelectBar = nil,
	_itemSelectIDBar = 0,

	-- edit maps
	_curroomid = 0,
    _curmapid = 0,
    _openingmap_url = "",
    _openingmap_id = 0,
    _openingmap_filename = "",
    _openingmap_closeddoopen = false,
    _iscommingroom_openmap = false,
    _isMapFirstInited = false,

	-- scene setting
	_ambientMax = 0.4,
	_diffuseMax = 1.0,
	_specularMax = 0.4,

	_ambientMax_noclearday = 0.2,
	_diffuseMax_noclearday = 0.4,
	_specularMax_noclearday = 0.05,

	_heightscale = 0.0,
	_startlong = "0.0",
	_startlat = "0.0",
	_endlong = "0.0",
	_endlat = "0.0",
	_maplength = 0.0,
	_mapwidth = 0.0,
	
	_terNumNavGridIndex = 0,
	_isUseTerrain = true,
	_isterrainuselod = false,
	_terrainLODTolerance = 1.0,
	_isTerrainLODCloseAssumption = false,
	_isTerrainonlyObst = false,

	_terrainMode = 0,
	_terrainpath = "",
	_terrainmd5 = "", 
	_terrainzipmd5 = "", 

	_gisZoom = 0,
	_gisTexturePath = "",
	_gisHeightPath = "",
	_gisTextureMinZoom = 0,
	_gisTextureMaxZoom = 16,
	_gisHeightMinZoom = 0,
	_gisHeightMaxZoom = 16,

	_gisHeightMinNotZeroing = 0.0,
	_gisHeightMaxing = 0.0,
	_gisHeightMinNotZero = 0.0,

	_gisCameraMinus = 0.0,

	_gisPosOffsetX = 0.0,
	_gisPosOffsetY = 0.0,
	_gotoOffset = 0.2,

	_gisZoomScale = 1.0,
	_gisFixGisZoomMinus = -1,

	_islightmodeeasy = true,
	_time = 10.0,
	_ambient = 0.5,
	_diffuse = 0.5,
	_specular = 0.2,
	_hotemissive = 0.2,
	_hotambient = 0.0,
	_hotemissiveterrain = 0.2,
	_hotambientterrain = 0.0,
	
	_fog_far = 6000.0,
	_fog_near = 6000.0,
	_fog_color = 0.0,
	_wind = 0.0,
	_rain = 0.0,
	_snow = 0.0,
	_thunder = 0.0,
	_cloudclip = 0.6,
	_isusesky = true,
	_viewdist_terrain = 0.0,
	_g_viewdist_objects = 0.0,
	_g_viewdist_objects_lod = 0.0,
	_moontype = 0.0,
	_moon = 0.0,
	_star = 0.0,    

	-- setting
	_wireframe = false,

	-- play
	_frameInMap = nil,
	_frameInMain = nil,
	_frameInInfo = nil,
	_frameInTest = nil,
	_frameInInFireT = nil,
	_frameAdj = nil,
	_frameAdjFText = nil,
	_btnsimu2 = nil,
	_isSimuing = false,
	_btnedit = nil,
	_btnedit2 = nil,
	_isediting = false,
	_isLockEdit = false,
	_mapOpenRunMode = 1,
	_mapOpenSlamMode = 0,
	_mapOpenViewStyle = 0,
	_loadprogressBar = nil,

	_isHideCursor = false,
	
	_agentAgentTakeProcess = nil,
	_agentAgentFirstView = nil,	
})
-------------------------------------------------------------------------------
function p_mworld:OnAttached()
	print(self._name.." p_mworld:OnAttached")

	p_holospace.OnAttached(self)

    self._mapOpenRunMode = 1
	
	PX2_LM_APP:AddItem("Scene", "Scene", "场景")
    PX2_LM_APP:AddItem("People", "People", "人员")
    PX2_LM_APP:AddItem("Edit", "Edit", "编辑")
    PX2_LM_APP:AddItem("Property", "Property", "属性")
    PX2_LM_APP:AddItem("Terrain", "Terrain", "地形")
    PX2_LM_APP:AddItem("Other", "Other", "其他")
    PX2_LM_APP:AddItem("Video", "Video", "视频")
    PX2_LM_APP:AddItem("Train", "Train", "训练")
    PX2_LM_APP:AddItem("Vehicle", "Vehicle", "装备")
    PX2_LM_APP:AddItem("Logic", "Logic", "逻辑")
    PX2_LM_APP:AddItem("Setting", "Setting", "设置")
    PX2_LM_APP:AddItem("Server", "Server", "服务")

    PX2_LM_APP:AddItem("scene", "Scene", "场景")
    PX2_LM_APP:AddItem("people", "People", "人员")
    PX2_LM_APP:AddItem("vehicle", "Vehicle", "装备")
    PX2_LM_APP:AddItem("logic", "Logic", "逻辑")
    PX2_LM_APP:AddItem("sky", "Sky", "天空")
    PX2_LM_APP:AddItem("dynamic", "Dynamic", "动态")
    PX2_LM_APP:AddItem("buildings", "Buildings", "建筑")
    PX2_LM_APP:AddItem("trees", "Trees", "树木")
    PX2_LM_APP:AddItem("fences", "Fences", "围栏")
    PX2_LM_APP:AddItem("other", "Other", "其他")
    PX2_LM_APP:AddItem("light", "Light", "灯光")

    PX2_LM_APP:AddItem("Name", "Name", "名称")
    PX2_LM_APP:AddItem("Remove", "Remove", "删除")
    PX2_LM_APP:AddItem("Add", "Add", "增加")
    PX2_LM_APP:AddItem("Create", "Create", "创建")
    PX2_LM_APP:AddItem("Refresh", "Refresh", "刷新")
    PX2_LM_APP:AddItem("Open", "Open", "打开")
    PX2_LM_APP:AddItem("Close", "Close", "关闭")

    PX2_LM_APP:AddItem("OpenMap", "Please Open Map", "请打开地图")

	PX2_LM_APP:AddItem(self._name, "MWrold", "世界(空间)")

	RegistEventObjectFunction("InputEventSpace::KeyReleased", self, function(myself, keyStr)

        if "KC_Q"==keyStr then
            if not UIEditBox:IsHasAttachedIME() then
                if g_manykit._isPressed_Ctrl then
                    g_manykit._isFullScreen = not g_manykit._isFullScreen
                    PX2_GH:GetMainWindow():SetFullScreen(g_manykit._isFullScreen)
                    if g_manykit._isFullScreen then
                        PX2_PROJ:SetConfig("isfullscreen", "1")
                    else
                        PX2_PROJ:SetConfig("isfullscreen", "0")
                    end
                end
            end
        end

		if "KC_R"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then
				local scene = PX2_PROJ:GetScene()
				local mainActor = scene:GetMainActor()
				if mainActor then
					local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(mainActor, "p_actor")
					if scCtrl then
						local skill = scCtrl._skillChara:GetDefSkill()
						if skill then
							scCtrl:_AutoCharge(skill, false)
						end
					end
				end
			end
		elseif "KC_1"==keyStr then
			print("KC_1")

		elseif "KC_2"==keyStr then
			print("KC_2")

		elseif "KC_9"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then
				PX2_GH:SendGeneralEvent("SlamClearMap")
			end
		elseif "KC_8"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then
				PX2_GH:SendGeneralEvent("SlamLoadMap")
			end
		elseif "KC_7"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then
                if g_manykit._isPressed_Ctrl then
                    PX2_GH:SendGeneralEvent("SlamSaveMap", "cloud")
                else
                    PX2_GH:SendGeneralEvent("SlamSaveMap")
                end
			end
		elseif "KC_DOWN"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then

                local addt = 0.0
                if g_manykit._isPressed_Ctrl then
                    addt = 0.1
                end
                if g_manykit._isPressed_Shift then
                    addt = 0.01
                end

                if addt~=0 then
                    local x = g_manykit._mapRotOffset:X() - addt
                    g_manykit._mapRotOffset:SetX(x)
                    PX2_PROJ:SetConfig("maprotoffset", g_manykit._mapRotOffset:ToString())

                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_UP"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then
	
                local addt = 0.0
                if g_manykit._isPressed_Ctrl then
                    addt = 0.1
                end
                if g_manykit._isPressed_Shift then
                    addt = 0.01
                end

                if addt~=0 then
                    local x = g_manykit._mapRotOffset:X() + addt
                    g_manykit._mapRotOffset:SetX(x)
                    PX2_PROJ:SetConfig("maprotoffset", g_manykit._mapRotOffset:ToString())
                
                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_LEFT"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then

                local addt = 0.0

                if g_manykit._isPressed_Ctrl then
                    addt = 0.1
                end
                if g_manykit._isPressed_Shift then
                    addt = 0.01
                end

                if addt~=0 then
                    g_manykit._slamEyeTransScale = g_manykit._slamEyeTransScale - addt
                    g_manykit._slamEyeTransScale = Mathf:Clamp(g_manykit._slamEyeTransScale, 0.0, 2.0)
                    PX2_PROJ:SetConfig("slameyetransscale", g_manykit._slamEyeTransScale)
                    p_holospace._g_holospace:_AdjustCameraMR()
                
                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_RIGHT"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then

                local addt = 0.0

                if g_manykit._isPressed_Ctrl then
                    addt = 0.1
                end
                if g_manykit._isPressed_Shift then
                    addt = 0.01
                end

                if addt~=0 then
                    g_manykit._slamEyeTransScale = g_manykit._slamEyeTransScale + addt
                    g_manykit._slamEyeTransScale = Mathf:Clamp(g_manykit._slamEyeTransScale, 0.0, 2.0)
                    PX2_PROJ:SetConfig("slameyetransscale", g_manykit._slamEyeTransScale)
                    p_holospace._g_holospace:_AdjustCameraMR()
                
                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_X"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then

                local x = g_manykit._camObjOffset:X()
                local y = g_manykit._camObjOffset:Y()
                local z = g_manykit._camObjOffset:Z()

                local addt = 0.0
                if g_manykit._isPressed_Ctrl then
                    addt = 0.001
                end
                if g_manykit._isPressed_Shift then
                    addt = - 0.001
                end

                if addt~=0 then
                    x = x + addt

                    g_manykit._camObjOffset = AVector(x, y, z)
                    print("camobjoffset:"..g_manykit._camObjOffset:ToString())

                    PX2_PROJ:SetConfig("camobjoffset", g_manykit._camObjOffset:ToString())

                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_Y"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then

                local x = g_manykit._camObjOffset:X()
                local y = g_manykit._camObjOffset:Y()
                local z = g_manykit._camObjOffset:Z()

                local addt = 0.0
                if g_manykit._isPressed_Ctrl then
                    addt = 0.001
                end
                if g_manykit._isPressed_Shift then
                    addt = - 0.001
                end

                if addt~=0 then
                    y = y + addt
                    
                    g_manykit._camObjOffset = AVector(x, y, z)
                    print("camobjoffset:"..g_manykit._camObjOffset:ToString())

                    PX2_PROJ:SetConfig("camobjoffset", g_manykit._camObjOffset:ToString())

                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_Z"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then
		
                local x = g_manykit._camObjOffset:X()
                local y = g_manykit._camObjOffset:Y()
                local z = g_manykit._camObjOffset:Z()

                local addt = 0.0
                if g_manykit._isPressed_Ctrl then
                    addt = 0.001
                end
                if g_manykit._isPressed_Shift then
                    addt = - 0.001
                end
                if addt~=0 then
                    z = z + addt
                    
                    g_manykit._camObjOffset = AVector(x, y, z)
                    print("camobjoffset:"..g_manykit._camObjOffset:ToString())

                    PX2_PROJ:SetConfig("camobjoffset", g_manykit._camObjOffset:ToString())

                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_U"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then

                local x = g_manykit._camObjOffsetRot:X()
                local y = g_manykit._camObjOffsetRot:Y()
                local z = g_manykit._camObjOffsetRot:Z()

                local addt = 0.0
                if g_manykit._isPressed_Ctrl then
                    addt = 0.2
                end
                if g_manykit._isPressed_Shift then
                    addt = -0.2
                end
                if addt~=0 then
                    x = x + addt
                    
                    g_manykit._camObjOffsetRot = AVector(x, y, z)
                    print("camobjoffsetrot:"..g_manykit._camObjOffsetRot:ToString())

                    PX2_PROJ:SetConfig("camobjoffsetrot", g_manykit._camObjOffsetRot:ToString())
                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_V"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then

                local x = g_manykit._camObjOffsetRot:X()
                local y = g_manykit._camObjOffsetRot:Y()
                local z = g_manykit._camObjOffsetRot:Z()

                local addt = 0.0
                if g_manykit._isPressed_Ctrl then
                    addt = 0.2
                end
                if g_manykit._isPressed_Shift then
                    addt = -0.2
                end
                if addt~=0 then
                    y = y + addt
                    
                    g_manykit._camObjOffsetRot = AVector(x, y, z)
                    print("camobjoffsetrot:"..g_manykit._camObjOffsetRot:ToString())

                    PX2_PROJ:SetConfig("camobjoffsetrot", g_manykit._camObjOffsetRot:ToString())
                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_W"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then
				
                local x = g_manykit._camObjOffsetRot:X()
                local y = g_manykit._camObjOffsetRot:Y()
                local z = g_manykit._camObjOffsetRot:Z()

                local addt = 0.0
                if g_manykit._isPressed_Ctrl then
                    addt = 0.2
                end
                if g_manykit._isPressed_Shift then
                    addt = -0.2
                end
                if addt~=0 then
                    z = z + addt
                    
                    g_manykit._camObjOffsetRot = AVector(x, y, z)
                    print("camobjoffsetrot:"..g_manykit._camObjOffsetRot:ToString())

                    PX2_PROJ:SetConfig("camobjoffsetrot", g_manykit._camObjOffsetRot:ToString())
                    self:_RegistPropertyOnSet()
                end

			end
		elseif "KC_B"==keyStr then
			if not UIEditBox:IsHasAttachedIME() then
				myself:_GoToTick()
			end
		end
	end)

	RegistEventObjectFunction("InputEventSpace::KeyPressed", self, function(myself, keyStr)
        local scene = PX2_PROJ:GetScene()
		local mainActor = scene:GetMainActor()

		if not UIEditBox:IsHasAttachedIME() then
			local ctrl, scCtrlHuman = g_manykit_GetControllerDriverFrom(mainActor, "p_human")
			local ctrl, scCtrlVehicle = g_manykit_GetControllerDriverFrom(mainActor, "p_vehicle")
			if "KC_SPACE" == keyStr then

                if scCtrlVehicle then
                    scCtrlVehicle:_Fire()
                else
                    if scCtrlHuman then
                        local tm = scCtrlHuman._agent:GetHumanTakePossessed()
                        if AIAgent.HTPM_ALL == tm then
                            scCtrlHuman:_Jump()
                        end
                    end	
                end

			elseif "KC_Z"==keyStr then		

                local scene = PX2_PROJ:GetScene()
                if scene then
                    local n = scene:GetNodeRoot()
                    if n then
                        local actBox = PX2_CREATER:CreateActorBox()
                        if actBox then
                            actBox.LocalTransform:SetTranslateZ(10.0)
                            n:AttachChild(actBox)
                            actBox:ResetPlay()
                        end
                    end
                end

			elseif "KC_0"==keyStr then
				myself:_ExitCurCtrl()

				if g_manykit._isPressed_Ctrl then
					myself._frameNoInput:Show(false)
					myself:_ShowCursor(true)

					if nil==self._agentAgentTakeProcess then
						p_holospace._g_cameraPlayCtrl:Enable(true)   
					end  
				end
			end
		end
    end)
		
	local platType = PX2_APP:GetPlatformType()
	if Application.PLT_UWP == platType then
	elseif Application.PLT_WINDOWS==platType then
	elseif Application.PLT_LINUX==platType then
		PX2_GH:GetMainWindow():MaxSize(true)
	end

	self:_UpdateCfgParam(true)
end
-------------------------------------------------------------------------------
function p_mworld:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_mworld:OnInitUpdate")

	if self._enable then
        -- need _ncLogic already created， if not created yet will not AddScriptHandler
        if p_net._g_net then
            if p_net._g_net._ncLogic then
                p_net._g_net._ncLogic:AddScriptHandler("_OnLogicCallback", self._scriptControl)
                p_net._g_net:_NetLogicConnect()
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:OnPluginTreeInstanceAfterAttached()
	print(self._name.." p_mworld:OnPluginTreeInstanceAfterAttached")

	self._enable = true

	p_holospace.OnPluginTreeInstanceAfterAttached(self)

	self:_CreateContentFrame()
	
	local hs = p_holospace._g_holospace
	if hs then 
		local cb = {
			obj = self,
			callback = self._PickMapCallback,
		}
		table.insert(hs._pickCallbacks, #hs._pickCallbacks + 1, cb)
	end

	print(self._name.." GraphicsES::GeneralString")
	RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
		if "OnDragClose"==str then
			if myself._curSelectActorID>0 and "1"==str1 then
				p_net._g_net:_RequestTranslateObj(myself._curSelectActorID, false, true, self._curmapid)
			end
		elseif "ReConnect"==str then
			myself:_SendReConnect()
		elseif "LogicDisConnecteded"==str then

		elseif "peoplesallchanged"==str then
			myself:_PeopleListSyn()
		elseif "ActorSetPos"==str then
			local scene = PX2_PROJ:GetScene()
			if scene then
				local mainActor = scene:GetMainActor()
				if mainActor then
					local id = mainActor:GetID()
					p_net._g_net:_RequestTranslateObj(id, false, false, self._curmapid)
				end
			end
		elseif "ActorDie"==str then
			local id = StringHelp:SToI(str1)
			myself:_OnActorDie(id)
		elseif "ActorTargetChanged"==str then
            print("ActorTargetChanged")

			if str1~="" then
				local stk = StringTokenizer(str1, ",")
				if stk:Count()==2 then
					local fromidstr = stk:GetAt(0)
					local toidstr = stk:GetAt(1)
					local fromid = StringHelp:StringToInt(fromidstr)
					local toid = StringHelp:StringToInt(toidstr)
					myself:_OnActorSeeTarget(fromid, toid)
				end
			end
		elseif "SkillRoomChanged"==str then
			myself:_RefreshMapInfo()
		elseif "SkillCharaChanged"==str then
			myself:_RefreshMapInfo()
		end
	end)

	self:_PeopleListSyn()

    --self:_CreateSlamHelpObjects()
    self:_CreateMRObjects()

    PX2_RM:AddTexPack("scripts/lua/plugins/p_mworld/images/blocks/blocks.xml")
    PX2_RM:AddTexPack("scripts/lua/plugins/p_mworld/images/blocks/blocks_nrm.xml")
    PX2_RM:AddTexPack("scripts/lua/plugins/p_mworld/images/blocks/blocks_disp.xml")
    PX2_RM:AddTexPack("scripts/lua/plugins/p_mworld/images/blocks/blocks_occ.xml")
    PX2_RM:AddTexPack("scripts/lua/plugins/p_mworld/images/blocks/blocks_spec.xml")
    PX2_VOXELM:LoadBlocksConfig("scripts/lua/plugins/p_mworld/images/blocks/blockconfig.xml")

	RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
		if "SkillCharaAddItems"==str then
			local skillcharaid = StringHelp:StringToInt(str1)
			local mainActor = PX2_PROJ:GetScene():GetMainActor()
			if mainActor and mainActor:GetID()==skillcharaid then
				myself:_SetBagItems(0)
			end
		elseif "SkillCharaEquipItems"==str then
			local skillcharaid = StringHelp:StringToInt(str1)
			local mainActor = PX2_PROJ:GetScene():GetMainActor()
			if mainActor and mainActor:GetID()==skillcharaid then
				myself:_RefreshMe(skillcharaid)
				myself:_RefreshQuickBarItemSkill(skillcharaid)
			end
		elseif "SkillCharaSetQuickBarItems"==str then
			local skillcharaid = StringHelp:StringToInt(str1)
			local mainActor = PX2_PROJ:GetScene():GetMainActor()
			if mainActor and mainActor:GetID()==skillcharaid then
				myself:_RefreshQuickBarItem(skillcharaid)
			end
		elseif "SkillCharaItemUpdate"==str then
			local stk = StringTokenizer(str1, "_")
			if 2==stk:Count() then
				local charaid = StringHelp:StringToInt(stk:GetAt(0))
				local itemid = StringHelp:StringToInt(stk:GetAt(1))

				local mainActor = PX2_PROJ:GetScene():GetMainActor()
				if mainActor and mainActor:GetID()==charaid then
					myself:_RefreshItemUI(charaid, itemid)
				end
			end
		elseif "SkillCharaMessage"==str then
			local stk = StringTokenizer(str1, "_")
			if 2==stk:Count() then
				local charaid = StringHelp:StringToInt(stk:GetAt(0))
				local message = stk:GetAt(1)
				print("charaid:"..charaid.." message:"..message)
				local scene = PX2_PROJ:GetScene()
            	if scene then
					local actor = scene:GetActorFromMap(charaid)
                	if actor then
						local ctrl ,scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_chara")
						if scCtrl then
							scCtrl:_CheckViewMode(message)
						end
					end
				end
			end
		elseif "calterrain"==str then
			myself:_CalTerrainGis()
		elseif "HumanTakeProcessd"==str then
			local id = tonumber(str1)
			myself:_UITakeCtrlActor(id)
		elseif "TerrainHeightUpdateMePos"==str then
			myself:_OnTerrainHeightUpdateMePos()
		elseif "ActorComeInMe"==str then
			myself:_UpdateScemeNav() 
		elseif "UIFirstView"==str then
			print("UIFirstView"..str1)
			myself:_UIFirstView(str1)
		elseif "UIAim"==str then
			print("UIAim"..str1)
			myself:_UIAim(str1)
		elseif "trigger"==str then
			print("trigger--------------------")

			if g_manykit._systemControlMode==1 then

				local pos0 = PX2_GH:GetSpaceInputFrom()
				local post = PX2_GH:GetSpaceInputTo()
				local dir = PX2_GH:GetSpaceInputDirection()
				
				local pos1 = pos0 + dir * 5000.0

				local pointslast = {}
				pointslast.points = {}

				local pt0 = {
					t = 0.0,
					x = post:X(),
					y = post:Y(),
					z = post:Z(),
				}
				table.insert(pointslast.points, #pointslast.points + 1, pt0)
				local pt1 = {
					t = 5000,
					x = pos1:X(),
					y = pos1:Y(),
					z = pos1:Z(),
				}
				table.insert(pointslast.points, #pointslast.points + 1, pt1)

				local jstr = PX2JSon.encode(pointslast)
				
				local scene = PX2_PROJ:GetScene()
				if scene then
					local mainActor = scene:GetMainActor()
					local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(mainActor, "p_chara")
					if scCtrl then    
						local skillChara = mainActor:GetSkillChara()
						local defSkill = skillChara:GetDefSkill()
						if defSkill then
							defSkill:MainActivateSkillInstance(true, jstr, false, "",  true, false, true)
						end
					end
				end
			else
				local scene = PX2_PROJ:GetScene()
				if scene then
					local mainActor = scene:GetMainActor()
					local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(mainActor, "p_chara")
					if scCtrl then    
						local skillChara = mainActor:GetSkillChara()
						local defSkill = skillChara:GetDefSkill()
						if defSkill then
							defSkill:MainActivateSkillInstance(true)
						end
					end
				end
			end
		elseif "SkillTarget"==str then
			print("SkillTarget")
			local stk = StringTokenizer(str1, "_")

			local fromcharaid = 0 
			local fromskilltypeid = 0
			local fromskilltypeStr = ""
			local toCharaID = 0
			local toCharaCollideID = 0
			local toCharaCollideStr = ""
			local tonum = 0

			if stk:Count()==2 then
				local charaidstr = stk:GetAt(0)
				local skilltypeidstr = stk:GetAt(1)

				local charaid = StringHelp:StringToInt(charaidstr)
				local skilltypeid = StringHelp:StringToInt(skilltypeidstr)

				fromcharaid = charaid
				fromskilltypeid = skilltypeid

				print("charaid:"..charaid)
				print("skilltypeid:"..skilltypeid)

				local scene = PX2_PROJ:GetScene()
				local actor = scene:GetActorFromMap(charaid)
				if actor then
					local skillChara = actor:GetSkillChara()
					if skillChara then
						local skill = skillChara:GetSkillByTypeID(skilltypeid)
						if skill then
							local numST = skill:GetNumLastSkillTargets()
							print("GetNumLastSkillTargets:"..numST)
							for i=0,numST-1, 1 do
								local st = skill:GetLastSkillTarget(i)
								if st then
									toCharaID = st.CharaID
									toCharaCollideID = st.CharaCollideID

									print("st CharaID:"..st.CharaID)
									print("st CharaCollideID:"..st.CharaCollideID)
								end
							end

							local defSkill = skill:GetDefSkill()
							if defSkill then
								fromskilltypeStr = defSkill.Title
							end

							local actorTo = scene:GetActorFromMap(toCharaID)
							if actorTo then
								local skillCharaTo = actorTo:GetSkillChara()
								if skillCharaTo then
									local defModel = skillCharaTo:GetDefModel()
									if defModel then
										tonum = defModel:GetNumCollideNames()
										print(" defModel: "..tonum..","..defModel.ID)
										for i = 0,tonum-1,1 do
											local outCollideName = defModel:GetCollideName(i)
											print(" "..i..": "..outCollideName)
										end

										local firstID = defModel:GetCollideID(0)
										if firstID>=0 then			
											local targetNum = toCharaCollideID - firstID
											local targetCollideName = defModel:GetCollideName(targetNum)
											toCharaCollideStr = targetCollideName
										else
											toCharaCollideStr = "NoName"
										end
									end
								end
							end

						end
					end
				end
			end
			coroutine.wrap(function()
				local frame = self._frameFire:GetObjectByID(1011)
				local fText = self._frameFire:GetObjectByID(1033)

				if frame and fText and self._frameInInFireT then
					local fireTransStr = ""
					if toCharaCollideStr ~= "" then 
						print("toCharaCollideStr:"..toCharaCollideStr)
						local ts = self._fireTrans[toCharaCollideStr]
						if ts then
							print(" _fireTrans: "..ts)
							fireTransStr = ts
						else
							print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ts is null")
						end
					end

					local fireText1 = "fire: "..fromcharaid.."["..fromskilltypeStr.."]".."--->"..toCharaID.."["..toCharaCollideID..":"..fireTransStr.."]"
					fText:GetText():SetText(fireText1)
					local fireText11 = "fire: \nFrom: "..fromcharaid.."["..fromskilltypeStr.."]".."\nTo: "..toCharaID.."["..toCharaCollideID..":"..fireTransStr.."]"
					self._frameInInFireT:GetText():SetText(fireText11)
					frame:Show(true)

					sleep(2.0)

					local fireText2 = ""
					fText:GetText():SetText(fireText2)
					self._frameInInFireT:GetText():SetText(fireText2)
					frame:Show(false)					
				end
			end)()
		elseif "sandbox"==str then
			myself:_SandBox("1" == str1, true)
		elseif "voicectrl_hotcamera"==str then
			myself:_UseCameraHot("1" == str1)
		elseif "handgesture_change"==str then
			local gesture = ""
			local ht = 0
			if "left"==str1 then
				ht = HT_LEFT
				gesture = PX2_INPUTM:GetHandGesture(HT_LEFT)
			elseif "right"==str1 then
				ht = HT_RIGHT
				gesture = PX2_INPUTM:GetHandGesture(HT_RIGHT)
			end

			myself:_HandGestureChange(ht, gesture)
		end
	end)

	RegistEventObjectFunction("EditorEventSpace::SelectTerrainPage", self, function(myself)
		print("SelectTerrainPage")

		local selectedPage = PX2_EDIT:GetTerrainEdit():GetBrush():GetSelectedPage()
		if selectedPage then
			local name = selectedPage:GetName()
			print("name:"..name)

			self._terSelectInfo = name

			local texProcess = PX2_EDIT:GetTerrainEdit():GetTextureProcess()
			local u = texProcess:GetSelectLayerUVRepeatU()
			local v = texProcess:GetSelectLayerUVRepeatV()
			self._terTexRepeatU = u
			self._terTexRepeatV = v

			self._scriptControl:BeginPropertyCata("Edit")
			self._scriptControl:AddPropertyClass("TerEdit", "编辑")
			self._scriptControl:AddPropertyString("TerSelectInfo", "选择信息", self._terSelectInfo, true, false)
			self._scriptControl:AddPropertyFloatSlider("TerUVRepeatU", "重复U", self._terTexRepeatU, 1.0, 100.0, true, false)
			self._scriptControl:AddPropertyFloatSlider("TerUVRepeatV", "重复V", self._terTexRepeatV, 1.0, 100.0, true, false)
			self._scriptControl:EndPropertyCata()

			self._propertyGridEdit:UpdateOnObject(self._scriptControl, "Edit", "TerSelectInfo")	
			self._propertyGridEdit:UpdateOnObject(self._scriptControl, "Edit", "TerUVRepeatU")
			self._propertyGridEdit:UpdateOnObject(self._scriptControl, "Edit", "TerUVRepeatV")		
		end
	end)

	local net = p_net._g_net
	if net then
		net:_CreateNetNC_APP()
		net:_SetUINAndSendComeInRoom(g_manykit._uin)
	end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateContentFrame()
	print(self._name.." p_mworld:_CreateContentFrame")

	local frame = UIFrame:New()
    self._frame:AttachChild(frame)
	frame:LLY(-20.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

	local frameUI = self:_CreateUI()
	self._frameUI = frameUI
	self._frame:AttachChild(frameUI)
	frameUI:SetAnchorHor(0.0, 1.0)
    frameUI:SetAnchorVer(0.0, 1.0)
	frameUI:LLY(-30.0)

    local frameInspector = self:_CreateFrameInspector(-1, -1)
    self._frameInspector = frameInspector
    self._frame:AttachChild(frameInspector)
    frameInspector:LLY(-40.0)
    frameInspector:SetAnchorHor(1.0, 1.0)
    frameInspector:SetPivot(1.0, 0.5)
    frameInspector:SetWidth(g_manykit._inspectorWidth)
    frameInspector:SetAnchorVer(0.0, 1.0)
    frameInspector:Show(false)

    local frameList = self:_CreateMapListFrame()
	self._frame:AttachChild(frameList)
	self._frameMapList = frameList
	frameList:LLY(-60)
	frameList:Show(false)

	local frameNoInput = self:_CreateFrameNoInput()
	if frameNoInput then
		frame:AttachChild(frameNoInput)
		self._frameNoInput = frameNoInput
		frameNoInput:LLY(-28.0)
		frameNoInput:Show(false)
	end	
end
-------------------------------------------------------------------------------
function p_mworld:_imgpthmworld(pth)
	local pth0 = "scripts/lua/plugins/p_mworld/images/"..pth
	return pth0
end
-------------------------------------------------------------------------------
function p_mworld:OnFixUpdate()
    if self._enable then
        local t = self._dt

        local scene = PX2_PROJ:GetScene()
        if scene then
            local terrain = scene:GetTerrain()
            if terrain then
                scene:SetTerrainViewDistance(self._viewdist_terrain)

                if p_net._g_net._islogicserver then
                    if not g_manykit._isUseViewDistance then
                        scene:SetTerrainViewDistance(0.0)
                    end 
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:OnUpdate()
	local scene = PX2_PROJ:GetScene()
	local nodeRoot = scene:GetNodeRoot()

	local camNodeRoot = scene:GetMainCameraNodeRoot()
	local angle = camNodeRoot.WorldTransform:GetRotateDegreeZ()
	if self._fPicCompassSub then
		self._fPicCompassSub.LocalTransform:SetRotateDegree(0,-angle,0)
	end

	local mainActor = scene:GetMainActor()

    if mainActor then
        if self._currentCatchObjectByID>0 and self._currentCatchObjectID>0 then				
            local actCatch = scene:GetActorFromMap(self._currentCatchObjectByID)
            local actCatched = scene:GetActorFromMap(self._currentCatchObjectID)
            if actCatch and actCatched then
                local ctrlCatch, scCtrlCatch = g_manykit_GetControllerDriverFrom(actCatch, "p_chara")
                local ctrlCatched, scCtrlCatched = g_manykit_GetControllerDriverFrom(actCatched, "p_chara")

                if scCtrlCatch and scCtrlCatched then
                    --local hdPos = scCtrlCatch:_HandPos()
                    if self._handTypeCatch>0 then
                        local handPos = PX2_INPUTM:GetHandPosion(self._handTypeCatch, 8)

                        local hpos = handPos
                        local uniScale = nodeRoot.WorldTransform:GetUniformScale()
                        if 1.0~=uniScale then
                            local transInverse = nodeRoot.WorldTransform:InverseTransform()
                            hpos = transInverse * handPos
                        end

                        scCtrlCatched._agent:SetPosition(hpos)
                    end
                end
            end
        end
    
        local pos = mainActor:GetAIAgent():GetPosition()
        if self._vs then
            self._vs:SetActorCenterPos(pos)
        end
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_mworld)
require("scripts/lua/plugins/p_mworld/p_mworldui.lua")
require("scripts/lua/plugins/p_mworld/p_mworlduibag.lua")
require("scripts/lua/plugins/p_mworld/p_mworlduiedit.lua")
require("scripts/lua/plugins/p_mworld/p_mworlduiscene.lua")
require("scripts/lua/plugins/p_mworld/p_mworlduibat.lua")
require("scripts/lua/plugins/p_mworld/p_mworlduiprogram.lua")

require("scripts/lua/plugins/p_mworld/p_mworldviewctrl.lua")

require("scripts/lua/plugins/p_mworld/p_mworldmap.lua")
require("scripts/lua/plugins/p_mworld/p_mworldpeople.lua")
require("scripts/lua/plugins/p_mworld/p_mworldactor.lua")
require("scripts/lua/plugins/p_mworld/p_mworldvoxel.lua")

require("scripts/lua/plugins/p_mworld/p_mworldscene.lua")
require("scripts/lua/plugins/p_mworld/p_mworldnet.lua")
require("scripts/lua/plugins/p_mworld/p_mworldnetprocess.lua")
require("scripts/lua/plugins/p_mworld/p_mworldnetserver.lua")

require("scripts/lua/plugins/p_mworld/p_mworldedit.lua")
require("scripts/lua/plugins/p_mworld/p_mworldblueprint.lua")
require("scripts/lua/plugins/p_mworld/p_mworldproperty.lua")
require("scripts/lua/plugins/p_mworld/p_mworldpropertyedit.lua")
require("scripts/lua/plugins/p_mworld/p_mworldpropertyserver.lua")
require("scripts/lua/plugins/p_mworld/p_mworldterrain.lua")
require("scripts/lua/plugins/p_mworld/p_mworldsimu.lua")
require("scripts/lua/plugins/p_mworld/p_mworldsimuplay.lua")
require("scripts/lua/plugins/p_mworld/p_mworldmr.lua")
require("scripts/lua/plugins/p_mworld/p_mworldtool.lua")
-------------------------------------------------------------------------------
