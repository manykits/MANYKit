-- p_mworldmap.lua

-------------------------------------------------------------------------------
function p_mworld:_OpenMap(url, id, filename)
	print(self._name.." p_mworld:_OpenMap:"..url)

    print("url:"..url)
    print("id:"..id)
    print("filename:"..filename)

    self._openingmap_url = url
    self._openingmap_id = id
    self._openingmap_filename = filename
    self._isMapFirstInited = false

    PX2_PROJ:SetConfig("lastmap_url", url)
    PX2_PROJ:SetConfig("lastmap_id", id)
    PX2_PROJ:SetConfig("lastmap_filename", filename)

    if self._curmapid==0 then
        self._openingmap_closeddoopen = false
        self:_OpenMapAct(url, id, filename)
    else
        self._openingmap_closeddoopen = true
        self:_CloseCurMap()
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OpenMapAct(url, id, filename)
    --http://127.0.0.1:6606/server/maps/a.xml
	print(self._name.." p_mworld:_OpenMapAct:"..url)
    print("url:"..url)
    print("id:"..id)    

    if self._loadprogressBar then
        self._loadprogressBar:SetProgress(0.0)
    end

    local parentPath = ResourceManager:GetWriteablePath().."Write_MANYKit/"
    if not PX2_RM:IsFileFloderExist(parentPath.."maps/") then
        PX2_RM:CreateFloder(parentPath, "maps/")
    end
    --./Write_MANYKit/maps/a.xml
    local wpath = parentPath.."maps/"..filename
    print("wpath:"..wpath)
    PX2_RM:ClearRes(wpath)

    local curlObj = CurlObj:NewThread("DownLoadMap")
    curlObj:SetUserDataString("filename", wpath)
    curlObj:Download(url, wpath, "_OnDownloadedMap", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_mworld:_OnDownloadedMap(ptr)
    local curlObj = Cast:ToO(ptr)
    local name = curlObj:GetName()

	local progress = curlObj:GetGettedProgress()
    local filename = curlObj:GetUserDataString("filename")
    
    print("name:"..name)
    print("_OnDownloadedMap Progress---------------------------------:"..progress)
    print("filename:"..filename)

    if curlObj:IsGettedOK() then
        if self._loadprogressBar then
            self._loadprogressBar:SetProgress(1.0)
        end

        print(self._name.." p_mworld:_OnDownloadedMap OK")

        local filename = curlObj:GetUserDataString("filename")
        self:_OpenMapFromFilename(filename)
    else
        if self._loadprogressBar then
            self._loadprogressBar:SetProgress(progress)
        end    
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OpenMapFromFilename(filename)
	print(self._name.." p_mworld:_OpenMapFromFilename:"..filename)

    local scene = PX2_PROJ:GetScene()
    if scene then
        scene:Load(filename)
        self._curmapid = scene:GetID()

        self:_GetPropertyValueOfSceneObject(scene)
        self:_RegistPropertyOnScene()
        self:_PropertyValueActivate(nil)

        local nodeObject = scene:GetObjectByID(p_holospace._g_IDNodeObject)
        if nodeObject then
            local numActors = scene:CalGetNumActors()
            for i=0, numActors-1, 1 do
                local act = scene:GetActor(i)
    
                local id = act:GetID()
                local typeidstr = act:GetUserDataString("typeid")
                local typeid = StringHelp:StringToInt(typeidstr)
                local pos = act.LocalTransform:GetTranslate()
                local rot = act.LocalTransform:GetRotateDegreeXYZ()
    
                local act, asc = self:_CreateOrUpdateActor(id, typeid, pos, act, 0, true)
                nodeObject:AttachChild(act)
                if asc then
                    self:_ListMapItemAdd(act, asc)
                end
            end
        end
        
        if 1==g_manykit._lessfullmode then
            self:_CreateVoxelWorld(self._LandscapeOctaves, self._LandscapePersistence, self._LandscapeScale,
                self._MountainOctaves, self._MountainPersistence, self._MountainScale, self._MountainMultiplier)

            local nodeTerrain = scene:GetObjectByID(p_holospace._g_IDNodeTerrain)
            p_holospace._g_holospace:_ReCreateTerrain(nodeTerrain, scene, self._loadprogressBar)
        end
    end

    if self._frameCover then
        self._frameCover:Show(false)
    end    
    self:_ShowMapListFrame(false)

    --in_map
    local net = p_net._g_net
    if net then
        net:_SendInMap(self._curmapid, APoint.ORIGIN, APoint.ORIGIN, true)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CloseCurMap()
	print(self._name.." p_mworld:_CloseCurMap")
        
    print("self._curmapid:"..self._curmapid)

    if self._curmapid==0 then        
    else
        p_net._g_net:_SendCloseMap(self._curmapid)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnCloseMap(mid)
    print(self._name.." p_mworld:_OnCloseMap:"..mid)

    if mid == self._curmapid then
        local scene = PX2_PROJ:GetScene()
        if scene then
            self:_OnSimu(false)

            scene:RemoveAllActors()
            scene:SetID(0)
            scene:SetMainActor(nil)

            local nodeTerrain = scene:GetObjectByID(p_holospace._g_IDNodeTerrain)
            if nodeTerrain then
                nodeTerrain:DetachAllChildren()
            end

            local terrain = scene:GetTerrain()
            if terrain then
                terrain:DetachFromParent()
            end

            scene:SetTerrain(nil)

            p_holospace._g_holospace._terrain = nil
        end

        self:_OnDisSelectObj(false)

        if self._frameCover then
            self._frameCover:Show(true)
        end
        if self._listMapItems then
            self._listMapItems:RemoveAllItems()
        end

        self._curmapid = 0
        self._isediting = false
        self._terrainmd5 = ""
        self._terrainzipmd5 = ""

        if self._openingmap_closeddoopen then
            self:_OpenMapAct( self._openingmap_url, self._openingmap_id, self._openingmap_filename)
            self._openingmap_closeddoopen = false
        end

        if not g_manykit._isUI3DMode then
            p_holospace._g_holospace:_ChangeTo2D3D(self._isUI3DMode)
        end

        self:_TakeControlOfAgent(nil)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ShowMapListFrame(show)
    print("p_mworld:_ShowMapListFrame")
    print_i_b(show)

	self._frameMapList:Show(show)

    if show then 
        if PX2_SS then
            PX2_SS:PlayASound(g_manykit._media.ui_open, g_manykit._soundVolume, 2.0)
        end

        p_net._g_net:_GetRefreshMap(self._listMap)
    else
        if PX2_SS then
            PX2_SS:PlayASound(g_manykit._media.ui_close, g_manykit._soundVolume, 2.0)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ListMapItemAdd(act, asc)
    if self._listMapItems then
        local item = self._listMapItems:GetItemByUserDataString("id", ""..asc._id)
        if nil==item then
            local allname = act:GetUserDataString("allname")

            local nameid = allname..":"..asc._id
            local item = self._listMapItems:AddItem(nameid)

            item:SetUserDataString("id", asc._id)
            item:SetUserDataString("typeid", asc._typeid)

            local txt = "Num:"..self._listMapItems:GetNumItems()
            self._fTextListInfo:GetText():SetText(txt)
        end
    end
end
-------------------------------------------------------------------------------