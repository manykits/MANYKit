-- p_mworldproperty.lua

-------------------------------------------------------------------------------
function p_mworld:_GetPropertyValueOfSceneObject(obj)
    print(self._name.." p_mworld:_GetPropertyValueOfSceneObject")

    local scene = PX2_PROJ:GetScene()
    local terrain = scene:GetTerrain()

    -- sky
    self._sunmoonparam0 = obj:PFloat("SunMoonParam0")
    self._sunmoonparam1 = obj:PFloat("SunMoonParam1")
    self._sunmoonparam2 = obj:PFloat("SunMoonParam2")
    self._sunmoonparam3 = obj:PFloat("SunMoonParam3")

    self._isusesky = obj:PBool("UseSky")
    self._skytechindex = obj:PInt("SkyTechIndex")

    -- terrain
    self._terrainMode = obj:PInt("TerrainMode")

    self._startlong = obj:PString("StartLong")
    self._endlong = obj:PString("EndLong")
    self._startlat = obj:PString("StartLat")
    self._endlat = obj:PString("EndLat")
    self._maplength = obj:PFloat("MapLength")
    self._mapwidth = obj:PFloat("MapWidth")

    self._terNumNavGridIndex = obj:PInt("TerNumNavGridIndex")

    if obj:GetPropertyByName("IsLightModeEasy") then
        self._islightmodeeasy = obj:PBool("IsLightModeEasy")
    end

    if self._terrainMode==Terrain.TM_GIS then
        self._gisZoom = obj:PInt("GisZoom")
    elseif self._terrainMode==Terrain.TM_GISING then
        if terrain then
            self._gisZoom = terrain:GetGisZoom()
        end
    end

    self._heightscale = obj:PFloat("TerrainHeightScale")

    self._gisTexturePath = obj:PString("GisTexturePath")
    self._gisHeightPath = obj:PString("GisHeightPath")

    self._gisTextureMinZoom = obj:PInt("GisTextureMinZoom")
    self._gisTextureMaxZoom = obj:PInt("GisTextureMaxZoom")

    self._gisHeightMinZoom = obj:PInt("GisHeightMinZoom")
    self._gisHeightMaxZoom = obj:PInt("GisHeightMaxZoom")

    self._gisHeightMinNotZero = obj:PFloat("HeightMinNotZero")
    self._gisCameraMinus = obj:PFloat("CameraGisingMinus")

    self._gisPosOffsetX = obj:PFloat("GisPosOffsetX")
    self._gisPosOffsetY = obj:PFloat("GisPosOffsetY")

    self._gotoOffset = obj:PFloat("GoToOffset", 0.2)
    if self._gotoOffset<=0.0 then
        self._gotoOffset = 0.1
    end

    self._gisZoomScale = obj:PFloat("GisZoomScale", 1.0)
    self._gisFixGisZoomMinus = obj:PInt("GisFixGisZoomMinus", -1)

    self._isterrainuselod = obj:PBool("IsTerrainLOD")
    self._terrainLODTolerance = obj:PFloat("TerrainLODTolerance")
    self._isTerrainLODCloseAssumption = obj:PBool("TerrainIsCloseAssumption")

    self._isUseTerrain = obj:PBool("IsUseTerrain",  self._isUseTerrain)
    self._isTerrainonlyObst = obj:PBool("IsTerrainOnlyObst", self._isTerrainonlyObst)
    
    self._terrainpath = obj:PString("TerrainPath", self._terrainpath)
    self._terrainmd5 = obj:PString("TerrainMD5", self._terrainmd5)
    self._terrainzipmd5 = obj:PString("TerrainZIPMD5", self._terrainzipmd5)

    -- camera
    p_holospace._g_cameraFov = obj:PFloat("VFov")    
    p_holospace._g_renderStyle = obj:PInt("RenderStyle")

    -- time
    self._time = obj:PFloat("Time")
    self._ambient = obj:PFloat("Ambient")
    self._diffuse = obj:PFloat("Diffuse")
    self._specular = obj:PFloat("Specular")

    if obj:GetPropertyByName("HotEmissive") then
        self._hotemissive = obj:PFloat("HotEmissive")
        self._hotambient = obj:PFloat("HotAmbient")
        self._hotemissiveterrain = obj:PFloat("HotEmissiveTerrain")
        self._hotambientterrain = obj:PFloat("HotAmbientTerrain")
    end

    self._fog_far = obj:PFloat("Fog_Far")
    self._fog_near = obj:PFloat("Fog_Near")
    self._fog_color = obj:PFloat("Fog_Color")
    self._wind = obj:PFloat("Wind")
    self._rain = obj:PFloat("Rain")
    self._snow = obj:PFloat("Snow")
    self._thunder = obj:PFloat("Thunder")
    self._cloudclip = obj:PFloat("CloudClip")

    self._moontype = obj:PInt("MoonType")
    self._moon = obj:PFloat("Moon")
    self._star = obj:PFloat("Star")

    -- view dist
    self._viewdist_terrain = obj:PFloat("ViewDistanceTerrain")
    p_holospace._g_viewdist_objects = obj:PFloat("ViewDistanceObjects")
    p_holospace._g_viewdist_objects_lod = obj:PFloat("ViewDistanceObjectsLOD")

    -- voxel
    self._isUseVoxel = obj:PBool("IsUseVoxel")

    -- bloom
    self._isUseBloom = obj:PBool("IsUseBloom")
    self._bloomParam = obj:PFloat4("Bloom")

    -- sandbox
    self._sandBoxUse = obj:PBool("SandBoxUse", self._sandBoxUse)
    self._sandBoxScale = obj:PFloat("SandBoxScale", self._sandBoxScale)
    self._sandBoxPosX = obj:PFloat("SandBoxPosX", self._sandBoxPosX)
    self._sandBoxPosY = obj:PFloat("SandBoxPosY", self._sandBoxPosY)
    self._sandBoxPosZ = obj:PFloat("SandBoxPosZ", self._sandBoxPosZ)
    self._sandBoxRot = obj:PFloat("SandBoxRot", self._sandBoxRot )

    -- hot
    self._hotUse = obj:PBool("HotUse", self._hotUse)

    -- nav
    self._navigationType = obj:PInt("NavType", self._navigationType)
end
-------------------------------------------------------------------------------
function p_mworld:_SetTerrainProperty(ter)
    local terrain = nil
    if ter then
        terrain = ter
    else
        local scene =PX2_PROJ:GetScene()
        terrain = scene:GetTerrain()
    end

    if terrain then
        terrain:SetUseLOD(self._isterrainuselod)
        
        terrain:SetPixelTolerance(self._terrainLODTolerance)
        terrain:SetCloseAssumption(self._isTerrainLODCloseAssumption)
        terrain:SetTerrainMode(self._terrainMode)

        if self._terrainMode==Terrain.TM_GIS then
            terrain:SetGisZoom(self._gisZoom)
        end

        terrain:SetGisTexturePath(self._gisTexturePath)
        terrain:SetGisHeightPath(self._gisHeightPath)

        terrain:SetGisTextureMinZoom(self._gisTextureMinZoom)
        terrain:SetGisTextureMaxZoom(self._gisTextureMaxZoom)

        terrain:SetGisHeightMinZoom(self._gisHeightMinZoom)
        terrain:SetGisHeightMaxZoom(self._gisHeightMaxZoom)

        terrain:SetHeightMinNotZero(self._gisHeightMinNotZero)
        terrain:SetCameraGisingMinus(self._gisCameraMinus)

        terrain:SetGisZoomCalScale(self._gisZoomScale)
        terrain:SetFixGisZoomMinus(self._gisFixGisZoomMinus)

        local sl = StringHelp:StringToFloat(self._startlong)
        local el = StringHelp:StringToFloat(self._endlong)
        local slat = StringHelp:StringToFloat(self._startlat)
        local elat = StringHelp:StringToFloat(self._endlat)
        terrain:SetLonLatMap(sl, el, slat, elat)

        local rsTer = 0
        rsTer = p_holospace._g_renderStyle
        if rsTer==3 then
            rsTer=2
        end

        terrain:SetRenderStyle(rsTer, true)
        terrain:SetCastShadow(false)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RegistPropertyOnScene()
    print(self._name.." p_mworld:_RegistPropertyOnScene")

    self:_RegistSceneProperiesFromValue()

    local scene = PX2_PROJ:GetScene()
    if scene and self._propertyGrid then    
        self._propertyGrid:RegistOnObject(scene, "Scene")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RegistSceneProperiesFromValue()
    print(self._name.." p_mworld:_RegistSceneProperiesFromValue")

    local scene = PX2_PROJ:GetScene()
    if scene then        
        local id = scene:GetID()
        local terrain = scene:GetTerrain()
        local minusing = 0.0
        if terrain then
             self._gisHeightMinNotZeroing = terrain:GetHeightMinNotZeroing()
             self._gisHeightMaxing = terrain:GetHeightMaxing()
             self._gisCameraMinus = terrain:GetCameraGisingMinus()
             minusing = terrain:GetFixGisZoomMinusing()
             self._gisZoom = terrain:GetGisZoom()
        end

        scene:RemoveProperties("Scene")

        scene:BeginPropertyCata("Scene")

        scene:AddPropertyClass("Scene", "场景")
        scene:AddPropertyInt("SceneID", "MapID", id, false, true)
 
        scene:AddPropertyInt("UIN", "UIN", g_manykit._uin, false, false)

        scene:AddPropertyString("StartLong", "开始经度", self._startlong, true, true)
        scene:AddPropertyString("EndLong", "结束经度", self._endlong, true, true)
        scene:AddPropertyString("StartLat", "开始纬度", self._startlat, true, true)
        scene:AddPropertyString("EndLat", "结束纬度", self._endlat, true, true)
        scene:AddPropertyFloat("MapLength", "地图长度", self._maplength, true, true)
        scene:AddPropertyFloat("MapWidth", "地图宽度", self._mapwidth, true, true)
        scene:AddPropertyButton("CalMapSize", "计算地图大小")
        scene:AddPropertyClass("View", "视觉")                
        scene:AddPropertyFloatSlider("VFov", "垂直FOV", p_holospace._g_cameraFov, 5.0, 120.0, true, true)

        PX2Table2Vector({"光照", "实时阴影", "法线贴图", "PBR"})
        local vec = PX2_GH:Vec()
        PX2Table2Vector({"Lighting", "Shadow", "Normal", "PBR"})
        local vec1 = PX2_GH:Vec()
        PX2Table2Vector({})
        local vec2 = PX2_GH:Vec()
        scene:AddPropertyEnumUserData("RenderStyle", "渲染样式", p_holospace._g_renderStyle, vec, vec1, vec2, true, true) 
        
        scene:AddPropertyClass("Light", "光线")        
        scene:AddPropertyBool("IsLightModeEasy", "简易模式", self._islightmodeeasy, true, true)

        scene:AddPropertyFloatSlider("Time", "时间", self._time, 0.0, 24.0, true, true)
        scene:AddPropertyFloatSlider("Ambient", "环境光", self._ambient, 0.0, 5.0, true, true)
        scene:AddPropertyFloatSlider("Diffuse", "漫反射", self._diffuse, 0.0, 10.0, true, true)
        scene:AddPropertyFloatSlider("Specular", "镜面反射", self._specular, 0.0, 5.0, true, true)

        scene:AddPropertyFloatSlider("HotEmissive", "热成像自发", self._hotemissive, 0.0, 3.0, true, true)
        scene:AddPropertyFloatSlider("HotAmbient", "热成像环境", self._hotambient, 0.0, 3.0, true, true)
        scene:AddPropertyFloatSlider("HotEmissiveTerrain", "热成像地形自发", self._hotemissiveterrain, 0.0, 3.0, true, true)
        scene:AddPropertyFloatSlider("HotAmbientTerrain", "热成像地形环境", self._hotambientterrain, 0.0, 3.0, true, true)

        scene:AddPropertyClass("Weather", "天气")--天气1
        scene:AddPropertyFloatSlider("Fog_Far", "雾-远", self._fog_far, 1.0, 8000.0, true, true)
        scene:AddPropertyFloatSlider("Fog_Near", "雾-近", self._fog_near, 1.0, 100.0, true, true)
        scene:AddPropertyFloatSlider("Fog_Color", "雾-色", self._fog_color, 0.0, 1.0, true, true)
        scene:AddPropertyFloatSlider("Wind", "风", self._wind, 0.0, 1.0, true, true)
        scene:AddPropertyFloatSlider("Rain", "雨", self._rain, 0.0, 1.0, true, true)
        scene:AddPropertyFloatSlider("Snow", "雪", self._snow, 0.0, 1.0, true, true)
        scene:AddPropertyFloatSlider("Thunder", "雷", self._thunder, 0.0, 1.0, true, true)

        scene:AddPropertyClass("Sky", "天空")
        scene:AddPropertyBool("UseSky", "显示", self._isusesky, true, true)

        PX2Table2Vector({"sky", "sky_sunmoon"})
        scene:AddPropertyEnum("SkyTechIndex", "天空材质", self._skytechindex, PX2_GH:Vec(), true, true)

        scene:AddPropertyFloatSlider("SunMoonParam0", "太阳内范围", self._sunmoonparam0, 0.0, 2048.0, true, true)
        scene:AddPropertyFloatSlider("SunMoonParam1", "太阳内比率", self._sunmoonparam1, 0.0, 1.0, true, true)
        scene:AddPropertyFloatSlider("SunMoonParam2", "太阳外范围", self._sunmoonparam2, 0.0, 1024.0, true, true)
        scene:AddPropertyFloatSlider("SunMoonParam3", "太阳外比率", self._sunmoonparam3, 0.0, 1.0, true, true)
        scene:AddPropertyFloatSlider("CloudClip", "云", self._cloudclip, 0.0, 1.0, true, true)
        
        PX2Table2Vector({ "新月", "峨眉月", "上弦月", "上凸月", "满月", "下凸月", "下弦月", "残月" })
        scene:AddPropertyEnum("MoonType", "月亮", self._moontype, PX2_GH:Vec(), true, true)
        scene:AddPropertyFloatSlider("Moon", "月亮亮度", self._moon, 0.0, 1.0, true, true)
        scene:AddPropertyFloatSlider("Star", "星星", self._star, 0.0, 1.0, true, true)

        scene:AddPropertyClass("Terrain", "地形")
        scene:AddPropertyBool("IsUseTerrain", "使用", self._isUseTerrain, true ,true)
        PX2Table2Vector({"Normal", "Gis", "Gising"})
        scene:AddPropertyEnum("TerrainMode", "地形模式", self._terrainMode, PX2_GH:Vec(), true, true)

        scene:AddPropertyString("TerrainPath", "TerrainPath", self._terrainpath, false, true)
        scene:AddPropertyString("TerrainMD5", "MD5", self._terrainmd5, false, true)
        scene:AddPropertyString("TerrainZIPMD5", "ZIPMD5", self._terrainzipmd5, false, true)

        if self._isUseTerrain then
            scene:AddPropertyClass("TerrainNormal", "地形-普通")
            scene:AddPropertyBool("IsTerrainLOD", "地形LOD", self._isterrainuselod, true ,true)
            scene:AddPropertyFloatSlider("TerrainLODTolerance", "地形LODTolerance", self._terrainLODTolerance, 0.0, 100.0, true, true)
            scene:AddPropertyBool("TerrainIsCloseAssumption", "地形IsCloseAss", self._isTerrainLODCloseAssumption, true ,true)
    
            scene:AddPropertyClass("TerrainGis", "地形-Gis")
            scene:AddPropertyString("GisTexturePath", "GisTexturePath", self._gisTexturePath, true ,true)
            scene:AddPropertyInt("GisTextureMinZoom", "纹理最小级别", self._gisTextureMinZoom, true ,true)
            scene:AddPropertyInt("GisTextureMaxZoom", "纹理最大级别", self._gisTextureMaxZoom, true ,true)
            scene:AddPropertyString("GisHeightPath", "GisHeightPath", self._gisHeightPath, true ,true)
            scene:AddPropertyInt("GisHeightMinZoom", "高程最小级别", self._gisHeightMinZoom, true ,true)
            scene:AddPropertyInt("GisHeightMaxZoom", "高程最大级别", self._gisHeightMaxZoom, true ,true)
            scene:AddPropertyFloat("HeightMinNotZeroing", "最低高度", self._gisHeightMinNotZeroing, false ,false)
            scene:AddPropertyFloat("HeightMax", "最大高度", self._gisHeightMaxing, false ,false)
            scene:AddPropertyFloat("HeightMinNotZero", "自设定底高度", self._gisHeightMinNotZero, true, true)
    
            scene:AddPropertyClass("TerrainGisStatic", "地形-Gis-静态")
            scene:AddPropertyInt("GisZoom", "GisZoom", self._gisZoom, true ,true)
            scene:AddPropertyButton("CalGis", "计算静态Gis地形")
    
            scene:AddPropertyClass("TerrainGisDynamic", "地形-Gis-动态")
            scene:AddPropertyFloat("CameraGisingMinus", "计算层级减相机高低", self._gisCameraMinus, true ,true)
            scene:AddPropertyFloat("GisZoomScale", "GisZoom高度缩放", self._gisZoomScale, true, true)
            scene:AddPropertyInt("GisFixGisZoomMinus", "GisingZoom固定跨越", self._gisFixGisZoomMinus, true, true)
            scene:AddPropertyInt("GisFixGisZoomMinusing", "GisingZoom跨越", minusing, false ,false)
        end

        scene:AddPropertyClass("Navgation", "导航")
        scene:AddPropertyBool("IsShowNav", "显示", self._isShowNav, true, true)
        
        PX2Table2Vector({"None", "Grid", "Mesh"})
        scene:AddPropertyEnum("NavType", "类型", self._navigationType, PX2_GH:Vec(), true, true)

        PX2Table2Vector({"25", "50", "75", "100", "125", "150", "175", "200"})
        local vec = PX2_GH:Vec()
        PX2Table2Vector({"25", "50", "75", "100", "125", "150", "175", "200"})
        local vec1 = PX2_GH:Vec()
        PX2Table2Vector({})
        local vec2 = PX2_GH:Vec()
        scene:AddPropertyEnumUserData("TerNumNavGridIndex", "2D导航网格数量", self._terNumNavGridIndex, vec, vec1, vec2, true, true) 

        scene:AddPropertyButton("UpdateNavGrid", "更新导航网格")
       
        scene:AddPropertyClass("Voxel", "体素")
        scene:AddPropertyBool("IsUseVoxel", "使用体素", self._isUseVoxel, true ,true)

        -- scene:AddPropertyClass("ViewDistance", "视距")
        -- scene:AddPropertyFloatSlider("ViewDistanceTerrain", "地形", self._viewdist_terrain, 0.0, 2000.0, true, true)
        -- scene:AddPropertyFloatSlider("ViewDistanceObjects", "物体", p_mworld._g_viewdist_objects, 0.0, 2000.0, true, true)
        -- scene:AddPropertyFloatSlider("ViewDistanceObjectsLOD", "物体细节", p_mworld._g_viewdist_objects_lod, 0.0, 2000.0, true, true)

        scene:AddPropertyClass("Rendering", "渲染")
        scene:AddPropertyBool("IsUseBloom", "使用Bloom", self._isUseBloom, true, true)
        scene:AddPropertyFloat4("Bloom", "Bloom", self._bloomParam, true, true)        

        scene:AddPropertyClass("SandBox", "沙盘")
        scene:AddPropertyBool("SandBoxUse", "使用", self._sandBoxUse, true ,true)
        scene:AddPropertyFloatSlider("SandBoxScale", "缩放", self._sandBoxScale, 0.005, 0.1, true, true)
        scene:AddPropertyFloatSlider("SandBoxPosX", "位移X", self._sandBoxPosX, -5.0, 5.0, true, true)
        scene:AddPropertyFloatSlider("SandBoxPosY", "位移Y", self._sandBoxPosY, -5.0, 5.0, true, true)
        scene:AddPropertyFloatSlider("SandBoxPosZ", "位移Z", self._sandBoxPosZ, -1.0, 2.0, true, true)
        scene:AddPropertyFloatSlider("SandBoxRot", "旋转", self._sandBoxRot, 0.0, 360.0, true, true)

        scene:AddPropertyClass("Hot", "热成像")
        scene:AddPropertyBool("HotUse", "使用", self._hotUse, true ,true)

        scene:EndPropertyCata()
    end
end
-------------------------------------------------------------------------------
function p_mworld:_PropertyValueSceneGetFromProps(mid, props)    
    if mid == self._curmapid then
        for k, val in pairs(props) do
            local v = val.v
            local t = val.t
            local n = val.n
            local tn = val.tn

            if "TerNumNavGridIndex"==n then
                self._terNumNavGridIndex = StringHelp:SToI(v)
            elseif "VFov"==n then
                p_holospace._g_cameraFov = StringHelp:SToF(v)
            elseif "RenderStyle"==n then
                p_holospace._g_renderStyle = StringHelp:SToI(v)
            elseif "IsUseTerrain"==n then
                self._isUseTerrain = StringHelp:SToB(v)
            elseif "IsTerrainOnlyObst"==na then
                self._isTerrainonlyObst = StringHelp:SToB(v)
            elseif "TerrainMD5"==na then
                self._terrainmd5 = v
            elseif "TerrainZIPMD5"==na then
                self._terrainzipmd5 = v
            elseif "Time"==n then
                self._time = StringHelp:SToF(v)
            elseif "Ambient"==n then
                self._ambient = StringHelp:SToF(v)
            elseif "Diffuse"==n then
                self._diffuse = StringHelp:SToF(v)
            elseif "Specular"==n then
                self._specular = StringHelp:SToF(v)
            elseif "HotEmissive"==n then
                self._hotemissive = StringHelp:SToF(v)
            elseif "HotAmbient"==n then
                self._hotambient = StringHelp:SToF(v)
            elseif "HotEmissiveTerrain"==n then
                self._hotemissiveterrain = StringHelp:SToF(v)
            elseif "HotAmbientTerrain"==n then
                self._hotambientterrain = StringHelp:SToF(v)
            elseif "Fog_Far"==n then
                self._fog_far = StringHelp:SToF(v)
            elseif "Fog_Near"==n then
                self._fog_near = StringHelp:SToF(v)
            elseif "Fog_Color"==n then
                self._fog_color = StringHelp:SToF(v)
            elseif "Wind"==n then
                self._wind = StringHelp:SToF(v)
            elseif "Rain"==n then
                self._rain = StringHelp:SToF(v)
            elseif "Snow"==n then
                self._snow = StringHelp:SToF(v)
            elseif "Thunder"==n then
                self._thunder = StringHelp:SToF(v)
            elseif "CloudClip"==n then
                self._cloudclip = StringHelp:SToF(v)
            elseif "SunMoonParam0"==n then
                self._sunmoonparam0 = StringHelp:SToF(v)
            elseif "SunMoonParam1"==n then
                self._sunmoonparam1 = StringHelp:SToF(v)
            elseif "SunMoonParam2"==n then
                self._sunmoonparam2 = StringHelp:SToF(v)
            elseif "SunMoonParam3"==n then
                self._sunmoonparam3 = StringHelp:SToF(v)
            elseif "skytechindex"==n then
                self._skytechindex = StringHelp:SToI(v)
            elseif "UseSky"==n then
                self._isusesky = StringHelp:SToB(v)
            elseif "ViewDistanceTerrain"==n then
                self._viewdist_terrain = StringHelp:SToF(v)
            elseif "ViewDistanceObjects"==n then
                p_mworld._g_viewdist_objects = StringHelp:SToF(v)
            elseif "ViewDistanceObjectsLOD"==n then
                p_mworld._g_viewdist_objects_lod = StringHelp:SToF(v)
            elseif "MoonType"==n then
                self._moontype = StringHelp:SToI(v)
            elseif "Moon"==n then
                self._moon = StringHelp:SToF(v)
            elseif "Star"==n then
                self._star = StringHelp:SToF(v)
            elseif "SandBoxScale"==n then
                self._sandBoxScale = StringHelp:SToF(v)
            elseif "SandBoxPosX"==n then
                self._sandBoxPosX = StringHelp:SToF(v)
            elseif "SandBoxPosY"==n then
                self._sandBoxPosY = StringHelp:SToF(v)
            elseif "SandBoxPosZ"==n then
                self._sandBoxPosZ = StringHelp:SToF(v)
            elseif "SandBoxRot"==n then
                self._sandBoxRot = StringHelp:SToF(v)
            elseif "IsUseTerrain"==n then
                self._isUseTerrain = StringHelp:SToB(v)
            elseif "IsUseVoxel"==n then
                self._isUseVoxel = StringHelp:SToB(v)
            elseif "IsTerrainLOD"==n then
                self._isterrainuselod = StringHelp:SToB(v)
            elseif "TerrainLODTolerance"==n then
                self._terrainLODTolerance = StringHelp:SToF(v)
            elseif "TerrainIsCloseAssumption"==n then
                self._isTerrainLODCloseAssumption = StringHelp:SToB(v)
            elseif "SandBoxUse"==n then
                self._sandBoxUse = StringHelp:SToB(v)
            elseif "HotUse"==n then
                self._hotUse = StringHelp:SToB(v)
            elseif "NavType"==n then
                self._navigationType = StringHelp:SToI(v)
            elseif "IsShowNav"==n then
                self._isShowNav = StringHelp:SToB(v)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_PropertyValueActivate(propname)
	print(self._name.." p_mworld:_PropertyValueActivate")

    if propname then
        print("propname:"..propname)
    else
        print("propname is nil")
    end

    local scene = PX2_PROJ:GetScene()
    if scene then
        print("RenderStyle")
        print(p_holospace._g_renderStyle)

        if nil==propname then
            PX2_GH:SendGeneralEvent("RenderStyle", p_holospace._g_renderStyle)
        elseif propname and "RenderStyle"==propname then
            PX2_GH:SendGeneralEvent("RenderStyle", p_holospace._g_renderStyle)
            return
        end

        local ambctrl = scene:GetAmbientRegionController()
        if ambctrl then
            -- time
            self:_SetTime(self._time)
            
            if self._islightmodeeasy then
            else
                self:_SetLightParam(self._ambient, self._diffuse, self._specular)
            end

            -- fog
            print("fog_near:"..self._fog_near)
            print("fog_far:"..self._fog_far)

            ambctrl:SetFogParamDistance(Float2(self._fog_near, self._fog_far))
            local c = Float3(self._fog_color, self._fog_color, self._fog_color)
            ambctrl:SetFogColorDistance(c)

            local ac = ambctrl:GetAmbientColor()
            local dc = ambctrl:GetDiffuseColor()

            -- weather
            local nodeWeather = scene:GetObjectByID(p_holospace._g_IDNodeWeather)
            if nodeWeather then
                -- wind
                local soundWind = nodeWeather:GetObjectByName("SoundWind")
                local soundableWind = Cast:ToSoundable(soundWind)
                if soundableWind then  
                    if self._wind < 0.1 then
                        soundableWind:Pause()
                    else
                        local v = (self._wind - 0.1)/0.9
                        soundableWind:SetVolume(v)    
                        soundableWind:Play()
                    end
                end

                -- thunder
                local soundThunder = nodeWeather:GetObjectByName("SoundThunder")
                local soundableThunder = Cast:ToSoundable(soundThunder)
                if soundableThunder then
                    if self._thunder < 0.1 then
                        soundableThunder:Pause()
                    else
                        soundableThunder:Play()
    
                        local tMin = 12.0  - 5.0 * (self._thunder - 0.1)/0.9
                        local tMax = tMin + 5.0
                        soundableThunder:SetRandomSeconds(tMin, tMax)
    
                        local v = 0.2 + (self._thunder - 0.1)/0.9 * 0.8
                        soundableThunder:SetRandomVolume(v, v+0.3)
                    end
                end

                -- rain
                local rainO = nodeWeather:GetObjectByName("Rain")
                local pe = Cast:ToParticleEmitter(rainO)
                if pe then
                    local rt = 200  + 800 * self._rain
                    pe:SetEmitRate(rt)
    
                    local szX = 0.8 + 1.0 * self._rain
                    local speed = 6 + 5 * self._rain
    
                    pe:SetEmitSizeX(szX)
                    pe:SetEmitSizeY(szX*0.2)
                    pe:SetEmitSpeed(speed)
    
                    local alpha = 0.4 + 0.8 * self._rain
                    pe:SetEmitAlpha(alpha)    
                    local ec = Float3(dc:X() + ac:X() + 0.1, dc:Y() + ac:Y()+ 0.1, dc:Z() + ac:Z() + 0.1)
                    pe:SetEmitColor(ec)
                    if self._rain < 0.1 then
                        pe:Pause()
                    else
                        print("rain play")
                        pe:Play()
                    end
                end

                -- snow
                local snowO = nodeWeather:GetObjectByName("Snow")
                local peSN = Cast:ToParticleEmitter(snowO)
                if peSN then
                    local rt = 200  + 600 * self._snow
                    peSN:SetEmitRate(rt)
        
                    local sz = 0.1 + 0.5 * self._snow
                    peSN:SetEmitSizeX(sz)
                    peSN:SetEmitSizeY(sz)
        
                    local alpha = 0.4 + 0.8 * self._snow
                    peSN:SetEmitAlpha(alpha)
    
                    local ec = Float3(dc:X() + ac:X() + 0.1, dc:Y() + ac:Y()+ 0.1, dc:Z() + ac:Z() + 0.1)
                    if pe then
                        pe:SetEmitColor(dc)
                    end
        
                    if self._snow < 0.1 then
                        peSN:Pause()
                    else
                        peSN:Play()
                    end
                end                

                -- sound rain
                local soundableRainO = nodeWeather:GetObjectByName("SoundableRain")
                local soundableRain = Cast:ToSoundable(soundableRainO)
                if soundableRain then
                    if self._rain < 0.1 then
                        soundableRain:Pause()
                    else
                        soundableRain:Play()
                    end
    
                    if self._rain < 0.4 then
                        soundableRain:SetSoundFilename("common/media/audio/rain1.wav")
                        soundableRain:SetVolume(0.4)
                    elseif 0.4<=self._rain and self._rain < 0.7 then
                        soundableRain:SetSoundFilename("common/media/audio/rain2.wav")
                        soundableRain:SetVolume(0.7)
                    else
                        soundableRain:SetSoundFilename("common/media/audio/rain.ogg")
                        soundableRain:SetVolume(1.0)
                    end
                end

                -- moon
                local bdMoon = scene:GetBillboardMoon()
                if bdMoon then
                    local t = self._moontype
                    if 0==t then
                        bdMoon:SetTex("engine/sky/moon/0new.png")
                    elseif 1==t then
                        bdMoon:SetTex("engine/sky/moon/1waxingcrescent.png")
                    elseif 2==t then
                        bdMoon:SetTex("engine/sky/moon/2firstquarter.png")
                    elseif 3==t then
                        bdMoon:SetTex("engine/sky/moon/3waxinggibbous.png")
                    elseif 4==t then
                        bdMoon:SetTex("engine/sky/moon/4full.png")
                    elseif 5==t then
                        bdMoon:SetTex("engine/sky/moon/5waninggibbous.png")
                    elseif 6==t then
                        bdMoon:SetTex("engine/sky/moon/6lastquarter.png")
                    elseif 7==t then
                        bdMoon:SetTex("engine/sky/moon/7waningcrescent.png")
                    end
                    bdMoon:SetEmitAlpha(self._moon)
                    bdMoon:ResetPlay()
                    if self._moon < 0.1 then  
                        bdMoon:Show(false)
                    else
                        bdMoon:Show(true)
                    end
                end

                local movStar = scene:GetMovableStar()
                if movStar then
                    if self._star < 0.1 then
                        movStar:SetAlpha(self._star)
                        movStar:Show(false)
                        movStar:Pause()
                    else
                        movStar:SetAlpha(self._star)
                        movStar:Show(true)
                        movStar:ResetPlay()
                    end
                end

                local nodeSky = scene:GetObjectByID(p_holospace._g_IDNodeSky)
                local skyMeshO = nodeSky:GetObjectByName("SkyMesh")
                local skyMesh = Cast:ToSkyMesh(skyMeshO)
                if skyMesh then
                    skyMesh:SetCloudClip(self._cloudclip)
                    skyMesh:SetSunMoonParam(Float4(self._sunmoonparam0, self._sunmoonparam1, self._sunmoonparam2, self._sunmoonparam3))
                
                    if 0==self._skytechindex then
                        skyMesh:SetTechnique("sky")
                    elseif 1==self._skytechindex then
                        skyMesh:SetTechnique("sky_sunmoon")
                    elseif 2==self._skytechindex then
                        skyMesh:SetTechnique("sky_sunmoon1")
                    elseif 3==self._skytechindex then
                        skyMesh:SetTechnique("sky_sunmoon2")
                    elseif 4==self._skytechindex then
                        skyMesh:SetTechnique("sky_sunmoon3")
                    end
                end     
            end
        end

        scene:SetTerrainViewDistance(self._viewdist_terrain)

        local nodeTerrain = scene:GetObjectByID(p_holospace._g_IDNodeTerrain)
        if nodeTerrain then
            nodeTerrain:Show(self._isUseTerrain)
        end

        local terrain = scene:GetTerrain()
        if terrain then
           p_holospace._SetTerrainObst(terrain, self._isTerrainonlyObst)
        end

        local nodeSky = scene:GetNodeSky()
        if nodeSky then
            nodeSky:Show(self._isusesky)
        end

        self:_RefreshEnvParam()

        local navWorld = scene:GetAIAgentWorld()
        if navWorld then
            navWorld:SetNavigationType(self._navigationType)
        end

        PX2_GH:SetDebugNavigations(self._isShowNav)

        local navNode = scene:GetNodeNavigation()
        if navNode then
            navNode:Show(self._isShowNav)
        end
    end

    if self._vs then
        self._vs:Show(self._isUseVoxel)
    end

    self:_SetTerrainProperty()

    self:_SandBox(self._sandBoxUse, true)

    self:_UseCameraHot(self._hotUse)

    -- bloom
    local envirParam = scene:GetEnvirParamController()
    envirParam:SetUseBloom(self._isUseBloom)
    envirParam:SetBloomParam(self._bloomParam)
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshEnvParam()
    print(self._name.." p_holospace:_RefreshEnvParam")
    
    local scene = PX2_PROJ:GetScene()
    if scene then
        local arctrl = scene:GetAmbientRegionController()
        
        if self._islightmodeeasy then
        else
            self:_SetLightParam(self._ambient, self._diffuse, self._specular)
        end

        self:_SetTime(self._time)

        -- local m =  self._curViewStyleMode
        -- self:_SetViewMode(m)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_SetViewMode(m)
    local scene = PX2_PROJ:GetScene()
    if scene then
        local arctrl = scene:GetAmbientRegionController()

        local shineEmissive = Float4(0.0, 0.0, 0.0, 1.0)
        local shineAmbient = Float4(1.0, 1.0, 1.0, 1.0)
        local shineDiffuse = Float4(1.0, 1.0, 1.0, 1.0)
        if 0 == m then
        -- 可见光
            arctrl:SetColorLuminosityType(0)
            arctrl:SetColorLuminosityAlpha(0.0)

            shineEmissive = Float4(0.0, 0.0, 0.0, 1.0)
            shineAmbient = Float4(1.0, 1.0, 1.0, 1.0)
        elseif 1==m then
        -- 微光
            arctrl:SetColorLuminosityType(2)
            arctrl:SetColorLuminosityAlpha(0.8)

            shineEmissive = Float4(0.1, 0.1, 0.1, 1.0)
            shineAmbient = Float4(1.0, 1.0, 1.0, 1.0)
        elseif 2==m then
        -- 热成像
            shineEmissive = Float4(0.0, 0.0, 0.0, 1.0)
            shineAmbient = Float4(2.0, 2.0, 2.0, 1.0)
            shineDiffuse = Float4(1.0, 1.0, 1.0, 1.0)

            arctrl:SetColorLuminosityType(4)
            arctrl:SetColorLuminosityAlpha(1.0)
        end

        -- set actors
        local numActors = scene:CalGetNumActors()
        for i=0, numActors-1, 1 do
            local act = scene:GetActor(i)
            local id = act:GetID()
            local model = act:GetModel()
            local temp = act:PFloat("Tempture")
            local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_actor")
            local ismodel = true
            if ismodel then
                if 2==m then
                    local tv = temp/100.0
                    if 0.0==temp then
                        tv = self._hotemissive
                    end
                    local tv1 = self._hotambient
                    shineEmissive = Float4(tv, tv, tv, 1.0)
                    shineAmbient = Float4(tv1, tv1, tv1, 1.0)
                end

                local propData = PropertySetData()
                propData.DoSetShine = true
                propData.ShineEmissive = shineEmissive
                propData.ShineAmbient = shineAmbient
                propData.ShineDiffuse = shineDiffuse
                PX2_GH:SetObjectMtlProperty(model, propData)
            end
        end
        
        -- set terrain
        local terrain = scene:GetTerrain()
        if nil~=terrain then
            if 2==m then
                local ve = self._hotemissiveterrain
                shineEmissive = Float4(ve, ve, ve, 1.0)
                local va = self._hotambientterrain
                shineAmbient = Float4(va, va, va, 1.0)
            end

            local propData = PropertySetData()
            propData.DoSetShine = true
            propData.ShineEmissive = shineEmissive
            propData.ShineAmbient = shineAmbient
            propData.ShineDiffuse = shineDiffuse
            PX2_GH:SetObjectMtlProperty(terrain, propData)
        
            if 2==m  then
                local temp = 0
                local tv = temp/100.0
                if 0.0==temp then
                    tv = self._hotemissive
                end
                local tv1 = self._hotambient
                shineEmissive = Float4(tv, tv, tv, 1.0)
                shineAmbient = Float4(tv1, tv1, tv1, 1.0)
                shineDiffuse = Float4(0.0, 0.00, 0.00, 1.0)
                local propDataTerObj = PropertySetData()
                propDataTerObj.DoSetShine = true
                propDataTerObj.ShineEmissive = shineEmissive
                propDataTerObj.ShineAmbient = shineAmbient
                propDataTerObj.ShineDiffuse = shineDiffuse
                PX2_CREATER:SetTerrainObjectsMtlProperty(terrain, propDataTerObj)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_SetTime(time)
    print(self._name.." p_mworld:_SetTime:"..time)

    local scene = PX2_PROJ:GetScene()
    if scene then
        local ambctrl = scene:GetAmbientRegionController()
        if ambctrl then
            -- time
            local amax = self._ambientMax
            local dmax = self._diffuseMax
            local smax = self._specularMax
            local tval = time

            local perc_a = 0.0
            local perc_d = 0.0
            local perc_s = 0.0
            if 0.0<=tval and tval<=6.0 then
                perc_a = 0.15
                perc_d = 0.1
                perc_s = 0.0
            elseif 6.0<tval and tval<=7.0 then
                local t = (tval-6.0)/1.0
                perc_a = Utils.Lerp(0.1, 0.5, t)
                perc_d = Utils.Lerp(0.1, 0.5, t)
                perc_s = 0.2
            elseif 7.0<tval and tval<=8.0 then
                local t = (tval-7.0)/1.0
                perc_a = Utils.Lerp(0.5, 1.0, t)
                perc_d = Utils.Lerp(0.5, 1.0, t)
                perc_s = 0.2
            elseif 8.0<tval and tval<=15.0 then
                perc_a = 1.0
                perc_d = 1.0
                perc_s = 0.2
            elseif 15.0<tval and tval<=18.0 then
                local t = (tval-16.0)/2.0
                perc_a = Utils.Lerp(1.0, 0.5, t)
                perc_d = Utils.Lerp(1.0, 0.5, t)
                perc_s = 0.2
            elseif 18.0<tval and tval<=20.0 then
                local t = (tval-18.0)/2.0
                perc_a = Utils.Lerp(0.5, 0.1, t)
                perc_d = Utils.Lerp(0.5, 0.1, t)
                perc_s = 0.2
            elseif 20.0<tval and tval<=24.0 then
                perc_a = 0.15
                perc_d = 0.1
                perc_s = 0.0
            end

            local aval = amax * perc_a + 0.05
            local dval = dmax * perc_d + 0.05
            local sval = smax * perc_s + 0.05

            if self._islightmodeeasy then
                self:_SetLightParam(aval, dval, sval)
            end

            ambctrl:SetIntensity(1.0)
            ambctrl:SetHorAngle(30.0)
            local tV = (tval-6.0)/12.0 * 180.0

            print("tvalllllllllllllllllllll:"..tval)
            print("tv:"..tV)

            ambctrl:SetVerAngle(tV)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_SetLightParam(aval, dval, sval)
    local scene = PX2_PROJ:GetScene()
    if scene then
        local ambctrl = scene:GetAmbientRegionController()
        if ambctrl then
            ambctrl:SetAmbientColor(Float3(aval, aval, aval))
            ambctrl:SetDiffuseColor(Float3(dval, dval, dval))
            ambctrl:SetSpecularColor(Float3(sval, sval, sval))
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RegistPropertyOnActor(actor)
    print(self._name.." p_mworld:_RegistPropertyOnActor")

    local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
    if scCtrl then
        scCtrl:_RegistProperty()
    end

    if self._propertyGrid then
        self._propertyGrid:RegistOnObject(actor, "Actor")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_GetObjectPropertyAndSend()
    print(self._name.." p_mworld:_GetObjectPropertyAndSend")

    if self._curSelectActorID > 0 then
        local scene = PX2_PROJ:GetScene()
        if scene then
            local actor = scene:GetActorFromMap(self._curSelectActorID)
            if actor then
                local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
                if scCtrl then
				    p_net._g_net:_SendProperty(actor)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_PropertyButtonTrigger(prop)
    print(self._name.." p_mworld:_PropertyButtonTrigger")

    if self._curSelectActorID > 0 then
        local scene = PX2_PROJ:GetScene()
        if scene then
            print(self._name.." p_mworld:scene")

            local act = scene:GetActorFromMap(self._curSelectActorID)
            if act then 
                print(self._name.." p_mworld:act")

                local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_actor")
                if scCtrl then
                    scCtrl:_OnPropertyButton(prop)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RegistPropertySceneEdit()
	print(self._name.." p_robotface:_RegistPropertySceneEdit")

	self._scriptControl:RemoveProperties("Edit")

    self._scriptControl:BeginPropertyCata("Edit")

    self._scriptControl:AddPropertyClass("Voxel", "体素")
    
    if self._vs then
        local cfg = self._vs:GetVoxelConfig()
        if cfg then
            self._LandscapeOctaves = cfg.LandscapeOctaves
            self._LandscapePersistence = cfg.LandscapePersistence
            self._LandscapeScale = cfg.LandscapeScale
            self._MountainOctaves = cfg.MountainOctaves
            self._MountainPersistence = cfg.MountainPersistence
            self._MountainScale = cfg.MountainScale
            self._MountainMultiplier = cfg.MountainMultiplier
        end        
        self._scriptControl:AddPropertyFloat("LandscapeOctaves", "LandscapeOctaves", self._LandscapeOctaves)
        self._scriptControl:AddPropertyFloat("LandscapePersistence", "LandscapePersistence", self._LandscapePersistence)
        self._scriptControl:AddPropertyFloat("LandscapeScale", "LandscapeScale", self._LandscapeScale)
        self._scriptControl:AddPropertyFloat("MountainOctaves", "MountainOctaves", self._MountainOctaves)
        self._scriptControl:AddPropertyFloat("MountainPersistence", "MountainPersistence", self._MountainPersistence)
        self._scriptControl:AddPropertyFloat("MountainScale", "MountainScale", self._MountainScale)
        self._scriptControl:AddPropertyFloat("MountainMultiplier", "MountainMultiplier", self._MountainMultiplier)
        self._scriptControl:AddPropertyButton("VoxelReGen", "生成")
    end

    self._scriptControl:AddPropertyClass("TerEdit", "地形编辑")

    self._scriptControl:AddPropertyString("TerSelectInfo", "选择信息", self._terSelectInfo, false, false)

    PX2Table2Vector({ "无", "高程", "地表", "植被", "树木", "障碍" })
	self._scriptControl:AddPropertyEnum("TerEditMode", "模式", self._terEditMode, PX2_GH:Vec(), true, true)
    self._scriptControl:AddPropertyFloatSlider("TerBrushSize", "画刷大小", self._terBrushSize, 1.0, 100.0, true, true)
    PX2_EDIT:GetTerrainEdit():GetBrush():SetSize(self._terBrushSize)
    self._scriptControl:AddPropertyFloatSlider("TerBrushStrength", "画刷强度", self._terBrushStrength, 0.0, 1.0, true, true)
    self._scriptControl:AddPropertyButton("TerSaveTexture", "保存纹理")

    self._scriptControl:AddPropertyClass("TerHigh", "高程")
    self._scriptControl:AddPropertyButton("TerReGen", "生成")

    PX2Table2Vector({ "抬高", "降低", "平整", "平滑", "障碍" })
	self._scriptControl:AddPropertyEnum("TerEditHighMode", "模式", self._terHighMode, PX2_GH:Vec(), true, true)
    self._scriptControl:AddPropertyClass("TerTex", "地表")

    PX2Table2Vector({ "1", "2", "3", "4" })
	self._scriptControl:AddPropertyEnum("TerEditTexLayer", "层级", self._terTexLayer, PX2_GH:Vec(), true, true)

    PX2Table2Vector({ "ONE", "REPEAT", "REPEATONE"})
    self._scriptControl:AddPropertyEnum("TerEditBaseLayerMode", "图片模式", self._terBaseLayer, PX2_GH:Vec(), true, true)

    self._scriptControl:AddPropertyFloatSlider("TerUVRepeatU", "重复U", self._terTexRepeatU, 1.0, 100.0, true, true)
    self._scriptControl:AddPropertyFloatSlider("TerUVRepeatV", "重复V", self._terTexRepeatV, 1.0, 100.0, true, true)

    PX2Table2Vector(self._terTexTextureNames)
    local tabTerNames = PX2_GH:Vec()
    PX2Table2Vector(self._terTexTextures)
    local tabTerTextures = PX2_GH:Vec()
    local textureTerTemp = {}
    PX2Table2Vector(textureTerTemp)
    local tabTerTextures1 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData("TerEditTexTexture", "贴图", self._terTexTexture, tabTerNames, tabTerTextures, tabTerTextures1, true, true)

    self._scriptControl:AddPropertyClass("TerGrass", "植被")
    self._scriptControl:AddPropertyFloatSlider("TerEditGrassWidth", "草宽", self._terGrassWidth, 0.0, 3.0, true, true)
    self._scriptControl:AddPropertyFloatSlider("TerEditGrassHigh", "草高", self._terGrassHigh, 0.0, 5.0, true, true)
    self._scriptControl:AddPropertyFloatSlider("TerEditGrassLower", "草低", self._terGrassLower, 0.0, 5.0, true, true)
    PX2Table2Vector(self._terGrassTextureName)
    local tabGrassNames = PX2_GH:Vec()
    PX2Table2Vector(self._terGrassTextures)
    local tabGrassTextures = PX2_GH:Vec()
    local textureGrassTemp = {}
    PX2Table2Vector(textureGrassTemp)
    local tabGrassTextures1 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData("TerEditGrassTexture", "贴图", self._terGrassTexture, tabGrassNames, tabGrassTextures, tabGrassTextures1, true, true)    

    self._scriptControl:AddPropertyClass("TerObjects", "物体")
    self._scriptControl:AddPropertyFloatSlider("TerEditObjectsSize", "大小(小)", self._terObjectSize, 0.0, 10.0, true, true)
    self._scriptControl:AddPropertyFloatSlider("TerEditObjectsSizeBig", "大小(大)", self._terObjectSizeBig, 0.0, 10.0, true, true)
    self._scriptControl:AddPropertyFloatSlider("TerEditObjectsLower", "低", self._terObjectLower, 0.0, 3.0, true, true)
    self._scriptControl:AddPropertyButton("TerEditObjectsRandom", "随机生成")

    PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetSize(self._terObjectSize)
    PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetSizeBig(self._terObjectSizeBig) 

    local nameVec = {}
    local texVec = {}
    for key, value in pairs(self._terObjects) do
        local tid = value
        local defModel = PX2_SDM:GetDefModel(tid)
        if defModel then
            table.insert(nameVec, #nameVec + 1, defModel.Name)
            table.insert(texVec, #texVec + 1, defModel.Model)
        end
    end
    PX2Table2Vector(nameVec)
    local tabObjectNames = PX2_GH:Vec()
    PX2Table2Vector(texVec)
    local tabObjectModelTextures = PX2_GH:Vec()
    local _tabObjectModels1 = {}
    PX2Table2Vector(_tabObjectModels1)
    local tabObjectModels1 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData("TerEditObjects", "模型", self._terObject, tabObjectNames, tabObjectModelTextures, tabObjectModels1, true, true)    

    self._scriptControl:EndPropertyCata()

    self._propertyGridEdit:RegistOnObject(self._scriptControl, "Edit")
end
-------------------------------------------------------------------------------
function p_mworld:_RegistPropertySceneEditExt()
	print(self._name.." p_robotface:_RegistPropertySceneEditExt")

    local iddebugphy = PX2_GH:IsDebugPhysics()

    self._scriptControl:RemoveProperties("Edit1")

    self._scriptControl:BeginPropertyCata("Edit1")

    self._scriptControl:AddPropertyClass("ObjectEdit1Terrain", "地形") 
    self._scriptControl:AddPropertyBool("TerWireframe", "线框模式", iswf, true, true)
    self._scriptControl:AddPropertyButton("TerSave", "保存")
    self._scriptControl:AddPropertyButton("TerUpload", "上传")

    self._scriptControl:EndPropertyCata()

    self._propertyGridEdit1:RegistOnObject(self._scriptControl, "Edit1")
end
-------------------------------------------------------------------------------