-- p_mworldworld.lua
-------------------------------------------------------------------------------
function p_mworld:_CreateVoxelWorld(lOcta, lPers, lScal, mOcta, mPers, mScal, mMulti)
    print("p_mworld:_CreateVoxelWorld")
    print("-------------------------------------------")

    local scene = PX2_PROJ:GetScene()

    local extXY = 2

    local nodeVoxel = scene:GetObjectByID(p_holospace._g_IDVoxel)
    nodeVoxel:DetachAllChildren()

    print("lOcta:"..lOcta)
    print("lPers:"..lPers)
    print("lScal:"..lScal)
    print("mOcta:"..mOcta)
    print("mPers:"..mPers)
    print("mScal:"..mScal)
    print("mMulti:"..mMulti)

    extXY = 4

    local voxelSection = PX2_CREATER:CreateVoxelSection(16, 1, -- titlesize, blocksize
        extXY, -1, 1, -- range
        4, 4,  -- viewrange
        118)
    self._vs = voxelSection
    --voxelSection:SetSampleBase("scripts/lua/plugins/p_mworld/images/blocks/blocks.png")
    voxelSection:SetDoReflect(false)

    local cfg = VoxelConfig:New()
    cfg.LandscapeOctaves = lOcta
    cfg.LandscapePersistence = lPers
    cfg.LandscapeScale = lScal
    cfg.MountainOctaves = mOcta
    cfg.MountainPersistence = mPers
    cfg.MountainScale = mScal
    cfg.MountainMultiplier = mMulti
    voxelSection:Generate(cfg)

    local actor = PX2_CREATER:CreateActor()
    actor:SetID(p_holospace._g_IDActorVoxel)
    actor:SetName("ActorVoxel")
    actor:SetAIType(Actor.AIT_AGENTOBJECT)
    actor:SetModel(voxelSection)
    actor:GetAIAgentBase():UsePhysics(g_manykit._isUsePhysics)
    if g_manykit._isUsePhysics then
        actor:SetPhysicsShapeType(Actor.PST_MESHSTATIC, voxelSection)
    end
    nodeVoxel:AttachChild(actor)
    scene:AddActor(actor)

    scene:SetVoxelSection(self._vs)

    self._vs:Show(self._isUseVoxel)
end
-------------------------------------------------------------------------------
function p_mworld:_SaveVoxelSectionCfgParam()
	print(self._name.." p_mworld:_SaveVoxelSectionCfgParam")

    local id = self._curmapid

    -- PX2_PROJ:SetConfig("mworld_vs_landscapeoctaves".."_"..id, self.LandscapeOctaves)
    -- PX2_PROJ:SetConfig("mworld_vs_landscapepersistence".."_"..id, self.LandscapePersistence)
    -- PX2_PROJ:SetConfig("mworld_vs_landscapescale".."_"..id, self.LandscapeScale)
    -- PX2_PROJ:SetConfig("mworld_vs_mountainoctaves".."_"..id, self.MountainOctaves)
    -- PX2_PROJ:SetConfig("mworld_vs_mountainpersistence".."_"..id, self.MountainPersistence)
    -- PX2_PROJ:SetConfig("mworld_vs_mountainscale".."_"..id, self.MountainScale)
    -- PX2_PROJ:SetConfig("mworld_vs_mountainmultiplier".."_"..id, self.MountainMultiplier)
end
-------------------------------------------------------------------------------
function p_mworld:_GetBarSelectBlockType()
	local scene = PX2_PROJ:GetScene()
	local mainActor = scene:GetMainActor()
	local bt = 0

	if mainActor then
		local skillChara = mainActor:GetSkillChara()
		local itemID = self._itemSelectIDBar
		if itemID>0 then
			local item = skillChara:GetItemByID(itemID)
			if item then
				local typeID = item:GetTypeID()
				local itemDef = item:GetDefItem()
				local charaID = itemDef.CharaID

				if DefItem.T_NORMAL==itemDef.TheType then
				elseif DefItem.T_BLOCK==itemDef.TheType then
					bt = StringHelp:StringToInt(itemDef.Mtl)
				end
			end
		end
	end

	return bt
end
-------------------------------------------------------------------------------