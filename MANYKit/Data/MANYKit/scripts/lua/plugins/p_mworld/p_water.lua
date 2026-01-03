-- p_water.lua

-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_actor.lua")
-------------------------------------------------------------------------------
p_water = class(p_actor,
{
    _requires = {"p_actor", },

	_name = "p_water",
    _titlesize = 5,
    _sz = 10.4,
})
-------------------------------------------------------------------------------
function p_water:OnAttached()
	PX2_LM_APP:AddItem(self._name, "Water", "水面")

	local defM = DefModel()
    defM.ID = 80003
    defM.Name = "水面"
    defM.Icon = "scripts/lua/plugins/p_mworld/images/items/water.png"
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
    defChara.ID = 80003
    defChara.Name = "水面"
    defChara.ModelID = 80003
    defChara.AgentType = 3
    defChara.Script = "p_water"
    defChara.BaseHP = 100
    defChara.BaseAP = 100
    defChara.BaseDP = 100
    PX2_SDM:AddDefChara(defChara)

    local defItem = DefItem()
    defItem.ID = 80003
    defItem.Cata = "army"
    defItem.Icon = "scripts/lua/plugins/p_mworld/images/items/water.png"
    defItem.Name = "水面"
    defItem.Desc = "水面"
    defItem.iType = 0
    defItem.TheType = DefItem.T_NORMAL
    defItem.Mtl = ""
    defItem.Anchor = ""
    defItem.SkillID = 0
    defItem.BufID = 0
    defItem.CharaID = 80003
    defItem.MonsterID = 0
    defItem.UserData = "10-2"
    PX2_SDM:AddDefItem(defItem)

    self._sz = self._titlesize * 2 + 0.4

	p_actor.OnAttached(self)
	print(self._name.." p_water:OnAttached")
end
-------------------------------------------------------------------------------
function p_water:OnInitUpdate()
	p_actor.OnInitUpdate(self)

	print(self._name.." p_water:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_water:_Cleanup()
	print(self._name.." p_water:_Cleanup")
end
-------------------------------------------------------------------------------
function p_water:OnPPlay()
	print(self._name.." p_water:OnPPlay")
end
-------------------------------------------------------------------------------
function p_water:OnFixUpdate()
	local t = self._dt
end
-------------------------------------------------------------------------------
function p_water:OnPUpdate()
    local t = PX2_APP:GetElapsedSecondsWidthSpeed()

    local nodeRoot = self._actor:GetNodeRoot()
    local obj = PX2_RM:BlockLoadCopy("objects/effect/watersound.px2obj")
    local mov = Cast:ToMovable(obj)
    if mov then
        nodeRoot:AttachChild(mov)
        mov.LocalTransform:SetUniformScale(0.5)
        mov.LocalTransform:SetRotateDegree(0.0, 0.0, 0.0)
        mov.LocalTransform:SetTranslateX(0.0)
        mov.LocalTransform:SetTranslateY(-3.0)
        mov.LocalTransform:SetTranslateZ(-1.0)
    end
    -- mov:Play()
end
-------------------------------------------------------------------------------
function p_water:_OnCreateSceneInstance()
	print(self._name.." p_water:_OnCreateSceneInstance")
    p_actor._OnCreateSceneInstance(self)

    if self._actor then
        local skillChara = self._actor:GetSkillChara()
	    local defModel = skillChara:GetDefModel()
	    local nodeRoot = self._actor:GetNodeRoot()

        local water = PX2_CREATER:CreateWater(8, 8, 4.0)
        self._actor:SetModel(water)
        water.LocalTransform:SetTranslateZ(1.0)
    end
end
-------------------------------------------------------------------------------
function p_water:_GetPropertiesValue()
	print(self._name.." p_water:_GetPropertiesValue")

    p_actor._GetPropertiesValue(self)

end
-------------------------------------------------------------------------------
function p_water:_RegistProperties()
	print(self._name.." p_water:_RegistProperties")

    p_actor._RegistProperties(self)

    self._node:AddPropertyClass("Water", "水面")
end
-------------------------------------------------------------------------------
function p_water:_OnPropertyAct()
    print(self._name.." p_water:_OnPropertyActttttttttttttttttttttttttttt")

    p_actor._OnPropertyAct(self)

	local model = self._actor:GetModel()
end
-------------------------------------------------------------------------------
function p_water:_OnPropertyButton(prop)
	print(self._name.." p_water:_OnPropertyButton:"..prop.Name)
end
-------------------------------------------------------------------------------
function p_water:_OnSelected(tag)
	print(self._name.." p_water:_OnSelected:"..tag)

    p_actor._OnSelected(self, tag)

    local mpO = self._actor:GetObjectByID(p_actor._g_idModelPick)
	local mpMov = Cast:ToMovable(mpO)
	if mpMov then
		mpMov:Show(true, false)
	end  
end
-------------------------------------------------------------------------------
function p_water:_OnDisSelected(tag)
	print(self._name.." p_water:_OnDisSelected:"..tag)

    p_actor._OnDisSelected(self, tag)

    local mpO = self._actor:GetObjectByID(p_actor._g_idModelPick)
	local mpMov = Cast:ToMovable(mpO)
	if mpMov then
		mpMov:Show(true, false)
	end  
end
-------------------------------------------------------------------------------
function p_water:_OnEdit(edit)
	print(self._name.." p_water:_OnEdit")

	p_actor._OnEdit(self, edit)

	print("_OnEdit:")
	print_i_b(edit)
end
-------------------------------------------------------------------------------
function p_water:_RegistPropertyEdit()
	print(self._name.." p_water:_RegistPropertyEdit")

	p_actor._RegistPropertyEdit(self)

	self._scriptControl:RemoveProperties("Edit")

    self._scriptControl:BeginPropertyCata("Edit")
	
    self._scriptControl:EndPropertyCata()
end
-------------------------------------------------------------------------------
function p_water:_OnPropertyEditChanged(pObj)
	print(self._name.." p_water:_OnPropertyEditChanged")
	print("obj.Name:"..pObj.Name)
	
	p_actor._OnPropertyEditChanged(self, pObj)

end
-------------------------------------------------------------------------------
function p_water:_OnEditPick(pickobj, worldPos, worldNormal, ptype, isMoved, mouseTag)
	print(self._name.." p_water:_OnEditPick:")
	print("worldPos:"..worldPos:ToString())
	print("worldNormal:"..worldNormal:ToString())
	print("ptype:"..ptype)
	print("isMoved:")
	print_i_b(isMoved)
	print("mouseTag:"..mouseTag)

	print("self._editMode:"..self._editMode)
end
-------------------------------------------------------------------------------
-- simu
function p_water:_Simu(simu)
	print(self._name.." p_water:_Simu")
	print_i_b(simu)

    p_actor._Simu(self, simu)
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_water)
-------------------------------------------------------------------------------