-- p_actorproperty.lua
-------------------------------------------------------------------------------
function p_actor:_RegistProperty()
	print(self._name.." p_actor:_RegistProperty")

	self:_GetPropertiesValue()

	self._node:RemoveProperties("Actor")	
	self._node:BeginPropertyCata("Actor")

	self:_RegistProperties()

	self._node:EndPropertyCata()
end
-------------------------------------------------------------------------------
function p_actor:_GetPropertiesValue()
	print(self._name.." p_actor:_GetPropertiesValue")

	if self._node then
		self._bornDist = self._node:PFloat("BornDist", self._bornDist)
		self._modelPercent = self._node:PFloat("ModelClodPercent", self._modelPercent)
		self._isActivate = self._node:PBool("IsActivate", self._isActivate)
		self._renderStyle = self._node:PInt("RenderStyle", self._renderStyle)
	end
end
-------------------------------------------------------------------------------
function p_actor:_RegistProperties()
	print(self._name.." p_actor:_RegistProperties")

	local act = self._actor
	local id = act:GetID()
	local agent = act:GetAIAgent()
	local schara = self._actor:GetSkillChara()
	local id = self._node:GetID()
	local scale = self._node.LocalTransform:GetScale()
	local pos = self._node.LocalTransform:GetTranslate()
	local rot = self._node.LocalTransform:GetRotateDegreeXYZ()
	local isBeMyS = schara:IsBeMyS()

	self._node:AddPropertyClass("Actor", "对象")
	self._node:AddPropertyInt("IDD", "ID", id, false, true)
	if self._uin>0 then
		self._node:AddPropertyInt("UIN", "UIN", self._uin, false, false)
	end
	self._node:AddPropertyBool("IsBeMyS", "IsBeMyS", isBeMyS, false, false)
	self._node:AddPropertyInt("TypeID", "类型ID", self._typeid, false, true)
	self._node:AddPropertyAPoint("Scale", "缩放", scale, false, false)
	self._node:AddPropertyAPoint("Position", "位置", pos, false, false)
	self._node:AddPropertyAPoint("Rotate", "旋转", rot, false, false)

	self._node:AddPropertyBool("IsActivate", "激活", self._isActivate, true, true)
	
	self._node:AddPropertyFloatSlider("BornDist", "出生距离", self._bornDist, 0, 500, true, true)
	self._node:AddPropertyFloatSlider("ModelClodPercent", "模型细节", self._modelPercent, 0, 1.0, true, false)

	PX2Table2Vector({"系统", "光照", "实时阴影", "法线贴图", "PBR"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({"Lighting", "Shadow", "Normal", "PBR"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._node:AddPropertyEnumUserData("RenderStyle", "渲染样式", self._renderStyle, vec, vec1, vec2, true, true)
end
-------------------------------------------------------------------------------
function p_actor:_OnPropertyAct()
	print(self._name.." p_actor:_OnPropertyAct")

	self:_GetPropertiesValue()

	if self._node then
		if self._actor then
			local model = self._actor:GetModel()
			if model then
				local rs = self._renderStyle
				if 0==rs then
				    rs = p_holospace._g_renderStyle
				else
					rs = self._renderStyle-1
			    end			
				model:SetRenderStyle(rs, true)
			end
		
			local isOnlyObst = self._node:PBool("IsOnlyObst")
			local modelPercent = self._node:PFloat("ModelClodPercent")
			local lodType = self._node:PInt("LODType")
			if self._actor:IsUseClodMesh() then
				self._actor:SetClodMeshPercent(modelPercent)
			end
			self._actor:SetLodType(lodType)
			self:_SetActivate(self._isActivate)
		end
	end
end
-------------------------------------------------------------------------------
function p_actor:_OnPropertyButton(prop)
	print(self._name.." p_actor:_OnPropertyButton:"..prop.Name)	

	if "ActivateSkillDefault"==prop.Name then
		local skillChara = self._actor:GetSkillChara()
		if skillChara then
			local defSkill = skillChara:GetDefSkill()
			if defSkill then
				self:_CheckSkillActivate(defSkill, nil, nil, true)
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_actor:_OnEdit(edit)
	print(self._name.." p_actor:_OnEdit")
	print("_OnEdit:")
	print_i_b(edit)
end
-------------------------------------------------------------------------------
function p_actor:_RegistPropertyEdit()
	print(self._name.." p_actor:_RegistPropertyEdit")
end
-------------------------------------------------------------------------------
function p_actor:_OnPropertyEditChanged(pObj)
	print(self._name.." p_actor:_OnPropertyEditChanged")
	print("pObj.Name:"..pObj.Name)


end
-------------------------------------------------------------------------------