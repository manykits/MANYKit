-- p_holoservermap.lua
-------------------------------------------------------------------------------
function p_holoserver:_CreateMap(name)
    print(self._name.." p_holoserver:_CreateMap "..name)

    local writePath = self:_CheckMapSavePath()..name..".xml"

    local id = self:_GenNextMapID()
    local scene = Scene:New("Scene")
    scene:SetID(id)
    scene:SetName(name)
    scene:SetUserDataString("filename", writePath)
    self._scenes[id] = scene
    PX2_PROJ:PoolSet("scenemap_"..id, scene)
    
    local room = PX2_SRMM:GetRoomByName("public")
    if room then
        room:AddScene(scene)
    end

    self:_GenDefaultSceneProperty(scene)
    self:_SaveScene(scene, nil)
end
-------------------------------------------------------------------------------
function p_holoserver:_ResetMapPlayers(mapid)
    print(self._name.." p_holoserver:_ResetMapPlayers:"..mapid)

    local exceptID = g_manykit._uin
    print("exceptID:"..exceptID)

    local scene = self._scenes[mapid]
    if scene then
        local room = PX2_SRMM:GetRoomByName("public")
        if room then
            local numMap = room:GetNumMaps()
            print("numMap:"..numMap)
            for i=0, numMap-1, 1 do
                local map = room:GetMapByIndex(i)
                if map then
                    local mid = map:GetID()
                    print("mid:"..mid)

                    if mid == mapid then
                        print("RemoveCharaPlayers:"..mid)

                        local exceptID = g_manykit._uin
                        print("exceptID:"..exceptID)

                        map:RemoveCharaNoPlayers()
                        map:RemoveCharaPlayers(exceptID)

                        scene:RemoveAllActors(exceptID)
                        if self._isDoSceneSave then
                            self:_SaveScene(scene, nil)
                        end
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_GenNextMapID()
    local nextmapid = PX2_IDM:GetNextID("Scene")
    return nextmapid
end
-------------------------------------------------------------------------------
function p_holoserver:_GenNextMapObjID()
    local nextmapobjid = 1000

    local nextmapobjidstr = PX2_PROJ:GetConfig("nextmapobjid")
    if ""==nextmapobjidstr then
        nextmapobjidstr = "1000"
    else
        nextmapobjid = StringHelp:StringToInt(nextmapobjidstr)
    end

    local nmid = nextmapobjid + 1
    PX2_PROJ:SetConfig("nextmapobjid", ""..nmid)

    return nextmapobjid
end
-------------------------------------------------------------------------------
function p_holoserver:_GenDefaultSceneProperty(scene)
    print(self._name.." p_holoserver:_GenDefaultSceneProperty")

    scene:BeginPropertyCata("Scene")
  
    scene:AddPropertyClass("Light", "光线")
    scene:AddPropertyFloatSlider("Time", "Time", 12, 0.0, 24.0, true, true)

    scene:AddPropertyClass("Weather", "天气")
    scene:AddPropertyFloatSlider("Fog_Far", "Fog_Far", 500.0, 1.0, 5000.0, true, true);
    scene:AddPropertyFloatSlider("Fog_Near", "Fog_Near", 100.0, 1.0, 100.0, true, true);

    scene:EndPropertyCata()
end
-------------------------------------------------------------------------------
function p_holoserver:_GetMapList()
    print(self._name.." p_holoserver:_GetMapList:") 

    local dt = {}

    for key, value in pairs(self._scenes) do
        local scene = value
        if scene then
            local id = scene:GetID()
            local webID = scene:PInt("WebID")
            local trainid = scene:PInt("trainid")
            local filename = scene:GetUserDataString("filename")
            local outBase = StringHelp:SplitFullFilename_OutBase(filename)
            local outExt = StringHelp:SplitFullFilename_OutExt(filename)
            local fn =  outBase..".xml"

            local d = {}
            d.id = id
            d.n = outBase
            d.f = fn
            d.trainid = trainid
            if manykit_IsInMap(webID, self._cloudSceneData) then
                d.isoverdate = "1"
            else
                d.isoverdate = "0"
            end

            if webID>0 then
                d.n = webName
            end

            table.insert(dt, #dt + 1, d)        
        end
    end

    return dt
end
-------------------------------------------------------------------------------
function p_holoserver:_LoadMaps()
    print(self._name.." p_holoserver:_LoadMaps")

    self._scenes = {}

    local dt = {}
    local path = self:_CheckMapSavePath()
	local dir = DirP()
	
    dir:GetAllFiles(path, "")
	dir:SortFilesByTime()

	local numFiles = dir:GetNumFiles()
	for i=0,numFiles-1,1 do
		local filename = dir:GetFile(i)
		print("filename:"..filename)
        local ext = StringHelp:SplitFullFilename_OutExt(filename)
        if "xml"==ext then
            self:_LoadScene(filename)
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_LoadScene(filename)
    print(self._name.." p_holoserver:_LoadScene:"..filename) 

    local scene = Scene:New()
    scene:Load(filename)
    local id = scene:GetID()
    scene:SetUserDataString("filename", filename)

    local numActors = scene:CalGetNumActors()
    for i=0, numActors-1, 1 do
        local act = scene:GetActor(i)
        if act then
            local typeidstr = act:GetUserDataString("typeid")
            local typeid = StringHelp:SToI(typeidstr)

            local skillChara = act:GetSkillChara()
            if skillChara then
                skillChara:SetTypeID(typeid)
                skillChara:CreateSkills()
                skillChara:EquipAllSkills()
                skillChara:CreateItems()
            end
         end
    end

    local skillMap = scene:GetSkillMap()
    if skillMap then
        skillMap:LoadState()
    end

    PX2_PROJ:PoolSet("scenemap_"..id, scene)
    self._scenes[id] = scene

    local room = PX2_SRMM:GetRoomByName("public")
    if room then
        room:AddScene(scene)
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_CheckLoadMapState(mapid, skillchara)
    local scene = self._scenes[mapid]
    if scene then
        local skillMap = scene:GetSkillMap()
        if skillMap then
            skillMap:SetSkillCharaMapState(skillchara)
        end
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_DeleteScene(idi)
    print(self._name.." p_holoserver:_DeleteScene:"..idi)

    local scene = self._scenes[idi]
    if scene then
        local filename = scene:GetUserDataString("filename")
        if ""~=filename then
            local f = File(filename)
            f:Delete()
        end
        PX2_PROJ:PoolSet("scenemap_"..idi, nil)
        self._scenes[idi] = nil
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_GetSceneByID(idi)
    local scene = self._scenes[idi]
    if scene then
        return scene
    end

    return nil
end
-------------------------------------------------------------------------------
function p_holoserver:_GetSceneByName(name)
    for key1, value1 in pairs(self._scenes) do
        local scene = value1
        local na = scene:GetName()
        if name == na then
            return scene
        end
    end

    return nil
end
-------------------------------------------------------------------------------
function p_holoserver:_SetScene(idi, tab)
    print(self._name.." p_holoserver:_SetScene:"..idi)

    local scene = self._scenes[idi]
    if scene then
        local props = tab.data.properties
        local propsstr = PX2JSon.encode(props)
        
        self:_SaveScene(scene, propsstr)
    end
end
-------------------------------------------------------------------------------
function p_holoserver:_CheckMapSavePath()
    local pth0 = g_manykit._writePathProj.."server/"
    if not PX2_RM:IsFileFloderExist(pth0) then
        PX2_RM:CreateFloder(g_manykit._writePathProj, "server/")
        print(self._name.." p_holoserver:createdpath:"..pth0)
    end

    local pth1 = g_manykit._writePathProj.."server/maps/"
    if not PX2_RM:IsFileFloderExist(pth1) then
        PX2_RM:CreateFloder(g_manykit._writePathProj.."server/", "maps/")
        print(self._name.." p_holoserver:createdpath:"..pth1)
    end

    return pth1
end
-------------------------------------------------------------------------------
function p_holoserver:_SaveScene(scene, propsstr)
    print(self._name.." p_holoserver:_SaveScene")

    if scene then
        if propsstr then
            PX2_CREATER:UpdatePropertyFromJSON(scene, propsstr, "Scene")
        end

        local filename = scene:GetUserDataString("filename")
        print("filename:"..filename)
        
        scene:Save(filename)
    end
end
-------------------------------------------------------------------------------