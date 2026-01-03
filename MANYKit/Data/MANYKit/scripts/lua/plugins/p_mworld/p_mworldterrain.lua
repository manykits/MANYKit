-- p_holocreateterrain.lua
---------------------------------------------------------------------------
function p_mworld:_TerrainSave()
    print(self._name.." p_mworld:_TerrainSave")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local id = scene:GetID()
        local savefilename = p_holospace._g_holospace:_GetTerrainSaveFilename(id)
        print("savefilenameeeeee:"..savefilename)

        local terrain = scene:GetTerrain()
        if terrain then
            local outStream = OutStream()
            outStream:Insert(terrain)
            outStream:Save(savefilename)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_TerrainUpload()
    print(self._name.." p_mworld:_TerrainUpload")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local net = p_net._g_net
        if net then
            local id = scene:GetID()
            local savefilename = p_holospace._g_holospace:_GetTerrainSaveFilename(id)
            print("savefilename:"..savefilename)
            
            if PX2_RM:IsFileFloderExist(savefilename) then
                print("p_TerrainUpload begin")

                local zipf = savefilename.."zip"

                PX2_RM:ZipFile(savefilename, zipf)

                local fmd5 = PX2_RM:MD5File(savefilename)
                print("fmd5:")
                print(fmd5)
                self._terrainmd5 = fmd5

                local zipmd5 = PX2_RM:MD5File(zipf)
                print("zipmd5:")
                print(zipmd5)
                self._terrainzipmd5 = zipmd5

                print("savefilename:"..savefilename)
                local outExt = StringHelp:SplitFullFilename_OutExt(savefilename)
                print("outExt:"..outExt)
                local outBase = StringHelp:SplitFullFilename_OutBase(savefilename)
                print("dataBase:"..outBase)
                local fp = outBase.."."..outExt
                self._terrainpath = fp

                local url = "http://"..p_net.g_ip_logic..":"..p_net._port_http_appserver.."/uploadterrain"
                print("url:"..url)

                local curlObj = CurlObj:NewThread()
                curlObj:SetUserDataString("filename", zipf)
                curlObj:SetUserDataString("md5", fmd5)
                curlObj:SetUserDataString("zipmd5", zipmd5)
                curlObj:PostFile(url, zipf, "_OnTerrainUpload", self._scriptControl)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnTerrainUpload(ptr)
	local curlObj = Cast:ToO(ptr)
    local progress = curlObj:GetGettedProgress()
	local iProj = progress * 100
    print("iProj:"..iProj)

    if curlObj:IsGettedOK() then
        self:_RegistPropertyOnScene()
        self:_GetScenePropertyAndSend("")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CalGisWidthHeight()
    print(self._name.." p_mworld:_CalGisWidthHeight")

    local scene = PX2_PROJ:GetScene()
    local ter = scene:GetTerrain()

    self._startlong = scene:PString("StartLong")
    self._endlong = scene:PString("EndLong")
    self._startlat = scene:PString("StartLat")
    self._endlat = scene:PString("EndLat")

    print("StartLong:"..self._startlong)
    print("EndLong:"..self._endlong)
    print("StartLat:"..self._startlat)
    print("EndLat:"..self._endlat)

    local slng = StringHelp:StringToFloat(self._startlong)
    local elng = StringHelp:StringToFloat(self._endlong)
    local slat = StringHelp:StringToFloat(self._startlat)
    local elat = StringHelp:StringToFloat(self._endlat)

    local length = GisLogic:LongitudeToDistance(elng - slng, slat, ter)
    local width = GisLogic:LatitudeToDistance(elat - slat)

    print("length:"..length)
    print("width:"..width)

    self._maplength = length
    self._mapwidth = width    
    scene:BeginPropertyCata("Scene")
    scene:AddPropertyFloat("MapLength", "地图长度", self._maplength, true, true)
    scene:AddPropertyFloat("MapWidth", "地图宽度", self._mapwidth, true, true)
    scene:EndPropertyCata()

    self:_GetScenePropertyAndSend("")
end
-------------------------------------------------------------------------------
function p_mworld:_CalTerrainGis()
    print(self._name.." p_mworld:_CalTerrainGis")

    local scene = PX2_PROJ:GetScene() 

    self:_SetTerrainProperty()
    
    local terrain = scene:GetTerrain()
    if terrain then
        local gismode = terrain:GetTerrainMode()
        terrain:CalTerrain()
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnTerrainHeightUpdateMePos()
	print(self._name.." p_mworld:_OnTerrainHeightUpdateMePos")
    print_i_b(self._isTerrainHeightUpdateMePosOK)

    local scene = PX2_PROJ:GetScene()
    local terrain = scene:GetTerrain()
    --local isTerrainLoadedOK = 

    if false == self._isTerrainHeightUpdateMePosOK then
        local scene = PX2_PROJ:GetScene()
        local meActor = scene:GetMeActor()
        if meActor then
            print("meActor")

            local curPos = meActor.LocalTransform:GetTranslate()

            local h = curPos:Z()
            h = manykit_PickScenePos(curPos, 8000.0, meActor):Z()
            
            local newAP = APoint(curPos:X(), curPos:Y(), h)
            meActor:GetAIAgentBase():SetPosition(newAP)

            PX2_GH:SendGeneralEvent("ActorSetPos")        
            PX2_GH:SendGeneralEvent("MapPrepareOK")

            self._isTerrainHeightUpdateMePosOK = true

        else
            print("meActor is null")
        end
    end
end
-------------------------------------------------------------------------------