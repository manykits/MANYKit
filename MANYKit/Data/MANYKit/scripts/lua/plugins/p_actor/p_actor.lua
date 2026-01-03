-- p_actor.lua
-------------------------------------------------------------------------------
p_actor = class(p_ctrl,
{
	_requires = {"p_holospace", "p_net", },
	_class = "p_actor",

	_g_idModelPick = 111111,

	_name = "p_actor",
	_actor = nil,
	_agentBase = nil,
	_agent = nil,
	_skillChara = nil,
	_isMe = false,
	_title = "",
	_group = 0,
	_downheighttime = 0.1,
	_downheighttiming = 0.0,

	-- property
	_uin = 0,
	_id = -1,
	_typeid = -1,
	_bornDist = 200.0,
	_modelPercent = 0.0,
	_renderStyle = 0,

	_bd = nil,
	_bdbar = nil,
	_fTextName = nil,

	_nodeRange = nil,
	_nodeDownInfo = nil,

	_isSimuing = false,

	_isActivate = true,
	
	-- run
	_hworld = 0.0,
})
-------------------------------------------------------------------------------
function p_actor:OnAttached()
	PX2_LM_APP:AddItem(self._name, "Actor", "角色")
	
	print(self._name.." p_actor:OnAttached")

	p_ctrl.OnAttached(self)
	
	print("self._typeid:"..self._typeid)

	self._actor = Cast:ToActor(self._node)
	if self._actor then
		self._agentBase = self._actor:GetAIAgentBase()
		self._agent = self._actor:GetAIAgent()
		self._skillChara = self._actor:GetSkillChara()
	end
end
-------------------------------------------------------------------------------
function p_actor:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_actor:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_actor:OnPPlay()
	print(self._name.." p_actor:OnPPlay")
end
-------------------------------------------------------------------------------
function p_actor:OnFixUpdate()
	local scene = PX2_PROJ:GetScene()
	if scene and self._agentBase then
		local isshow = true
		if self._actor then
			local useDist = p_holospace._g_viewdist_objects
			if self._bornDist>1.0 then
				useDist = self._bornDist
			end

			local mainCameraNodeRoot = scene:GetMainCameraNodeRoot()
			local accpos = mainCameraNodeRoot.LocalTransform:GetTranslate()

			local curPos = self._agentBase:GetPosition()

			local diff = curPos - accpos
			local diffLength = diff:Normalize()
			
			if useDist>1.0 then
				if diffLength <= useDist then
					isshow = true
				else
					isshow = false
				end
			else
				isshow = true
			end

			if p_net._g_net._islogicserver then
				if not g_manykit._isUseViewDistance then
					isshow = true
				end
			end
			
			if p_holospace._g_viewdist_objects_lod>1.0 then
				if ""~=self._actor:GetFilenameCrossBoard() then				
					if diffLength > p_holospace._g_viewdist_objects_lod then
						self._actor:SetLodType(Actor.LDT_CROSSBOARD)
					else
						self._actor:SetLodType(Actor.LDT_MODEL)
					end
				end
			else
				self._actor:SetLodType(Actor.LDT_MODEL)
			end
		end

		if self._isSimuing then
			if self._actor then
				if self._isActivate then
				else
					isshow = false
				end	
			end
		end

		if self._actor then
			--self._actor:Show(isshow)
		end
	end
end
-------------------------------------------------------------------------------
function p_actor:OnPUpdate()
	self:_OnPUpdate()
end
-------------------------------------------------------------------------------
function p_actor:_OnPUpdate()
end
-------------------------------------------------------------------------------
function p_actor:_OnCreateSceneInstance()
	print(self._name.." p_actor:_OnCreateSceneInstance")

	self:_CreateSelectBox()

	local id = self._actor:GetID()
	local agent = self._actor:GetAIAgent()
	local nodeRoot = self._actor:GetNodeRoot()
	local skillChara = self._actor:GetSkillChara()
	local defModel = skillChara:GetDefModel()
	local defChara = skillChara:GetDefChara()

	local th = 1.0
	if defModel then
	    th = defModel.HeightTitle
	end
	local title = defChara.Name
	
	local bd = BillboardNode:New("BDActorName")
	self._bd = bd
	nodeRoot:AttachChild(bd)
	bd.LocalTransform:SetTranslateZ(th)
	local scene = PX2_PROJ:GetScene()
	local cameraNodeRoot = scene:GetMainCameraNodeRoot()
    bd:AlignTo(cameraNodeRoot)
	bd:SetAlignType(BillboardNode.BAT_Z)
	bd:SetDoPick(false)

	local fTextName = UIFText:New("ActorName")
	self._fTextName = fTextName
	bd:AttachChild(fTextName)
	fTextName:GetText():SetText("") 
	fTextName:SetSize(400.0, 80.0)
	fTextName:SetPivot(0.5, 0.0)
	fTextName.LocalTransform:SetUniformScale(0.005)
	fTextName:GetText():SetRenderLayer(Renderable.RL_UI)
	fTextName:GetText():SetFontSize(24)
	fTextName:GetText():SetFontColor(Float3.WHITE)
	fTextName:GetText():SetFontScale(0.9)
	fTextName:SetColorSelfCtrled(true)
	self:_RefreshTitle()

	if agent then
		-- bar
		local bar = UIProgressBar:New("HPBar")
		self._bdbar = bar
		bd:AttachChild(bar)
		bar:SetID(100)
		bar.LocalTransform:SetUniformScale(0.005)
		bar.LocalTransform:SetTranslateZ(-0.01)			
		bar:GetBackPicBox():GetUIPicBox():SetTexture("engine/white.png")
		bar:GetBackPicBox():GetUIPicBox():SetColor(Float3(0.0, 0.0, 0.0))
		bar:GetBackPicBox():GetUIPicBox():SetAlpha(0.1)	
		bar:GetProgressPicBox():GetUIPicBox():SetTexture("engine/white.png")
		bar:GetProgressPicBox():GetUIPicBox():SetColor(Float3(1.0, 0.0, 0.0))
		bar:GetProgressPicBox():GetUIPicBox():SetAlpha(0.6)
		bar:SetColorSelfCtrled(true)
		bar:SetColor(Float3.WHITE)
		bar:SetSize(130.0, 10.0)
		bar:SetProgress(1.0)
		self._actor:GetSkillChara():SetBloodProgressBar(bar)

		-- noderange
		local nodeRange = Node:New("NodeRange")
		self._nodeRange = nodeRange
        nodeRoot:AttachChild(nodeRange)
        nodeRange.LocalTransform:SetTranslateZ(0.4)
		nodeRange.LocalTransform:SetUniformScale(0.001)
		nodeRange:SetDoPick(false)

        local bd30 = Billboard:New("BillboardRangeView30")
        nodeRange:AttachChild(bd30)
        bd30:SetFaceType(Effectable.FT_Z)
        bd30:SetFixedBound(false)
        bd30:SetEmitSizeX(2.0)
        bd30:SetEmitSizeY(2.0)
        bd30:SetEmitColor(Float3.YELLOW)
        bd30:SetEmitAlpha(0.4)
        bd30:SetTex("common/images/scene/30.png")
        bd30:SetPivot(0.5, 0.5)
        bd30:ResetPlay()

        local bd45= Billboard:New("BillboardRangeView45")
        nodeRange:AttachChild(bd45)
        bd45:SetFaceType(Effectable.FT_Z)
        bd45:SetFixedBound(false)
        bd45:SetEmitSizeX(2.0)
        bd45:SetEmitSizeY(2.0)
        bd45:SetEmitColor(Float3.YELLOW)
        bd45:SetEmitAlpha(0.4)
        bd45:SetTex("common/images/scene/45.png")
        bd45:SetPivot(0.5, 0.5)
        bd45:ResetPlay()
            
        local bd60= Billboard:New("BillboardRangeView60")
        nodeRange:AttachChild(bd60)
        bd60:SetFaceType(Effectable.FT_Z)
        bd60:SetFixedBound(false)
        bd60:SetEmitSizeX(2.0)
        bd60:SetEmitSizeY(2.0)
        bd60:SetEmitColor(Float3.YELLOW)
        bd60:SetEmitAlpha(0.4)
        bd60:SetTex("common/images/scene/60.png")
        bd60:SetPivot(0.5, 0.5)
        bd60:ResetPlay()

        local bd90= Billboard:New("BillboardRangeView90")
        nodeRange:AttachChild(bd90)
        bd90:SetFaceType(Effectable.FT_Z)
        bd90:SetFixedBound(false)
        bd90:SetEmitSizeX(2.0)
        bd90:SetEmitSizeY(2.0)
        bd90:SetEmitColor(Float3.YELLOW)
        bd90:SetEmitAlpha(0.4)
        bd90:SetTex("common/images/scene/90.png")
        bd90:SetPivot(0.5, 0.5)
        bd90:ResetPlay()

        local bd360= Billboard:New("BillboardRangeView360")
        nodeRange:AttachChild(bd360)
        bd360:SetFaceType(Effectable.FT_Z)
        bd360:SetFixedBound(false)
        bd360:SetEmitSizeX(2.0)
        bd360:SetEmitSizeY(2.0)
        bd360:SetEmitColor(Float3.YELLOW)
        bd360:SetEmitAlpha(0.4)
        bd360:SetTex("common/images/scene/360.png")
        bd360:SetPivot(0.5, 0.5)
        bd360:ResetPlay()

        nodeRange:SetActiveChildByIndex(0)
        nodeRange:Show(false, false)
	end

	self:_CreateSkillsAndItems()
end
-------------------------------------------------------------------------------
function p_actor:_RefreshTitle()
	if self._skillChara then
		local defChara = self._skillChara:GetDefChara()
		local id = self._id
		local title = defChara.Name

		if self._fTextName then
			self._fTextName:GetText():SetText(self._title .. ":" .. id) 
		end
	end
end
-------------------------------------------------------------------------------
function p_actor:_CreateSelectBox()
	print(self._name.." p_actor:_CreateSelectBox")

	if self._actor then
	    local skillChara = self._actor:GetSkillChara()

	    local defModel = skillChara:GetDefModel()
	    local nodeRoot = self._actor:GetNodeRoot()
	    local nodeModel = self._actor:GetNodeModel()
	    nodeModel:SetDoPick(false)

	    -- select
	    local mp = PX2_CREATER:CreateMovable_Box("engine/white.png")
	    nodeRoot:AttachChild(mp)
	    mp:SetName("ModelModelPick")
	    mp:SetID(p_actor._g_idModelPick)
		if defModel then
	        mp.LocalTransform:SetScale(APoint(defModel.Length, defModel.Width, defModel.Height))
			mp.LocalTransform:SetTranslateZ(defModel.Height*0.5)
		else
			mp.LocalTransform:SetScale(APoint(10, 10, 10))
		end
		mp:Show(false, false)
	    mp:SetRenderStyle(Movable.RS_LIGHTING, true)
	    mp:SetCastShadow(false)
	    mp:SetDoPick(true)
	    mp:SetAlphaSelfCtrled(true)
	    mp:SetUserDataString("id", ""..self._id)
	    local r = Cast:ToRenderable(mp)
	    if r then
		    r:SetRenderLayer(Renderable.RL_SCENE, 1)
	    end
	    
		local pd = PropertySetData()
	    pd.DoSetBlend = true
	    pd.BlendType = 1
	    pd.DoSetAlpha = true
	    pd.Alpha = 0.4
	    pd.DoSetShine = true
	    pd.ShineEmissive = Float4(1.0, 1.0, 0.0, 0.4)
	    pd.ShineAmbient = Float4(0.0, 0.0, 1.0, 0.4)
	    PX2_GH:SetObjectMtlProperty(mp, pd)
	    mp:RegistToScriptSystem()
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_actor)
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_actoraction.lua")
require("scripts/lua/plugins/p_actor/p_actorgroup.lua")
require("scripts/lua/plugins/p_actor/p_actorpick.lua")
require("scripts/lua/plugins/p_actor/p_actorproperty.lua")
require("scripts/lua/plugins/p_actor/p_actorskill.lua")
require("scripts/lua/plugins/p_actor/p_actorrun.lua")
-------------------------------------------------------------------------------