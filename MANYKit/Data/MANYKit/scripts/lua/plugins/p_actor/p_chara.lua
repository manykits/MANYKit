-- p_chara.lua

require("scripts/lua/plugins/p_actor/p_actor.lua")
-------------------------------------------------------------------------------
p_chara = class(p_actor,
{
	_requires = {"p_actor", },
	_class = "p_chara",

	_name = "p_chara",

	_fromItemTypeID = 0,

	-- property
	_enablegp = true,
	_group = 0,
	_hpIdx = 0,
	_tempture = 0.0,
	_seeDist = 100.0,
	_seeDegreeIndex = 0.0,

	_animblendmode = 0,

	_anim = 0,
	_animnodenames = "",

	_anim1 = 0,
	_animnodenames1 = "",

	_aiAction = 0,
	_aiPath = "",

	--
	_ischarging = false,
	_isControllingByOther = false,
	
	-- anim
	_animrun = "runaim",
	_animstand = "standaim",

	_lastHP = 0,
	_speedrun = 2.0,
	_maxspeed = 3.5,
	_isOnGround = false,
	_g = -9.8,
	_speedZ = 0.0,
	_isAutoHideHeadBar = true,

	-- simu
	_sendStateTiming = 0.0,
	_isOnFirstView = false,
	_firstViewDist = 0.6,
	_isViewFix = false,
    _isAiming = false,

	_posture = 1,
	_isSetRun = false,
	_lastAnimName = "",

	_gotopos = APoint(0,0,0),
	_lastProto = "",

	_camera0 = nil,

	_rotateDegreeAPointFromServer = APoint(0,0,0),
	_isUpdateRotateFormServer = true,

	_lastTimeProto = nil,
	_lastTimeGoTo = nil,

	_lastTimeMySelf = nil,
	_lastTimeMySelfCalSpeed = nil,
	
	_lastSubobjectStr = "",
	_lastState = "",

	_isShow = true,
})
-------------------------------------------------------------------------------
function p_chara:OnAttached()
	print(self._name.." p_chara:OnAttached")

	PX2_LM_APP:AddItem(self._name, "Chrara", "个性角色")

	p_actor.OnAttached(self)

	if self._agent then
		self._agent:GetAISteeringBehavior():AddScriptHandler(
			"_CharaOnAISteeringBehavior", self._scriptControl)
	end

	if self._actor then
		local movModel = self._actor:GetModel()
		if movModel then
			local objEye = movModel:GetObjectByName("camera0")
			self._camera0 = Cast:ToMovable(objEye)
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:OnInitUpdate()
	p_actor.OnInitUpdate(self)

	print(self._name.." p_chara:OnInitUpdate")

	if self._agent then
		self._agent:GetAISteeringBehavior():SetWaypointSeekDist(0.2)
		self._agent:GetAISteeringBehavior():SetWaypointSeekDistLast(0.18)
		self._agent:SetRadius(0.3)
		self._agent:SetHeight(2.0)
		self._agent:SetPhysicsRadius(0.6)
		self._agent:SetMass(50.0)
		self._agent:SetMaxForce(200000.0)
		self._agent:SetMaxSpeed(self._maxspeed)
		self._agent:UsePhysics(g_manykit._isUsePhysics)
		self._agent:GetSensoryMemory():SetMemorySpan(5.0)
		self._agent:EnableTargetSystem(true)
		self._agent:EnableSteeringBehavior(true)
	end
end
-------------------------------------------------------------------------------
function p_chara:OnPUpdate()
	--print(self._name.." p_chara:OnPUpdate")

	p_actor.OnPUpdate(self)
end
-------------------------------------------------------------------------------
function p_chara:OnPPlay()
	print(self._name.." p_chara:OnPPlay")
end
-------------------------------------------------------------------------------
function p_chara:_Cleanup()
	print(self._name.." p_chara:_Cleanup")

	UnRegistEventObjectFunction("InputEventSpace::MousePressed", self, nil)
	UnRegistEventObjectFunction("GraphicsES::GeneralString", self, nil)
end
-------------------------------------------------------------------------------
function p_chara:_CheckGetProto()
	self._timingCalSpeedReset = true
end
-------------------------------------------------------------------------------
function p_chara:_SetUpdateRotateFromDegree(doupdate)
	self._isUpdateRotateFormServer = doupdate
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_chara)
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_charaskill.lua")
require("scripts/lua/plugins/p_actor/p_charaaction.lua")
require("scripts/lua/plugins/p_actor/p_chararun.lua")
require("scripts/lua/plugins/p_actor/p_charaproperty.lua")
-------------------------------------------------------------------------------