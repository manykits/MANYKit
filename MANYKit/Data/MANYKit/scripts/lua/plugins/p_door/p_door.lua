-- p_door.lua
-------------------------------------------------------------------------------
require("scripts/lua/plugins/p_actor/p_actor.lua")
-------------------------------------------------------------------------------
p_door = class(p_actor,
{
    _requires = {"p_actor", "p_net", },

	_name = "p_door",

    _nodeCenter = nil,
    _nodeSideDoor = nil,

    _l = 8.0,
    _w = 1.0,
    _h = 2.0,
    _cw = 0.5,
    _ch = 1.5,
    
    _ls = 1.5,

    _speed =  0.1,
    _state = 0, --0 stop, 1 open, 2 close
    _percent = 0, -- open percent
    
    _distance = 0.0,
    _distanceSendTiming = 0.0,

    _speedSide =  30,
    _stateSide = 0, --0 stop, 1 open, 2 close
    _degreeSide = 0, -- open percent

    _nodeTrigger = nil,
    _trigger = nil,

    _nodeTriggerInterp = nil,
    _triggerInterp = nil,
    _nodeTriggerInterp1 = nil,
    _triggerInterp1 = nil,

    _udpSocket = nil,
    _ipServerStr = "",
    _portServer = 0,

    -- _triggerType = 0,
    -- _triggerRadius = 1.0,
})
-------------------------------------------------------------------------------
function p_door:OnAttached()

	p_actor.OnAttached(self)
	print(self._name.." p_door:OnAttached")

    PX2_LM_APP:AddItem(self._name, "Door", "门禁")

    local defChara = DefChara()
    defChara.ID = 13001
    defChara.Name = "智能门禁"
    defChara.ModelID = 23001
    defChara.AgentType = 3
    defChara.Script = "p_door"
    defChara.BaseHP = 100
    defChara.BaseAP = 100
    defChara.BaseDP = 100
    PX2_SDM:AddDefChara(defChara)

    local defM = DefModel()
    defM.ID = 23001
    defM.Name = "智能门禁"
    defM.Icon = "scripts/lua/plugins/p_door/images/door.png"
    defM.Model = ""
    defM.Tex = ""
    defM.Model = ""
    defM.Anim = ""
    defM.DefaultAnim = ""
    defM.ModelScale = 1.0
    defM.Length = 1.0
    defM.Width = 1.0
    defM.Height = 1.0
    defM.HeightTitle = 1.0
    PX2_SDM:AddDefModel(defM)

    local defItem = DefItem()
    defItem.ID = 43001
    defItem.Icon = "scripts/lua/plugins/p_door/images/door.png"
    defItem.Name = "智能门禁"
    defItem.Desc = "智能门禁系统"
    defItem.iType = 0
    defItem.TheType = DefItem.T_NORMAL
    defItem.Mtl = ""
    defItem.Anchor = ""
    defItem.SkillID = 0
    defItem.BufID = 0
    defItem.CharaID = 13001
    defItem.MonsterID = 0
    PX2_SDM:AddDefItem(defItem)
end
-------------------------------------------------------------------------------
function p_door:OnInitUpdate()
	p_actor.OnInitUpdate(self)

	print(self._name.." p_door:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_door:_Cleanup()
	print(self._name.." p_door:_Cleanup")
end
-------------------------------------------------------------------------------
function p_door:OnPPlay()
	print(self._name.." p_door:OnPPlay")
end
-------------------------------------------------------------------------------
function p_door:OnFixUpdate()
	local t = self._dt

end
-------------------------------------------------------------------------------
function p_door:OnPUpdate()
    local t = PX2_APP:GetElapsedSecondsWidthSpeed()

    if self._isSimuing then
        self:_OnTick(t)
    end
end
-------------------------------------------------------------------------------
function p_door:_OnTick(t)
    local scene = PX2_PROJ:GetScene()
    if scene then
        local mid = scene:GetID()

        local move = t * self._speed
        if 1 == self._state then
            -- open
            self._percent = self._percent + move
            if self._percent >= 1.0 then
                self:_Stop()
            end
        elseif 2 == self._state then
            -- close
            self._percent = self._percent - move
            if self._percent <= 0.0 then
                self:_Stop()
            end
        elseif 0 == self._state then
        end
        if self._nodeCenter then
            local l = (self._l - self._w) * (1.0 - self._percent)
            self._nodeCenter.LocalTransform:SetScale(APoint(l, 1.0, 1.0))
        end

        local dist = self._percent * (self._l - self._w)
        self._distance = dist
        self._distanceSendTiming = self._distanceSendTiming + t
        if self._distanceSendTiming>0.3 then
            self._distanceSendTiming = 0.0

            if self._udpSocket and self._ipServerStr and ""~=self._ipServerStr then
                local dt = {
                    t = "door_distance",
                    mid = mid,
                    id = self._id,
                    distance = self._distance,
                }
                local dtstr = PX2JSon.encode(dt)
                self._udpSocket:SendTo(dtstr, self._ipServerStr, self._portServer)
            end
        end

        local moveSide = t * self._speedSide
        if 1 == self._stateSide then
            -- open
            self._degreeSide = self._degreeSide + moveSide
            if self._degreeSide >= 90.0 then
                self:_StopSide()
            end
        elseif 2 == self._stateSide then
            -- close
            self._degreeSide = self._degreeSide - moveSide
            if self._degreeSide <= 0.0 then
                self:_StopSide()
            end
        elseif 0 == self._stateSide then
        end

        if self._nodeSideDoor then
            self._nodeSideDoor.LocalTransform:SetRotateDegreeZ(self._degreeSide)
        end

        local actorMain = scene:GetMainActor()
        if actorMain then
            local pos = actorMain.LocalTransform:GetTranslate()
            local pos1 = APoint(pos:X(), pos:Y(), pos:Z()+0.5)

            local ct = Float4(1.0, 1.0, 0.0, 1.0)
            if self._trigger:IsPointIn(pos1) then
                self._trigger:TryTrigger()
                ct = Float4(1.0, 0.0, 0.0, 1.0)
            else
                self._trigger:TryResetTrigger()
            end
            self._trigger:SetAreaColor(ct)

            local bw = Bound()
            bw:SetCenter(pos1)
            bw:SetRadius(0.3)

            local c = Float4(1.0, 1.0, 0.0, 1.0)
            if self._triggerInterp:IsBoundIntersection(bw) then
                c = Float4(1.0, 0.0, 0.0, 1.0)
                self._triggerInterp:TryTrigger()
            else
                self._triggerInterp:TryResetTrigger()
            end
            self._triggerInterp:SetAreaColor(c)

            local c1 = Float4(1.0, 1.0, 0.0, 1.0)
            if self._triggerInterp1:IsBoundIntersection(bw) then
                c1 = Float4(1.0, 0.0, 0.0, 1.0)
                self._triggerInterp1:TryTrigger()
            else
                self._triggerInterp1:TryResetTrigger()
            end
            self._triggerInterp1:SetAreaColor(c1)
        end
    end
end
-------------------------------------------------------------------------------
function p_door:_OnCreateSceneInstance()
	print(self._name.." p_door:_OnCreateSceneInstance")

	p_actor._OnCreateSceneInstance(self)

    local l = self._l
    local w = self._w
    local h = self._h
    local cw = self._cw
    local ch = self._ch

    local mp = self._node:GetObjectByID(p_actor._g_idModelPick)
    local mpl = l + w + self._ls + w
    mp.LocalTransform:SetScale(APoint(mpl, w, h))
    mp.LocalTransform:SetTranslate(APoint(mpl*0.5 - w *0.5, 0, h*0.5))

    local act = Cast:ToActor(self._node)
    local nr = act:GetNodeRoot()

    local nodeModel = Node:New("Node")
    act:SetModel(nodeModel)

    local boxLeft = PX2_CREATER:CreateMovable_Box("engine/white.png")
    nodeModel:AttachChild(boxLeft)
    boxLeft.LocalTransform:SetScale(APoint(w, w, h))
    boxLeft.LocalTransform:SetTranslateZ(h*0.5)

    local nodeRight = Node:New("NodeRight")
    nodeModel:AttachChild(nodeRight)
    nodeRight.LocalTransform:SetTranslate(APoint(l, 0.0, 0.0))
    local boxRight = PX2_CREATER:CreateMovable_Box("engine/white.png")
    nodeRight:AttachChild(boxRight)
    boxRight.LocalTransform:SetScale(APoint(w, w, h))
    boxRight.LocalTransform:SetTranslateZ(h*0.5)

    local nodeCenter = Node:New("NodeCenter")
    self._nodeCenter = nodeCenter
    nodeModel:AttachChild(nodeCenter)
    nodeCenter.LocalTransform:SetTranslate(APoint(0.5*w, 0.0, 0.0))
    local boxCenter = PX2_CREATER:CreateMovable_Box("engine/white.png")
    nodeCenter:AttachChild(boxCenter)
    boxCenter.LocalTransform:SetScale(APoint(1.0, cw, ch))
    boxCenter.LocalTransform:SetTranslate(APoint(0.5, 0.0, ch*0.5))

    local boxSide = PX2_CREATER:CreateMovable_Box("engine/white.png")
    nodeModel:AttachChild(boxSide)
    boxSide.LocalTransform:SetScale(APoint(w, w, h))
    boxSide.LocalTransform:SetTranslateZ(h*0.5)
    boxSide.LocalTransform:SetTranslateX(l + self._ls + w)

    local nodeSideDoor = Node:New("NodeSideDoor")
    self._nodeSideDoor = nodeSideDoor
    nodeModel:AttachChild(nodeSideDoor)
    nodeSideDoor.LocalTransform:SetTranslate(APoint(l + w*0.5, 0.0, 0.0))
    local boxSideDoor = PX2_CREATER:CreateMovable_Box("engine/white.png")
    nodeSideDoor:AttachChild(boxSideDoor)
    boxSideDoor.LocalTransform:SetScale(APoint(self._ls, 0.1, ch))
    boxSideDoor.LocalTransform:SetTranslate(APoint(self._ls*0.5, 0.0, ch*0.5))

    -- triger
    local nt = Node:New()
    self._nodeTrigger = nt
    nr:AttachChild(nt)
    nt.LocalTransform:SetTranslate(APoint(self._l + self._w*0.5 + self._ls*0.5, 0.0, self._h*0.5))

    local tri = PX2_CREATER:CreateTriggerController()
    self._trigger = tri
    nt:AttachController(tri)
    tri:SetName("TriggerSide")
    tri:SetAreaParam(Float4(self._ls*2, self._ls*1.5, self._ls*3.5, self._h))
    tri:ResetPlay()
    tri:AddScriptHandler("_OnTriggerCallback", self._scriptControl)
    tri:GetAreaNode():Show(false)

    -- interp triger
    local ntInterp = Node:New()
    self._nodeTriggerInterp = ntInterp
    nr:AttachChild(ntInterp)
    ntInterp.LocalTransform:SetTranslate(APoint(self._l*0.5, self._w*0.4, 0.4))
    local triInterp = PX2_CREATER:CreateTriggerController()
    self._triggerInterp = triInterp
    ntInterp:AttachController(triInterp)
    triInterp:SetName("TriggerInterp")
    local tl = self._l - self._w
    triInterp:SetAreaParam(Float4(1.0, tl, 0.05, 0.05))
    triInterp:ResetPlay()
    triInterp:AddScriptHandler("_OnTriggerCallback", self._scriptControl)
    triInterp:GetAreaNode():Show(false)
    triInterp:SetAreaType(TriggerController.AT_BOX)

    local ntInterp1 = Node:New()
    self._nodeTriggerInterp1 = ntInterp1
    nr:AttachChild(ntInterp1)
    ntInterp1.LocalTransform:SetTranslate(APoint(self._l*0.5, -self._w*0.4, 0.4))
    local triInterp1 = PX2_CREATER:CreateTriggerController()
    self._triggerInterp1 = triInterp1
    ntInterp1:AttachController(triInterp1)
    triInterp1:SetName("TriggerInterp1")
    triInterp1:SetAreaParam(Float4(1.0, tl, 0.05, 0.05))
    triInterp1:ResetPlay()
    triInterp1:AddScriptHandler("_OnTriggerCallback", self._scriptControl)
    triInterp1:GetAreaNode():Show(false)
    triInterp1:SetAreaType(TriggerController.AT_BOX)

    -- udp
    self._udpSocket = DatagramSocket()

    RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
        if "doormgr"==str then
            myself:_DoorMgr(str1)
        end
    end)
end
-------------------------------------------------------------------------------
-- property
function p_door:_GetPropertiesValue()
	print(self._name.." p_door:_GetPropertiesValue")

    p_actor._GetPropertiesValue(self)

    self._ipServerStr = self._node:PString("IPServer")
    self._portServer = self._node:PInt("PortServer")
end
-------------------------------------------------------------------------------
function p_door:_RegistProperties()
	print(self._name.." p_door:_RegistProperties")

    p_actor._RegistProperties(self)    

    self._node:AddPropertyClass("DoorMgrNet", "网络")
    self._node:AddPropertyString("IPServer", "minnaip", self._ipServerStr, true, true)
    self._node:AddPropertyInt("PortServer", "mthing本地UDPPort", self._portServer, true, true)

    self._node:AddPropertyClass("DoorBig", "大门")
    self._node:AddPropertyButton("Open", "开")
    self._node:AddPropertyButton("Close", "关")
    self._node:AddPropertyButton("Stop", "停")
    self._node:AddPropertyClass("DoorSide", "小门")
    self._node:AddPropertyButton("OpenSide", "开")
    self._node:AddPropertyButton("CloseSide", "关")
    self._node:AddPropertyButton("StopSide", "停")

    self._node:AddPropertyClass("Trigger", "触发器")

    local tt = self._trigger:GetAreaType()
    local tr = self._trigger:GetAreaRadius()
    local tExt = self._trigger:GetAreaExtent()

    PX2Table2Vector({ "球形", "方形"})
    local vec = PX2_GH:Vec()
    self._node:AddPropertyEnum("TriggerType", "类型", tt, vec, true, true)
	self._node:AddPropertyFloatSlider("TriggerRadius", "范围Radius", tr, 0, 10, true, true)
    self._node:AddPropertyFloat3("TriggerExt", "范围Ext", tExt, true, true)
end
-------------------------------------------------------------------------------
function p_door:_OnPropertyAct()
    print(self._name.." p_door:_OnPropertyAct")

    p_actor._OnPropertyAct(self)

    local tt = self._node:PInt("TriggerType")
    print("tt:"..tt)
    self._trigger:SetAreaType(tt)

    local tr = self._node:PFloat("TriggerRadius")
    print("tr:"..tr)
    self._trigger:SetAreaRadius(tr)

    local tExt = self._node:PFloat3("TriggerExt")
    --print("tExt:"..tExt:ToString())
    self._trigger:SetAreaExtent(tExt)
end
-------------------------------------------------------------------------------
function p_door:_OnPropertyButton(prop)
	print(self._name.." p_door:_OnPropertyButton:"..prop.Name)

    local l = self._l
    local w = self._w
    local h = self._h
    local cw = self._cw
    local ch = self._ch

    if "Open"==prop.Name then
        self:_Open()
    elseif "Close"==prop.Name then
        self:_Close()
    elseif "Stop"==prop.Name then
        self:_Stop()
    elseif "OpenSide"==prop.Name then
        self:_OpenSide()
    elseif "CloseSide"==prop.Name then
        self:_CloseSide()
    elseif "StopSide"==prop.Name then
        self:_StopSide()
    end
end
-------------------------------------------------------------------------------
-- functions
function p_door:_DoorMgr(str)
    print(self._name.." p_door:_DoorMgr")
    print(str)

    local js = PX2JSon.decode(str)
    local id = js.id
    local action = js.act
    local id_virtual = js.id_virtual

    print("id_virtual:"..id_virtual)
    print("self._id:"..self._id)
    print("action:"..action)

    local idi_virtual = StringHelp:StringToInt(id_virtual)

    if idi_virtual==self._id then
        if "dooropen"==action then
            self:_Open()
        elseif "doorclose"==action then
            self:_Close()
        elseif "doorstop"==action then
            self:_Stop()
        elseif "doorsideopen"==action then
            self:_OpenSide()
        end
    end
end
-------------------------------------------------------------------------------
function p_door:_Open()
	print(self._name.." p_door:_Open")

    if self._state == 0 then
        self._state = 1
    end
end
-------------------------------------------------------------------------------
function p_door:_Close()
	print(self._name.." p_door:_Close")

    if self._state == 0 then
        self._state = 2
    end
end
-------------------------------------------------------------------------------
function p_door:_Stop()
	print(self._name.." p_door:_Stop")

    self._state = 0
end
-------------------------------------------------------------------------------
function p_door:_OpenSide()
	print(self._name.." p_door:_OpenSide")

    self._stateSide = 1
end
-------------------------------------------------------------------------------
function p_door:_CloseSide()
	print(self._name.." p_door:_CloseSide")

    self._stateSide = 2
end
-------------------------------------------------------------------------------
function p_door:_StopSide()
	print(self._name.." p_door:_StopSide")

    self._stateSide = 0
end
-------------------------------------------------------------------------------
function p_door:_TriggerDoInterp(isinterp, idx)
	print(self._name.." p_door:_TriggerDoInterp:"..idx)

    local scene = PX2_PROJ:GetScene()
    if scene then
        local mid = scene:GetID()
        local ip = 0
        if isinterp then
            ip = 1
        else
            ip = 0
        end
        if self._udpSocket and self._ipServerStr and ""~=self._ipServerStr then
            local dt = {
                t = "door_interp",
                mid = mid,
                id = self._id,
                interp = ip,
                index = idx,
            }
            local dtstr = PX2JSon.encode(dt)
            self._udpSocket:SendTo(dtstr, self._ipServerStr, self._portServer)
        end
    end
end
-------------------------------------------------------------------------------
-- trigger
function p_door:_OnTriggerCallback(ptr, tag, name)
	print(self._name.." p_door:_OnTriggerCallback:"..tag.." Name:"..name)

    if "Trigger"==tag then
        if "TriggerSide"== name then
            self:_OpenSide()
        elseif "TriggerInterp"==name then
            self:_TriggerDoInterp(true, 0)
        elseif "TriggerInterp1"==name then
            self:_TriggerDoInterp(true, 1)
        end
    elseif "ResetTrigger"==tag then
        if "TriggerSide"== name then
            self:_CloseSide()
        elseif "TriggerInterp"==name then
            self:_TriggerDoInterp(false, 0)
        elseif "TriggerInterp1"==name then
            self:_TriggerDoInterp(false, 1)
        end
    end
end
-------------------------------------------------------------------------------
function p_door:_OnSelected(tag)
	print(self._name.." p_door:_OnSelected:"..tag)

    if self._trigger then
        self._trigger:GetAreaNode():Show(true)
    end

    if self._triggerInterp then
        self._triggerInterp:GetAreaNode():Show(true)
    end
    if self._triggerInterp1 then
        self._triggerInterp1:GetAreaNode():Show(true)
    end

    p_actor._OnSelected(self, tag)
end
-------------------------------------------------------------------------------
function p_door:_OnDisSelected(tag)
	print(self._name.." p_door:_OnDisSelected:"..tag)

    if self._trigger then
        self._trigger:GetAreaNode():Show(false)
    end

    if self._triggerInterp then
        self._triggerInterp:GetAreaNode():Show(false)
    end
    if self._triggerInterp1 then
        self._triggerInterp1:GetAreaNode():Show(false)
    end

    p_actor._OnDisSelected(self, tag)
end
-------------------------------------------------------------------------------
-- simu
function p_door:_Simu(simu)
	print(self._name.." p_door:_Simu")
	print_i_b(simu)

    p_actor._Simu(self, simu)
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_door)
-------------------------------------------------------------------------------