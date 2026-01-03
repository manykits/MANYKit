-- p_weapon.lua
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_chara.lua")
-------------------------------------------------------------------------------
p_weapon = class(p_chara,
{
    _requires = {"p_chara", "p_net", },
	_name = "p_weapon",

    _weapontype = "jiqiang",

	_isFire = false,

    _mortar = nil,
    _heavyMachineGun = nil,
	_grenadeLauncher = nil,
	_changdingLR = nil,

    _angleMortar = 0,

    _angleHeavyMachineGunH = 0,
	_angleHeavyMachineGunV = 0,

	_angleGrenadeLauncherH = 0,
	_angleGgrenadeLauncherV = 0,

	_angleChangdingLRH = 0,
	_angleChangdingLRV = 0,

	_rotPoint = nil,
})
-------------------------------------------------------------------------------
function p_weapon:OnAttached()
	print(self._name.." p_weapon:OnAttached")

    PX2_LM_APP:AddItem(self._name, "Weapon", "武器")

	self._firstViewDist = 2.0

	p_chara.OnAttached(self)    
    
	if self._actor then
        local mortar = self._actor:GetModel():GetObjectByName("rot1")
        self._mortar = Cast:ToMovable(mortar)

        local heavyMachineGun = self._actor:GetModel():GetObjectByName("rot2")
        self._heavyMachineGun = Cast:ToMovable(heavyMachineGun)

		local grenadeLauncher = self._actor:GetModel():GetObjectByName("rot10")
        self._grenadeLauncher = Cast:ToMovable(grenadeLauncher)

		local changdingLR = self._actor:GetModel():GetObjectByName("rot10")
        self._changdingLR = Cast:ToMovable(changdingLR)
    end	

	if self._skillChara then
		local item = self._skillChara:GetEquippedItem("def", 0)
		if item then
			self._skillChara:TakeControlOfItem(item)
			self._rotPoint = item:GetDefItem().RotPoint		
		end			
	end
end
-------------------------------------------------------------------------------
function p_weapon:OnInitUpdate()
    print(self._name.." p_weapon:OnInitUpdate")

	p_chara.OnInitUpdate(self)
end
-------------------------------------------------------------------------------
function p_weapon:_Cleanup()
	print(self._name.." p_weapon:_Cleanup")

    p_chara._Cleanup(self)
end
-------------------------------------------------------------------------------
function p_weapon:_OnPUpdateProcesRunning_TakeMove()
	self:_OnPUpdateWeapon()
end
-------------------------------------------------------------------------------
function p_weapon:_OnPUpdateWeapon()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()

	local scene = PX2_PROJ:GetScene()
	local mainActor = scene:GetMainActor()

	if mainActor == self._actor then

		if g_manykit._isPressed_Left then
			if self._rotPoint=="Rot1" and  self._angleHeavyMachineGunH < 45 then
				self._angleHeavyMachineGunH = self._angleHeavyMachineGunH + 10.0 * t
			elseif self._rotPoint=="Rot3" and self._angleGrenadeLauncherH < 45 then
				self._angleGrenadeLauncherH = self._angleGrenadeLauncherH + 5.0 * t
			elseif self._rotPoint=="Rot4" and self._angleChangdingLRH < 45 then
				self._angleChangdingLRH = self._angleChangdingLRH + 10.0 * t
			end
		end

		if g_manykit._isPressed_Right then
			if self._rotPoint=="Rot1" and self._angleHeavyMachineGunH > -45 then
				self._angleHeavyMachineGunH = self._angleHeavyMachineGunH - 10.0 * t
			elseif self._rotPoint=="Rot3" and self._angleGrenadeLauncherH > -45 then
				self._angleGrenadeLauncherH = self._angleGrenadeLauncherH - 5.0 * t
			elseif self._rotPoint=="Rot4" and self._angleChangdingLRH > -45 then
				self._angleChangdingLRH = self._angleChangdingLRH - 10.0 * t
			end					
		end	


		if g_manykit._isPressed_Up then
			if self._rotPoint=="Rot1" and self._angleHeavyMachineGunV  < 20 then 
				self._angleHeavyMachineGunV = self._angleHeavyMachineGunV + 10.0 * t
			elseif self._rotPoint=="Rot0" and self._angleMortar < 20 then
				self._angleMortar = self._angleMortar + 5.0 * t
			elseif self._rotPoint=="Rot3" and self._angleGgrenadeLauncherV < 20 then
				self._angleGgrenadeLauncherV = self._angleGgrenadeLauncherV + 5.0 * t
			elseif self._rotPoint=="Rot4" and self._angleChangdingLRV > -20 then
				self._angleChangdingLRV = self._angleChangdingLRV - 10.0 * t
			end
		end

		if g_manykit._isPressed_Down then
			if self._rotPoint=="Rot1" and self._angleHeavyMachineGunV  > -20 then 
				self._angleHeavyMachineGunV = self._angleHeavyMachineGunV - 10.0 * t
			elseif self._rotPoint=="Rot0" and self._angleMortar > -20 then
				self._angleMortar = self._angleMortar - 5.0 * t
			elseif self._rotPoint=="Rot3" and self._angleGgrenadeLauncherV > -20 then
				self._angleGgrenadeLauncherV = self._angleGgrenadeLauncherV - 5.0 * t
			elseif self._rotPoint=="Rot4" and self._angleChangdingLRV < 20 then
				self._angleChangdingLRV = self._angleChangdingLRV + 10.0 * t
			end
		end	

	end
end
-------------------------------------------------------------------------------
function p_weapon:_OnPUpdateProcesRunning_NotTakeMove()
	self:_OnPUpdateWeapon()
end
-------------------------------------------------------------------------------
function p_weapon:OnPPlay()
	print(self._name.." p_weapon:OnPPlay")

    p_chara.OnPPlay(self)
end
-------------------------------------------------------------------------------
function p_weapon:OnFixUpdate()
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
function p_weapon:OnPUpdate()
    local t = PX2_APP:GetElapsedSecondsWidthSpeed()
    p_chara._OnPUpdate(self)

	local scene = PX2_PROJ:GetScene()
	local camNodeRoot = scene:GetMainCameraNodeRoot()
	local curDir = self._agent:GetDirection()
	local defModel = self._skillChara:GetDefModel()	

	if self._mortar then
		if 2==defModel.Rot1 then
			self._mortar.LocalTransform:SetRotateDegree(0, self._angleMortar, 0)
		elseif 1==defModel.Rot1 then
			self._mortar.LocalTransform:SetRotateDegree(self._angleMortar, 0, 0)
		else
			self._mortar.LocalTransform:SetRotateDegree(0, 0, self._angleMortar)
		end
	end

	if self._heavyMachineGun  then
		if 1==defModel.Rot1 then
			self._heavyMachineGun.LocalTransform:SetRotateDegree(self._angleHeavyMachineGunH, 0, self._angleHeavyMachineGunV)
		elseif 2==defModel.Rot1 then
			self._heavyMachineGun.LocalTransform:SetRotateDegree(self._angleHeavyMachineGunV, self._angleHeavyMachineGunH, 0)
		elseif 4 == defModel.Rot1 then
			self._heavyMachineGun.LocalTransform:SetRotateDegree(self._angleHeavyMachineGunV, 0 , self._angleHeavyMachineGunH)
		elseif 3 == defModel.Rot1 then
			self._heavyMachineGun.LocalTransform:SetRotateDegree(0, 0 , self._angleHeavyMachineGunH)
		else
			self._heavyMachineGun.LocalTransform:SetRotateDegree(0, self._angleHeavyMachineGunV, self._angleHeavyMachineGunH)
		end
	end

	if self._grenadeLauncher  then
		if 1==defModel.Rot10 then
			self._grenadeLauncher.LocalTransform:SetRotateDegree(self._angleGrenadeLauncherH, 0, self._angleGgrenadeLauncherV)
		elseif 2==defModel.Rot10 then
			self._grenadeLauncher.LocalTransform:SetRotateDegree(self._angleGgrenadeLauncherV, self._angleGrenadeLauncherH, 0)
		elseif 4 == defModel.Rot10 then
			self._grenadeLauncher.LocalTransform:SetRotateDegree(self._angleGgrenadeLauncherV, 0 , self._angleGrenadeLauncherH)
		elseif 3 == defModel.Rot10 then
			self._grenadeLauncher.LocalTransform:SetRotateDegree(0, 0 , self._angleGrenadeLauncherH)
		else
			self._grenadeLauncher.LocalTransform:SetRotateDegree(0, self._angleGgrenadeLauncherV, self._angleGrenadeLauncherH)
		end
	end

	if self._changdingLR  then
		if 1==defModel.Rot10 then
			self._changdingLR.LocalTransform:SetRotateDegree(self._angleChangdingLRV, 0, self._angleChangdingLRH)
		elseif 2==defModel.Rot10 then
			self._changdingLR.LocalTransform:SetRotateDegree(self._angleChangdingLRV, self._angleChangdingLRH, 0)
		elseif 4 == defModel.Rot10 then
			self._changdingLR.LocalTransform:SetRotateDegree(self._angleChangdingLRV, 0 , self._angleChangdingLRH)
		elseif 3 == defModel.Rot10 then
			self._changdingLR.LocalTransform:SetRotateDegree(0, 0 , self._angleChangdingLRH)
		else
			self._changdingLR.LocalTransform:SetRotateDegree(0, self._angleChangdingLRV, self._angleChangdingLRH)
		end
	end
end
-------------------------------------------------------------------------------
function p_weapon:_SetItemRot(typeid, rot)
	print(self._name.." p_vehicle:_SetItemRot")

	print("typeid:"..typeid)

	p_chara._SetItemRot(self, typeid, rot)


	local item = self._skillChara:GetItemByTypeID(typeid)
	if item then
		print("-------------------------")

		if typeid == 43395 then
			print("self._angleMortar:"..rot:X())

			self._angleMortar = -rot:X()
		elseif typeid == 43396 then
			print("self._angleChangdingLRH:"..rot:Z())

			self._angleChangdingLRH = rot:Z()
			self._angleChangdingLRV = rot:X()
		elseif typeid == 43397 then
			print("self._angleGrenadeLauncherH:"..rot:Z())

			self._angleGrenadeLauncherH = rot:Z()
			self._angleGgrenadeLauncherV = rot:X()
		elseif typeid == 43302 then
			print("self._angleHeavyMachineGunH:"..rot:Z())

			self._angleHeavyMachineGunH = rot:Z()
			self._angleHeavyMachineGunV = rot:X()
		end
	else
		print("_SetItemRot no item:"..typeid)
	end
end
-------------------------------------------------------------------------------
function p_weapon:_OnCreateSceneInstance()
	print(self._name.." p_weapon:_OnCreateSceneInstance")

	p_chara._OnCreateSceneInstance(self)
end
-------------------------------------------------------------------------------
-- property
function p_weapon:_GetPropertiesValue()
	print(self._name.." p_weapon:_GetPropertiesValue")

    p_chara._GetPropertiesValue(self)
end
-------------------------------------------------------------------------------
function p_weapon:_RegistProperties()
	print(self._name.." p_weapon:_RegistProperties")

    p_chara._RegistProperties(self)

    self._node:AddPropertyClass("Weapon", "Weapon")

    self._node:AddPropertyButton("Test", "Test")
end
-------------------------------------------------------------------------------
function p_weapon:_OnPropertyAct()
    print(self._name.." p_weapon:_OnPropertyAct")

    p_chara._OnPropertyAct(self)
end
-------------------------------------------------------------------------------
function p_weapon:_OnPropertyButton(prop)
	print(self._name.." p_weapon:_OnPropertyButton:"..prop.Name)

    p_chara._OnPropertyButton(self, prop)
end
-------------------------------------------------------------------------------
function p_weapon:_OnSelected(tag)
	print(self._name.." p_weapon:_OnSelected:"..tag)

    p_chara._OnSelected(self, tag)
end
-------------------------------------------------------------------------------
function p_weapon:_OnDisSelected(tag)
	print(self._name.." p_weapon:_OnDisSelected:"..tag)

    p_chara._OnDisSelected(self, tag)
end
-------------------------------------------------------------------------------
-- simu
function p_weapon:_Simu(simu)
	print(self._name.." p_weapon:_Simu")
	print_i_b(simu)

    p_chara._Simu(self, simu)
end
-------------------------------------------------------------------------------
function p_weapon:_OnFirstView(use)
	print(self._name.." p_weapon:_OnFirstView")

	local isFirstView = self._isOnFirstView
	p_chara._OnFirstView(self, use)
end
-------------------------------------------------------------------------------
function p_weapon:_CheckSetPosture(iPosture)
	local posture = self._posture
	p_chara._CheckSetPosture(self, iPosture)

	local curStateStr = self._agent:GetFSM_Movement():GetCurrentState()
	print("curStateStrrrrrrrrrrrrrrrrrrrrrrrrrrr:"..curStateStr)

	-- local isMov = curStateStr=="StateM_GoTo"
	-- if isMov then
	-- 	local isShow = self._actor:GetNodeModel():IsShow()
	-- 	if isShow then
	-- 		coroutine.wrap(function()
	-- 			sleep(2.0)
	-- 			self._actor:GetNodeModel():Show(false)
	-- 		end)()
	-- 	end
	-- end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_weapon)
-------------------------------------------------------------------------------