-- p_charaaction.lua
-------------------------------------------------------------------------------
function p_chara:_UpdateGravity()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()
	-- print("t:"..t)

	local curPos = self._agent:GetPosition()

	local toPos = APoint(curPos:X(), curPos:Y(), curPos:Z())
	
	local toZ = toPos:Z()
	local speedZ = 0.0
	if not g_manykit._isUsePhysics then
		speedZ = self._speedZ + self._g * t * 3
		toZ = curPos:Z() + t * speedZ
	end
	
	local diff = toZ - self._hworld

	if diff<0.01 and speedZ<=0.0 then		
		if not g_manykit._isUsePhysics then
			toPos:SetZ(self._hworld)
			self._agent:SetPosition(toPos)
			self._speedZ = 0.0
		end

		self._isOnGround = true
	else
		if not g_manykit._isUsePhysics then
			toPos:SetZ(toZ)
			self._agent:SetPosition(toPos)
			self._speedZ = speedZ
		end

		self._isOnGround = false
	end
end
-------------------------------------------------------------------------------
function p_chara:_CharaOnAISteeringBehavior(typestr, idxstr)
	print(self._name.." p_chara:_CharaOnAISteeringBehavior:")
	
	if "Path_SetWayPointIndex" == typestr then
        if p_net._g_net._islogicserver then
            p_net._g_net:_SendSetWayPointIndex(typestr, idxstr, self._id, self._agent)
        end
	end
end
-------------------------------------------------------------------------------
function p_chara:_SetActivate(act)
	print(self._name.." p_chara:_SetActivate")
	print_i_b(act)

	p_actor._SetActivate(self, act)

	if self._isSimuing then
		if self._isActivate then
			if p_net._g_net._islogicserver then
				self:_ResetAIAction()
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:_ResetAIAction()
	print(self._name.." p_chara:_SetActivate")

	local aiaction = self._actor:PEnumData2("AIAction")

	if "idle"==aiaction then
		p_net._g_net:_RequestStateMachine("StateL_Alive", "", self._id)
	elseif "patrol"==aiaction then
		local aipath = self._actor:PString("AIPathV")
		print("aipath:"..aipath)
		if ""~=aipath then
			p_net._g_net:_RequestStateMachine("StateL_FollowPath", aipath, self._id)
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:_FollowPath(actPath)
	print(self._name.." p_actor:_FollowPath")

	local pp = actPath:PString("PathPath")
	local actPathPos = actPath.LocalTransform:GetTranslate()

	local ap = AISteeringPath()

	local jsonData = JSONData()
	jsonData:LoadBuffer(pp)
	local path = jsonData:GetMember("path")
	if path:IsArray() then
		local arsize = path:GetArraySize()
		for i=0, arsize-1, 1 do
			local e = path:GetArrayElement(i)

			local pna = e:GetMember("ptn"):ToString()
			local posstr = e:GetMember("pos"):ToString()

			local apt = APoint():FromString(posstr)
			local apt1 = apt + actPathPos

			ap:AddWayPoint(apt1)
		end
	end
	ap:LoopOn()
	
	if self._agent then
		self._agent:SetPath(ap, false)
	end
end
-------------------------------------------------------------------------------
function p_chara:_StateMovementGoTo(pos, speed, state)
	print(self._name.." p_chara:_GoToooooooooooooooooooo")
	print(pos:ToString())

	self._gotopos = pos
	self._agent:SetRadius(0.3)
	self._agent:SetMass(1.0)
	self._agent:SetMaxForce(1000.0)

	local spd = -1
	if speed then
		spd = speed
	else
		self._agent:SetMaxSpeed(self._maxspeed)
		self._agent:SetSpeed(self._maxspeed)
		spd = self._maxspeed
	end
	self._agent:SetSpeedDir(AVector(0,0,0))
	local isAlive = self._agent:IsAlive()

	if isAlive then
		local curPos = self._agent:GetPosition()
			
		if g_manykit._isUsePathAllRB then
			local aiPath = self._agent:GetAISteeringPath()
			if aiPath then
				local numWP = aiPath:GetNumWayPoints()

				--manykit_l(true)
				local id = self._agent:GetID()
				print("id:"..id.." numwp:"..numWP)
				if numWP>30 then
					print("id:"..id.." clear waypoints")
					self._agent:ClearPath()
				end
				--manykit_l(false)

				local isNewStart = false
				numWP = aiPath:GetNumWayPoints()
				if numWP==0 then
					local posCur = self._agent:GetPosition()
					local laststatestr = ""
					if self._lastState then
						laststatestr = self._lastState
					end
					aiPath:AddWayPointWithSpeed(posCur, spd, laststatestr)
					isNewStart = true
				end

				aiPath:AddWayPointWithSpeed(pos, spd, state)

				if isNewStart then
					self._agent:GetAISteeringBehavior():SetPathActivate()
				end
			end
		else
			local laststatestr = ""
			if self._lastState then
				laststatestr = self._lastState
			end
			local ap = AISteeringPath()
			ap:AddWayPointWithSpeed(curPos, spd, state)
			ap:AddWayPointWithSpeed(pos, spd, state)
			self._agent:SetPath(ap, false)
		end
	else
		self._agent:ClearPath()
	end
end
-------------------------------------------------------------------------------
function p_chara:_PostureToHumainName(iPosture, ismoving)
	-- 姿态修改 
	-- 1:站立瞄准
	-- 2:下蹲
	-- 3:匍匐

	local animName = "stand"

	local numItemEquipped = self._skillChara:GetNumEquippedItem("def")

	local isAlive = self._agent:IsAlive() or self._agent:IsSpawning()
	local isdead = not isAlive
	if isdead then
		animName = "dead"
	else
		if ismoving then
			if 1==iPosture then
				if self._isSetRun then
					animName = "runaim"
					if 0==numItemEquipped then
						animName = "run"
					end
				else
					animName = "walkaim"
					if 0==numItemEquipped then
						animName = "walk"
					end
				end
			elseif 3==iPosture then
				animName = "downaim"
			elseif 2==iPosture then
				animName = "crawlforward"
			end
		else
			if 1==iPosture then
				animName = "standaim"
				if 0==numItemEquipped then
					animName = "stand"
				end
			elseif 3==iPosture then
				animName = "downaim"
			elseif 2==iPosture then
				animName = "crawl"
			end
		end
	end

	return animName
end
-------------------------------------------------------------------------------
function p_chara:_CheckSetPosture(iPosture)
	print(self._name.." p_chara:_CheckSetPosture".. iPosture)

	self._posture = iPosture
end
-------------------------------------------------------------------------------
function p_chara:_OnDetectBattleAttack()
	local isTakeNone = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_NONE)
	if self._agent:IsEnableTargetSystem() and isTakeNone then
		local agent = self._agent
		if agent then
			local targetSystem = agent:GetTargetingSystem()
			local target = targetSystem:GetTarget()
			local skillChara = self._actor:GetSkillChara()
			local curPos = agent:GetPosition()
	
			if target then
				if targetSystem:IsTargetInSight() then
					p_net._g_net:_RequestStateMachine("StateL_Attack", "", self._id)
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:_GetEquippedJuJiFov()
	local item = self._skillChara:GetEquippedItem("def", 0)
	if item then
		local itemDef = item:GetDefItem()
		if itemDef then
			local itemid = itemDef.ID
			local fov = itemDef.Fov

			return fov
		end
	end

	return fov
end
-------------------------------------------------------------------------------
function p_chara:_OnFirstView(use)
	self._isOnFirstView = use

	if self._skillChara then
		self._skillChara:SetFlyObjectUseAimingPos(false)
	end
end
-------------------------------------------------------------------------------
function p_chara:_Aim(aim)
	self._isAiming = aim

	if aim then
		if self._isOnFirstView then
			PX2_GH:SendGeneralEvent("UIAim", ""..self._id)
		end
	else
		PX2_GH:SendGeneralEvent("UIAim", "0")
	end
end
-------------------------------------------------------------------------------
function p_chara:_SetCameraNodeCtrlFirstView(nodePlayCtrl, camNodeRoot, dir)
	local target = nodePlayCtrl:GetTarget()
	if target then
		local pos = target.WorldTransform:GetTranslate()
		camNodeRoot.LocalTransform:SetTranslate(pos)
		camNodeRoot.LocalTransform:SetDU(dir, AVector.UNIT_Z)
	end
end
-------------------------------------------------------------------------------
function p_chara:_OnDie()
	print(self._name.." p_chara:_OnDie")

	p_actor._OnDie(self)

	local skillChara = self._actor:GetSkillChara()
	if skillChara then
		local defModel = skillChara:GetDefModel()
		if defModel then
			print("defChara.ModelBroken:")
			print(defModel.ModelBroken)

			if ""~=defModel.ModelBroken then
				local model = self._actor:GetModel()
				if model then
					model:Show(false)
				end

				local mbMovable = nil
				local objModelBorken = self._actor:GetNodeModel():GetObjectByName("ModelBroken")
				if nil==objModelBorken then
					objModelBorken = PX2_RM:BlockLoadCopy(defModel.ModelBroken)
					if objModelBorken then
						objModelBorken:SetName("ModelBroken")
	
						mbMovable = Cast:ToMovable(objModelBorken)
						if mbMovable then
							self._actor:GetNodeModel():AttachChild(mbMovable)
						end
					end
				else
					mbMovable = Cast:ToMovable(objModelBorken)
				end
				if mbMovable then
					mbMovable:Show(true)
				end

				self._actor:GetNodeModel():Update()
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:_OnReAlive()
	print(self._name.." p_chara:_OnReAlive")

	p_actor._OnReAlive(self)

	local model = self._actor:GetModel()
	if model then
		model:Show(true)
	end

	local objModelBorken = self._actor:GetNodeModel():GetObjectByName("ModelBroken")
	if nil~=objModelBorken then
		local mbMovable = Cast:ToMovable(objModelBorken)
		if mbMovable then
			mbMovable:Show(false)
		end
	end
end
-------------------------------------------------------------------------------