-- p_holospaceterrain.lua
-------------------------------------------------------------------------------
-- terrain
function p_holospace:_MapNumNavGridByIndex(idx)
    --PX2Table2Vector({"25", "50", "75", "100", "125", "150", "175", "200"})

    if 0==idx then
        return 25
    elseif 1==idx then
        return 50
    elseif 2==idx then
        return 75
    elseif 3==idx then
        return 100
    elseif 4==idx then
        return 125
    elseif 5==idx then
        return 150
    elseif 6==idx then
        return 175
    elseif 7==idx then
        return 200
    end

    return 50
end
-------------------------------------------------------------------------------
function p_holospace:_ReCreateTerrain(nodeTerrain, scene, progressBar)
    print("p_holospace:_ReCreateTerrain")

    if nodeTerrain then
        nodeTerrain:DetachAllChildren()
    end
    local terrain = scene:GetTerrain()
    if terrain then
        terrain:DetachFromParent()
    end
    self._terrain = nil
    self._terrainpathimageDownLoaded = ""
    self._isTerrainHeightCreatedOK = false

    local nodeSky = scene:GetNodeSky()
    local meshSky = scene:GetMeshSky()
    meshSky.LocalTransform:SetUniformScale(p_holospace._g_skyDefaultScale)
    local nodeMoon = scene:GetNodeMoon()
    local moonPos = p_holospace._g_skyDefaultScale * 0.8
    nodeMoon.LocalTransform:SetTranslate(APoint(moonPos, moonPos, moonPos*0.6))
    nodeMoon:Show(true)
    local bdMoon = scene:GetBillboardMoon()
    bdMoon:SetEmitSizeXYZ(moonPos * 0.1)
    nodeMoon:ResetPlay()

    local nodeStar = scene:GetNodeStar() 
    nodeStar.LocalTransform:SetUniformScale( (4.0/150.0) * moonPos * 0.13)
    nodeStar:Show(true)
    nodeStar:ResetPlay()

    local terrainpath = scene:PString("TerrainPath", "")
    local terrainmd5 = scene:PString("TerrainMD5", "")
    local terrainzipmd5 = scene:PString("TerrainZIPMD5", "")
    local terrainMode = scene:PInt("TerrainMode", 0)

    local net = p_net._g_net
    if net then
        print("terrainpathhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh:")
        print(terrainpath)

        if ""==terrainpath then
            local maplength = 16.0
            local mapwidth = 16.0

            if 0==terrainMode then
                local spaceTemp = 4
                local sz = 64
                local titleSZ = spaceTemp * sz

                local numTitlesW = maplength/titleSZ
                local numTitlesH = mapwidth/titleSZ
                local iNumTitlesW = Mathf:Ceil(numTitlesW)
                local iNumTitlesH = Mathf:Ceil(numTitlesH)
                if (iNumTitlesW % 2 == 0) then
                else iNumTitlesW = iNumTitlesW+1 end    
                if (iNumTitlesH % 2 == 0) then
                else iNumTitlesH = iNumTitlesH+1 end

                local spaceW = maplength/(iNumTitlesW * sz)
                local spaceH = mapwidth/(iNumTitlesH * sz)
                local spaceingLast = Sizef(spaceW, spaceH)

                terrain = PX2_CREATER:CreateTerrain(spaceingLast, iNumTitlesW, iNumTitlesH, sz+1, true, false)
            else
                if 0.0==maplength then 
                    maplength = 1000.0 
                end
                if 0.0==mapwidth then 
                    mapwidth = 1000.0
                end
        
                terrain = Terrain:New()
            end

            local mapSize = Mathf:Max(maplength, mapwidth)
            g_manykit._mapMaxSize = mapSize
            g_manykit._defaultViewDistanceMax = 500.0
            p_holospace._g_cameraFar = mapSize*2.0
            p_holospace._g_cameraNear = p_holospace._g_cameraFar/10000.0

            terrain:SetLoadMultiThread(g_manykit._isTerrainMultiThread)
            
            p_holospace._g_holospace:_SetTerrainProperty(terrain)

            local actor = PX2_CREATER:CreateActor()
            actor:SetID(p_holospace._g_IDActorTerrain)
            actor:SetName("ActorTerrain")
            actor:SetAIType(Actor.AIT_AGENTOBJECT)
            actor:SetModel(terrain)
            actor:GetAIAgentBase():UsePhysics(g_manykit._isUsePhysics)

            if g_manykit._isUsePhysics then
                actor:SetPhysicsShapeType(Actor.PST_MESHSTATIC, terrain)
            end
            nodeTerrain:AttachChild(actor)
            scene:AddActor(actor)

            self:_OnTerrainSetted(terrain)
        else
            local outExt = StringHelp:SplitFullFilename_OutExt(terrainpath)
            print("outExt:"..outExt)
            local outBase = StringHelp:SplitFullFilename_OutBase(terrainpath)
            print("dataBase:"..outBase)
            local fp = outBase..".px2obj"

            local id = scene:GetID()
            local terrainwritepath = self:_GetTerrainSaveFilename(id)
            local terrainwritepathzip = terrainwritepath.."zip"
            if ""==terrainmd5 then
                terrainwritepathzip = ""
            end

            local needdownloadTerrain = true
            if ""~=terrainzipmd5 then
                fp = outBase..".px2objzip"

                if PX2_RM:IsFileFloderExist(terrainwritepathzip) then
                    local fmd5zip = PX2_RM:MD5File(terrainwritepathzip)
                    print("fmd5zip:")
                    print(fmd5zip)
                    if terrainzipmd5==fmd5zip then
                        needdownloadTerrain = false
                    end
                end
            else
                fp = outBase..".px2obj"

                if ""~=terrainmd5 then
                    if PX2_RM:IsFileFloderExist(terrainwritepath) then
                        local fmd5 = PX2_RM:MD5File(terrainwritepath)
                        print("fmd5:")
                        print(fmd5)
                        if terrainmd5==fmd5 then
                            needdownloadTerrain = false
                        end
                    end
                end
            end

            print("needdownloadTerrain:")
            print_i_b(needdownloadTerrain)

            if needdownloadTerrain then
                if progressBar then
                    progressBar:SetProgress(0.0)
                end

                local fn = terrainwritepath
                if ""~=terrainzipmd5 then
                    fn = terrainwritepathzip
                end

                print("fn:"..fn)
                print("fp:"..fp)

                print("p_net.g_ip_logic:"..p_net.g_ip_logic)
                
                local realurl = "http://".. p_net.g_ip_logic..":"..net._port_http_appserver.."/server/maps/"..fp
                print("terrainpath realurl:"..realurl)

                local curl = CurlObj:NewThread("TerrainPath")
                curl:SetUserDataString("filename", fp)
                curl:SetUserDataString("terrainwritepath", terrainwritepath)
                curl:SetUserDataString("terrainwritepathzip", terrainwritepathzip)
                curl:SetUserDataPointer("progressbar", progressBar)
                curl:Download(realurl, fn, "_OnDownloadFileTerrain", self._scriptControl)
            else
                print("not need download terrain!!!!!!!!!!!!!!!!!!!!!!!!!!")

                if progressBar then
                    progressBar:SetProgress(1.0)
                end

                if ""~=terrainzipmd5 then
                    PX2_RM:UnZipFile(terrainwritepathzip, terrainwritepath)
                    self:_LoadTerrain(terrainwritepath)
                else
                    self:_LoadTerrain(terrainwritepath)
                end

                if ""~=self._terrainpathimageDownLoaded then
                    if self._terrain then
                        self._terrain:SetBaseTexture(self._terrainpathimageDownLoaded)
                    end
                end
            end
        end
    end

    return terrain
end
-------------------------------------------------------------------------------
function p_holospace:_LoadTerrain(pathfile)
    print("p_holospace:_LoadTerrainnnnnnnnnnnnnnnn:"..pathfile)

    local inStream = InStream()
    if inStream:Load(pathfile) then
        print("pathfile load suc")
        local obj = inStream:GetObjectAt(0)
        if obj then
            print("inStream load succccccccccccccccccccc")

            local terrain = Cast:ToTerrain(obj)
            if terrain then
                local scene = PX2_PROJ:GetScene()
                local nodeTerrain = scene:GetObjectByID(p_holospace._g_IDNodeTerrain)
                if nodeTerrain then                    
                    self._terrain = terrain

                    local actor = PX2_CREATER:CreateActor()
                    actor:SetID(p_holospace._g_IDActorTerrain)
                    actor:SetName("ActorTerrain")
                    actor:SetAIType(Actor.AIT_AGENTOBJECT)
                    actor:SetModel(terrain)
                    actor:GetAIAgentBase():UsePhysics(g_manykit._isUsePhysics)
                    if g_manykit._isUsePhysics then
                        actor:SetPhysicsShapeType(Actor.PST_MESHSTATIC, terrain)
                    end

                    nodeTerrain:AttachChild(actor)
                    scene:AddActor(actor)

                    self:_OnTerrainSetted(terrain)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_OnTerrainSetted(terrain)
    self._terrain = terrain

    local sm = terrain:GetShowSubMode()
    local lod = terrain:GetShowSubIndex()
    local scene = PX2_PROJ:GetScene()
    local numNavGridIndex = scene:PInt("TerNumNavGridIndex")
    local numNavGrid = self:_MapNumNavGridByIndex(numNavGridIndex)    
    self:_SetNavGridNum(terrain, numNavGrid)
    self:_SetTerrainObst(terrain, false)

    scene:Update()
    
    local tm = terrain:GetTerrainMode()

    if tm == Terrain.TM_NORMAL  then
        coroutine.wrap(function()
            sleep(1.0)
            self:_TerrainHeightCreatedOK()
        end)()
    elseif tm == Terrain.TM_GIS then
    elseif tm == Terrain.TM_GISING then
        PX2_GH:SendGeneralEvent("calterrain")
        
		coroutine.wrap(function()
            sleep(3.0)
            self:_TerrainHeightCreatedOK()
        end)()
    end
end
-------------------------------------------------------------------------------
function p_holospace:_SetTerrainObst(terrain, obst)
    local scene = PX2_PROJ:GetScene()
        if scene then
        if terrain then
            if obst then
                local propData = PropertySetData()
                propData.DoSetAllow = true
                propData.AllowAlpha = false
                propData.AllowRed = false
                propData.AllowGreen = false
                propData.AllowBlue = false
                propData.DoSetBlend = true
                propData.BlendType = 0
                PX2_GH:SetObjectMtlProperty(terrain, propData)
                PX2_CREATER:SetRenderLayer(terrain, Renderable.RL_BACKGROUND, 1)
            else
                local propData = PropertySetData()
                propData.DoSetAllow = true
                propData.AllowAlpha = true
                propData.AllowRed = true
                propData.AllowGreen = true
                propData.AllowBlue = true
                propData.DoSetBlend = true
                propData.BlendType = 0
                PX2_GH:SetObjectMtlProperty(terrain, propData)
                PX2_CREATER:SetRenderLayer(terrain, Renderable.RL_SCENE)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_SetNavGridNum(terrain, numcell)
    print("p_holospace:_SetNavGridNum:"..numcell)

    local tsize = terrain:GetSizeWithScale()

    local maplength = tsize.Width
    local mapwidth = tsize.Height

    print("maplength:"..maplength)
    print("mapwidth:"..mapwidth)

    if maplength>0 and mapwidth>0 then
        local hw = maplength * 0.5
        local hh = mapwidth * 0.5
        local spNav = maplength/(numcell*1.0)
        local numW = maplength/spNav
        local numH = mapwidth/spNav
        local iNumW = Mathf:Ceil(numW)
        local inumH = Mathf:Ceil(numH)

        local scene = PX2_PROJ:GetScene()
        scene:GetAIAgentWorld():GetAINavObject():CreateNavGraph(APoint(-hw, -hh, 0), iNumW, inumH, spNav)
    end

end
-------------------------------------------------------------------------------
function p_holospace:_GetTerrainSaveFilename(mapid)
    local path = ResourceManager:GetWriteablePath().."Write_MANYKit/maps/"
    local savefilename = path.."ter_"..mapid..".px2obj"

    return savefilename
end
-------------------------------------------------------------------------------
function p_holospace:_OnDownloadFileTerrain(ptr)

    print("_OnDownloadFileTerrainnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn")

    local curlObj = Cast:ToO(ptr)
    local name = curlObj:GetName()
    local progress = curlObj:GetGettedProgress()
    local progressbarptr = curlObj:GetUserDataPointer("progressbar")
    local progressbar = Cast:ToO(progressbarptr)

    print("name:"..name)
    print("progress:"..progress)

    if curlObj:IsGettedOK() then
        print("000")

        if "TerrainPath"==name then
            print("_OnDownloadFileTerrain TerrainPathhhhhhhhhhhhhhhhhhhhhhhhhhhhh"..progress)

            if progressbar then
                progressbar:SetProgress(1.0)
            end    

            local terrainwritepath = curlObj:GetUserDataString("terrainwritepath")
            local terrainwritepathzip = curlObj:GetUserDataString("terrainwritepathzip")

            if ""~=terrainwritepathzip then
                PX2_RM:UnZipFile(terrainwritepathzip, terrainwritepath)
                self:_LoadTerrain(terrainwritepath)
            else
                self:_LoadTerrain(terrainwritepath)
            end

            if ""~=self._terrainpathimageDownLoaded then
                if self._terrain then
                    self._terrain:SetBaseTexture(self._terrainpathimageDownLoaded)
                end
            end
        end
    else
        if "TerrainPath"==name then
            print("_OnDownloadFileTerrain TerrainPath"..progress)

            if progressbar then
                progressbar:SetProgress(progress)
            end   
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_TerrainHeightCreatedOK()
    print(self._name.." p_holospace:_TerrainHeightCreatedOK")

    self._isTerrainHeightCreatedOK = true

    PX2_GH:SendGeneralEvent("TerrainHeightUpdateMePos")
end
-------------------------------------------------------------------------------