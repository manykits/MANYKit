-- p_vehicle.lua
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_chara.lua")
-------------------------------------------------------------------------------
p_vehicle = class(p_chara,
{
    _requires = {"p_chara", "p_net", },

	_name = "p_vehicle",

	-- 0tank，1car，2air
	_DriveType = 0,

	_tankSpeed = 8,
	_hworld = 0.0,
	_angleZ = 0.0,
	_rotatespeed = 20.0,
	
	_isVehicleRunning = false,
	_isTankPaoTaiRotation = false,
	_isTankPaoGuanRotation = false,

	_isMovingRB = false,
	_soundRun = nil,
	_soundLoad = nil,
	_soundPaoTai = nil,
	_soundPaoGuan = nil,
	_soundJiQiang = nil,

	_wheelctrls = {},
	_airctrls = {},
	_wheels = {},
	_frequency = 0,
	_rotPoint = nil,
	_camera0 = nil,

	_paotai = nil,
	_paoguan = nil,
	_jiqiang = nil,

	_angleWheelsH = 0,
	_angleWheelsV = 0,

	_anglePaoTai = 0,
	_anglePaoGuan = 0,
	_angleJiQiangH = 0,
	_angleJiQiangV = 0,
	_angleAirJiQiang = 0,

	_movSmoke = nil,
	_aliveSmoek = nil,
})
-------------------------------------------------------------------------------
function p_vehicle:OnAttached()
	print(self._name.." p_vehicle:OnAttached")

    PX2_LM_APP:AddItem(self._name, "Vehicle", "交通工具")

	self._maxspeed = 0.5

	p_chara.OnAttached(self)

	self._firstViewDist = 0.5

	if self._skillChara then 
		local defModel = self._skillChara:GetDefModel()
		if defModel then
			self._DriveType = defModel.DriveType
		end
	end	

	self._wheelctrls = {}
	self._airctrls = {}
	self._wheels = {}

	print("wwwwww")
	print(#self._wheelctrls)
	print("self._id:"..self._id)

	if self._actor then
		-- hide camera0
		if self._camera0 then
			self._camera0:Show(false)
		end

		-- get objs
		local objPaoTai = self._actor:GetModel():GetObjectByName("rot0")
		self._paotai = Cast:ToMovable(objPaoTai)
		local paoguan = self._actor:GetModel():GetObjectByName("rot1")
		self._paoguan = Cast:ToMovable(paoguan)
		local jiqiang = self._actor:GetModel():GetObjectByName("rot2")
		self._jiqiang = Cast:ToMovable(jiqiang)
	
		--self._wheelctrls = {}
		local wheelNum = 20
		for i=0,wheelNum,1 do
			local wheel01 =  self._actor:GetModel():GetObjectByName("wheel"..i)
			local wheel01mov = Cast:ToMovable(wheel01)
			if wheel01mov then		
				if self._DriveType==1 then
					
					self._wheels[#self._wheels +1] = Cast:ToMovable(wheel01)

				elseif self._DriveType==0 then
					local defModel = self._skillChara:GetDefModel()
					if 2==defModel.Wheelrot then
						local ctrlObj = PX2_RM:BlockLoadCopy("objects/ctrl/wheelctrlY.px2obj")
						local ctrl = Cast:ToController(ctrlObj)

						if ctrl then
							ctrl.Frequency = self._frequency
							wheel01mov:AttachController(ctrl)
							ctrl:Pause()
							
							table.insert(self._wheelctrls, #self._wheelctrls + 1, ctrl)
						end
					elseif 3==defModel.Wheelrot then
						local ctrlObj = PX2_RM:BlockLoadCopy("objects/ctrl/wheelctrlZ.px2obj")
						local ctrl = Cast:ToController(ctrlObj)
						if ctrl then
							ctrl.Frequency = self._frequency
							wheel01mov:AttachController(ctrl)
							ctrl:Pause()
							
							table.insert(self._wheelctrls, #self._wheelctrls + 1, ctrl)
						end
					else
						local ctrlObj = PX2_RM:BlockLoadCopy("objects/ctrl/wheelctrlX.px2obj")
						local ctrl = Cast:ToController(ctrlObj)
						if ctrl then
							ctrl.Frequency = self._frequency
							wheel01mov:AttachController(ctrl)
							ctrl:Pause()
							
							table.insert(self._wheelctrls, #self._wheelctrls + 1, ctrl)
						end
					end
				end
			end
		end	
	end
end
-------------------------------------------------------------------------------
function p_vehicle:OnInitUpdate()
    print(self._name.." p_vehicle:OnInitUpdate")

	p_chara.OnInitUpdate(self)
end
-------------------------------------------------------------------------------
function p_vehicle:_Cleanup()
	print(self._name.." p_vehicle:_Cleanup")

    p_chara._Cleanup(self)

	if self._soundRun then
		PX2_CREATER:Delete(self._soundRun)
		self._soundRun = nil
	end

	if self._soundLoad then
		PX2_CREATER:Delete(self._soundLoad)
		self._soundLoad = nil
	end

	if self._soundPaoTai then
		PX2_CREATER:Delete(self._soundPaoTai)
		self._soundPaoTai = nil
	end

	if self._soundJiQiang then
		PX2_CREATER:Delete(self._soundJiQiang)
		self._soundJiQiang = nil
	end

	if self._soundPaoGuan then
		PX2_CREATER:Delete(self._soundPaoGuan)
		self._soundPaoGuan = nil
	end
end
-------------------------------------------------------------------------------
function p_vehicle:OnPPlay()
	print(self._name.." p_vehicle:OnPPlay")

    p_chara.OnPPlay(self)
end
-------------------------------------------------------------------------------
function p_vehicle:OnFixUpdate()
	local t = self._dt

    p_chara.OnFixUpdate(self)

	if self._skillChara then
		local itemCtrling = self._skillChara:GetControllingItem()
		if nil==itemCtrling then
			local item = self._skillChara:GetEquippedItem("def", 0)
			if item then
				itemCtrling = item
				self._skillChara:TakeControlOfItem(item)
			end	
		end

		if itemCtrling then
			local defItem = itemCtrling:GetDefItem()
			if defItem then
				self._rotPoint = defItem.RotPoint	
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_vehicle:_OnPUpdateProcesRunning_TakeMove()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()
	local curPos = self._agent:GetPosition()
	
	local isRunning = false
	local speed = 0.0

	if not g_manykit._isRobot then
		if g_manykit._isPressed_W then
			isRunning = true
			speed = 5.0

			if self._DriveType==1 then
				self._angleWheelsV = self._angleWheelsV + 180 * t
				speed = 20.0
			else
				for i = 1,#self._wheelctrls do
					self._wheelctrls[i].Frequency = 1
				end
			end
		elseif g_manykit._isPressed_S then 
			isRunning = true
			speed = -5.0	
			if self._DriveType==1 then
				self._angleWheelsV = self._angleWheelsV - 180 * t
				speed = -20.0
			else
				for i = 1,#self._wheelctrls do
					self._wheelctrls[i].Frequency = -1
				end
			end			
		else
			isRunning = false
			speed = 0.0
		end
	end

	self._agent:SetSpeed(speed)
	self._agent:SetSpeedDir(self._agent:GetDirection())

	if self._DriveType==1 then
		-- car
		if g_manykit._isPressed_A and self._angleWheelsH < 25 then
			self._angleWheelsH = self._angleWheelsH + 20 * t
		elseif self._angleWheelsH >0 then
			self._angleWheelsH = self._angleWheelsH - 40 * t
		end
		if g_manykit._isPressed_D and self._angleWheelsH > -25 then
			self._angleWheelsH = self._angleWheelsH - 20 * t
		elseif self._angleWheelsH <0 then
			self._angleWheelsH = self._angleWheelsH + 40 * t
		end					
		if g_manykit._isPressed_A and g_manykit._isPressed_W then
			self._angleWheelsH = self._angleWheelsH + 20 * t
			self._angleZ = self._angleZ + 60 * t
		end
		if g_manykit._isPressed_D and g_manykit._isPressed_W then
			self._angleWheelsH = self._angleWheelsH - 40 * t
			self._angleZ = self._angleZ - 60 * t
		end
		if g_manykit._isPressed_A and g_manykit._isPressed_S then
			self._angleWheelsH = self._angleWheelsH + 20 * t
			self._angleZ = self._angleZ - 60 * t
		end
		if g_manykit._isPressed_D and g_manykit._isPressed_S then
			self._angleWheelsH = self._angleWheelsH - 20 * t
			self._angleZ = self._angleZ + 60 * t
		end
	else
		-- tank
		if g_manykit._isPressed_A and g_manykit._isPressed_S then
			isRunning = true
			self._angleZ = self._angleZ - self._rotatespeed * t
		elseif g_manykit._isPressed_D and g_manykit._isPressed_S then
			isRunning = true
			self._angleZ = self._angleZ + self._rotatespeed * t 
		elseif g_manykit._isPressed_D then
			isRunning = true
			self._angleZ = self._angleZ - self._rotatespeed * t
		elseif g_manykit._isPressed_A then
			isRunning = true 
			self._angleZ = self._angleZ + self._rotatespeed * t 
		end
	end

	self:_VehicleRunning(isRunning)
	self:_OnUpdatePaoTai()

	local topos = curPos
	local toh = 0.0
	local worldNormal = AVector(0,0,1)
	local isOnlyTerrain = false
	if not g_manykit._isUsePhysics then
		topos = curPos + self._agent:GetVelocity()  * t
		self._hworld, worldNormal= self:_PickHeight(topos, isOnlyTerrain, true)
	else
		self._hworld, worldNormal = self:_PickHeight(curPos, isOnlyTerrain, true)
	end
	self._agent:SetRotate(self._angleZ, worldNormal)

	if self._isUpdateRotateFormServer and self._nodeDownInfo then
		self._nodeDownInfo.LocalTransform:SetRotateDegreeZ(self._rotateDegreeAPointFromServer:Z())
	end

	self._agent:SetPosition(topos)
	self:_UpdateGravity()
end
-------------------------------------------------------------------------------
function p_vehicle:_OnUpdatePaoTai()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()

	local scene = PX2_PROJ:GetScene()
	local mainActor = scene:GetMainActor()

	if mainActor == self._actor then
		local isTurningPaoTai = false
		local isTurningPaoGuan = false

		local skillChara = self._actor:GetSkillChara()

		if self._DriveType~=2 then
			if g_manykit._isPressed_Left then
				if self._rotPoint=="Rot0"  then 
					isTurningPaoTai = true
					self._anglePaoTai = self._anglePaoTai + 10.0 * t
				elseif self._rotPoint=="Rot1" then
					self._angleJiQiangH = self._angleJiQiangH + 40.0 * t
				end
			end

			if g_manykit._isPressed_Right then
				if self._rotPoint=="Rot0" then 
					isTurningPaoTai = true
					self._anglePaoTai = self._anglePaoTai - 10.0 * t
				elseif self._rotPoint=="Rot1" then
					self._angleJiQiangH = self._angleJiQiangH - 40.0 * t
				end					
			end	
		end
		self:_PaoTaiRotationSound(isTurningPaoTai)	
		
		local defModel = self._skillChara:GetDefModel()				
		if 1~=defModel.Rot1_1 then
			if g_manykit._isPressed_Up then
				if self._rotPoint=="Rot0" and self._anglePaoGuan > -25 then 
					isTurningPaoGuan = true
					self._anglePaoGuan = self._anglePaoGuan - 5.0 * t
				elseif self._rotPoint=="Rot1" and self._angleJiQiangV > -25 then 
					self._angleJiQiangV = self._angleJiQiangV - 40.0 * t
				end
			end

			if g_manykit._isPressed_Down then
				if self._rotPoint=="Rot0" and self._anglePaoGuan < 10 then 
					isTurningPaoGuan = true
					self._anglePaoGuan = self._anglePaoGuan + 5.0 * t
				elseif self._rotPoint=="Rot1" and self._angleJiQiangV < 10 then 
					self._angleJiQiangV = self._angleJiQiangV + 40.0 * t
				end
			end	
		else		
			if g_manykit._isPressed_Up then
				if self._rotPoint=="Rot0" and self._anglePaoGuan < 25 then 
					isTurningPaoGuan = true
					self._anglePaoGuan = self._anglePaoGuan + 5.0 * t
				elseif self._rotPoint=="Rot1" and self._angleJiQiangV < 25 then 
					self._angleJiQiangV = self._angleJiQiangV + 40.0 * t
				end
			end

			if g_manykit._isPressed_Down and self._anglePaoGuan > -10 then
				if self._rotPoint=="Rot0" and self._anglePaoGuan > -10 then 
					isTurningPaoGuan = true
					self._anglePaoGuan = self._anglePaoGuan - 5.0 * t
				elseif self._rotPoint=="Rot1" and self._angleJiQiangV > -10 then 
					self._angleJiQiangV = self._angleJiQiangV - 40.0 * t
				end
			end	
		end
		self:_PaoGaunRotationSound(isTurningPaoGuan)
	end
end
-------------------------------------------------------------------------------
function p_vehicle:_OnPUpdateProcesRunning_NotTakeMove()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()
	local curPos = self._agent:GetPosition()

	local isOnlyTerrain = false
	local topos = curPos + self._agent:GetVelocity()  * t
	local toh, worldNormal = self:_PickHeight(topos, isOnlyTerrain, true)
	local pos1 = APoint(topos:X(), topos:Y(), toh)
	topos:SetZ(toh)
	self._hworld = toh
	self._agent:SetPosition(topos)

	if self._isUpdateRotateFormServer then
		if self._isUpdateRotateFormServer then
			self._angleZ = self._rotateDegreeAPointFromServer:Z()
		end

		self._agent:SetRotate(self._angleZ, worldNormal)

		if self._isUpdateRotateFormServer and self._nodeDownInfo then
			self._nodeDownInfo.LocalTransform:SetRotateDegreeZ(self._rotateDegreeAPointFromServer:Z())
		end
	end
	
	self._isOnGround = true

	for i = 1,#self._wheelctrls do
		self._wheelctrls[i].Frequency = 1
	end

	self:_VehicleRunning(self._isMovingRB)
	self:_OnUpdatePaoTai()
end
-------------------------------------------------------------------------------
function p_vehicle:_OnPUpdate()
	p_chara._OnPUpdate(self)

	local scene = PX2_PROJ:GetScene()
	local camNodeRoot = scene:GetMainCameraNodeRoot()
	
    local t = PX2_APP:GetElapsedSecondsWidthSpeed()
	local curPos = self._agent:GetPosition()
	local curDir = self._agent:GetDirection()
	local defModel = self._skillChara:GetDefModel()	

	local nodeRoot = self._actor:GetNodeRoot()

	if nil==self._aliveSmoek then
		local obj = PX2_RM:BlockLoadCopy("objects/effect/file1.px2obj")
		local mov = Cast:ToMovable(obj)
		if mov then
			self._aliveSmoek = mov

			nodeRoot:AttachChild(mov)
			mov.LocalTransform:SetUniformScale(2.0)
			mov.LocalTransform:SetRotateDegree(0.0, 0.0, 0.0)
			mov.LocalTransform:SetTranslateX(0.0)
			mov.LocalTransform:SetTranslateY(0.0)
			mov.LocalTransform:SetTranslateZ(0.0)
		end
	end

	local isAlive = self._agent:IsAlive()
	
	if self._aliveSmoek then
		if not isAlive then
			self._aliveSmoek:Play()
		else
			self._aliveSmoek:Pause()
		end
	end


	if 1==self._DriveType then
		for i=1,#self._wheels do
			if defModel.Wheelrot==2 then 
				self._wheels[i].LocalTransform:SetRotateDegree(self._angleWheelsV ,0 , self._angleWheelsH)
			elseif defModel.Wheelrot==1 then 
				self._wheels[i].LocalTransform:SetRotateDegree(-self._angleWheelsV , 0 ,self._angleWheelsH)
			else
				self._wheels[i].LocalTransform:SetRotateDegree(self._angleWheelsV, self._angleWheelsH, 0)
			end
		end
	end

	local defModel = self._skillChara:GetDefModel()
	if self._paotai then
		if 2==defModel.Rot0 then
			self._paotai.LocalTransform:SetRotateDegree(0, self._anglePaoTai, 0)
		elseif 1==defModel.Rot0 then
			self._paotai.LocalTransform:SetRotateDegree(self._anglePaoTai, 0, 0)
		else
			self._paotai.LocalTransform:SetRotateDegree(0, 0, self._anglePaoTai)
		end
	end

	if self._paoguan then
		if 1==defModel.Rot1 then
			self._paoguan.LocalTransform:SetRotateDegree(self._anglePaoGuan, 0, 0)
		elseif 2==defModel.Rot1 then
			self._paoguan.LocalTransform:SetRotateDegree(0, self._anglePaoGuan, 0)
		else
			self._paoguan.LocalTransform:SetRotateDegree(0, 0, self._anglePaoGuan)
		end
	end

	if self._jiqiang  then
		if 1==defModel.Rot2 then
			self._jiqiang.LocalTransform:SetRotateDegree(self._angleJiQiangH, 0, self._angleJiQiangV)
		elseif 2==defModel.Rot2 then
			self._jiqiang.LocalTransform:SetRotateDegree(self._angleJiQiangV, self._angleJiQiangH, 0)
		elseif 4 == defModel.Rot2 then
			self._jiqiang.LocalTransform:SetRotateDegree(self._angleJiQiangV, 0 , self._angleJiQiangH)
		elseif 3 == defModel.Rot2 then
			self._jiqiang.LocalTransform:SetRotateDegree(0, 0 , self._angleJiQiangH)
		else
			self._jiqiang.LocalTransform:SetRotateDegree(0, self._angleJiQiangV, self._angleJiQiangH)
		end
	end

	local isHumainTakeBody = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_BODY)
	local isHumainTakeNone = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_NONE)
	local tm = self._agent:GetHumanTakePossessed()
	local isHumainTakeBodyExactly = tm==AIAgent.HTPM_BODY

	if self._isOnFirstView then
		if isHumainTakeNone then
			if self._isUpdateRotateFormServer then
				self._angleZ = self._rotateDegreeAPointFromServer:Z()
			end

			local agDir = self._agent:GetDirection()

			self:_SetCameraNodeCtrlFirstView( p_holospace._g_cameraPlayCtrl, camNodeRoot, agDir)
		end
	else
		if isHumainTakeNone then
			if self._isUpdateRotateFormServer then
				self._angleZ = self._rotateDegreeAPointFromServer:Z()
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_vehicle:_SetItemRot(typeid, rot)
	print(self._name.." p_vehicle:_SetItemRot")

	print("typeid:"..typeid)

	p_chara._SetItemRot(self, typeid, rot)

	local item = self._skillChara:GetItemByTypeID(typeid)
	if item then
		print("-------------------------")

		if typeid == 43301 then
			print("self._anglePaoTai:"..rot:Z())

			self._anglePaoTai = rot:Z()
			self._anglePaoGuan = -rot:X()
		elseif typeid == 43302 then
			print("self._angleJiQiangH:"..rot:Z())

			self._angleJiQiangH = rot:Z()
			self._angleJiQiangV = rot:X()
		end
	else
		print("_SetItemRot no item:"..typeid)
	end
end
-------------------------------------------------------------------------------
function p_vehicle:_OnCreateSceneInstance()
	print(self._name.." p_vehicle:_OnCreateSceneInstance")

	p_chara._OnCreateSceneInstance(self)
end
-------------------------------------------------------------------------------
-- property
function p_vehicle:_GetPropertiesValue()
	print(self._name.." p_vehicle:_GetPropertiesValue")

    p_chara._GetPropertiesValue(self)
end
-------------------------------------------------------------------------------
function p_vehicle:_RegistProperties()
	print(self._name.." p_vehicle:_RegistProperties")

    p_chara._RegistProperties(self)

    self._node:AddPropertyClass("Vehicle", "Vehicle")

    self._node:AddPropertyButton("Test", "Test")
end
-------------------------------------------------------------------------------
function p_vehicle:_OnPropertyAct()
    print(self._name.." p_vehicle:_OnPropertyAct")

    p_chara._OnPropertyAct(self)
end
-------------------------------------------------------------------------------
function p_vehicle:_OnPropertyButton(prop)
	print(self._name.." p_vehicle:_OnPropertyButton:"..prop.Name)

    p_chara._OnPropertyButton(self, prop)
end
-------------------------------------------------------------------------------
function p_vehicle:_OnSelected(tag)
	print(self._name.." p_vehicle:_OnSelected:"..tag)

    p_chara._OnSelected(self, tag)
end
-------------------------------------------------------------------------------
function p_vehicle:_OnDisSelected(tag)
	print(self._name.." p_vehicle:_OnDisSelected:"..tag)

    p_chara._OnDisSelected(self, tag)
end
-------------------------------------------------------------------------------
-- simu
function p_vehicle:_Simu(simu)
	print(self._name.." p_vehicle:_Simu")
	print_i_b(simu)

    p_chara._Simu(self, simu)

	if simu then
		if self._agent then
			self._agent:GetAISteeringBehavior():SetWaypointSeekDist(0.3)
			self._agent:GetAISteeringBehavior():SetWaypointSeekDistLast(0.3)
		end
	end
end
-------------------------------------------------------------------------------
function p_vehicle:_VehicleRunning(run)
	if self._isVehicleRunning ~= run then
		local defModel = self._skillChara:GetDefModel()
		local nodeRoot = self._actor:GetNodeRoot()

		if nil==self._movSmoke then
			local obj = PX2_RM:BlockLoadCopy("objects/effect/yanwu.px2obj")
			local mov = Cast:ToMovable(obj)
			if mov then
				self._movSmoke = mov

				nodeRoot:AttachChild(mov)
				mov.LocalTransform:SetUniformScale(0.5)
				mov.LocalTransform:SetRotateDegree(0.0, 0.0, 0.0)
				mov.LocalTransform:SetTranslateX(0.0)
				mov.LocalTransform:SetTranslateY(-3.0)
				mov.LocalTransform:SetTranslateZ(-1.0)
			end
		end

		if run then
			if self._movSmoke then
				self._movSmoke:ResetPlay()
			end

			if nil==self._soundRun then
				if PX2_SS then
					self._soundRun = PX2_SS:PlaySound2DControl1(defModel.RunSound, 1.0, true)
				end
			else
				self._soundRun:Play()
			end

			if 22018~=defModel.ID then 
				print("NumWheels:"..#self._wheelctrls)
				for k,v in pairs(self._wheelctrls) do
					v:Play()
				end	
			end
		else
			if self._movSmoke then
				self._movSmoke:Pause()
			end
			
			if self._soundRun then
				self._soundRun:Stop()
			end

			if 22018~=defModel.ID then 
				for k,v in pairs(self._wheelctrls) do
					v:Pause()
				end
			end
		end
	end
	self._isVehicleRunning = run
end
-------------------------------------------------------------------------------
function p_vehicle:_PaoTaiRotationSound(rotation)
	if self._isTankPaoTaiRotation ~= rotation then
		if rotation then
			if nil==self._soundPaoTai then
				local defModel = self._skillChara:GetDefModel()
				if PX2_SS then
					self._soundPaoTai = PX2_SS:PlaySound2DControl1(defModel.PaoTaiRotationSound, 1.0, true)
				end
			else
				self._soundPaoTai:Play()
			end
		else
			if self._soundPaoTai then
				self._soundPaoTai:Stop()
			end
		end
	end
	self._isTankPaoTaiRotation = rotation
end
-------------------------------------------------------------------------------
function p_vehicle:_PaoGaunRotationSound(rotation)
	if self._isTankPaoGuanRotation ~= rotation then
		if rotation then
			if nil==self._soundPaoGuan then
				local defModel = self._skillChara:GetDefModel()
				if PX2_SS then
					self._soundPaoGuan = PX2_SS:PlaySound2DControl1(defModel.PaoGuanRotationSound, 1.0, true)
				end
			else
				self._soundPaoGuan:Play()
			end
		else
			if self._soundPaoGuan then
				self._soundPaoGuan:Stop()
			end
		end
	end
	self._isTankPaoGuanRotation = rotation
end
-------------------------------------------------------------------------------
function p_vehicle:_JiQiangFireSound(rotation)
	if self._isJiQiangFire ~= rotation then
		if rotation then
			if nil==self._soundJiQiang then
				local defModel = self._skillChara:GetDefModel()
				if PX2_SS then
					--self._soundJiQiang = PX2_SS:PlaySound2DControl1("", 1.0, true)
				end
			else
				self._soundJiQiang:Play()
			end
		else
			if self._soundJiQiang then
				self._soundJiQiang:Stop()
			end
		end
	end
	self._isJiQiangFire = rotation
end
-------------------------------------------------------------------------------
function p_vehicle:_OnFirstView(use)
	print(self._name.." p_human:_OnFirstView")

	local isFirstView = self._isOnFirstView
	p_chara._OnFirstView(self, use)

	local tm = self._agent:GetHumanTakePossessed()
	print("tm:"..tm)

	if self._isOnFirstView then
		if self._camera0 then
			p_holospace._g_cameraPlayCtrl:SetTarget(self._camera0)
		end
	else
		local isHumainTakeBodyExactly = tm==AIAgent.HTPM_BODY
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
function p_vehicle:_CheckSetPosture(iPosture)
	local posture = self._posture
	p_chara._CheckSetPosture(self, iPosture)

	local curStateStr = self._agent:GetFSM_Movement():GetCurrentState()
	print("curStateStrrrrrrrrrrrrrrrrrrrrrrrrrrr:"..curStateStr)

	local isMov = curStateStr=="StateM_GoTo"
	self._isMovingRB = isMov
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_vehicle)
-------------------------------------------------------------------------------