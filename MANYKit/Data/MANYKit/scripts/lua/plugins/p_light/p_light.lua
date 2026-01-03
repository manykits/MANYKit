-- p_light.lua
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_actor.lua")
-------------------------------------------------------------------------------
p_light = class(p_actor,
{
    _requires = {"p_actor", "p_net", },
	_name = "p_light",
    _titlesize = 5,
    _sz = 10.4,
    
    _lightNode = nil,
    _lightMesh = nil,

    _lightRange = 10.0,
    _lightIntensity = 1.0, 
})
-------------------------------------------------------------------------------
function p_light:OnAttached()
	PX2_LM_APP:AddItem(self._name, "Light", "灯光")

	local defM = DefModel()
    defM.ID = 80004
    defM.Name = "灯光"
    defM.Icon = "scripts/lua/plugins/p_mworld/images/items/water.png"
    defM.Model = ""
    defM.Tex = ""
    defM.Model = ""
    defM.Anim = ""
    defM.DefaultAnim = ""
    defM.ModelScale = 1.0
    defM.Length = 1.6
    defM.Width = 1.6
    defM.Height = 3.0
    defM.HeightTitle = 4.0
    PX2_SDM:AddDefModel(defM)

	local defChara = DefChara()
    defChara.ID = 80004
    defChara.Name = "灯光"
    defChara.ModelID = 80004
    defChara.AgentType = 3
    defChara.Script = "p_light"
    defChara.BaseHP = 100
    defChara.BaseAP = 100
    defChara.BaseDP = 100
    PX2_SDM:AddDefChara(defChara)

    local defItem = DefItem()
    defItem.ID = 80004
    defItem.Cata = "army"
    defItem.Icon = "scripts/lua/plugins/p_mworld/images/items/water.png"
    defItem.Name = "灯光"
    defItem.Desc = "灯光"
    defItem.iType = 0
    defItem.TheType = DefItem.T_NORMAL
    defItem.Mtl = ""
    defItem.Anchor = ""
    defItem.SkillID = 0
    defItem.BufID = 0
    defItem.CharaID = 80004
    defItem.MonsterID = 0
    defItem.UserData = "10-1"
    PX2_SDM:AddDefItem(defItem)

    self._sz = self._titlesize * 2 + 0.4

	p_actor.OnAttached(self)
	print(self._name.." p_light:OnAttached")
end
-------------------------------------------------------------------------------
function p_light:OnInitUpdate()
	print(self._name.." p_light:OnInitUpdate")

	p_actor.OnInitUpdate(self)
end
-------------------------------------------------------------------------------
function p_light:_Cleanup()
	print(self._name.." p_light:_Cleanup")

    p_actor._Cleanup(self)
end
-------------------------------------------------------------------------------
function p_light:OnPPlay()
	print(self._name.." p_light:OnPPlay")

    p_actor.OnPPlay(self)
end
-------------------------------------------------------------------------------
function p_light:OnFixUpdate()
	local t = self._dt

    p_actor.OnFixUpdate(self)
end
-------------------------------------------------------------------------------
function p_light:OnPUpdate()
    local t = PX2_APP:GetElapsedSecondsWidthSpeed()
    p_actor._OnPUpdate(self)
    
end
---------------------------------------------------------------
function p_light:_OnCreateSceneInstance()
	print(self._name.." p_light:_OnCreateSceneInstance")

    p_actor._OnCreateSceneInstance(self)

    if self._actor then
        local skillChara = self._actor:GetSkillChara()
	    local defModel = skillChara:GetDefModel()
	    local nodeRoot = self._actor:GetNodeRoot()
	    local nodeModel = self._actor:GetNodeModel()

        local ln = PX2_CREATER:CreateLightNode()
        ln.LocalTransform:SetTranslateZ(2.0)
        self._lightNode = ln
        self._actor:SetModel(ln)

        local lm = ln:GetObjectByName("LightMesh")
        local lmMov = Cast:ToMovable(lm)
        self._lightMesh = lmMov
        if lmMov then
            lmMov:Show(false)
        end
    end
end
-------------------------------------------------------------------------------
function p_light:_Cleanup()
	print(self._name.." p_light:_Cleanup")

    p_actor._Cleanup(self)

    local scene = PX2_PROJ:GetScene()
    if scene then
        scene:SetNeedReCalCollect(true)
    end
end
-------------------------------------------------------------------------------
-- property
-------------------------------------------------------------------------------
function p_light:_GetPropertiesValue()
	print(self._name.." p_light:_GetPropertiesValue")

    p_actor._GetPropertiesValue(self)

    self._lightRange = self._node:PFloat("LightRange", self._lightRange)
	self._lightIntensity = self._node:PFloat("LightIntensity", self._lightIntensity)
end
-------------------------------------------------------------------------------
function p_light:_RegistProperties()
	print(self._name.." p_light:_RegistProperties")

    p_actor._RegistProperties(self)    

    self._node:AddPropertyClass("Light", "灯光")

    self._node:AddPropertyFloatSlider("LightRange", "范围", self._lightRange, 0, 100.0, true, true)
    self._node:AddPropertyFloatSlider("LightIntensity", "亮度", self._lightIntensity, 0, 5.0, true, true)
end
-------------------------------------------------------------------------------
function p_light:_OnPropertyAct()
    print(self._name.." p_light:_OnPropertyAct")

    p_actor._OnPropertyAct(self)

    local light = self._lightNode:GetLight()
    light.Range = self._lightRange
    light.Intensity = self._lightIntensity
end
-------------------------------------------------------------------------------
function p_light:_SetLightRange(range)
    print(self._name.." p_light:_SetLightRange")

    self._lightRange = range

    local light = self._lightNode:GetLight()
    light.Range = self._lightRange
end
-------------------------------------------------------------------------------
function p_light:_SetLightIntensity(intens)
    print(self._name.." p_light:_SetLightRange")

    self.Intensity = intens

    local light = self._lightNode:GetLight()
    light.Range = self._lightRange
end
-------------------------------------------------------------------------------
-- simu
function p_light:_Simu(simu)
	print(self._name.." p_light:_Simu")
	print_i_b(simu)

    p_actor._Simu(self, simu)
end
---------------------------------------------------------------
g_manykit:plugin_regist(p_light)
---------------------------------------------------------------