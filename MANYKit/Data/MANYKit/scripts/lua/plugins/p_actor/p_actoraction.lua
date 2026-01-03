-- p_actoraction.lua
-------------------------------------------------------------------------------
function p_actor:_SetActivate(act)
	print(self._name.." p_actor:_SetActivate")
	print_i_b(act)

	self._isActivate = act

	if self._actor then
		self._actor:EnableAgent(act)
	end
end
-------------------------------------------------------------------------------
function p_actor:_OnDie()
	print(self._name.." p_actor:_OnDie")

	if self._agent then
		self._agent:SetSpeed(0.0)
		self._agent:ClearPath()
		self._agent:SetDead()

		if self._bdbar then
			self._bdbar:Show(true)
		end

		if self._fTextName then
			self._fTextName:Show(true)
		end

		if p_net._g_net._islogicserver then
			PX2_GH:SendGeneralEvent("ActorDie", ""..self._id)
		end
	end

	print("_OnDie Over")
end
-------------------------------------------------------------------------------
function p_actor:_OnReAlive()
	print(self._name.." p_actor:_OnReAlive")
	
end
-------------------------------------------------------------------------------