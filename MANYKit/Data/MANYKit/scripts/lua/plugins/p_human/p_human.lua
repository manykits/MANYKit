-- p_human.lua
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_chara.lua")
-------------------------------------------------------------------------------
p_human = class(p_chara,
{
    _requires = {"p_chara", "p_net", },

	_name = "p_human",
    
    _frameBag = nil,

	_nodeMiddle = nil,
	_nodeMiddleBTC = nil,
	_isuseupper = false,
	_updegee = 0,

	_meGoType = 0,

	_TakeBodyCanChange = true,
})
-------------------------------------------------------------------------------
function p_human:OnAttached()
    PX2_LM_APP:AddItem(self._name, "human", "人形")

	self._firstViewDist = 0.1
	self._maxspeed = 3.5

	p_chara.OnAttached(self)

	print(self._name.." p_human:OnAttached")
end
-------------------------------------------------------------------------------
function p_human:OnInitUpdate()
	p_chara.OnInitUpdate(self)

	print(self._name.." p_human:OnInitUpdate")

	if self._actor then
		local model = self._actor:GetModel()
		if model then
			local obj = model:GetObjectByName("_Bip02 Spine1")
			self._nodeMiddle = Cast:ToMovable(obj)

			if self._nodeMiddle then
				local btc = self._nodeMiddle:GetControllerByName("BTC")
				if btc then
					self._nodeMiddleBTC = Cast:ToBlendTransformController(btc)
				end
			end
		end
	end

	if self._skillChara then
		local scid = self._skillChara:GetID()
		if scid==10002 or scid==10004 then
			-- 解放军
			self._maxspeed = 1.6
		else
			-- 印度
			self._maxspeed = 2.0
		end
	end
end
-------------------------------------------------------------------------------
function p_human:_Cleanup()
	print(self._name.." p_human:_Cleanup")

    p_chara._Cleanup(self)
end
-------------------------------------------------------------------------------
function p_human:OnPPlay()
	print(self._name.." p_human:OnPPlay")

    p_chara.OnPPlay(self)
end
-------------------------------------------------------------------------------
function p_human:OnPUpdate()
	p_holospace._g_holospace._g_cameraPlayCtrl:Update(0.0, 0.0)

    local t = PX2_APP:GetElapsedSecondsWidthSpeed()
    p_chara.OnPUpdate(self)

	local scene = PX2_PROJ:GetScene()
	local camNodeRoot = scene:GetMainCameraNodeRoot()
	local r = camNodeRoot.WorldTransform:GetRight()
	local d = camNodeRoot.WorldTransform:GetDirection()
	local dd = AVector(d:X(), d:Y(), d:Z())
	local u = camNodeRoot.WorldTransform:GetUp()

	local isHumainTakeBody = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_BODY)
	local isHumainTakeNone = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_NONE)
	local tm = self._agent:GetHumanTakePossessed()
	local isHumainTakeBodyExactly = tm==AIAgent.HTPM_BODY

	if self._isOnFirstView then
		if isHumainTakeBodyExactly then
			if self._isUpdateRotateFormServer then
				p_holospace._g_cameraPlayCtrl:SetParentHorVerFromRotateDegreeAPoint(self._rotateDegreeAPointFromServer)
			end
			p_holospace._g_cameraPlayCtrl:SetDegreeHorRange(60.0)
		else
			p_holospace._g_cameraPlayCtrl:SetParentHor(0)
			p_holospace._g_cameraPlayCtrl:SetParentVer(0)
			p_holospace._g_cameraPlayCtrl:SetDegreeHorRange(-1.0)
		end

		if isHumainTakeBody then
			d:SetZ(0.0)
			d:Normalize()
			r:SetZ(0.0)
			r:Normalize()
			
			local dirFace = d
			self._agent:SetForward(dirFace)

			local v0 = Mathf:Sqrt(dd:X()*dd:X() + dd:Y()*dd:Y())
			local degreev = dd:Z()/v0
			local degree = Mathf:ATan(degreev) * RAD_TO_DEG
			self:_SetUpperDegree(degree)
		end
		if isHumainTakeNone then
			if self._isUpdateRotateFormServer then
				self._agent:SetRotateDegreeAPoint(self._rotateDegreeAPointFromServer)
				if self._nodeDownInfo then
                    self._nodeDownInfo.LocalTransform:SetRotateDegreeZ(self._rotateDegreeAPointFromServer:Z())
                end
            end

			local agDir = self._agent:GetDirection()
			local agRight0 = self._agent:GetRight()
			local agRight = AVector(agRight0:X(), agRight0:Y(), 0.0)
			agRight:Normalize()
			local agUp = self._agent:GetUp()

			local degree = self._updegee
			
			local matRot = HMatrix()
			matRot:MakeRotation(agRight, degree * DEG_TO_RAD)
			local trans = Transform()
			trans:SetRotate(matRot)
			
			local agDir1 = trans:Multip(agDir)
			
			self:_SetCameraNodeCtrlFirstView( p_holospace._g_cameraPlayCtrl, camNodeRoot, agDir1)
		end
	else
		if isHumainTakeNone then
			if self._isUpdateRotateFormServer then
				self._agent:SetRotateDegreeAPoint(self._rotateDegreeAPointFromServer)
				if self._nodeDownInfo then
                    self._nodeDownInfo.LocalTransform:SetRotateDegreeZ(self._rotateDegreeAPointFromServer:Z())
                end
            end
		end
	end
end
-------------------------------------------------------------------------------
function p_human:_OnPUpdateProcesRunning_TakeMove()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()
	local curPos = self._agent:GetPosition()

	if not g_manykit._isRobot then
		if g_manykit._isPressed_W and g_manykit._isPressed_A  then
			self:_MeGo(5)
		elseif g_manykit._isPressed_W and g_manykit._isPressed_D then
			self:_MeGo(6)
		elseif g_manykit._isPressed_S and g_manykit._isPressed_A then
			self:_MeGo(7)
		elseif g_manykit._isPressed_S and g_manykit._isPressed_D then
			self:_MeGo(8)
		elseif g_manykit._isPressed_W then
			self:_MeGo(1)
		elseif g_manykit._isPressed_S then 
			self:_MeGo(2)
		elseif g_manykit._isPressed_A then
			self:_MeGo(3)
		elseif g_manykit._isPressed_D then
			self:_MeGo(4)
		end
		if not g_manykit._isPressed_W and not g_manykit._isPressed_S and 
			not g_manykit._isPressed_A and not g_manykit._isPressed_D then
			self:_MeGo(0)
		end

		local topos = curPos
		if not g_manykit._isUsePhysics then
			topos = curPos + self._agent:GetVelocity()  * t
	
			local toh = self:_PickHeight(topos, false)
			local diff = toh - curPos:Z()
			if diff < 0.6 then
				-- not too high, auto go to
				self._agent:SetPosition(topos)
				self._hworld = toh
			end
		else
			self._hworld = self:_PickHeight(curPos, false)
		end
	
		self:_UpdateGravity()
	end
end
-------------------------------------------------------------------------------
function p_human:_OnPUpdateProcesRunning_NotTakeMove()
	local t = PX2_APP:GetElapsedSecondsWidthSpeed()
	local curPos = self._agent:GetPosition()

	if g_manykit._isUsePhysics then

	else
		local topos = curPos + self._agent:GetVelocity()  * t
		local toh = self:_PickHeight(topos, false)
		topos:SetZ(toh)
		self._hworld = toh
		self._agent:SetPosition(topos)
		self._isOnGround = true
	end
end
-------------------------------------------------------------------------------
function p_human:_OnCreateSceneInstance()
	print(self._name.." p_human:_OnCreateSceneInstance")

	p_chara._OnCreateSceneInstance(self)
end
-------------------------------------------------------------------------------
-- property
-------------------------------------------------------------------------------
function p_human:_GetPropertiesValue()
	print(self._name.." p_human:_GetPropertiesValue")

    p_chara._GetPropertiesValue(self)

	self._isuseupper = self._node:PBool("IsUseUpper", false)
	self._updegee = self._node:PFloat("UpDegree")
end
-------------------------------------------------------------------------------
function p_human:_RegistProperties()
	print(self._name.." p_human:_RegistProperties")

	p_chara._RegistProperties(self)

	self._node:AddPropertyClass("Human", "Human")
	
	self._node:AddPropertyBool("IsUseUpper", "使用俯仰", self._isuseupper, true, true)
	self._node:AddPropertyFloatSlider("UpDegree", "俯仰", self._updegee, -60, 60, true, true)
end
-------------------------------------------------------------------------------
function p_human:_OnPropertyAct()
    print(self._name.." p_human:_OnPropertyAct")

    p_chara._OnPropertyAct(self)

	print("updegree:"..self._updegee)

	if self._isuseupper then
		self:_SetUpperDegree(self._updegee)
	end
end
-------------------------------------------------------------------------------
function p_human:_OnPropertyButton(prop)
	print(self._name.." p_human:_OnPropertyButton:"..prop.Name)

    p_chara._OnPropertyButton(self, prop)
end
-------------------------------------------------------------------------------
function p_human:_OnSelected(tag)
	print(self._name.." p_human:_OnSelected:"..tag)

    p_chara._OnSelected(self, tag)
end
-------------------------------------------------------------------------------
function p_human:_OnDisSelected(tag)
	print(self._name.." p_human:_OnDisSelected:"..tag)

    p_chara._OnDisSelected(self, tag)
end
-------------------------------------------------------------------------------
-- simu
function p_human:_Simu(simu)
	print(self._name.." p_human:_Simu")
	print_i_b(simu)

    p_chara._Simu(self, simu)
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_human)
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_human/p_humanaction.lua")
-------------------------------------------------------------------------------