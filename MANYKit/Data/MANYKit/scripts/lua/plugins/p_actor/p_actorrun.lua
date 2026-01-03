-- p_actorupdate.lua

-------------------------------------------------------------------------------
function p_actor:_DownHeight()
	local seconds = PX2_APP:GetElapsedSeconds()
	self._downheighttiming = self._downheighttiming + seconds

	if self._downheighttiming > self._downheighttime then
		self._downheighttiming = 0.0

		if self._agentBase then
			local pos = self._agentBase:GetPosition()
			local pos1 = APoint(pos:X(), pos:Y(), pos:Z())
	
			self._hworld = self:_PickHeight(pos1, false)
			
			pos1:SetZ(self._hworld)
			
			self._agentBase:SetPosition(pos1)
		end
	end
end
-------------------------------------------------------------------------------
function p_actor:_Simu(simu)
	print(self._name.." p_actor:_Simu")
	print_i_b(simu)

	self._isSimuing = simu

	if simu then
		self._scriptControl:ResetPlay()

		if self._bdbar then
			if self._isAutoHideHeadBar then
				self._bdbar:Show(false)
			end
		end

		if self._agent then
			self._agent:ResetPlay()
		end

		self:_SetActivate(self._isActivate)
	else
		self._scriptControl:Pause()

		if self._fTextName then
			self._fTextName:Show(true)
		end

		if self._bdbar then
			self._bdbar:Show(true)
		end

		self._actor:Show(true)

		if self._agent then
			self._agent:SetSpawning()
			self._agent:Pause()
		
			self:_OnPropertyAct()
		end
	end
end
-------------------------------------------------------------------------------