-- p_landmine.lua
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_chara.lua")
-------------------------------------------------------------------------------
p_landmine = class(p_chara,
{
    _requires = {"p_chara", "p_net", },
	_name = "p_landmine",
})
-------------------------------------------------------------------------------
function p_landmine:OnAttached()
	print(self._name.." p_landmine:OnAttached")

    PX2_LM_APP:AddItem(self._name, "Landmine", "地雷")

	p_chara.OnAttached(self)	
end
-------------------------------------------------------------------------------
function p_landmine:OnInitUpdate()
    print(self._name.." p_landmine:OnInitUpdate")

	p_chara.OnInitUpdate(self)
end
-------------------------------------------------------------------------------
function p_landmine:_Cleanup()
	print(self._name.." p_landmine:_Cleanup")

    p_chara._Cleanup(self)
end
-------------------------------------------------------------------------------
function p_landmine:OnPPlay()
	print(self._name.." p_landmine:OnPPlay")

    p_chara.OnPPlay(self)
end
-------------------------------------------------------------------------------
function p_landmine:OnFixUpdate()
	local t = self._dt

    p_chara.OnFixUpdate(self)
end
-------------------------------------------------------------------------------
function p_landmine:_OnCreateSceneInstance()
	print(self._name.." p_landmine:_OnCreateSceneInstance")

	p_chara._OnCreateSceneInstance(self)
end
-------------------------------------------------------------------------------
-- property
function p_landmine:_GetPropertiesValue()
	print(self._name.." p_landmine:_GetPropertiesValue")

    p_chara._GetPropertiesValue(self)
end
-------------------------------------------------------------------------------
function p_landmine:_RegistProperties()
	print(self._name.." p_landmine:_RegistProperties")

    p_chara._RegistProperties(self)

    self._node:AddPropertyClass("Landmine", "Landmine")

    self._node:AddPropertyButton("Test", "Test")
end
-------------------------------------------------------------------------------
function p_landmine:_OnPropertyAct()
    print(self._name.." p_landmine:_OnPropertyAct")

    p_chara._OnPropertyAct(self)
end
-------------------------------------------------------------------------------
function p_landmine:_OnPropertyButton(prop)
	print(self._name.." p_landmine:_OnPropertyButton:"..prop.Name)

    p_chara._OnPropertyButton(self, prop)
end
-------------------------------------------------------------------------------
function p_landmine:_OnSelected(tag)
	print(self._name.." p_landmine:_OnSelected:"..tag)

    p_chara._OnSelected(self, tag)
end
-------------------------------------------------------------------------------
function p_landmine:_OnDisSelected(tag)
	print(self._name.." p_landmine:_OnDisSelected:"..tag)

    p_chara._OnDisSelected(self, tag)
end
-------------------------------------------------------------------------------
-- simu
function p_landmine:_Simu(simu)
	print(self._name.." p_landmine:_Simu")
	print_i_b(simu)

    p_chara._Simu(self, simu)
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_landmine)
-------------------------------------------------------------------------------