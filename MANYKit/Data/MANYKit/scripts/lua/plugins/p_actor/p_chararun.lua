-- p_chararun.lua
-------------------------------------------------------------------------------
function p_chara:OnFixUpdate()

	p_actor.OnFixUpdate(self)

	local scene = PX2_PROJ:GetScene()
	if scene and self._agentBase then
		if self._isSimuing then
			if self._actor then
				local skillChara = self._actor:GetSkillChara()
				local curHP = skillChara:GetCurHP()
				local maxHP = skillChara:GetMaxHP()
				local id = skillChara:GetID()

				if self._isAutoHideHeadBar then
					if curHP~=self._lastHP then
						if self._bdbar then
							coroutine.wrap(function()
								self._bdbar:Show(true)
								self._fTextName:Show(true)
								sleep(2.0)
								self._bdbar:Show(false)
								self._fTextName:Show(false)
							end)()
						end
					end
				end

				if self._agent then
					self._lastHP = curHP

					self._agent:SetHealth(curHP)
					self._agent:SetMaxHealth(maxHP)				

					if self._agent:IsAlive() then
						if curHP<=0 then
							-- set dead, _RequestStateMachine only once 
							print("curHP < 0")
							self._agent:SetDead()
							if p_net._g_net._islogicserver then
								p_net._g_net:_RequestStateMachine("StateL_Die", "", self._id)
							end
						end
					else
						if curHP>0 then		
							-- set alive, _RequestStateMachine only once 						
							self._agent:SetAlive()
							if p_net._g_net._islogicserver then
								p_net._g_net:_RequestStateMachine("StateL_Alive", "", self._id)
							end
						end
					end
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:_OnPUpdateProcesRunning_TakeMove()
end
-------------------------------------------------------------------------------
function p_chara:_OnPUpdateProcesRunning_NotTakeMove()
end
-------------------------------------------------------------------------------
function p_chara:_OnPUpdate()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()
	local appsec = PX2_APP:GetAppSeconds()
	local scene = PX2_PROJ:GetScene()
	local terrain = scene:GetTerrain()
	local mainActor = scene:GetMainActor()
	local camNodeRoot = scene:GetMainCameraNodeRoot()
	local r = camNodeRoot.WorldTransform:GetRight()
	local d = camNodeRoot.WorldTransform:GetDirection()
	local u = camNodeRoot.WorldTransform:GetUp()
	d:SetZ(0.0)
	d:Normalize()
	r:SetZ(0.0)
	r:Normalize()

	local cameraDist = p_holospace._g_cameraPlayCtrl:GetCameraDistance()
	local cameraDistMin = p_holospace._g_cameraPlayCtrl:GetCameraDistMin()

	if self._agent then
		local id = self._agent:GetID()
		local curPos = self._agent:GetPosition()
		local isAlive = self._agent:IsAlive()
		local isHumainTakeMove = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_MOVE)

		if self._isSimuing then	
            --[[
			if isAlive then
				if mainActor and mainActor==self._actor then
					local tm = self._agent:GetHumanTakePossessed()
					if tm==AIAgent.HTPM_ALL then
						if cameraDist < (cameraDistMin+self._firstViewDist) then	
							p_holospace._g_holospace:_FirstViewOfAgent(self._agent)				
						else
							p_holospace._g_holospace:_FirstViewOfAgent(nil)	
						end
					elseif tm==AIAgent.HTPM_NONE then
					end
				end

				-- humain ctrl move, send move
				if isHumainTakeMove then
                    if g_manykit._systemControlMode==1 then
                        self._agent:SetPosition(g_manykit._mapPos)
                        self._agent:SetRotateDegreeAPoint(APoint(g_manykit._mapRot:X(), g_manykit._mapRot:Y(), g_manykit._mapRot:Z()))
                    end

                    self._sendStateTiming = self._sendStateTiming + t
                    if self._sendStateTiming > g_manykit._mkSendStateTime then
                        p_net._g_net:_SendStateTrans(self._agent)
                        self._sendStateTiming = 0.0
                    end

					self:_OnPUpdateProcesRunning_TakeMove()
				else
					self:_OnPUpdateProcesRunning_NotTakeMove()
				end
			end
            ]]--
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:_Simu(simu)
	print(self._name.." p_chara:_Simu")
	print_i_b(simu)

	self._lastAnimName = ""

	p_actor._Simu(self, simu)

	self._skillChara:SetAimTargetID(0)
	self._agent:GetSensoryMemory():Clear()
	self._agent:GetTargetingSystem():SetTarget(nil)

	if simu then		
		if self._agent then
			if g_manykit._isUsePhysics then
			else
				local curPos = self._agent:GetPosition()
				local toh = self:_PickHeight(curPos, false)
				local newAP = APoint(curPos:X(), curPos:Y(), toh)
				self._agent:SetPosition(newAP)
			end

			self._agent:SetAlive()
			self._agent:ResetPlay()
		end
	else
		if p_net._g_net._islogicserver then
			p_net._g_net:_RequestStateMachine("StateL_Null", "", self._id)
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:_SL_AttackUpdate()
	local agent = self._agent
	if agent then
		local sensoryMemory = agent:GetSensoryMemory()
		local targetSystem = agent:GetTargetingSystem()
		local target = targetSystem:GetTarget()
		local skillChara = self._actor:GetSkillChara()
		local curPos = agent:GetPosition()

		if target then
			local node = target:GetNode()
			local targetActor = Cast:ToActor(node)
			if targetActor then
				local targetSkillChara = targetActor:GetSkillChara()
				if targetSkillChara then
					skillChara:CalGetValidSkills(targetSkillChara, true, 1, 1, 1)
					local numSKills = skillChara:GetNumValidSkills()
					if numSKills>0 then
						local skill = skillChara:GetValidSkilHeighestPriority()
						if skill then
							local targetPos = target:GetPosition()
							local diff = targetPos - curPos
							diff:Normalize()
							agent:SetForward(diff)

							local skid = skill:GetID()

							local pointslast = {}
							pointslast.points = {}

							local pt = {
								t = 0,
								x = curPos:X(),
								y = curPos:Y(),
								z = curPos:Z() + 1,
							}
							table.insert(pointslast.points, #pointslast.points + 1, pt)

							local pt = {
								t = 50.0,
								x = targetPos:X(),
								y = targetPos:Y(),
								z = targetPos:Z() + 1,
							}
							table.insert(pointslast.points, #pointslast.points + 1, pt)

							local pointslaststr = PX2JSon.encode(pointslast)
							print("pointslaststr:"..pointslaststr)

							skillChara:SetAimTargetID(targetSkillChara:GetID())
							local ret = skill:MainActivateSkillInstance(true, pointslaststr, false, "100", true, false, true)
						end
					end
				end
			end
		else
			self:_ResetAIAction()
		end
	end
end
-------------------------------------------------------------------------------