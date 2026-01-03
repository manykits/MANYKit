-- p_mworldscene.lua

-------------------------------------------------------------------------------
function p_mworld:_TerEditObjectsRandom()
    print("_TerEditObjectsRandom")

    PX2_EDIT:GetTerrainEdit():EnableEdit()
    
    local modelID = self._terObjects[1]
    local defModel = PX2_SDM:GetDefModel(modelID)
    if defModel then
        local name = defModel.Name
        local model = defModel.Model
        local scale = defModel.ModelScale
        local bd = defModel.BD

        PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetInitSize(scale)
        PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetSize(0.6)
        PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetSizeBig(1.5)
        PX2_EDIT:GetTerrainEdit():GetTerrainObjectsProcess():SetUsingFilename(model)
    end

    local img = self._terTexTextures[2]
    local srd = SelectResData()
    srd:SetResPathnameObject(img)
    PX2_EDIT:SetSelectedResource(srd)
    PX2_EDIT:GetTerrainEdit():GetTextureProcess():SetSelectedLayer(1)
    
    PX2_EDIT:GetTerrainEdit():GetJunglerProcess():SetWidth(1.0)
    PX2_EDIT:GetTerrainEdit():GetJunglerProcess():SetHeight(1.0)
    PX2_EDIT:GetTerrainEdit():GetJunglerProcess():SetUsingTexture("scripts/lua/plugins/p_mworld/images/grass/grass1.png")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local terrain = scene:GetTerrain()

        local mapw = scene:PFloat("MapLength")
        local maph = scene:PFloat("MapWidth")
        if mapw<=0.0 then
            mapw = 200.0
        end
        if maph<=0.0 then
            maph = 200.0
        end
        local mapSize = Mathf:Max(mapw, maph)
        local dist = mapSize * 1.5
        for i=1, 10, 1 do
            local fx = Mathf:IntervalRandom(-dist, dist)
            local fy = Mathf:IntervalRandom(-dist, dist)
            local h = terrain:GetHeight(fx, fy)
            local pos = APoint(fx, fy, h)
            local sz = Mathf:IntervalRandom(10.0, 20.0)
            local strength = sz/20.0
            PX2_EDIT:GetTerrainEdit():GetBrush():SetSize(sz)
            PX2_EDIT:GetTerrainEdit():GetBrush():SetStrength(strength)
            PX2_EDIT:GetTerrainEdit():GetBrush():SetPos(pos)

            PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_TERRAINOBJECTS)
            PX2_EDIT:GetTerrainEdit():Apply(true)

            PX2_EDIT:GetTerrainEdit():GetBrush():SetSize(sz*1.4)
            PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_JUNGLER)
            PX2_EDIT:GetTerrainEdit():Apply(true)

            PX2_EDIT:GetTerrainEdit():GetBrush():SetSize(sz*1.5)
            PX2_EDIT:GetTerrainEdit():SetEditType(TerrainProcess.TPT_TEXTURE)
            PX2_EDIT:GetTerrainEdit():Apply(true)
        end
    end

    PX2_EDIT:GetTerrainEdit():DisableEdit()
end
-------------------------------------------------------------------------------
function p_mworld:_UpdateScemeNav()
    print("p_mworld:_UpdateScemeNav")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local terrain = scene:GetTerrain()

        local aw = scene:GetAIAgentWorld()
        local navType = aw:GetNavigationType()
        print("GetNavigationType:")
        print(navType)

        if AIAgentWorld.NT_GRID==navType then
            print("LoadFromSceneTerrainWalkTexture")
            aw:GetAINavObject():LoadFromSceneTerrainWalkTexture(terrain)
        elseif AIAgentWorld.NT_MESH==navType then
            print("ClearNavigationMeshs")
            aw:ClearNavigationMeshs()
            aw:CreateAddNavigationMesh("Nav")
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_GoToTick()
    print("p_mworld:_GoToTick")

    local scene = PX2_PROJ:GetScene()
    if scene then
        local aw = scene:GetAIAgentWorld()
        if aw then
            local nav = aw:GetNavigationMesh("Nav")
            if nav then
                local ap = nav:RandomPoint()
                print("ap:"..ap:ToString())

                local ap1 = nav:RandomPoint()
                print("ap1:"..ap1:ToString())

                -- local from = APoint(0, 0, 0.0)
                -- local to = APoint(3, 3, 0.0)

                nav:FindPath(ap, ap1)
            end
        end
    end
end
-------------------------------------------------------------------------------