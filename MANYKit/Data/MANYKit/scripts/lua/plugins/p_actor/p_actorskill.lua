-- p_actorskill.lua
-------------------------------------------------------------------------------
function p_actor:_CreateSkillsAndItems()
	print(self._name.." p_actor:_CreateSkillsAndItems")

	local sc = self._actor:GetSkillChara()
	if sc then
		sc:CreateSkills()
		sc:EquipAllSkills()
		sc:CreateItems()
	end
end
-------------------------------------------------------------------------------