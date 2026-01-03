-- p_actorpick.lua
-------------------------------------------------------------------------------
function p_actor:_OnSelected(tag)
	print(self._name.." p_actor:_OnSelected:"..tag)

	local mpO = self._actor:GetObjectByID(p_actor._g_idModelPick)
	local mpMov = Cast:ToMovable(mpO)
	if mpMov then
		mpMov:Show(true, false)
	end

	if "edit"==tag then
		local bpsctrl = self._actor:GetObjectByID(100)
		if bpsctrl then
			PX2_LOGICM:SetSelectLogicObject(bpsctrl)
		end

		if self._nodeRange then
			self._nodeRange:Show(true, false)
		end
	end
end
-------------------------------------------------------------------------------
function p_actor:_OnDisSelected(tag)
	print(self._name.." p_actor:_OnDisSelected:"..tag)

	local mpO = self._actor:GetObjectByID(p_actor._g_idModelPick)
	local mpMov = Cast:ToMovable(mpO)
	if mpMov then
		mpMov:Show(false, false)
	end  

	if "edit"==tag then
		local bpsctrl = self._actor:GetObjectByID(100)
		if bpsctrl then
			PX2_LOGICM:SetSelectLogicObject(nil)
		end

		if self._nodeRange then
			self._nodeRange:Show(false, false)
		end
	end
end
-------------------------------------------------------------------------------
function p_actor:_OnEditPick(pickobj, worldPos, worldNormal, ptype, isMoved, mouseTag)
	print(self._name.." p_actor:_OnEditPick:")
	print("worldPos:"..worldPos:ToString())
	print("worldNormal:"..worldNormal:ToString())
	print("ptype:"..ptype)
	print("isMoved:")
	print_i_b(isMoved)
	print("mouseTag:"..mouseTag)

end
-------------------------------------------------------------------------------
function p_actor:_PickHeight(origin, isOnlyTerrain, needNormal)
	local id = self._actor:GetID()

	local scene = PX2_PROJ:GetScene()
	local terrain = scene:GetTerrain()
	if terrain then
		if isOnlyTerrain then
			local pX = origin:X()
			local pY = origin:Y()
			local h = terrain:GetHeight(pX, pY)
			local nor = AVector(0.0, 0.0, 1.0)
			if needNormal then
				nor = terrain:GetNormal(pX, pY)
			end
			return h, nor
		else
			local worldPos, worldNormal = manykit_PickScenePos(origin, 2.2, self._actor)

			local pX = origin:X()
			local pY = origin:Y()
			local h = terrain:GetHeight(pX, pY)
			if worldPos:Z() < h then
				worldPos:SetZ(h)
			end
			return worldPos:Z(), worldNormal
		end
	end
end
-------------------------------------------------------------------------------