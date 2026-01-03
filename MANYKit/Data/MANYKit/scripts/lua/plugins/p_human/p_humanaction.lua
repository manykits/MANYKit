-- humainaction.lua
-------------------------------------------------------------------------------
function p_human:_Jump()
	print(self._name.." p_human:_Jump")
	print_i_b(self._isOnGround)

	if self._isOnGround then
		coroutine.wrap(function()
			local mctrl = self._actor:GetModelController()
			if mctrl then
				self._actor:PlayAnimationWithItem("jump")
				self._lastAnimName = "jump"
			end
			sleep(0.45)
			if g_manykit._isUsePhysics then
				self._agent:SetVelocity(AVector(0, 0, 8.0))
			else
				self._speedZ = 12.0
			end
		end)()
	end
end
-------------------------------------------------------------------------------
function p_human:_Aim(aim)
	local isAimBefore = self._isAiming
	
	p_chara._Aim(self, aim)

	if isAimBefore ~= aim then
		self:_CheckSetPosture(self._posture)
	end
end
-------------------------------------------------------------------------------
function p_human:_SetUpperDegree(degree)
	--print(self._name.." p_chara:_SetUpperDegree")

	self._updegee = degree

	if self._nodeMiddleBTC then
		self._nodeMiddleBTC:SetUseTransfromAdjust(true)
		self._nodeMiddleBTC:GetAdjustTransfrom():SetRotateDegreeZ(-self._updegee)
	end
end
-------------------------------------------------------------------------------
function p_human:_OnFirstView(use)
	print(self._name.." p_human:_OnFirstView")

	local isFirstViewBefore = self._isOnFirstView
	p_chara._OnFirstView(self, use)

	local isHumainTakeBody = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_BODY)
	local tm = self._agent:GetHumanTakePossessed()
	print("tm:"..tm)
	
	if self._isOnFirstView then
		if self._camera0 then
			p_holospace._g_cameraPlayCtrl:SetTarget(self._camera0)
		end
	else
		local isHumainTakeBodyExactly = tm==AIAgent.HTPM_BODY
		local isHumainTakeBody = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_BODY)
		if isHumainTakeBody then
			self:_SetUpperDegree(0)
		end

		if isHumainTakeBodyExactly then
			if self._isUpdateRotateFormServer then
				if self._rotateDegreeAPointFromServer~=APoint(0,0,0) then
					self._agent:SetRotateDegreeAPoint(self._rotateDegreeAPointFromServer)
					if self._nodeDownInfo then
                        self._nodeDownInfo.LocalTransform:SetRotateDegreeZ(self._rotateDegreeAPointFromServer:Z())
                    end
                end
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_human:_CheckAnimWithItem()
	print(self._name.." p_chara:_CheckAnimWithItem")

	local t = self._meGoType

	local mctrl = self._actor:GetModelController()
	if mctrl then
		local isalive = self._agent:IsAlive() or self._agent:IsSpawning()
		local numItemEquipped = self._skillChara:GetNumEquippedItem("def")

		local animName = ""
		if not isalive then
			animName = "dead"
			self._actor:PlayAnimationWithItem(animName)
		else
			if 0==t then
				animName = self._animstand
				if numItemEquipped == 0 then
					animName = "stand"
				end
				self._actor:PlayAnimationWithItem(animName)
			else
				animName = self._animrun
				if numItemEquipped == 0 then
					animName = "run"
				end
				self._actor:PlayAnimationWithItem(animName)
			end
		end

		self._lastAnimName = animName
	end
end
-------------------------------------------------------------------------------
function p_human:_MeGo(t)
	local scene = PX2_PROJ:GetScene()
	local camNodeRoot = scene:GetMainCameraNodeRoot()
	local r = camNodeRoot.WorldTransform:GetRight()
	local d = camNodeRoot.WorldTransform:GetDirection()
	local u = camNodeRoot.WorldTransform:GetUp()
	d:SetZ(0.0)
	d:Normalize()
	r:SetZ(0.0)
	r:Normalize()

	if t ~=self._meGoType then
		self._meGoType = t

		self:_CheckSetPosture(self._posture)
	end

	if 0~=self._meGoType then
		local dirSpeed = AVector.UNIT_Y
		local dirFace = AVector.UNIT_Y

		if 1==t then
			dirSpeed = AVector(d:X(), d:Y(), d:Z())
		elseif 2==t then
			dirSpeed = AVector(-d:X(), -d:Y(), -d:Z())
		elseif 3==t then
			dirSpeed = AVector(-r:X(), -r:Y(), -r:Z())
		elseif 4==t then
			dirSpeed = AVector(r:X(), r:Y(), r:Z())
		elseif 5==t then
			dirSpeed = AVector(d:X()-r:X()/2, d:Y()-r:Y()/2, d:Z()-r:Z()/2)
		elseif 6==t then
			dirSpeed = AVector(d:X()+r:X()/2, d:Y()+r:Y()/2, d:Z()+r:Z()/2)
		elseif 7==t then
			dirSpeed = AVector(-d:X()-r:X()/2, -d:Y()-r:Y()/2, -d:Z()-r:Z()/2)
		elseif 8==t then
			dirSpeed = AVector(-d:X()+r:X()/2, -d:Y()+r:Y()/2, -d:Z()+r:Z()/2)
		end
		dirSpeed:Normalize()

		if self._isOnFirstView then
		else
			if self._isAiming then
				dirFace = AVector(d:X(), d:Y(), d:Z())
			else
				dirFace = AVector(dirSpeed:X(), dirSpeed:Y(), dirSpeed:Z())
			end
			self._agent:SetForward(dirFace)
		end

		local spd = 2.0
		if g_manykit._isUsePhysics then
			local vec = dirSpeed * spd
			self._agent:SetVelocity(vec)
		else
			self._agent:SetSpeed(spd)
			self._agent:SetSpeedDir(dirSpeed)
		end
	else
		self._agent:SetSpeed(0.0)
		local vec = self._agent:GetVelocity()
		if g_manykit._isUsePhysics then
			vec = AVector(0.0, 0.0, vec:Z())
		else
			vec = AVector(0.0, 0.0, 0.0)
		end
		self._agent:SetVelocity(vec)
	end
end
-------------------------------------------------------------------------------
function p_human:_CheckSetPosture(iPosture)
	local posture = self._posture
	p_chara._CheckSetPosture(self, iPosture)

	local curStateStr = self._agent:GetFSM_Movement():GetCurrentState()

	local isMov = false

	local isHumainTakeMove = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_MOVE)
	if isHumainTakeMove then
		isMov = self._meGoType~=0
	else
		isMov = curStateStr=="StateM_GoTo"
	end

	print("isMove:")
	print_i_b(isMov)

	local animName = self:_PostureToHumainName(iPosture, isMov)
	print("animName:"..animName)
	print("_lastAnimName:"..self._lastAnimName)

	if self._lastAnimName~=animName then
		local mctrl = self._actor:GetModelController()
		if mctrl then
			self._actor:PlayAnimationWithItem(animName)
		end
		self._lastAnimName = animName
	end
end
-------------------------------------------------------------------------------
function p_human:_ChangePosture()
	print(self._name.." p_human:_ChangePosture")

	self._posture = self._posture + 1
	if self._posture>=4 then
		self._posture = 1
	end

	self:_CheckSetPosture(self._posture)
end
-------------------------------------------------------------------------------