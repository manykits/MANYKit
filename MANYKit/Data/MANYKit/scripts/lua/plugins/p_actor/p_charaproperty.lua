-- p_charaproperty.lua
-------------------------------------------------------------------------------
function p_chara:_GetPropertiesValue()
	print(self._name.." p_chara:_GetPropertiesValue")
	
	p_actor._GetPropertiesValue(self)

	if self._uin > 0 then
		--self._enablegp = false
	end
	self._group = self._node:PInt("Group")
	self._hpIdx = self._node:PInt("HP")
	self._tempture = self._node:PFloat("Tempture")
	self._seeDist = self._node:PFloat("SeeDist")
	self._seeDegreeIndex = self._node:PInt("SeeDegree")

	self._animblendmode = self._node:PInt("AnimBlendMode")

	self._anim = self._node:PInt("Anim")
	self._animnodenames = self._node:PString("AnimNodeNames")

	self._anim1 = self._node:PInt("Anim1")
	self._animnodenames1 = self._node:PString("AnimNodeNames1")

	self._aiAction = self._node:PInt("AIAction")
	self._aiPath = self._node:PString("AIPathV")
end
-------------------------------------------------------------------------------
function p_chara:_RegistProperties()
	print(self._name.." p_actor:_RegistProperties")

    p_actor._RegistProperties(self)

	local act = self._actor

	local id = act:GetID()
	local agent = act:GetAIAgent()
	local schara = self._actor:GetSkillChara()
	local id = self._node:GetID()
	local scale = self._node.LocalTransform:GetScale()
	local pos = self._node.LocalTransform:GetTranslate()
	local rot = self._node.LocalTransform:GetRotateDegreeXYZ()

	self._node:AddPropertyClass("Character", "Character")
	PX2Table2Vector({ "0", "1", "2" })
	self._node:AddPropertyEnum("Group", "阵营", self._group, PX2_GH:Vec(), self._enablegp, self._enablegp)
	local maxhp = schara:GetMaxHP()
	local curhp = schara:GetCurHP()
	local curap  =schara:GetCurAP()
	self._node:AddPropertyInt("MaxHP", "最大生命值", maxhp, false, false)
	self._node:AddPropertyInt("CurHP", "当前生命值", curhp, false, false)--

	self._node:AddPropertyInt("AP", "攻击力", curap, false, false)

	self._node:AddPropertyFloatSlider("Tempture", "温度", self._tempture, -10, 100, true, true)

	PX2Table2Vector({"30", "45", "60", "90", "360"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({"30", "45", "60", "90", "360"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._node:AddPropertyEnumUserData("SeeDegree", "视角", self._seeDegreeIndex, vec, vec1, vec2, true, true)
	self._node:AddPropertyFloatSlider("SeeDist", "视距", self._seeDist, 0, 500, true, true)

	PX2Table2Vector({"默认", "融合"})
	local vec = PX2_GH:Vec()
	self._node:AddPropertyEnum("AnimBlendMode", "动画模式", self._animblendmode, vec, true, true)

	local mctrl = self._actor:GetModelController()
	if mctrl then
		local tab = {}
		local numAnim = mctrl:GetNumAnims()
		for a=0, numAnim-1, 1 do
			local anim = mctrl:GetAnim(a)
			local t = anim:GetTitle()
			local na = anim:GetName()
			table.insert(tab, #tab+1, na)
		end
		PX2Table2Vector(tab)
		local vec = PX2_GH:Vec()
		self._node:AddPropertyEnum("Anim", "动画", self._anim, vec, true, true)
	end
	self._node:AddPropertyString("AnimNodeNames", "动画骨骼", self._animnodenames, true, true)

	if mctrl then
		local tab = {}
		local numAnim = mctrl:GetNumAnims()
		for a=0, numAnim-1, 1 do
			local anim = mctrl:GetAnim(a)
			local t = anim:GetTitle()
			local na = anim:GetName()
			table.insert(tab, #tab+1, na)
		end
		PX2Table2Vector(tab)
		self._node:AddPropertyEnum("Anim1", "动画1", self._anim1, PX2_GH:Vec(), true, true)
	end
	self._node:AddPropertyString("AnimNodeNames1", "动画骨骼1", self._animnodenames1, true, true)

	local numSkill = schara:GetNumSkills()
	local numEquipSkill = schara:GetNumEquippedSkill()
	self._node:AddPropertyInt("NumSkill", "技能数量", numSkill, false, false)
	self._node:AddPropertyInt("NumSkillEquip", "装备技能数", numEquipSkill, false, false)
    self._node:AddPropertyButton("ActivateSkillDefault", "触发基础技能")

	self._node:AddPropertyClass("AI", "智能")
	PX2Table2Vector({"待机", "巡逻"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({"idle", "patrol"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._node:AddPropertyEnumUserData("AIAction", "行为", self._aiAction, vec, vec1, vec2, true, true)

	local tabpaths = self:_GetPathActorIDs()
	PX2Table2Vector(tabpaths)
	local vec = PX2_GH:Vec()
	local tab2 = {}
	PX2Table2Vector(tab2)
	local vec2 = PX2_GH:Vec()
	self._node:AddPropertyEnumUserData1("AIPathV", "巡逻路径", self._aiPath, vec, vec, vec2, true, true)
end
-------------------------------------------------------------------------------
function p_chara:_GetPathActorIDs()
	local ids = {0,}
	local scene = PX2_PROJ:GetScene()
	if scene then
		local numActors = scene:CalGetNumActors()
		for i=0, numActors-1, 1 do 
            local act = scene:GetActor(i)
			local id = act:GetID()
			
			local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
			if scCtrl then
				-- if scCtrl._cfg.name=="path" then
				-- 	table.insert(ids, #ids + 1, id)
				-- end
			end
		end
	end

	return ids
end
-------------------------------------------------------------------------------
function p_chara:_OnPropertyAct()
	print(self._name.." p_chara:_OnPropertyAct")

    p_actor._OnPropertyAct(self)
	
	local group = self._node:PInt("Group")
	if self._uin > 0 then
		--group = self:_GetGroupByParty()
	end
    self:_SetGroup(group)

	local animBlendMode = self._node:PInt("AnimBlendMode")
	local animIndex = self._node:PInt("Anim")
	local animIndex1 = self._node:PInt("Anim1")

	local mctrl = self._actor:GetModelController()
	if mctrl then
		mctrl:SetAnimBlendMode(animBlendMode)
		
		local anim = mctrl:GetAnim(animIndex)
		if anim then
			if 0==self._animblendmode then
				mctrl:PlayAnim(anim, self._animnodenames)
			else
				mctrl:ClearCurAnims()

				mctrl:PlayAnim(anim, self._animnodenames)

				local anim1 = mctrl:GetAnim(animIndex1)
				if anim1 then
					mctrl:PlayAnim(anim1, self._animnodenames1)
				end
			end
		end
	end

	local hp = self._node:PEnumData2("HP")
	local seeDist = self._node:PFloat("SeeDist")
	local seeDegreeIndex = self._node:PInt("SeeDegree")
	local seeDegree = self._node:PEnumData2Int("SeeDegree")

	if self._nodeRange then
		self._nodeRange:SetActiveChildByIndex(seeDegreeIndex)
		self._nodeRange.LocalTransform:SetUniformScale(seeDist)
	end
	
	self._seeDist = seeDist
	if self._agent then
		self._agent:SetFieldOfView(seeDegree * DEG_TO_RAD)
		self._agent:SetFieldOfViewDistance(seeDist)
		self._agent:SetAttackDistance(seeDist)
	end

	if self._node then
		print("has node----------------------------------------")
	end
end
-------------------------------------------------------------------------------
function p_chara:_OnPropertyButton(prop)
	print(self._name.." p_actor:_OnPropertyButton:"..prop.Name)	

	p_actor._OnPropertyButton(self, prop)
end
-------------------------------------------------------------------------------