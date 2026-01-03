-- p_voxel.lua
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_actor.lua")
-------------------------------------------------------------------------------
p_voxel = class(p_actor,
{
    _requires = {"p_actor", },

	_name = "p_voxel",
    _titlesize = 5,
    _sz = 10.4,

	_vl = 1,
	_vw = 1,
	_vh = 1,

	_editMode = 0,
})
-------------------------------------------------------------------------------
function p_voxel:OnAttached()
	PX2_LM_APP:AddItem(self._name, "Voxel", "体素")

	local defM = DefModel()
    defM.ID = 42003
    defM.Name = "体素"
    defM.Icon = "scripts/lua/plugins/p_mworld/images/items/voxel.png"
    defM.Model = ""
    defM.Tex = ""
    defM.Model = ""
    defM.Anim = ""
    defM.DefaultAnim = ""
    defM.ModelScale = 1.0
    defM.Length = 1.0
    defM.Width = 1.0
    defM.Height = 1.0
    defM.HeightTitle = 1.0
    PX2_SDM:AddDefModel(defM)

	local defChara = DefChara()
    defChara.ID = 10003
    defChara.Name = "体素"
    defChara.ModelID = 42003
    defChara.AgentType = 3
    defChara.Script = "p_voxel"
    defChara.BaseHP = 100
    defChara.BaseAP = 100
    defChara.BaseDP = 100
    PX2_SDM:AddDefChara(defChara)

    local defItem = DefItem()
    defItem.ID = 40003
    defItem.Icon = "scripts/lua/plugins/p_mworld/images/items/voxel.png"
    defItem.Name = "体素"
    defItem.Desc = "体素"
    defItem.iType = 0
    defItem.TheType = DefItem.T_NORMAL
    defItem.Mtl = ""
    defItem.Anchor = ""
    defItem.SkillID = 0
    defItem.BufID = 0
    defItem.CharaID = 10003
    defItem.MonsterID = 0
    PX2_SDM:AddDefItem(defItem)

    self._sz = self._titlesize * 2 + 0.4

	p_actor.OnAttached(self)
	print(self._name.." p_voxel:OnAttached")
end
-------------------------------------------------------------------------------
function p_voxel:OnInitUpdate()
	p_actor.OnInitUpdate(self)

	print(self._name.." p_voxel:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_voxel:_Cleanup()
	print(self._name.." p_voxel:_Cleanup")
end
-------------------------------------------------------------------------------
function p_voxel:OnPPlay()
	print(self._name.." p_voxel:OnPPlay")
end
-------------------------------------------------------------------------------
function p_voxel:OnFixUpdate()
	local t = self._dt

end
-------------------------------------------------------------------------------
function p_voxel:OnPUpdate()
    local t = PX2_APP:GetElapsedSecondsWidthSpeed()
end
-------------------------------------------------------------------------------
function p_voxel:_OnCreateSceneInstance()
	print(self._name.." p_voxel:_OnCreateSceneInstance")
    p_actor._OnCreateSceneInstance(self)

    if self._actor then
        local skillChara = self._actor:GetSkillChara()
	    local defModel = skillChara:GetDefModel()
	    local nodeRoot = self._actor:GetNodeRoot()
	    local nodeModel = self._actor:GetNodeModel()

        local voxel = PX2_CREATER:CreateVoxelSection(self._titlesize, 1, 
          1, 0, 0,
          6, 6, 
          0)
        voxel:SetID(self._id)

        self._actor:SetModel(voxel)
        local savePath = V_SectionData:GetSavePath()..self._id..".json"
        if PX2_RM:IsFileFloderExist(savePath) then
            voxel:LoadFromJSONObject(savePath)
        else
            voxel:SaveToJSONObject(savePath)
        end
    end
end
-------------------------------------------------------------------------------
function p_voxel:_CreateSelectBox()
    print(self._name.." p_actor:_CreateSelectBox")

	if self._actor then
	    local skillChara = self._actor:GetSkillChara()
	    local defModel = skillChara:GetDefModel()
	    local nodeRoot = self._actor:GetNodeRoot()
	    local nodeModel = self._actor:GetNodeModel()
	    nodeModel:SetDoPick(false)

	    -- select
	    local mp = PX2_CREATER:CreateMovable_Box("engine/white.png")
	    nodeRoot:AttachChild(mp)
	    mp:SetName("ModelModelPick")
	    mp:SetID(p_actor._g_idModelPick)
	    mp.LocalTransform:SetScale(APoint(self._sz, self._sz, 0.1))
	    mp:Show(true, false)
	    mp:SetRenderStyle(Movable.RS_LIGHTING, true)
	    mp:SetCastShadow(false)
	    mp:SetDoPick(true)
	    mp.LocalTransform:SetTranslateZ(0.05)
	    mp:SetAlphaSelfCtrled(true)
	    mp:SetUserDataString("id", ""..self._id)
	    local r = Cast:ToRenderable(mp)
	    if r then
		    r:SetRenderLayer(Renderable.RL_SCENE, 1)
	    end
	    
		local pd = PropertySetData()
	    pd.DoSetBlend = true
	    pd.BlendType = 1
	    pd.DoSetAlpha = true
	    pd.Alpha = 0.4
	    pd.DoSetShine = true
	    pd.ShineEmissive = Float4(1.0, 1.0, 0.0, 0.4)
	    pd.ShineAmbient = Float4(0.0, 0.0, 1.0, 0.4)
	    PX2_GH:SetObjectMtlProperty(mp, pd)
	    mp:RegistToScriptSystem()
    end
end
-------------------------------------------------------------------------------
function p_voxel:_GetPropertiesValue()
	print(self._name.." p_voxel:_GetPropertiesValue")

    p_actor._GetPropertiesValue(self)

	self._vl = self._node:PInt("VLength", self._vl)
	self._vw = self._node:PInt("VWidth", self._vw)
	self._vh = self._node:PInt("VHeight", self._vh)

	print("self._vl:"..self._vl)
	print("self._vw:"..self._vw)
	print("self._vh:"..self._vh)
end
-------------------------------------------------------------------------------
function p_voxel:_RegistProperties()
	print(self._name.." p_voxel:_RegistProperties")

    p_actor._RegistProperties(self)

    self._node:AddPropertyClass("Voxel", "体素")

	PX2Table2Vector({ "1", "2", "4", "5", "10"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({ "1", "2", "4", "5", "10"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._node:AddPropertyEnumUserData("VLength", "长", self._vl, vec, vec1, vec2, true, true)
	self._node:AddPropertyEnumUserData("VWidth", "宽", self._vw, vec, vec1, vec2, true, true)
	self._node:AddPropertyEnumUserData("VHeight", "高", self._vh, vec, vec1, vec2, true, true)
end
-------------------------------------------------------------------------------
function p_voxel:_OnPropertyAct()
    print(self._name.." p_voxel:_OnPropertyActttttttttttttttttttttttttttt")

    p_actor._OnPropertyAct(self)

	local model = self._actor:GetModel()
	local vs = Cast:ToVoxelSection(model)
	if vs then
		local vl0 =  self._node:PInt("VLength")
		local vw0 =  self._node:PInt("VWidth")
		local vh0 =  self._node:PInt("VHeight")
		print("vl0:"..vl0)
		print("vw0:"..vw0)
		print("vh0:"..vh0)

		local vl =  self._node:PEnumData2Int("VLength")
		local vw =  self._node:PEnumData2Int("VWidth")
		local vh =  self._node:PEnumData2Int("VHeight")
	
		print("vl:"..vl)
		print("vw:"..vw)
		print("vh:"..vh)

		vs:SetMinSize(-vl, -vw, 0)
		vs:SetMaxSize(vl-1, vw-1, vh)
		vs:SetInitMtlType(0)

		local id = vs:GetID()
		local savePath = V_SectionData:GetSavePath()..id..".json"
		vs:SaveToJSONObject(savePath)

		local sz = vl*10
		local w = vw*10

		local nodeRoot = self._actor:GetNodeRoot()
		local modelPick = nodeRoot:GetObjectByID(p_actor._g_idModelPick)
		local modelPickMov = Cast:ToMovable(modelPick)
		if modelPickMov then
			modelPickMov.LocalTransform:SetScale(APoint(sz+0.1, w+0.1, 0.2))
		end
	end
end
-------------------------------------------------------------------------------
function p_voxel:_OnPropertyButton(prop)
	print(self._name.." p_voxel:_OnPropertyButton:"..prop.Name)
end
-------------------------------------------------------------------------------
function p_voxel:_OnSelected(tag)
	print(self._name.." p_voxel:_OnSelected:"..tag)

    p_actor._OnSelected(self, tag)

    local mpO = self._actor:GetObjectByID(p_actor._g_idModelPick)
	local mpMov = Cast:ToMovable(mpO)
	if mpMov then
		mpMov:Show(true, false)
	end  
end
-------------------------------------------------------------------------------
function p_voxel:_OnDisSelected(tag)
	print(self._name.." p_voxel:_OnDisSelected:"..tag)

    p_actor._OnDisSelected(self, tag)

    local mpO = self._actor:GetObjectByID(p_actor._g_idModelPick)
	local mpMov = Cast:ToMovable(mpO)
	if mpMov then
		mpMov:Show(true, false)
	end  
end
-------------------------------------------------------------------------------
function p_voxel:_OnEdit(edit)
	print(self._name.." p_voxel:_OnEdit")

	p_actor._OnEdit(self, edit)

	print("_OnEdit:")
	print_i_b(edit)
end
-------------------------------------------------------------------------------
function p_voxel:_RegistPropertyEdit()
	print(self._name.." p_voxel:_RegistPropertyEdit")

	p_actor._RegistPropertyEdit(self)

	self._scriptControl:RemoveProperties("Edit")

    self._scriptControl:BeginPropertyCata("Edit")
	
    self._scriptControl:AddPropertyClass("VSEdit", "体素")
    PX2Table2Vector({ "无", "增加", "减少" })
	self._scriptControl:AddPropertyEnum("EditMode", "模式", self._editMode, PX2_GH:Vec(), true, true)

    self._scriptControl:EndPropertyCata()
end
-------------------------------------------------------------------------------
function p_voxel:_OnPropertyEditChanged(pObj)
	print(self._name.." p_voxel:_OnPropertyEditChanged")
	print("obj.Name:"..pObj.Name)
	
	p_actor._OnPropertyEditChanged(self, pObj)

	if "EditMode"==pObj.Name then
		local ch = pObj:PInt()
		self._editMode = ch
	end
end
-------------------------------------------------------------------------------
function p_voxel:_OnEditPick(pickobj, worldPos, worldNormal, ptype, isMoved, mouseTag)
	print(self._name.." p_voxel:_OnEditPick:")
	print("worldPos:"..worldPos:ToString())
	print("worldNormal:"..worldNormal:ToString())
	print("ptype:"..ptype)
	print("isMoved:")
	print_i_b(isMoved)
	print("mouseTag:"..mouseTag)

	print("self._editMode:"..self._editMode)

	local scene = PX2_PROJ:GetScene()
	local mainActor = scene:GetMainActor()
	local skillChara = mainActor:GetSkillChara()
	local pw = g_manykit:GetPluginTreeInstanceByName("p_mworld")
	local bt = pw:_GetBarSelectBlockType()

	print("bt:"..bt)

	local targetPos = worldPos - worldNormal * 0.01
	local isdo = false
	if self._editMode==0 then
		isdo = false
	elseif self._editMode==1 then
		-- add
		if bt>0 then
		    isdo = true
		end
		targetPos = worldPos + worldNormal * 0.01
	elseif self._editMode==2 then
		isdo = true
		targetPos = worldPos - worldNormal * 0.01
		bt = 0
	end
	if isdo then
		local model = self._actor:GetModel()
		local vs = Cast:ToVoxelSection(model)
		if vs then
			local id = vs:GetID()

			print("targetPos x:"..targetPos:X().." y:"..targetPos:Y().." z:"..targetPos:Z())
			vs:SetBlock(targetPos, bt, nil)
			if id > 0 then
				local savePath = V_SectionData:GetSavePath()..id..".json"
				vs:SaveToJSONObject(savePath)
			end
		end
	end
end
-------------------------------------------------------------------------------
-- simu
function p_voxel:_Simu(simu)
	print(self._name.." p_voxel:_Simu")
	print_i_b(simu)

    p_actor._Simu(self, simu)
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_voxel)
-------------------------------------------------------------------------------